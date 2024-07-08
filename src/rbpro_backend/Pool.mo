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

    private stable var principal_repayments_index : Nat = 0;
    private stable var interest_repayments_index : Nat = 0;

    private stable var loan : Loan = args.loan;
    private stable var fee : Fee = args.fee;
    private stable var fee_asset : Nat = 10000; // reduce inter canister call
    private stable var total_fund : Nat = 0;
    private stable var decimal_offset : Nat8 = 0;
    private stable var status : PoolStatus = #open;

    private stable var factory : Principal = args.factory;
    private stable var owner : Principal = args.owner;
    private stable let token = ICRC1.init({
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
    private stable var borrowers : [Principal] = args.loan.borrowers;
    private stable var asset : Principal = args.loan.asset;
    private stable var fundrise_end_time : Time.Time = args.loan.fundrise_end_time;
    private stable var origination_date : Time.Time = args.loan.origination_date;
    private stable var maturity_date : Time.Time = args.loan.maturity_date;
    private stable var pool_ops : [PoolTxRecord] = [genesis];

    private stable var principal_schedule : [Nat] = args.loan.principal_schedule;
    private stable var interest_schedule : [Nat] = args.loan.interest_schedule;
    private stable var principal_payment_deadline : [Time.Time] = args.loan.principal_payment_deadline;
    private stable var interest_payment_deadline : [Time.Time] = args.loan.interest_payment_deadline;

    // ===== POOL INFORMATION ===== //

    public shared ({ caller }) func set_factory(new_factory : Principal) : async (Principal) {
        if (caller != owner) {
            throw Error.reject("Unauthorized");
        };

        factory := new_factory;
        return factory;
    };

    public shared query func get_factory() : async Principal {
        return factory;
    };

    public shared ({ caller }) func set_fee_asset(amount : Nat) : async (Nat) {
        if (caller != owner) {
            throw Error.reject("Unauthorized");
        };

        fee_asset := amount;
        return fee_asset;
    };

    public shared query func get_fee_asset() : async Nat {
        return fee_asset;
    };

    public shared ({ caller }) func transfer_ownership(new_owner : Principal) : async (Principal) {
        if (caller != owner) {
            throw Error.reject("Unauthorized");
        };

        owner := new_owner;
        return owner;
    };

    public shared query func get_owner() : async Principal {
        return owner;
    };

    public query func get_info() : async PoolRecord {
        return {
            loan.info with id = Principal.fromActor(this);
            borrowers = borrowers;
            fundrise_end_time = fundrise_end_time;
            maturity_date = maturity_date;
            origination_date = origination_date;
            smart_contract_url = Principal.toText(Principal.fromActor(this));
            total_loan_amount = total_fund;
            timestamp = genesis.timestamp;
            status = status;
        };
    };

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

    public shared ({ caller }) func set_fundrise_end_time(time : Time.Time) : async Time.Time {
        if (caller != owner) {
            throw Error.reject("Unauthorized");
        };

        fundrise_end_time := time;
        return fundrise_end_time;
    };

    public shared ({ caller }) func set_origination_date(time : Time.Time) : async Time.Time {
        if (caller != owner) {
            throw Error.reject("Unauthorized");
        };

        origination_date := time;
        return origination_date;
    };

    public shared ({ caller }) func set_maturity_date(time : Time.Time) : async Time.Time {
        if (caller != owner) {
            throw Error.reject("Unauthorized");
        };

        maturity_date := time;
        return maturity_date;
    };

    public shared ({ caller }) func trigger_closed() : async PoolStatus {
        if (caller != owner) {
            throw Error.reject("Unauthorized");
        };

        await set_status(#closed);

        return status;
    };

    public shared ({ caller }) func trigger_default() : async PoolStatus {
        if (caller != owner) {
            throw Error.reject("Unauthorized");
        };

        await set_status(#default);

        return status;
    };

    private func set_status(new_status : PoolStatus) : async () {
        status := new_status;

        let fact = actor (Principal.toText(factory)) : T.Factory;
        await fact.set_pool_status(status);
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

    public shared func get_outstanding_loan() : async Nat {
        var total : Nat = 0;

        for (element in loan.principal_schedule.vals()) {
            total += element;
        };

        for (element in loan.interest_schedule.vals()) {
            total += element;
        };

        let icrc = actor (Principal.toText(asset)) : ICRC.Actor;
        let account = {
            owner = Principal.fromActor(this);
            subaccount = null;
        };
        let balance = await icrc.icrc1_balance_of(account);

        return total - balance;
    };

    public shared func balance_of(lender : Principal) : async Nat {
        let account = {
            owner = lender;
            subaccount = null;
        };
        let amount = await icrc1_balance_of(account);
        let supply = await icrc1_total_supply();

        return (amount * (total_fund + 1)) / (supply + Nat.pow(10, Nat8.toNat(decimal_offset)));
    };

    public shared func convert_to_shares(amount : Nat) : async Nat {
        // todo: support multiple standards
        let shares : Nat = switch (await is_icrc2(asset)) {
            case (true) {
                let icrc = actor (Principal.toText(asset)) : ICRC.Actor;
                let account = {
                    owner = Principal.fromActor(this);
                    subaccount = null;
                };
                let balance = await icrc.icrc1_balance_of(account);
                let supply = await icrc1_total_supply();

                (amount * (supply + Nat.pow(10, Nat8.toNat(decimal_offset)))) / (balance + 1);
            };
            case (_) {
                let dip20 = actor (Principal.toText(asset)) : DIPInterface;
                let balance = await dip20.balanceOf(Principal.fromActor(this));
                let supply = await icrc1_total_supply();

                (amount * (supply + Nat.pow(10, Nat8.toNat(decimal_offset)))) / (balance + 1);
            };
        };

        return shares;
    };

    public shared func convert_to_assets(amount : Nat) : async Nat {
        let asset_amount : Nat = switch (await is_icrc2(asset)) {
            case (true) {
                let icrc = actor (Principal.toText(asset)) : ICRC.Actor;
                let account = {
                    owner = Principal.fromActor(this);
                    subaccount = null;
                };
                let balance = await icrc.icrc1_balance_of(account);
                let supply = await icrc1_total_supply();

                (amount * (balance + 1)) / (supply + Nat.pow(10, Nat8.toNat(decimal_offset)));
            };
            case (_) {
                let dip20 = actor (Principal.toText(asset)) : DIPInterface;
                let balance = await dip20.balanceOf(Principal.fromActor(this));
                let supply = await icrc1_total_supply();

                (amount * (balance + 1)) / (supply + Nat.pow(10, Nat8.toNat(decimal_offset)));
            };
        };

        return asset_amount;
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
        let rev_records : [PoolTxRecord] = Array.reverse(pool_ops);
        var i = start;
        while (i < start + limit and i < rev_records.size()) {
            ret := pool_add(ret, rev_records[i]);
            i += 1;
        };
        return ret;
    };

    public query func get_user_transactons(a : Principal, start : Nat, limit : Nat) : async [PoolTxRecord] {
        var res : [PoolTxRecord] = [];
        let user_records = Array.filter<PoolTxRecord>(pool_ops, func i = i.caller == ?a or i.from == a or i.to == a);
        let rev_records : [PoolTxRecord] = Array.reverse(user_records);

        var index : Nat = 0;
        for (i in rev_records.vals()) {
            if (index >= start and index < start + limit) {
                res := pool_add(res, i);
            };
            index += 1;
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
        let receipt = if (fundrise_end_time < Time.now()) {
            #Err(#FundriseTimeEnded);
        } else if (await is_icrc2(asset)) {
            await deposit_icrc(msg.caller, amount);
        } else {
            await deposit_dip(msg.caller, amount);
        };

        receipt;
    };

    private func deposit_dip(caller : Principal, amount : Nat) : async T.DepositReceipt {
        let dip20 = actor (Principal.toText(asset)) : DIPInterface;
        let trx_fee = await fetch_dip_fee(asset);

        let amount_after_tfee : Nat = amount - trx_fee;

        let protocol_fee = await fee_calc(amount_after_tfee);
        let amount_after_pfee : Nat = amount_after_tfee - protocol_fee;

        let new_shares = await convert_to_shares(amount_after_pfee);

        // transfer fund to pool.
        let token_receipt = await dip20.transferFrom(caller, Principal.fromActor(this), amount);
        switch token_receipt {
            case (#Err e) {
                return #Err(#TransferFailure);
            };
            case _ {};
        };

        // transfer fee to treasury
        if (protocol_fee > trx_fee) {
            let _ = await dip20.transfer(fee.treasury, protocol_fee - trx_fee);
        };

        switch (lenders.get(caller)) {
            case (null) {
                lenders.put(caller, amount_after_pfee);
            };
            case (?old_fund) {
                lenders.put(caller, old_fund + amount_after_pfee);
            };
        };

        total_fund := total_fund + amount_after_pfee;

        let trx_receipt = await* ICRC1.transfer(
            token,
            {
                amount = new_shares;
                created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
                fee = null; // mint is fee free
                from_subaccount = null;
                memo = null;
                to = { owner = caller; subaccount = null };
            },
            token.minting_account.owner,
        );

        switch trx_receipt {
            case (#Err e) {
                return #Err e;
            };
            case _ {};
        };

        let _txtid = add_pool_record(?caller, #deposit, caller, Principal.fromActor(this), amount_after_pfee, trx_fee + protocol_fee, Time.now(), #succeeded);

        #Ok(new_shares);
    };

    private func deposit_icrc(caller : Principal, amount : Nat) : async T.DepositReceipt {
        let icrc = actor (Principal.toText(asset)) : ICRC.Actor;
        let trx_fee = fee_asset;

        let amount_after_tfee : Nat = amount - trx_fee;

        let protocol_fee = await fee_calc(amount_after_tfee);
        let amount_after_pfee : Nat = amount_after_tfee - protocol_fee;

        let new_shares = await convert_to_shares(amount_after_pfee);

        let account : ICRC.Account = { owner = caller; subaccount = null };
        let spender : ICRC.Account = {
            owner = Principal.fromActor(this);
            subaccount = null;
        };

        let transfer_args : ICRC.TransferFromArgs = {
            created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
            spender_subaccount = null;
            from = account;
            to = spender;
            amount = amount_after_tfee;
            fee = ?trx_fee;
            memo = null;
        };

        // transfer fund to pool.
        let token_receipt = await icrc.icrc2_transfer_from(transfer_args);
        switch token_receipt {
            case (#Err e) {
                return #Err e;
            };
            case _ {};
        };

        // transfer fee to treasury
        if (protocol_fee > trx_fee) {
            let transfer_args : ICRC.TransferArg = {
                created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
                from_subaccount = null;
                to = { owner = fee.treasury; subaccount = null };
                amount = protocol_fee - trx_fee;
                fee = ?trx_fee;
                memo = null;
            };
            let _ = await icrc.icrc1_transfer(transfer_args);
        };

        switch (lenders.get(caller)) {
            case (null) {
                lenders.put(caller, amount_after_pfee);
            };
            case (?old_fund) {
                lenders.put(caller, old_fund + amount_after_pfee);
            };
        };

        total_fund := total_fund + amount_after_pfee;

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
            case (#Err e) {
                return #Err e;
            };
            case _ {};
        };

        let _txtid = add_pool_record(?caller, #deposit, caller, Principal.fromActor(this), amount_after_pfee, trx_fee + protocol_fee, Time.now(), #succeeded);

        #Ok(new_shares);
    };

    public shared (msg) func drawdown() : async T.DrawdownReceipt {
        if (not is_borrower(msg.caller)) {
            return #Err(#NotAuthorized);
        };

        if (origination_date > Time.now()) {
            return #Err(#BeforeOriginationDate);
        };

        if (status != #open) {
            return #Err(#InvalidDrawdown);
        };

        let self : Principal = Principal.fromActor(this);
        var amount : Nat = 0;
        var total : Nat = 0;
        var trx_fee : Nat = 0;

        if (await is_icrc2(asset)) {
            let icrc = actor (Principal.toText(asset)) : ICRC.Actor;
            amount := await icrc.icrc1_balance_of({
                owner = self;
                subaccount = null;
            });
            trx_fee := fee_asset;
            total := amount - trx_fee;

            let transfer_args : ICRC.TransferArg = {
                created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
                from_subaccount = null;
                to = { owner = msg.caller; subaccount = null };
                amount = total;
                fee = ?trx_fee;
                memo = null;
            };

            let receipt = await icrc.icrc1_transfer(transfer_args);
            switch receipt {
                case (#Err e) {
                    return #Err e;
                };
                case _ {};
            };
        } else {
            let dip20 = actor (Principal.toText(asset)) : DIPInterface;
            amount := await dip20.balanceOf(self);
            trx_fee := await fetch_dip_fee(asset);
            total := amount - trx_fee;

            let receipt = await dip20.transfer(msg.caller, total);
            switch receipt {
                case (#Err _) {
                    return #Err(#TransferFailure);
                };
                case _ {};
            };
        };

        await set_status(#active);

        let _txtid = add_pool_record(?msg.caller, #drawdown, self, msg.caller, total, trx_fee, Time.now(), #succeeded);

        #Ok(total);
    };

    public func next_principal_repayment() : async Nat {
        let max_index : Nat = principal_schedule.size() - 1;

        if (principal_repayments_index > max_index) {
            return 0;
        } else {
            return principal_schedule[principal_repayments_index];
        };
    };

    public func next_interest_repayment() : async Nat {
        let max_index : Nat = interest_schedule.size() - 1;

        if (interest_repayments_index > max_index) {
            return 0;
        } else {
            return interest_schedule[interest_repayments_index];
        };
    };

    public func next_principal_repayment_deadline() : async ?Time.Time {
        let max_index : Nat = principal_payment_deadline.size() - 1;

        if (principal_repayments_index > max_index) {
            return null;
        } else {
            return ?principal_payment_deadline[principal_repayments_index];
        };
    };

    public func next_interest_repayment_deadline() : async ?Time.Time {
        let max_index : Nat = interest_payment_deadline.size() - 1;

        if (interest_repayments_index > max_index) {
            return null;
        } else {
            return ?interest_payment_deadline[interest_repayments_index];
        };
    };

    public func get_repayment_index() : async { index : Nat; total : Nat } {
        return {
            index = interest_repayments_index;
            total = interest_payment_deadline.size();
        };
    };

    public shared (msg) func repay_principal() : async T.RepayPrincipalReceipt {
        let amount = await next_principal_repayment();
        if (amount == 0) {
            return #Err(#ZeroAmountTransfer);
        };

        var total : Nat = 0;
        var trx_fee : Nat = 0;

        if (await is_icrc2(asset)) {
            let icrc = actor (Principal.toText(asset)) : ICRC.Actor;
            trx_fee := fee_asset;
            total := amount - trx_fee;

            let account : ICRC.Account = {
                owner = msg.caller;
                subaccount = null;
            };
            let spender : ICRC.Account = {
                owner = Principal.fromActor(this);
                subaccount = null;
            };

            let transfer_args : ICRC.TransferFromArgs = {
                created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
                spender_subaccount = null;
                from = account;
                to = spender;
                amount = total;
                fee = ?trx_fee;
                memo = null;
            };

            // transfer fund to pool.
            let token_receipt = await icrc.icrc2_transfer_from(transfer_args);
            switch token_receipt {
                case (#Err e) {
                    return #Err e;
                };
                case _ {};
            };
        } else {
            // cast token to actor
            let dip20 = actor (Principal.toText(asset)) : DIPInterface;
            trx_fee := await fetch_dip_fee(asset);
            total := amount - trx_fee;

            // transfer to account.
            let token_receipt = await dip20.transferFrom(msg.caller, Principal.fromActor(this), total);
            switch token_receipt {
                case (#Err e) {
                    return #Err(#TransferFailure);
                };
                case _ {};
            };
        };

        principal_repayments_index += 1;

        let _txtid = add_pool_record(?msg.caller, #repayPrincipal, msg.caller, Principal.fromActor(this), total, trx_fee, Time.now(), #succeeded);

        #Ok(total);
    };

    public shared (msg) func repay_interest() : async T.RepayInterestReceipt {
        let amount = await next_interest_repayment();
        if (amount == 0) {
            return #Err(#ZeroAmountTransfer);
        };

        var total : Nat = 0;
        var trx_fee : Nat = 0;

        if (await is_icrc2(asset)) {
            let icrc = actor (Principal.toText(asset)) : ICRC.Actor;
            trx_fee := fee_asset;
            total := amount - trx_fee;

            let account : ICRC.Account = {
                owner = msg.caller;
                subaccount = null;
            };
            let spender : ICRC.Account = {
                owner = Principal.fromActor(this);
                subaccount = null;
            };

            let transfer_args : ICRC.TransferFromArgs = {
                created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
                spender_subaccount = null;
                from = account;
                to = spender;
                amount = total;
                fee = ?trx_fee;
                memo = null;
            };

            // transfer fund to pool.
            let token_receipt = await icrc.icrc2_transfer_from(transfer_args);
            switch token_receipt {
                case (#Err e) {
                    return #Err e;
                };
                case _ {};
            };
        } else {
            // cast token to actor
            let dip20 = actor (Principal.toText(asset)) : DIPInterface;
            trx_fee := await fetch_dip_fee(asset);
            total := amount - trx_fee;

            // transfer to account.
            let token_receipt = await dip20.transferFrom(msg.caller, Principal.fromActor(this), total);
            switch token_receipt {
                case (#Err e) {
                    return #Err(#TransferFailure);
                };
                case _ {};
            };

        };

        interest_repayments_index += 1;

        let _txtid = add_pool_record(?msg.caller, #repayInterest, msg.caller, Principal.fromActor(this), total, trx_fee, Time.now(), #succeeded);

        #Ok(total);
    };

    public shared (msg) func withdraw(amount : Nat) : async T.WithdrawReceipt {
        if (maturity_date > Time.now()) {
            return #Err(#WithdrawBeforeMaturityDate);
        };

        let balance = ICRC1.balance_of(
            token,
            {
                owner = msg.caller;
                subaccount = ?Account.defaultSubaccount();
            },
        );

        if (balance < amount) {
            return #Err(#BalanceLow);
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

        var total : Nat = 0;
        var trx_fee : Nat = 0;

        if (await is_icrc2(asset)) {
            let icrc = actor (Principal.toText(asset)) : ICRC.Actor;
            trx_fee := fee_asset;
            total := asset_amount - trx_fee;

            let transfer_args : ICRC.TransferArg = {
                created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
                from_subaccount = null;
                to = { owner = msg.caller; subaccount = null };
                amount = total;
                fee = ?trx_fee;
                memo = null;
            };

            let receipt = await icrc.icrc1_transfer(transfer_args);
            switch receipt {
                case (#Err e) {
                    return #Err e;
                };
                case _ {};
            };
        } else {
            let dip20 = actor (Principal.toText(asset)) : DIPInterface;
            trx_fee := await fetch_dip_fee(asset);
            total := asset_amount - trx_fee;

            let receipt = await dip20.transfer(msg.caller, asset_amount);
            switch receipt {
                case (#Err _) {
                    return #Err(#TransferFailure);
                };
                case _ {};
            };
        };

        let _txtid = add_pool_record(?msg.caller, #withdraw, Principal.fromActor(this), msg.caller, total, trx_fee, Time.now(), #succeeded);

        #Ok(total);
    };

    private func fetch_dip_fee(token : Principal) : async Nat {
        let dip20 = actor (Principal.toText(token)) : DIPInterface;
        let metadata = await dip20.getMetadata();
        metadata.fee;
    };

    private func _fetch_icrc_fee(token : Principal) : async Nat {
        let icrc = actor (Principal.toText(token)) : ICRC.Actor;
        let fee = await icrc.icrc1_fee();
        fee;
    };

    private func is_icrc2(token : Principal) : async Bool {
        /*
        let icrc = actor (Principal.toText(token)) : ICRC.Actor;
        let standards = await icrc.icrc1_supported_standards();
        var found : Bool = false;
        for (x in standards.vals()) {
            if (x.name == "ICRC-2") {
                found := true;
            };
        };
        */
        // reduce inter canister call :P
        return true;
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
