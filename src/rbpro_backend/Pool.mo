import Principal "mo:base/Principal";
import Option "mo:base/Option";
import Time "mo:base/Time";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Nat64 "mo:base/Nat64";
import Int "mo:base/Int";
import Blob "mo:base/Blob";
import ICRC1 "mo:icrc1/ICRC1";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Error "mo:base/Error";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";

import T "types";
import Account "Account";
import Hex "hex";
import ICRC "icrc";

shared (msg) actor class Pool(args : T.InitPool) : async ICRC1.FullInterface = this {

    type Loan = T.Loan;
    type Fee = T.Fee;
    type PoolStatus = T.PoolStatus;
    type PoolRecord = T.PoolRecord;

    type DIPInterface = T.DIPInterface;

    type PoolOperation = T.PoolOperation;
    type TransactionStatus = T.TxStatus;
    type PoolTxRecord = T.PoolTxRecord;

    private func isPrincipalEqual(x : Principal, y : Principal) : Bool {
        x == y;
    };
    private var lenders : HashMap.HashMap<Principal, Nat> = HashMap.HashMap<Principal, Nat>(10, isPrincipalEqual, Principal.hash);
    private stable var upgrade_lenders : [(Principal, Nat)] = [];

    private stable var loan : Loan = args.loan;
    private stable var fee : Fee = args.fee;
    private stable var total_fund : Nat = 0;
    private stable var decimal_offset : Nat8 = 0;
    private stable var status : PoolStatus = #pending;

    stable let owner : Principal = msg.caller;
    stable let token = ICRC1.init({
        args.token_args with minting_account = Option.get(
            args.token_args.minting_account,
            {
                owner = msg.caller;
                subaccount = null;
            },
        );
    });
    private stable let genesis : PoolTxRecord = {
        caller = ?msg.caller;
        op = #init;
        index = 0;
        from = msg.caller;
        to = msg.caller;
        amount = 0;
        fee = 0;
        timestamp = Time.now();
        status = #succeeded;
    };
    stable var borrowers : [Principal] = args.loan.borrowers;
    stable let asset : Principal = args.loan.asset;
    private stable var pool_ops : [PoolTxRecord] = [genesis];

    // ===== POOL INFORMATION ===== //

    public query func get_info() : async PoolRecord {
        return {
            loan.info with id = Principal.fromActor(this);
            borrowers = loan.borrowers;
            fundrise_end_time = loan.fundrise_end_time;
            maturity_date = loan.maturity_date;
            origination_date = loan.origination_date;
            smart_contract_url = Principal.toText(Principal.fromActor(this));
            total_loan_amount = loan.total_loan_amount;
            timestamp = genesis.timestamp;
            status = status;
        };
    };

    /*
    public shared ({ caller }) func set_info(new_info : T.PoolInfo) : async T.PoolInfo {
        if (caller != owner) {
            throw Error.reject("Unauthorized");
        };

        info := new_info;
        return info;
    };
    */
    public query func get_fee() : async Fee {
        return fee;
    };

    public shared ({ caller }) func set_fee(new_fee : Fee) : async Fee {
        if (caller != owner) {
            throw Error.reject("Unauthorized");
        };

        fee := new_fee;
        return fee;
    };

    public shared func fee_calc(amount : Nat) : async Nat {
        return (amount * fee.fee) / fee.fee_basis_point;
    };

    public shared func get_decimal_offset() : async Nat8 {
        return decimal_offset;
    };

    public shared ({ caller }) func set_decimal_offset(decimal : Nat8) : async Nat8 {
        if (caller != owner) {
            throw Error.reject("Unauthorized");
        };

        decimal_offset := decimal;
        return decimal_offset;
    };

    public query func get_asset() : async Principal {
        return asset;
    };

    public query func get_total_fund() : async Nat {
        return total_fund;
    };

    public shared query func balance_of(lender : Principal) : async Nat {
        switch (lenders.get(lender)) {
            case (null) {
                return 0;
            };
            case (?amount) {
                return amount;
            };
        };
    };

    public shared func convert_to_shares(amount : Nat) : async Nat {
        let dip20 = actor (Principal.toText(asset)) : DIPInterface;
        let balance = await dip20.balanceOf(Principal.fromActor(this));
        let supply = await icrc1_total_supply();

        return (amount * (supply + Nat.pow(10, Nat8.toNat(decimal_offset)))) / (balance + 1);
    };

    public shared func convert_to_assets(amount : Nat) : async Nat {
        let dip20 = actor (Principal.toText(asset)) : DIPInterface;
        let balance = await dip20.balanceOf(Principal.fromActor(this));
        let supply = await icrc1_total_supply();

        return (amount * (balance + 1)) / (supply + Nat.pow(10, Nat8.toNat(decimal_offset)));
    };

    // ===== ICRC1 TOKEN STANDARD ===== //

    public shared query func icrc1_name() : async Text {
        ICRC1.name(token);
    };

    public shared query func icrc1_symbol() : async Text {
        ICRC1.symbol(token);
    };

    public shared query func icrc1_decimals() : async Nat8 {
        ICRC1.decimals(token) + decimal_offset;
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

    public shared query func get_transactions(req : ICRC1.GetTransactionsRequest) : async ICRC1.GetTransactionsResponse {
        ICRC1.get_transactions(token, req);
    };

    public shared func get_transaction(i : ICRC1.TxIndex) : async ?ICRC1.Transaction {
        await* ICRC1.get_transaction(token, i);
    };

    // ===== TRANSACTIONS ===== //

    private func pool_add(arr : [PoolTxRecord], data : PoolTxRecord) : [PoolTxRecord] {
        let buff = Buffer.Buffer<PoolTxRecord>(arr.size());
        for (x in arr.vals()) {
            buff.add(x);
        };

        buff.add(data);
        return Buffer.toArray(buff);
    };

    private func add_pool_record(
        caller : ?Principal,
        op : PoolOperation,
        from : Principal,
        to : Principal,
        amount : Nat,
        fee : Nat,
        timestamp : Time.Time,
        status : TransactionStatus,
    ) : Nat {
        let index = pool_ops.size();
        let o : PoolTxRecord = {
            caller = caller;
            op = op;
            index = index;
            from = from;
            to = to;
            amount = amount;
            fee = fee;
            timestamp = timestamp;
            status = status;
        };

        pool_ops := pool_add(pool_ops, o);
        return index;
    };

    public query func history_size() : async Nat {
        return pool_ops.size();
    };

    public query func get_pool_transaction(index : Nat) : async PoolTxRecord {
        return pool_ops[index];
    };

    public query func get_pool_transactions(start : Nat, limit : Nat) : async [PoolTxRecord] {
        var ret : [PoolTxRecord] = [];
        var i = start;
        while (i < start + limit and i < pool_ops.size()) {
            ret := pool_add(ret, pool_ops[i]);
            i += 1;
        };
        return ret;
    };

    public query func get_user_transactons(a : Principal, start : Nat, limit : Nat) : async [PoolTxRecord] {
        var res : [PoolTxRecord] = [];
        var index : Nat = 0;
        for (i in pool_ops.vals()) {
            if (i.caller == ?a or i.from == a or i.to == a) {
                if (index >= start and index < start + limit) {
                    res := pool_add(res, i);
                };
                index += 1;
            };
        };
        return res;
    };

    // ===== LENDING FUNCTIONS ===== //

    public func get_borrower() : async [Principal] {
        borrowers;
    };

    public shared (msg) func get_deposit_address() : async Text {
        let account = Account.accountIdentifier(Principal.fromActor(this), Account.principalToSubaccount(msg.caller));
        Hex.encode(Blob.toArray(account));
    };

    public shared (msg) func deposit(amount : Nat) : async T.DepositReceipt {
        if (await is_icrc2(loan.asset)) {
            await deposit_icrc(msg.caller, amount);
        } else {
            await deposit_dip(msg.caller, amount);
        };
    };

    private func deposit_dip(caller : Principal, amount : Nat) : async T.DepositReceipt {
        // cast token to actor
        let dip20 = actor (Principal.toText(asset)) : T.DIPInterface;
        let dip_fee = await fetch_dip_fee(asset);
        let protocol_fee = await fee_calc(amount);
        let total : Nat = amount - dip_fee - protocol_fee;
        let new_shares = await convert_to_shares(total);

        // check DIP20 allowance
        let balance : Nat = (await dip20.allowance(caller, Principal.fromActor(this)));

        // transfer fund to pool.
        let token_receipt = if (balance >= amount) {
            await dip20.transferFrom(caller, Principal.fromActor(this), amount);
        } else {
            return #Err(#BalanceLow);
        };

        switch token_receipt {
            case (#Err e) {
                return #Err(#TransferFailure);
            };
            case _ {};
        };

        // transfer fee to treasury
        if (protocol_fee > dip_fee) {
            let _ = await dip20.transfer(fee.treasury, protocol_fee);
        };

        switch (lenders.get(caller)) {
            case (null) {
                lenders.put(caller, total);
            };
            case (?old_fund) {
                lenders.put(caller, old_fund + total);
            };
        };

        total_fund := total_fund + total;

        let trx_receipt = await* ICRC1.transfer(
            token,
            {
                amount = new_shares;
                created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
                fee = null;
                from_subaccount = null;
                memo = null;
                to = { owner = caller; subaccount = null };
            },
            token.minting_account.owner,
        );

        switch trx_receipt {
            case (#Err _) {
                return #Err(#TransferFailure);
            };
            case _ {};
        };

        let _txtid = add_pool_record(?caller, #deposit, caller, Principal.fromActor(this), amount, dip_fee, Time.now(), #succeeded);

        #Ok(new_shares);
    };

    private func deposit_icrc(caller : Principal, amount : Nat) : async T.DepositReceipt {
        // cast token to actor
        let icrc = actor (Principal.toText(asset)) : ICRC.Actor;
        let icrc_fee = await fetch_icrc_fee(asset);
        let protocol_fee = await fee_calc(amount);
        let total : Nat = amount - icrc_fee - protocol_fee;
        let new_shares = await convert_to_shares(total);

        // check ICRC-2 allowance
        let account : ICRC.Account = { owner = caller; subaccount = null };
        let spender : ICRC.Account = {
            owner = Principal.fromActor(this);
            subaccount = null;
        };
        let balance : ICRC.Allowance = await icrc.icrc2_allowance({
            account;
            spender;
        });

        // transfer fund to pool.
        let token_receipt = if (balance.allowance >= amount) {
            let transfer_args : ICRC.TransferFromArgs = {
                created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
                spender_subaccount = null;
                from = account;
                to = spender;
                amount = amount;
                fee = null;
                memo = null;
            };
            // handle transfer result
            await icrc.icrc2_transfer_from(transfer_args);
        } else {
            return #Err(#BalanceLow);
        };

        switch token_receipt {
            case (#Err e) {
                return #Err(#TransferFailure);
            };
            case _ {};
        };

        // transfer fee to treasury
        if (protocol_fee > icrc_fee) {
            let transfer_args : ICRC.TransferArg = {
                created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
                from_subaccount = null;
                to = { owner = fee.treasury; subaccount = null };
                amount = protocol_fee;
                fee = null;
                memo = null;
            };
            let _ = await icrc.icrc1_transfer(transfer_args);
        };

        switch (lenders.get(caller)) {
            case (null) {
                lenders.put(caller, total);
            };
            case (?old_fund) {
                lenders.put(caller, old_fund + total);
            };
        };

        total_fund := total_fund + total;

        let trx_receipt = await* ICRC1.transfer(
            token,
            {
                amount = new_shares;
                created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
                fee = null;
                from_subaccount = null;
                memo = null;
                to = { owner = caller; subaccount = null };
            },
            token.minting_account.owner,
        );

        switch trx_receipt {
            case (#Err _) {
                return #Err(#TransferFailure);
            };
            case _ {};
        };

        let _txtid = add_pool_record(?caller, #deposit, caller, Principal.fromActor(this), amount, icrc_fee, Time.now(), #succeeded);

        #Ok(new_shares);
    };

    public shared (msg) func drawdown(amount : Nat) : async T.DrawdownReceipt {
        if (not is_borrower(msg.caller)) {
            return #Err(#NotAuthorized);
        };

        // cast token to actor
        let dip20 = actor (Principal.toText(asset)) : T.DIPInterface;
        let dip_fee = await fetch_dip_fee(asset);
        let total : Nat = amount - dip_fee;

        let receipt = await dip20.transfer(msg.caller, amount);
        switch receipt {
            case (#Err _) {
                return #Err(#TransferFailure);
            };
            case _ {};
        };

        let _txtid = add_pool_record(?msg.caller, #drawdown, Principal.fromActor(this), msg.caller, amount, dip_fee, Time.now(), #succeeded);

        #Ok(total);
    };

    public shared (msg) func repay_principal(amount : Nat) : async T.RepayPrincipalReceipt {
        // cast token to actor
        let dip20 = actor (Principal.toText(asset)) : T.DIPInterface;
        let dip_fee = await fetch_dip_fee(asset);
        let total : Nat = amount - dip_fee;

        // check DIP20 allowance
        let balance : Nat = (await dip20.allowance(msg.caller, Principal.fromActor(this)));

        // transfer to account.
        let token_receipt = if (balance >= amount) {
            await dip20.transferFrom(msg.caller, Principal.fromActor(this), amount);
        } else {
            return #Err(#BalanceLow);
        };
        switch token_receipt {
            case (#Err e) {
                return #Err(#TransferFailure);
            };
            case _ {};
        };

        let _txtid = add_pool_record(?msg.caller, #repayPrincipal, msg.caller, Principal.fromActor(this), amount, dip_fee, Time.now(), #succeeded);

        #Ok(total);
    };

    public shared (msg) func repay_interest(amount : Nat) : async T.RepayInterestReceipt {
        // cast token to actor
        let dip20 = actor (Principal.toText(asset)) : T.DIPInterface;
        let dip_fee = await fetch_dip_fee(asset);
        let total : Nat = amount - dip_fee;

        // check DIP20 allowance
        let balance : Nat = (await dip20.allowance(msg.caller, Principal.fromActor(this)));

        // transfer to account.
        let token_receipt = if (balance >= amount) {
            await dip20.transferFrom(msg.caller, Principal.fromActor(this), amount);
        } else {
            return #Err(#BalanceLow);
        };
        switch token_receipt {
            case (#Err e) {
                return #Err(#TransferFailure);
            };
            case _ {};
        };

        let _txtid = add_pool_record(?msg.caller, #repayInterest, msg.caller, Principal.fromActor(this), amount, dip_fee, Time.now(), #succeeded);

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

        if (balance < amount) {
            return return #Err(#BalanceLow);
        };

        // calculate asset before burn shares
        let asset_amount = await convert_to_assets(amount);

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
        switch trx_receipt {
            case (#Err _) {
                return #Err(#TransferFailure);
            };
            case _ {};
        };

        let dip20 = actor (Principal.toText(asset)) : T.DIPInterface;
        let dip_fee = await fetch_dip_fee(asset);
        let total : Nat = asset_amount - dip_fee;

        let receipt = await dip20.transfer(msg.caller, total);
        switch receipt {
            case (#Err _) {
                return #Err(#TransferFailure);
            };
            case _ {};
        };

        let _txtid = add_pool_record(?msg.caller, #withdraw, Principal.fromActor(this), msg.caller, total, dip_fee, Time.now(), #succeeded);

        #Ok(total);
    };

    private func fetch_dip_fee(token : Principal) : async Nat {
        let dip20 = actor (Principal.toText(token)) : T.DIPInterface;
        let metadata = await dip20.getMetadata();
        metadata.fee;
    };

    private func fetch_icrc_fee(token : Principal) : async Nat {
        let icrc = actor (Principal.toText(token)) : ICRC.Actor;
        let fee = await icrc.icrc1_fee();
        fee;
    };

    private func is_icrc2(token : Principal) : async Bool {
        let icrc = actor (Principal.toText(token)) : ICRC.Actor;
        let standards = await icrc.icrc1_supported_standards();
        var found : Bool = false;
        for (x in standards.vals()) {
            if (x.name == "ICRC-2") {
                found := true;
            };
        };

        return found;
    };

    public shared (msg) func set_borrower(n_borrower : Principal) {
        if (msg.caller != owner) {
            throw Error.reject("Unauthorized");
        };

        let buff = Buffer.Buffer<Principal>(borrowers.size());
        var found = false;
        for (x in borrowers.vals()) {
            buff.add(x);
            if (x == n_borrower) {
                found := true;
            };
        };

        if (not found) {
            buff.add(n_borrower);
        };

        borrowers := Buffer.toArray(buff);
    };

    public shared (msg) func remove_borrower(n_borrower : Principal) {
        if (msg.caller != owner) {
            throw Error.reject("Unauthorized");
        };

        let buff = Buffer.Buffer<Principal>(borrowers.size());
        for (x in borrowers.vals()) {
            if (x != n_borrower) {
                buff.add(x);
            };
        };

        buff.add(n_borrower);
        borrowers := Buffer.toArray(buff);
    };

    private func is_borrower(user : Principal) : Bool {
        return Array.find<Principal>(borrowers, func x = x == user) != null;
    };

    // ===== UPGRADE ===== //

    system func preupgrade() {
        upgrade_lenders := Iter.toArray(lenders.entries());
    };

    system func postupgrade() {
        lenders := HashMap.fromIter<Principal, Nat>(upgrade_lenders.vals(), 10, isPrincipalEqual, Principal.hash);
        upgrade_lenders := [];
    };
};
