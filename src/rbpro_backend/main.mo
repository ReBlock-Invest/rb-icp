import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Nat64 "mo:base/Nat64";
import Int "mo:base/Int";
import Blob "mo:base/Blob";
import Debug "mo:base/Debug";

import ExperimentalCycles "mo:base/ExperimentalCycles";

import ICRC1 "mo:icrc1/ICRC1";
import Array "mo:base/Array";
import T "types";
import Account "Account";
import Ledger "Ledger";
import Hex "hex";

shared ({ caller = _owner }) actor class Token(
    token_args : ICRC1.TokenInitArgs
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

    let icp_fee : Nat = 10_000;

    private let ledger : Ledger.Interface = actor (Ledger.CANISTER_ID);

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

    public shared (msg) func getDepositAddress() : async Text {
        let account = Account.accountIdentifier(Principal.fromActor(this), Account.principalToSubaccount(msg.caller));

        Hex.encode(Blob.toArray(account));
    };

    public shared (msg) func deposit(balance : Nat) : async T.DepositReceipt {

        let source_account = Account.accountIdentifier(Principal.fromActor(this), Account.principalToSubaccount(msg.caller));
        Debug.print(debug_show (source_account));
        Debug.print(debug_show (msg.caller));

        let source_balance = await ledger.account_balance({
            account = source_account;
        });
        Debug.print(debug_show (source_balance));
        // Transfer to default subaccount
        let icp_receipt = await ledger.transfer({
            memo : Nat64 = 0;
            from_subaccount = ?Account.principalToSubaccount(msg.caller);
            to = Account.accountIdentifier(Principal.fromText("pgnkx-ni6qy-vo72n-ubskw-pt4pi-7ftdk-np5wv-zsbnn-fey4m-7tnmq-2ae"), Account.defaultSubaccount());
            amount = { e8s = Nat64.fromNat(balance) };
            fee = { e8s = 10_000 };
            created_at_time = ?{
                timestamp_nanos = Nat64.fromNat(Int.abs(Time.now()));
            };
        });

        Debug.print(debug_show (icp_receipt));
        switch icp_receipt {
            case (#Err _) {
                return #Err(#TransferFailure);
            };
            case _ {};
        };
        let available = {
            e8s : Nat = Nat64.toNat(source_balance.e8s) - icp_fee;
        };

        let token_receipt = await* ICRC1.transfer(
            token,
            {
                amount = balance * 1000;
                created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
                fee = null;
                from_subaccount = null;
                memo = null;
                to = { owner = msg.caller; subaccount = null };
            },
            Principal.fromText("x24eu-2jbtp-gqxjp-g7qeo-4bxy3-itz4h-4v7zw-gzva2-jm7oc-gac6g-7qe"),
        );

        switch token_receipt {
            case (#Err _) {
                return #Err(#TransferFailure);
            };
            case _ {};
        };

        // Return result
        #Ok(balance);
    };
};
