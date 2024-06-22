import Cycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
import TrieMap "mo:base/TrieMap";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Error "mo:base/Error";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import ICRC1 "mo:icrc1/ICRC1";

import IC "ic.types";
import T "types";
import Pool "Pool";

shared (msg) actor class Factory(args : T.InitFactory) = this {

    type Loan = T.Loan;
    type LoanStatus = T.LoanStatus;

    type PoolRecord = T.PoolRecord;
    type PoolStatus = T.PoolStatus;

    type Fee = T.Fee;
    type TokenInitArgs = ICRC1.TokenInitArgs;

    type LoanValidationErr = T.LoanValidationErr;
    type LoanValidation = T.LoanValidation;
    type ProposeLoanReceipt = T.ProposeLoanReceipt;

    private var loans : TrieMap.TrieMap<Nat, Loan> = TrieMap.TrieMap<Nat, Loan>(Nat.equal, Hash.hash);
    private var pools : TrieMap.TrieMap<Nat, PoolRecord> = TrieMap.TrieMap<Nat, PoolRecord>(Nat.equal, Hash.hash);

    // ===== STABLE DATA ===== //

    private stable var upgrade_loans : [(Nat, Loan)] = [];
    private stable var upgrade_pools : [(Nat, PoolRecord)] = [];
    private stable let ic : IC.Self = actor "aaaaa-aa"; // management canister id
    private stable var pool_cycle : Nat = 1_000_000_000_000;
    private stable var fee : Fee = args.fee;
    private stable var pool_token_args : TokenInitArgs = args.pool_token_args;
    private stable var owner : Principal = msg.caller;

    // ===== GOVERNANCE ===== //

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

    public shared ({ caller }) func set_pool_cycle(amount : Nat) : async Nat {
        if (caller != owner) {
            throw Error.reject("Unauthorized");
        };

        pool_cycle := amount;
        return pool_cycle;
    };

    public shared query func get_pool_cycle() : async Nat {
        return pool_cycle;
    };

    public shared ({ caller }) func set_default_fee(f : Fee) : async Fee {
        if (caller != owner) {
            throw Error.reject("Unauthorized");
        };

        fee := f;
        return fee;
    };

    public shared query func get_default_fee() : async Fee {
        return fee;
    };

    public shared ({ caller }) func set_default_pool_token_args(args : TokenInitArgs) : async TokenInitArgs {
        if (caller != owner) {
            throw Error.reject("Unauthorized");
        };

        pool_token_args := args;
        return pool_token_args;
    };

    public shared query func get_default_pool_token_args() : async TokenInitArgs {
        return pool_token_args;
    };

    // ===== LOAN ===== //

    private func is_valid_loan(loan : Loan) : LoanValidation {
        if (loan.principal_schedule.size() != loan.principal_payment_deadline.size()) {
            return #Err(#InvalidPrincipalPaymentSchedule);
        };

        if (loan.interest_schedule.size() != loan.interest_payment_deadline.size()) {
            return #Err(#InvalidInterestPaymentSchedue);
        };

        var total_payment : Nat = 0;
        for (amount in loan.principal_schedule.vals()) {
            total_payment += amount;
        };

        if (total_payment < loan.total_loan_amount) {
            return #Err(#InvalidTotalLoanAmount);
        };

        var t : Time.Time = Time.now();
        for (pt in loan.principal_payment_deadline.vals()) {
            if (t > pt) {
                return #Err(#InvalidPrincipalPaymentDeadline);
            };

            t := pt;
        };

        t := Time.now();
        for (it in loan.interest_payment_deadline.vals()) {
            if (t > it) {
                return #Err(#InvalidInterestPaymentDeadline);
            };

            t := it;
        };

        return #Ok;
    };

    public shared func propose_loan(loan : Loan) : async ProposeLoanReceipt {
        switch (is_valid_loan(loan)) {
            case (#Err(error)) {
                return #Err(error);
            };
            case (#Ok) {};
        };

        let index = loans.size() + 1;
        loans.put(
            index,
            {
                loan with index = ?index;
                status = ? #active;
            },
        );

        let new_loan = switch (loans.get(index)) {
            case (?result) {
                result;
            };
            case (null) {
                throw Error.reject("LoanNotFound");
            };
        };

        return #Ok(new_loan);
    };

    public query func get_loans(status : ?LoanStatus, start : Nat, limit : Nat) : async [Loan] {
        let f_loans = if (status != null) {
            TrieMap.mapFilter<Nat, Loan, Loan>(
                loans,
                Nat.equal,
                Hash.hash,
                func(key, value) = if (value.status == status) { ?value } else {
                    null;
                },
            );
        } else {
            loans;
        };

        let o_loans : [Loan] = Iter.toArray(f_loans.vals());
        var n_loans : [Loan] = [];
        var i = start;
        while (i < start + limit and i < o_loans.size()) {
            n_loans := add_loan(n_loans, o_loans[i]);
            i += 1;
        };

        return n_loans;
    };

    private func add_loan(arr : [Loan], data : Loan) : [Loan] {
        let buff = Buffer.Buffer<Loan>(arr.size());
        for (x in arr.vals()) {
            buff.add(x);
        };

        buff.add(data);
        return Buffer.toArray(buff);
    };

    public shared ({ caller }) func reject_loan(index : Nat) : async (?Loan) {
        if (caller != owner) {
            throw Error.reject("Unauthorized");
        };

        switch (loans.get(index)) {
            case (null) {
                throw Error.reject("Not Found");
            };
            case (?loan) {
                loans.put(
                    index,
                    {
                        loan with status = ? #rejected;
                    },
                );

                return loans.get(index);
            };
        };
    };

    // ===== POOL FACTORY ===== //

    public shared ({ caller }) func back_loan(index : Nat) : async (Principal) {
        if (caller != owner) {
            throw Error.reject("Unauthorized");
        };

        let loan : Loan = switch (loans.get(index)) {
            case (null) {
                throw Error.reject("Not Found");
            };
            case (?l) {
                if (l.status == ? #active) {
                    l;
                } else {
                    throw Error.reject("Inactive Loan");
                };
            };
        };

        loans.put(
            index,
            {
                loan with status = ? #approved;
            },
        );

        Cycles.add<system>(pool_cycle);
        let pool = await Pool.Pool({
            owner = owner;
            loan = loan;
            fee = fee;
            token_args = {
                pool_token_args with name = loan.info.title # " Token";
                symbol = "RB" # Nat.toText(index);
            };
        });
        let canister_id = ?(Principal.fromActor(pool));

        switch (canister_id) {
            case null {
                throw Error.reject("Pool init error");
            };
            case (?canister_id) {
                let self : Principal = Principal.fromActor(this);
                let controllers : ?[Principal] = ?[canister_id, caller, self];

                await ic.update_settings({
                    canister_id = canister_id;
                    settings = {
                        controllers = controllers;
                        freezing_threshold = null;
                        memory_allocation = null;
                        compute_allocation = null;
                    };
                });

                let pool_record : PoolRecord = {
                    id = canister_id;
                    borrowers = loan.borrowers;
                    apr = loan.info.apr;
                    credit_rating = loan.info.credit_rating;
                    description = loan.info.description;
                    fundrise_end_time = loan.fundrise_end_time;
                    issuer_description = loan.info.issuer_description;
                    issuer_picture = loan.info.issuer_picture;
                    loan_term = loan.info.loan_term;
                    maturity_date = loan.maturity_date;
                    origination_date = loan.origination_date;
                    payment_frequency = loan.info.payment_frequency;
                    secured_by = loan.info.secured_by;
                    smart_contract_url = Principal.toText(canister_id);
                    title = loan.info.title;
                    total_loan_amount = loan.total_loan_amount;
                    timestamp = Time.now();
                    status = #active;
                };

                pools.put(index, pool_record);

                return canister_id;
            };
        };
    };

    public query func get_pools(status : ?PoolStatus, start : Nat, limit : Nat) : async [PoolRecord] {
        let f_pools = if (status != null) {
            let nstatus : PoolStatus = switch (status) {
                case (null) {
                    #open;
                };
                case (?s) {
                    s;
                };
            };
            TrieMap.mapFilter<Nat, PoolRecord, PoolRecord>(
                pools,
                Nat.equal,
                Hash.hash,
                func(key, value) = if (value.status == nstatus) { ?value } else {
                    null;
                },
            );
        } else {
            pools;
        };

        let o_pools : [PoolRecord] = Iter.toArray(f_pools.vals());
        var n_pools : [PoolRecord] = [];
        var i = start;
        while (i < start + limit and i < o_pools.size()) {
            n_pools := add_pool(n_pools, o_pools[i]);
            i += 1;
        };

        return n_pools;
    };

    private func add_pool(arr : [PoolRecord], data : PoolRecord) : [PoolRecord] {
        let buff = Buffer.Buffer<PoolRecord>(arr.size());
        for (x in arr.vals()) {
            buff.add(x);
        };

        buff.add(data);
        return Buffer.toArray(buff);
    };

    // ===== UPGRADE ===== /

    system func preupgrade() {
        upgrade_loans := Iter.toArray(loans.entries());
        upgrade_pools := Iter.toArray(pools.entries());
    };

    system func postupgrade() {
        loans := TrieMap.fromEntries<Nat, Loan>(upgrade_loans.vals(), Nat.equal, Hash.hash);
        pools := TrieMap.fromEntries<Nat, PoolRecord>(upgrade_pools.vals(), Nat.equal, Hash.hash);
    };
};
