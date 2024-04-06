import Time "mo:base/Time";

module {

    public type Token = Principal;

    // ledger types
    public type Operation = {
        #approve;
        #mint;
        #transfer;
        #transferFrom;
    };

    public type PoolOperation = {
        #init;
        #deposit;
        #withdraw;
        #repayInterest;
        #repayPrincipal;
        #drawdown;
    };

    public type TransactionStatus = {
        #succeeded;
        #failed;
    };

    public type TxRecord = {
        caller : ?Principal;
        op : Operation; // operation type
        index : Nat; // transaction index
        from : Principal;
        to : Principal;
        amount : Nat;
        fee : Nat;
        timestamp : Time.Time;
        status : TransactionStatus;
    };

    public type PoolTxRecord = {
        caller : ?Principal;
        op : PoolOperation; // operation type
        index : Nat; // transaction index
        from : Principal;
        to : Principal;
        amount : Nat;
        fee : Nat;
        timestamp : Time.Time;
        status : TransactionStatus;
    };

    // Dip20 token interface
    public type TxReceipt = {
        #Ok : Nat;
        #Err : {
            #InsufficientAllowance;
            #InsufficientBalance;
            #ErrorOperationStyle;
            #Unauthorized;
            #LedgerTrap;
            #ErrorTo;
            #Other;
            #BlockUsed;
            #AmountTooSmall;
        };
    };

    public type Metadata = {
        logo : Text; // base64 encoded logo or logo url
        name : Text; // token name
        symbol : Text; // token symbol
        decimals : Nat8; // token decimal
        totalSupply : Nat; // token total supply
        owner : Principal; // token owner
        fee : Nat; // fee for update calls
    };

    public type DIPInterface = actor {
        transfer : (Principal, Nat) -> async TxReceipt;
        transferFrom : (Principal, Principal, Nat) -> async TxReceipt;
        allowance : (owner : Principal, spender : Principal) -> async Nat;
        getMetadata : () -> async Metadata;
    };

    public type WithdrawErr = {
        #BalanceLow;
        #TransferFailure;
    };
    public type WithdrawReceipt = {
        #Ok : Nat;
        #Err : WithdrawErr;
    };
    public type DepositErr = {
        #BalanceLow;
        #TransferFailure;
    };
    public type DepositReceipt = {
        #Ok : Nat;
        #Err : DepositErr;
    };
    public type RepayPrincipalErr = {
        #BalanceLow;
        #TransferFailure;
    };
    public type RepayPrincipalReceipt = {
        #Ok : Nat;
        #Err : RepayPrincipalErr;
    };
    public type RepayInterestErr = {
        #BalanceLow;
        #TransferFailure;
    };
    public type RepayInterestReceipt = {
        #Ok : Nat;
        #Err : RepayInterestErr;
    };
    public type DrawdownErr = {
        #BalanceLow;
        #TransferFailure;
        #NotAuthorized;
    };
    public type DrawdownReceipt = {
        #Ok : Nat;
        #Err : DrawdownErr;
    };
    public type Balance = {
        owner : Principal;
        token : Token;
        amount : Nat;
    };

};
