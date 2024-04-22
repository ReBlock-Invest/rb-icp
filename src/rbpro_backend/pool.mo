import T "types";

actor class Pool(pool_info : T.PoolInfo) = this {

    private stable var info : T.PoolInfo = pool_info;

    public query func get_info() : async T.PoolInfo {
        return info;
    };

};
