import Option "mo:base/Option";
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Nat64 "mo:base/Nat64";
import Int "mo:base/Int";
import Blob "mo:base/Blob";
import Debug "mo:base/Debug";

import ExperimentalCycles "mo:base/ExperimentalCycles";

import ICRC1 "mo:icrc1/ICRC1";
import T "types";
import Account "Account";
import Hex "hex";

shared ({ caller = _owner }) actor class Token(
    token_args : ICRC1.TokenInitArgs,
    _borrower : Principal,
    _currency : Principal,
) : async ICRC1.FullInterface = this {

    stable let token = ICRC1.init({
        token_args with minting_account = Option.get(
            token_args.minting_account,
            {
                owner = _owner;
                subaccount = null;
            },
        );
    });

    stable var borrower : Principal = _borrower;
    stable var currency : T.Token = _currency;

    /// Functions for the ICRC1 token standard
    public shared query func icrc1_name() : async Text {
        ICRC1.name(token);
    };

    public shared query func icrc1_symbol() : async Text {
        ICRC1.symbol(token);
    };

    public shared query func icrc1_decimals() : async Nat8 {
        ICRC1.decimals(token);
    };

    public shared query func icrc1_fee() : async ICRC1.Balance {
        ICRC1.fee(token);
    };

    public shared query func icrc1_metadata() : async [ICRC1.MetaDatum] {
        ICRC1.metadata(token);
    };

    public shared query func icrc1_total_supply() : async ICRC1.Balance {
        ICRC1.total_supply(token);
    };

    public shared query func icrc1_minting_account() : async ?ICRC1.Account {
        ?ICRC1.minting_account(token);
    };

    public shared query func icrc1_balance_of(args : ICRC1.Account) : async ICRC1.Balance {
        ICRC1.balance_of(token, args);
    };

    public shared query func icrc1_supported_standards() : async [ICRC1.SupportedStandard] {
        ICRC1.supported_standards(token);
    };

    public shared ({ caller }) func icrc1_transfer(args : ICRC1.TransferArgs) : async ICRC1.TransferResult {
        await* ICRC1.transfer(token, args, caller);
    };

    public shared ({ caller }) func mint(args : ICRC1.Mint) : async ICRC1.TransferResult {
        await* ICRC1.mint(token, args, caller);
    };

    public shared ({ caller }) func burn(args : ICRC1.BurnArgs) : async ICRC1.TransferResult {
        await* ICRC1.burn(token, args, caller);
    };

    // Functions from the rosetta icrc1 ledger
    public shared query func get_transactions(req : ICRC1.GetTransactionsRequest) : async ICRC1.GetTransactionsResponse {
        ICRC1.get_transactions(token, req);
    };

    // Additional functions not included in the ICRC1 standard
    public shared func get_transaction(i : ICRC1.TxIndex) : async ?ICRC1.Transaction {
        await* ICRC1.get_transaction(token, i);
    };

    // Deposit cycles into this archive canister.
    public shared func deposit_cycles() : async () {
        let amount = ExperimentalCycles.available();
        let accepted = ExperimentalCycles.accept(amount);
        assert (accepted == amount);
    };

    public shared (_msg) func get_borrower() : async Principal {
        borrower;
    };

    public shared (_msg) func get_currency() : async Principal {
        currency;
    };

    // ===== DEPOSIT FUNCTIONS =====

    public shared (msg) func get_deposit_address() : async Text {
        let account = Account.accountIdentifier(Principal.fromActor(this), Account.principalToSubaccount(msg.caller));
        Hex.encode(Blob.toArray(account));
    };

    public shared (msg) func deposit(amount : Nat) : async T.DepositReceipt {
        await deposit_dip(msg.caller, amount);
    };

    // After user approves tokens to the DEX
    private func deposit_dip(caller : Principal, amount : Nat) : async T.DepositReceipt {
        // cast token to actor
        let dip20 = actor (Principal.toText(currency)) : T.DIPInterface;
        let dip_fee = await fetch_dip_fee(currency);
        let total = amount - dip_fee;

        // Check DIP20 allowance
        let balance : Nat = (await dip20.allowance(caller, Principal.fromActor(this)));

        // Transfer to account.
        let token_receipt = if (balance >= amount) {
            await dip20.transferFrom(caller, Principal.fromActor(this), amount);
        } else {
            return #Err(#BalanceLow);
        };

        Debug.print(debug_show (token_receipt));
        switch token_receipt {
            case (#Err e) {
                return #Err(#TransferFailure);
            };
            case _ {};
        };

        let trx_receipt = await* ICRC1.transfer(
            token,
            {
                amount = total;
                created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
                fee = null;
                from_subaccount = null;
                memo = null;
                to = { owner = caller; subaccount = null };
            },
            token.minting_account.owner,
        );

        Debug.print(debug_show (trx_receipt));
        switch trx_receipt {
            case (#Err _) {
                return #Err(#TransferFailure);
            };
            case _ {};
        };

        #Ok(total);
    };

    public shared (msg) func drawdown(amount : Nat) : async T.DrawdownReceipt {
        if (msg.caller != borrower) {
            return return #Err(#NotAuthorized);
        };

        // cast token to actor
        let dip20 = actor (Principal.toText(currency)) : T.DIPInterface;
        let dip_fee = await fetch_dip_fee(currency);
        let total = amount - dip_fee;

        let receipt = await dip20.transfer(borrower, amount);

        Debug.print(debug_show (receipt));
        switch receipt {
            case (#Err _) {
                return #Err(#TransferFailure);
            };
            case _ {};
        };

        #Ok(total);
    };

    public shared (msg) func repay_principal(amount : Nat) : async T.RepayPrincipalReceipt {
        // cast token to actor
        let dip20 = actor (Principal.toText(currency)) : T.DIPInterface;
        let dip_fee = await fetch_dip_fee(currency);
        let total = amount - dip_fee;

        // Check DIP20 allowance
        let balance : Nat = (await dip20.allowance(msg.caller, Principal.fromActor(this)));

        // Transfer to account.
        let token_receipt = if (balance >= amount) {
            await dip20.transferFrom(msg.caller, Principal.fromActor(this), amount);
        } else {
            return #Err(#BalanceLow);
        };
        Debug.print(debug_show (token_receipt));
        switch token_receipt {
            case (#Err e) {
                return #Err(#TransferFailure);
            };
            case _ {};
        };

        #Ok(total);
    };

    public shared (msg) func repay_interest(amount : Nat) : async T.RepayInterestReceipt {
        // cast token to actor
        let dip20 = actor (Principal.toText(currency)) : T.DIPInterface;
        let dip_fee = await fetch_dip_fee(currency);
        let total = amount - dip_fee;

        // Check DIP20 allowance
        let balance : Nat = (await dip20.allowance(msg.caller, Principal.fromActor(this)));

        // Transfer to account.
        let token_receipt = if (balance >= amount) {
            await dip20.transferFrom(msg.caller, Principal.fromActor(this), amount);
        } else {
            return #Err(#BalanceLow);
        };
        Debug.print(debug_show (token_receipt));
        switch token_receipt {
            case (#Err e) {
                return #Err(#TransferFailure);
            };
            case _ {};
        };

        #Ok(total);
    };

    public shared (msg) func withdraw(amount : Nat) : async T.WithdrawReceipt {
        let balance = ICRC1.balance_of(
            token,
            {
                owner = msg.caller;
                subaccount = ?Account.defaultSubaccount();
            },
        );
        Debug.print(debug_show (balance));

        if (balance < amount) {
            return return #Err(#BalanceLow);
        };

        let trx_receipt = await* ICRC1.burn(
            token,
            {
                amount = amount;
                created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
                from_subaccount = ?Account.defaultSubaccount();
                memo = null;
            },
            msg.caller,
        );

        Debug.print(debug_show (trx_receipt));
        switch trx_receipt {
            case (#Err _) {
                return #Err(#TransferFailure);
            };
            case _ {};
        };

        // cast token to actor
        let dip20 = actor (Principal.toText(currency)) : T.DIPInterface;
        let dip_fee = await fetch_dip_fee(currency);
        let total = amount - dip_fee;

        let receipt = await dip20.transfer(msg.caller, amount);

        Debug.print(debug_show (receipt));
        switch receipt {
            case (#Err _) {
                return #Err(#TransferFailure);
            };
            case _ {};
        };

        #Ok(total);
    };

    private func fetch_dip_fee(token : T.Token) : async Nat {
        let dip20 = actor (Principal.toText(token)) : T.DIPInterface;
        let metadata = await dip20.getMetadata();
        metadata.fee;
    };

    public shared (msg) func set_borrower(_borrower : Principal) {
        assert (msg.caller == token.minting_account.owner);
        borrower := _borrower;
    };

    public shared (msg) func set_currency(_currency : Principal) {
        assert (msg.caller == token.minting_account.owner);
        currency := _currency;
    };
};
