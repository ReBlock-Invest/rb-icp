import Cycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
import Error "mo:base/Error";
import Array "mo:base/Array";
import Time "mo:base/Time";

import IC "./ic.types";
import T "types";
import Pool "./pool";

actor Main {
    private stable var canisterId : ?Principal = null;
    private stable var pools : [T.PoolRecord] = [];

    private let ic : IC.Self = actor "aaaaa-aa";

    private func add_pool_record(pool_info : T.PoolRecord) : Nat {
        let index = pools.size();
        pools := Array.append(pools, [pool_info]);
        return index;
    };

    public shared ({ caller }) func proposePool(pool_info : T.PoolInfo) : async (Principal) {
        Cycles.add<system>(1_000_000_000_000);
        let p = await Pool.Pool(pool_info);

        canisterId := ?(Principal.fromActor(p));

        switch (canisterId) {
            case null {
                throw Error.reject("Pool init error");
            };
            case (?canisterId) {
                let self : Principal = Principal.fromActor(Main);

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
                    borrower = pool_info.borrower;
                    apr = pool_info.apr;
                    credit_rating = pool_info.credit_rating;
                    description = pool_info.description;
                    fundrise_end_time = pool_info.fundrise_end_time;
                    issuer_description = pool_info.issuer_description;
                    issuer_picture = pool_info.issuer_picture;
                    loan_term = pool_info.loan_term;
                    maturity_date = pool_info.maturity_date;
                    origination_date = pool_info.origination_date;
                    payment_frequency = pool_info.payment_frequency;
                    secured_by = pool_info.secured_by;
                    smart_contract_url = pool_info.smart_contract_url;
                    title = pool_info.title;
                    total_loan_amount = pool_info.total_loan_amount;
                    timestamp = Time.now();
                    status = #pending;
                };

                let _txtid = add_pool_record(pool_record);

                return canisterId;
            };
        };
    };

    public query func get_pools(start : Nat, limit : Nat) : async [T.PoolRecord] {
        var ret : [T.PoolRecord] = [];
        var i = start;
        while (i < start + limit and i < pools.size()) {
            ret := Array.append(ret, [pools[i]]);
            i += 1;
        };
        return ret;
    };
};
