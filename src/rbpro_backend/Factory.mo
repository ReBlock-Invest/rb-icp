import Cycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
import Error "mo:base/Error";
import Buffer "mo:base/Buffer";
import Time "mo:base/Time";

import IC "ic.types";
import T "types";
import Pool "Pool";

shared (msg) actor class Factory() = this {

    private stable var pools : [T.PoolRecord] = [];
    private stable let ic : IC.Self = actor "aaaaa-aa";
    private stable var pool_cycle : Nat = 1_000_000_000_000;
    private stable var owner : Principal = msg.caller;
    private stable var proposals : [T.PoolInfo] = [];

    // ===== GOVERNANCE =====

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

    // ===== POOL FACTORY =====

    private func is_valid_proposal(_loan : T.PoolInfo) : Bool {

        return true;
    };

    private func add_proposal(arr : [T.PoolInfo], data : T.PoolInfo) : [T.PoolInfo] {
        let buff = Buffer.Buffer<T.PoolInfo>(arr.size());
        for (x in arr.vals()) {
            buff.add(x);
        };

        buff.add(data);
        return Buffer.toArray(buff);
    };

    public func propose_loan(args : T.PoolArgs) {
        if (not is_valid_proposal(args.info)) {
            throw Error.reject("Invalid Proposal");
        };

        proposals := add_proposal(proposals, args.info);
    };

    public shared ({ caller }) func back_loan(args : T.PoolArgs) : async (Principal) {
        if (caller != owner) {
            throw Error.reject("Unauthorized");
        };

        Cycles.add<system>(pool_cycle);
        let pool = await Pool.Pool(args);
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

                let pool_record : T.PoolRecord = {
                    id = canister_id;
                    borrowers = args.borrowers;
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
                    smart_contract_url = args.info.smart_contract_url # Principal.toText(canister_id);
                    title = args.info.title;
                    total_loan_amount = args.info.total_loan_amount;
                    timestamp = Time.now();
                    status = #active;
                };

                add_pool_record(pool_record);

                return canister_id;
            };
        };
    };

    public shared ({ caller }) func unback_loan(pool_id : Principal) : async (Principal) {
        if (caller != owner) {
            throw Error.reject("Unauthorized");
        };

        return caller;
    };

    private func add_pool(arr : [T.PoolRecord], data : T.PoolRecord) : [T.PoolRecord] {
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
            ret := add_pool(ret, pools[i]);
            i += 1;
        };
        return ret;
    };

    private func add_pool_record(pool_info : T.PoolRecord) {
        pools := add_pool(pools, pool_info);
    };

    public shared ({ caller }) func remove_pool(pool_id : Principal) : async [T.PoolRecord] {
        if (caller != owner) {
            throw Error.reject("Unauthorized");
        };

        let buff = Buffer.Buffer<T.PoolRecord>(pools.size());
        label iters for (x in pools.vals()) {
            if (x.id == pool_id) {
                continue iters;
            };

            buff.add(x);
        };

        pools := Buffer.toArray(buff);

        return pools;
    };
};
