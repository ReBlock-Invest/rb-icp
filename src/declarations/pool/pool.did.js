export const idlFactory = ({ IDL }) => {
  const Fee = IDL.Record({
    'fee' : IDL.Nat,
    'fee_basis_point' : IDL.Nat,
    'treasury' : IDL.Principal,
  });
  const LoanStatus = IDL.Variant({
    'active' : IDL.Null,
    'approved' : IDL.Null,
    'rejected' : IDL.Null,
  });
  const LoanInfo = IDL.Record({
    'apr' : IDL.Text,
    'title' : IDL.Text,
    'issuer_picture' : IDL.Text,
    'payment_frequency' : IDL.Text,
    'description' : IDL.Text,
    'loan_term' : IDL.Text,
    'issuer_description' : IDL.Text,
    'secured_by' : IDL.Text,
    'credit_rating' : IDL.Text,
  });
  const Time = IDL.Int;
  const Loan = IDL.Record({
    'status' : IDL.Opt(LoanStatus),
    'asset' : IDL.Principal,
    'finder_fee' : IDL.Nat,
    'info' : LoanInfo,
    'total_loan_amount' : IDL.Nat,
    'maturity_date' : Time,
    'late_fee' : IDL.Nat,
    'interest_rate' : IDL.Nat,
    'interest_schedule' : IDL.Vec(IDL.Nat),
    'principal_schedule' : IDL.Vec(IDL.Nat),
    'index' : IDL.Opt(IDL.Nat),
    'fundrise_end_time' : Time,
    'origination_date' : Time,
    'principal_payment_deadline' : IDL.Vec(Time),
    'borrowers' : IDL.Vec(IDL.Principal),
    'interest_payment_deadline' : IDL.Vec(Time),
  });
  const Balance = IDL.Nat;
  const Timestamp = IDL.Nat64;
  const AdvancedSettings = IDL.Record({
    'permitted_drift' : Timestamp,
    'burned_tokens' : Balance,
    'transaction_window' : Timestamp,
  });
  const Subaccount = IDL.Vec(IDL.Nat8);
  const Account = IDL.Record({
    'owner' : IDL.Principal,
    'subaccount' : IDL.Opt(Subaccount),
  });
  const TokenInitArgs = IDL.Record({
    'fee' : Balance,
    'advanced_settings' : IDL.Opt(AdvancedSettings),
    'decimals' : IDL.Nat8,
    'minting_account' : IDL.Opt(Account),
    'name' : IDL.Text,
    'initial_balances' : IDL.Vec(IDL.Tuple(Account, Balance)),
    'min_burn_amount' : Balance,
    'max_supply' : Balance,
    'symbol' : IDL.Text,
  });
  const InitPool = IDL.Record({
    'fee' : Fee,
    'loan' : Loan,
    'token_args' : TokenInitArgs,
  });
  const BurnArgs = IDL.Record({
    'memo' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'from_subaccount' : IDL.Opt(Subaccount),
    'created_at_time' : IDL.Opt(IDL.Nat64),
    'amount' : Balance,
  });
  const TxIndex = IDL.Nat;
  const TransferError = IDL.Variant({
    'GenericError' : IDL.Record({
      'message' : IDL.Text,
      'error_code' : IDL.Nat,
    }),
    'TemporarilyUnavailable' : IDL.Null,
    'BadBurn' : IDL.Record({ 'min_burn_amount' : Balance }),
    'Duplicate' : IDL.Record({ 'duplicate_of' : TxIndex }),
    'BadFee' : IDL.Record({ 'expected_fee' : Balance }),
    'CreatedInFuture' : IDL.Record({ 'ledger_time' : Timestamp }),
    'TooOld' : IDL.Null,
    'InsufficientFunds' : IDL.Record({ 'balance' : Balance }),
  });
  const TransferResult = IDL.Variant({ 'Ok' : TxIndex, 'Err' : TransferError });
  const DepositErr = IDL.Variant({
    'TransferFailure' : IDL.Null,
    'FundriseTimeEnded' : IDL.Null,
    'BalanceLow' : IDL.Null,
  });
  const DepositReceipt = IDL.Variant({ 'Ok' : IDL.Nat, 'Err' : DepositErr });
  const DrawdownErr = IDL.Variant({
    'BeforeOriginationDate' : IDL.Null,
    'TransferFailure' : IDL.Null,
    'NotAuthorized' : IDL.Null,
    'BalanceLow' : IDL.Null,
  });
  const DrawdownReceipt = IDL.Variant({ 'Ok' : IDL.Nat, 'Err' : DrawdownErr });
  const Fee__1 = IDL.Record({
    'fee' : IDL.Nat,
    'fee_basis_point' : IDL.Nat,
    'treasury' : IDL.Principal,
  });
  const PoolStatus = IDL.Variant({
    'closed' : IDL.Null,
    'active' : IDL.Null,
    'pending' : IDL.Null,
    'open' : IDL.Null,
    'default' : IDL.Null,
  });
  const PoolRecord = IDL.Record({
    'id' : IDL.Principal,
    'apr' : IDL.Text,
    'status' : PoolStatus,
    'title' : IDL.Text,
    'issuer_picture' : IDL.Text,
    'smart_contract_url' : IDL.Text,
    'total_loan_amount' : IDL.Nat,
    'payment_frequency' : IDL.Text,
    'description' : IDL.Text,
    'maturity_date' : Time,
    'loan_term' : IDL.Text,
    'issuer_description' : IDL.Text,
    'timestamp' : Time,
    'secured_by' : IDL.Text,
    'fundrise_end_time' : Time,
    'credit_rating' : IDL.Text,
    'origination_date' : Time,
    'borrowers' : IDL.Vec(IDL.Principal),
  });
  const PoolOperation = IDL.Variant({
    'withdraw' : IDL.Null,
    'init' : IDL.Null,
    'repayPrincipal' : IDL.Null,
    'deposit' : IDL.Null,
    'drawdown' : IDL.Null,
    'repayInterest' : IDL.Null,
  });
  const TxStatus = IDL.Variant({ 'failed' : IDL.Null, 'succeeded' : IDL.Null });
  const PoolTxRecord = IDL.Record({
    'op' : PoolOperation,
    'to' : IDL.Principal,
    'fee' : IDL.Nat,
    'status' : TxStatus,
    'from' : IDL.Principal,
    'timestamp' : Time,
    'caller' : IDL.Opt(IDL.Principal),
    'index' : IDL.Nat,
    'amount' : IDL.Nat,
  });
  const TxIndex__1 = IDL.Nat;
  const Burn = IDL.Record({
    'from' : Account,
    'memo' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'created_at_time' : IDL.Opt(IDL.Nat64),
    'amount' : Balance,
  });
  const Mint__1 = IDL.Record({
    'to' : Account,
    'memo' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'created_at_time' : IDL.Opt(IDL.Nat64),
    'amount' : Balance,
  });
  const Transfer = IDL.Record({
    'to' : Account,
    'fee' : IDL.Opt(Balance),
    'from' : Account,
    'memo' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'created_at_time' : IDL.Opt(IDL.Nat64),
    'amount' : Balance,
  });
  const Transaction__1 = IDL.Record({
    'burn' : IDL.Opt(Burn),
    'kind' : IDL.Text,
    'mint' : IDL.Opt(Mint__1),
    'timestamp' : Timestamp,
    'index' : TxIndex,
    'transfer' : IDL.Opt(Transfer),
  });
  const GetTransactionsRequest = IDL.Record({
    'start' : TxIndex,
    'length' : IDL.Nat,
  });
  const Transaction = IDL.Record({
    'burn' : IDL.Opt(Burn),
    'kind' : IDL.Text,
    'mint' : IDL.Opt(Mint__1),
    'timestamp' : Timestamp,
    'index' : TxIndex,
    'transfer' : IDL.Opt(Transfer),
  });
  const GetTransactionsRequest__1 = IDL.Record({
    'start' : TxIndex,
    'length' : IDL.Nat,
  });
  const TransactionRange = IDL.Record({
    'transactions' : IDL.Vec(Transaction),
  });
  const QueryArchiveFn = IDL.Func(
      [GetTransactionsRequest__1],
      [TransactionRange],
      ['query'],
    );
  const ArchivedTransaction = IDL.Record({
    'callback' : QueryArchiveFn,
    'start' : TxIndex,
    'length' : IDL.Nat,
  });
  const GetTransactionsResponse = IDL.Record({
    'first_index' : TxIndex,
    'log_length' : IDL.Nat,
    'transactions' : IDL.Vec(Transaction),
    'archived_transactions' : IDL.Vec(ArchivedTransaction),
  });
  const Account__1 = IDL.Record({
    'owner' : IDL.Principal,
    'subaccount' : IDL.Opt(Subaccount),
  });
  const Balance__1 = IDL.Nat;
  const Value = IDL.Variant({
    'Int' : IDL.Int,
    'Nat' : IDL.Nat,
    'Blob' : IDL.Vec(IDL.Nat8),
    'Text' : IDL.Text,
  });
  const MetaDatum = IDL.Tuple(IDL.Text, Value);
  const SupportedStandard = IDL.Record({ 'url' : IDL.Text, 'name' : IDL.Text });
  const TransferArgs = IDL.Record({
    'to' : Account,
    'fee' : IDL.Opt(Balance),
    'memo' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'from_subaccount' : IDL.Opt(Subaccount),
    'created_at_time' : IDL.Opt(IDL.Nat64),
    'amount' : Balance,
  });
  const Mint = IDL.Record({
    'to' : Account,
    'memo' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'created_at_time' : IDL.Opt(IDL.Nat64),
    'amount' : Balance,
  });
  const RepayInterestErr = IDL.Variant({
    'TransferFailure' : IDL.Null,
    'BalanceLow' : IDL.Null,
    'ZeroAmountTransfer' : IDL.Null,
  });
  const RepayInterestReceipt = IDL.Variant({
    'Ok' : IDL.Nat,
    'Err' : RepayInterestErr,
  });
  const RepayPrincipalErr = IDL.Variant({
    'TransferFailure' : IDL.Null,
    'BalanceLow' : IDL.Null,
    'ZeroAmountTransfer' : IDL.Null,
  });
  const RepayPrincipalReceipt = IDL.Variant({
    'Ok' : IDL.Nat,
    'Err' : RepayPrincipalErr,
  });
  const WithdrawErr = IDL.Variant({
    'TransferFailure' : IDL.Null,
    'WithdrawBeforeMaturityDate' : IDL.Null,
    'BalanceLow' : IDL.Null,
  });
  const WithdrawReceipt = IDL.Variant({ 'Ok' : IDL.Nat, 'Err' : WithdrawErr });
  const Pool = IDL.Service({
    'balance_of' : IDL.Func([IDL.Principal], [IDL.Nat], ['query']),
    'burn' : IDL.Func([BurnArgs], [TransferResult], []),
    'convert_to_assets' : IDL.Func([IDL.Nat], [IDL.Nat], []),
    'convert_to_shares' : IDL.Func([IDL.Nat], [IDL.Nat], []),
    'deposit' : IDL.Func([IDL.Nat], [DepositReceipt], []),
    'drawdown' : IDL.Func([], [DrawdownReceipt], []),
    'fee_calc' : IDL.Func([IDL.Nat], [IDL.Nat], []),
    'get_asset' : IDL.Func([], [IDL.Principal], ['query']),
    'get_borrower' : IDL.Func([], [IDL.Vec(IDL.Principal)], []),
    'get_decimal_offset' : IDL.Func([], [IDL.Nat8], []),
    'get_deposit_address' : IDL.Func([], [IDL.Text], []),
    'get_fee' : IDL.Func([], [Fee__1], ['query']),
    'get_info' : IDL.Func([], [PoolRecord], ['query']),
    'get_pool_transaction' : IDL.Func([IDL.Nat], [PoolTxRecord], ['query']),
    'get_pool_transactions' : IDL.Func(
        [IDL.Nat, IDL.Nat],
        [IDL.Vec(PoolTxRecord)],
        ['query'],
      ),
    'get_total_fund' : IDL.Func([], [IDL.Nat], ['query']),
    'get_transaction' : IDL.Func([TxIndex__1], [IDL.Opt(Transaction__1)], []),
    'get_transactions' : IDL.Func(
        [GetTransactionsRequest],
        [GetTransactionsResponse],
        ['query'],
      ),
    'get_user_transactons' : IDL.Func(
        [IDL.Principal, IDL.Nat, IDL.Nat],
        [IDL.Vec(PoolTxRecord)],
        ['query'],
      ),
    'history_size' : IDL.Func([], [IDL.Nat], ['query']),
    'icrc1_balance_of' : IDL.Func([Account__1], [Balance__1], ['query']),
    'icrc1_decimals' : IDL.Func([], [IDL.Nat8], ['query']),
    'icrc1_fee' : IDL.Func([], [Balance__1], ['query']),
    'icrc1_metadata' : IDL.Func([], [IDL.Vec(MetaDatum)], ['query']),
    'icrc1_minting_account' : IDL.Func([], [IDL.Opt(Account__1)], ['query']),
    'icrc1_name' : IDL.Func([], [IDL.Text], ['query']),
    'icrc1_supported_standards' : IDL.Func(
        [],
        [IDL.Vec(SupportedStandard)],
        ['query'],
      ),
    'icrc1_symbol' : IDL.Func([], [IDL.Text], ['query']),
    'icrc1_total_supply' : IDL.Func([], [Balance__1], ['query']),
    'icrc1_transfer' : IDL.Func([TransferArgs], [TransferResult], []),
    'mint' : IDL.Func([Mint], [TransferResult], []),
    'next_interest_repayment' : IDL.Func([], [IDL.Nat], []),
    'next_interest_repayment_deadline' : IDL.Func([], [IDL.Opt(Time)], []),
    'next_principal_repayment' : IDL.Func([], [IDL.Nat], []),
    'next_principal_repayment_deadline' : IDL.Func([], [IDL.Opt(Time)], []),
    'remove_borrower' : IDL.Func([IDL.Principal], [], ['oneway']),
    'repay_interest' : IDL.Func([], [RepayInterestReceipt], []),
    'repay_principal' : IDL.Func([], [RepayPrincipalReceipt], []),
    'set_borrower' : IDL.Func([IDL.Principal], [], ['oneway']),
    'set_decimal_offset' : IDL.Func([IDL.Nat8], [IDL.Nat8], []),
    'set_fee' : IDL.Func([Fee__1], [Fee__1], []),
    'withdraw' : IDL.Func([IDL.Nat], [WithdrawReceipt], []),
  });
  return Pool;
};
export const init = ({ IDL }) => {
  const Fee = IDL.Record({
    'fee' : IDL.Nat,
    'fee_basis_point' : IDL.Nat,
    'treasury' : IDL.Principal,
  });
  const LoanStatus = IDL.Variant({
    'active' : IDL.Null,
    'approved' : IDL.Null,
    'rejected' : IDL.Null,
  });
  const LoanInfo = IDL.Record({
    'apr' : IDL.Text,
    'title' : IDL.Text,
    'issuer_picture' : IDL.Text,
    'payment_frequency' : IDL.Text,
    'description' : IDL.Text,
    'loan_term' : IDL.Text,
    'issuer_description' : IDL.Text,
    'secured_by' : IDL.Text,
    'credit_rating' : IDL.Text,
  });
  const Time = IDL.Int;
  const Loan = IDL.Record({
    'status' : IDL.Opt(LoanStatus),
    'asset' : IDL.Principal,
    'finder_fee' : IDL.Nat,
    'info' : LoanInfo,
    'total_loan_amount' : IDL.Nat,
    'maturity_date' : Time,
    'late_fee' : IDL.Nat,
    'interest_rate' : IDL.Nat,
    'interest_schedule' : IDL.Vec(IDL.Nat),
    'principal_schedule' : IDL.Vec(IDL.Nat),
    'index' : IDL.Opt(IDL.Nat),
    'fundrise_end_time' : Time,
    'origination_date' : Time,
    'principal_payment_deadline' : IDL.Vec(Time),
    'borrowers' : IDL.Vec(IDL.Principal),
    'interest_payment_deadline' : IDL.Vec(Time),
  });
  const Balance = IDL.Nat;
  const Timestamp = IDL.Nat64;
  const AdvancedSettings = IDL.Record({
    'permitted_drift' : Timestamp,
    'burned_tokens' : Balance,
    'transaction_window' : Timestamp,
  });
  const Subaccount = IDL.Vec(IDL.Nat8);
  const Account = IDL.Record({
    'owner' : IDL.Principal,
    'subaccount' : IDL.Opt(Subaccount),
  });
  const TokenInitArgs = IDL.Record({
    'fee' : Balance,
    'advanced_settings' : IDL.Opt(AdvancedSettings),
    'decimals' : IDL.Nat8,
    'minting_account' : IDL.Opt(Account),
    'name' : IDL.Text,
    'initial_balances' : IDL.Vec(IDL.Tuple(Account, Balance)),
    'min_burn_amount' : Balance,
    'max_supply' : Balance,
    'symbol' : IDL.Text,
  });
  const InitPool = IDL.Record({
    'fee' : Fee,
    'loan' : Loan,
    'token_args' : TokenInitArgs,
  });
  return [InitPool];
};
