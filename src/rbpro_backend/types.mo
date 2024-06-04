import Time "mo:base/Time";
import ICRC1 "mo:icrc1/ICRC1";

module {

    public type Balance = {
        owner : Principal;
        token : Principal;
        amount : Nat;
    };

    public type Fee = {
        treasury : Principal;
        fee_basis_point : Nat;
        fee : Nat;
    };

    // ===== FACTORY ===== //

    public type InitFactory = {
        fee : Fee;
        pool_token_args : ICRC1.TokenInitArgs;
    };

    // ===== LOAN ===== //

    public type LoanStatus = {
        #active;
        #rejected;
        #approved;
    };

    public type Loan = {
        index : ?Nat;
        borrowers : [Principal];
        asset : Principal;
        total_loan_amount : Nat;
        principal_schedule : [Nat];
        interest_schedule : [Nat];
        principal_payment_deadline : [Time.Time];
        interest_payment_deadline : [Time.Time];
        interest_rate : Nat;
        finder_fee : Nat;
        late_fee : Nat;
        status : ?LoanStatus;
        fundrise_end_time : Time.Time;
        origination_date : Time.Time;
        maturity_date : Time.Time;
        info : LoanInfo;
    };

    public type LoanInfo = {
        title : Text;
        description : Text;
        issuer_description : Text;
        issuer_picture : Text;
        apr : Text;
        credit_rating : Text;
        loan_term : Text;
        payment_frequency : Text;
        secured_by : Text;
    };

    // ===== POOL ===== //

    public type PoolStatus = {
        #pending;
        #open;
        #active;
        #default;
        #closed;
    };

    public type Pool = {
        time_open : Time.Time;
        deposit_deadline : Time.Time;
        token_args : ICRC1.TokenInitArgs;
        status : ?PoolStatus;
    };

    public type InitPool = {
        loan : Loan;
        fee : Fee;
        token_args : ICRC1.TokenInitArgs;
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
        total_loan_amount : Nat;
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
        #WithdrawBeforeMaturityDate;
    };

    public type WithdrawReceipt = {
        #Ok : Nat;
        #Err : WithdrawErr;
    };

    public type DepositErr = {
        #BalanceLow;
        #TransferFailure;
        #FundriseTimeEnded;
    };

    public type DepositReceipt = {
        #Ok : Nat;
        #Err : DepositErr;
    };

    public type RepayPrincipalErr = {
        #BalanceLow;
        #TransferFailure;
        #ZeroAmountTransfer;
    };

    public type RepayPrincipalReceipt = {
        #Ok : Nat;
        #Err : RepayPrincipalErr;
    };

    public type RepayInterestErr = {
        #BalanceLow;
        #TransferFailure;
        #ZeroAmountTransfer;
    };

    public type RepayInterestReceipt = {
        #Ok : Nat;
        #Err : RepayInterestErr;
    };

    public type DrawdownErr = {
        #BalanceLow;
        #TransferFailure;
        #NotAuthorized;
        #BeforeOriginationDate;
    };

    public type DrawdownReceipt = {
        #Ok : Nat;
        #Err : DrawdownErr;
    };

    public type LoanValidationErr = {
        #InvalidPrincipalPaymentSchedule;
        #InvalidInterestPaymentSchedue;
        #InvalidTotalLoanAmount;
        #InvalidPrincipalPaymentDeadline;
        #InvalidInterestPaymentDeadline;
    };

    public type LoanValidation = {
        #Ok;
        #Err : LoanValidationErr;
    };

    public type ProposeLoanReceipt = {
        #Ok : Loan;
        #Err : LoanValidationErr;
    };
};
