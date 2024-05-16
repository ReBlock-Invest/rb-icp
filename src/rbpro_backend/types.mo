import Time "mo:base/Time";
import ICRC1 "mo:icrc1/ICRC1";

module {

    public type Balance = {
        owner : Principal;
        token : Principal;
        amount : Nat;
    };

    public type PoolStatus = {
        #pending;
        #upcoming;
        #active;
        #default;
        #inactive;
    };

    public type Proposal = {
        borrowers : [Principal];
        apr : Text;
        credit_rating : Text;
        description : Text;
        fundrise_end_time : Time.Time;
        issuer_description : Text;
        issuer_picture : Text;
        loan_term : Text;
        maturity_date : Time.Time;
        origination_date : Time.Time;
        payment_frequency : Text;
        secured_by : Text;
        title : Text;
        total_loan_amount : Text;
    };

    public type ProposalRecord = {
        borrowers : [Principal];
        apr : Text;
        credit_rating : Text;
        description : Text;
        fundrise_end_time : Time.Time;
        issuer_description : Text;
        issuer_picture : Text;
        loan_term : Text;
        maturity_date : Time.Time;
        origination_date : Time.Time;
        payment_frequency : Text;
        secured_by : Text;
        title : Text;
        total_loan_amount : Text;
    };

    public type PoolInfo = {
        apr : Text;
        credit_rating : Text;
        description : Text;
        fundrise_end_time : Time.Time;
        issuer_description : Text;
        issuer_picture : Text;
        loan_term : Text;
        maturity_date : Time.Time;
        origination_date : Time.Time;
        payment_frequency : Text;
        secured_by : Text;
        smart_contract_url : Text;
        title : Text;
        total_loan_amount : Text;
    };

    public type PoolArgs = {
        info : PoolInfo;
        token_args : ICRC1.TokenInitArgs;
        borrowers : [Principal];
        asset : Principal;
        fee : FeeArgs;
    };

    public type FeeArgs = {
        treasury : Principal;
        fee_basis_point : Nat;
        fee : Nat;
    };

    public type AssetOperation = {
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

    public type TxStatus = {
        #succeeded;
        #failed;
    };

    public type PoolRecord = {
        id : Principal;
        borrowers : [Principal];
        apr : Text;
        credit_rating : Text;
        description : Text;
        fundrise_end_time : Time.Time;
        issuer_description : Text;
        issuer_picture : Text;
        loan_term : Text;
        maturity_date : Time.Time;
        origination_date : Time.Time;
        payment_frequency : Text;
        secured_by : Text;
        smart_contract_url : Text;
        title : Text;
        total_loan_amount : Text;
        timestamp : Time.Time;
        status : PoolStatus;
    };

    public type TxRecord = {
        caller : ?Principal;
        op : AssetOperation; // operation type
        index : Nat; // transaction index
        from : Principal;
        to : Principal;
        amount : Nat;
        fee : Nat;
        timestamp : Time.Time;
        status : TxStatus;
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
        status : TxStatus;
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
        balanceOf : (who : Principal) -> async Nat;
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
};
