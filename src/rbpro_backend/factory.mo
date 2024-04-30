import Cycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
import Error "mo:base/Error";
import Buffer "mo:base/Buffer";
import Time "mo:base/Time";

import IC "ic.types";
import T "types";
import Pool "pool";

shared (msg) actor class Factory() = this {

    private stable var canisterId : ?Principal = null;
    private stable var pools : [T.PoolRecord] = [];
    private let ic : IC.Self = actor "aaaaa-aa";
    private var pool_cycle : Nat = 1_000_000_000_000;
    private var owner : Principal = msg.caller;

    // ===== GOVERNANCE =====

    public shared ({ caller }) func transfer_ownership(new_owner : Principal) : async (Principal) {
        assert (caller == owner);

        owner := new_owner;
        return owner;
    };

    public shared ({ caller }) func set_pool_cycle(amount : Nat) : async Nat {
        assert (caller == owner);

        pool_cycle := amount;
        return pool_cycle;
    };

    // ===== LOAN FACTORY =====

    public shared ({ caller }) func propose_loan(args : T.PoolArgs) : async (Principal) {
        Cycles.add<system>(pool_cycle);
        let p = await Pool.Pool(args);

        canisterId := ?(Principal.fromActor(p));

        switch (canisterId) {
            case null {
                throw Error.reject("Pool init error");
            };
            case (?canisterId) {
                let self : Principal = Principal.fromActor(this);
                let controllers : ?[Principal] = ?[canisterId, caller, self];

                await ic.update_settings({
                    canister_id = canisterId;
                    settings = {
                        controllers = controllers;
                        freezing_threshold = null;
                        memory_allocation = null;
                        compute_allocation = null;
                    };
                });

                let pool_record : T.PoolRecord = {
                    id = canisterId;
                    borrowers = args.info.borrowers;
                    apr = args.info.apr;
                    credit_rating = args.info.credit_rating;
                    description = args.info.description;
                    fundrise_end_time = args.info.fundrise_end_time;
                    issuer_description = args.info.issuer_description;
                    issuer_picture = args.info.issuer_picture;
                    loan_term = args.info.loan_term;
                    maturity_date = args.info.maturity_date;
                    origination_date = args.info.origination_date;
                    payment_frequency = args.info.payment_frequency;
                    secured_by = args.info.secured_by;
                    smart_contract_url = args.info.smart_contract_url;
                    title = args.info.title;
                    total_loan_amount = args.info.total_loan_amount;
                    timestamp = Time.now();
                    status = #pending;
                };

                add_pool_record(pool_record);

                return canisterId;
            };
        };
    };

    public shared ({ caller }) func back_loan(args : T.PoolArgs) : async (Principal) {
        assert (caller == owner);

        Cycles.add<system>(pool_cycle);
        let p = await Pool.Pool(args);

        canisterId := ?(Principal.fromActor(p));

        switch (canisterId) {
            case null {
                throw Error.reject("Pool init error");
            };
            case (?canisterId) {
                let self : Principal = Principal.fromActor(this);
                let controllers : ?[Principal] = ?[canisterId, caller, self];

                await ic.update_settings({
                    canister_id = canisterId;
                    settings = {
                        controllers = controllers;
                        freezing_threshold = null;
                        memory_allocation = null;
                        compute_allocation = null;
                    };
                });

                let pool_record : T.PoolRecord = {
                    id = canisterId;
                    borrowers = args.info.borrowers;
                    apr = args.info.apr;
                    credit_rating = args.info.credit_rating;
                    description = args.info.description;
                    fundrise_end_time = args.info.fundrise_end_time;
                    issuer_description = args.info.issuer_description;
                    issuer_picture = args.info.issuer_picture;
                    loan_term = args.info.loan_term;
                    maturity_date = args.info.maturity_date;
                    origination_date = args.info.origination_date;
                    payment_frequency = args.info.payment_frequency;
                    secured_by = args.info.secured_by;
                    smart_contract_url = args.info.smart_contract_url;
                    title = args.info.title;
                    total_loan_amount = args.info.total_loan_amount;
                    timestamp = Time.now();
                    status = #pending;
                };

                add_pool_record(pool_record);

                return canisterId;
            };
        };
    };

    private func pool_add(arr : [T.PoolRecord], data : T.PoolRecord) : [T.PoolRecord] {
        let buff = Buffer.Buffer<T.PoolRecord>(arr.size());
        for (x in arr.vals()) {
            buff.add(x);
        };

        buff.add(data);
        return Buffer.toArray(buff);
    };

    public query func get_pools(start : Nat, limit : Nat) : async [T.PoolRecord] {
        var ret : [T.PoolRecord] = [];
        var i = start;
        while (i < start + limit and i < pools.size()) {
            ret := pool_add(ret, pools[i]);
            i += 1;
        };
        return ret;
    };

    private func add_pool_record(pool_info : T.PoolRecord) {
        pools := pool_add(pools, pool_info);
    };
};
