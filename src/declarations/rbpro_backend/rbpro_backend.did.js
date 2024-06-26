export const idlFactory = ({ IDL }) => {
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
    'BalanceLow' : IDL.Null,
  });
  const DepositReceipt = IDL.Variant({ 'Ok' : IDL.Nat, 'Err' : DepositErr });
  const DrawdownErr = IDL.Variant({
    'TransferFailure' : IDL.Null,
    'NotAuthorized' : IDL.Null,
    'BalanceLow' : IDL.Null,
  });
  const DrawdownReceipt = IDL.Variant({ 'Ok' : IDL.Nat, 'Err' : DrawdownErr });
  const PoolOperation = IDL.Variant({
    'withdraw' : IDL.Null,
    'init' : IDL.Null,
    'repayPrincipal' : IDL.Null,
    'deposit' : IDL.Null,
    'drawdown' : IDL.Null,
    'repayInterest' : IDL.Null,
  });
  const TransactionStatus = IDL.Variant({
    'failed' : IDL.Null,
    'succeeded' : IDL.Null,
  });
  const Time = IDL.Int;
  const PoolTxRecord = IDL.Record({
    'op' : PoolOperation,
    'to' : IDL.Principal,
    'fee' : IDL.Nat,
    'status' : TransactionStatus,
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
  });
  const RepayInterestReceipt = IDL.Variant({
    'Ok' : IDL.Nat,
    'Err' : RepayInterestErr,
  });
  const RepayPrincipalErr = IDL.Variant({
    'TransferFailure' : IDL.Null,
    'BalanceLow' : IDL.Null,
  });
  const RepayPrincipalReceipt = IDL.Variant({
    'Ok' : IDL.Nat,
    'Err' : RepayPrincipalErr,
  });
  const WithdrawErr = IDL.Variant({
    'TransferFailure' : IDL.Null,
    'BalanceLow' : IDL.Null,
  });
  const WithdrawReceipt = IDL.Variant({ 'Ok' : IDL.Nat, 'Err' : WithdrawErr });
  const Token = IDL.Service({
    'burn' : IDL.Func([BurnArgs], [TransferResult], []),
    'deposit' : IDL.Func([IDL.Nat], [DepositReceipt], []),
    'deposit_cycles' : IDL.Func([], [], []),
    'drawdown' : IDL.Func([IDL.Nat], [DrawdownReceipt], []),
    'get_borrower' : IDL.Func([], [IDL.Principal], []),
    'get_currency' : IDL.Func([], [IDL.Principal], []),
    'get_deposit_address' : IDL.Func([], [IDL.Text], []),
    'get_pool_transaction' : IDL.Func([IDL.Nat], [PoolTxRecord], ['query']),
    'get_pool_transactions' : IDL.Func(
        [IDL.Nat, IDL.Nat],
        [IDL.Vec(PoolTxRecord)],
        ['query'],
      ),
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
    'repay_interest' : IDL.Func([IDL.Nat], [RepayInterestReceipt], []),
    'repay_principal' : IDL.Func([IDL.Nat], [RepayPrincipalReceipt], []),
    'set_borrower' : IDL.Func([IDL.Principal], [], ['oneway']),
    'set_currency' : IDL.Func([IDL.Principal], [], ['oneway']),
    'withdraw' : IDL.Func([IDL.Nat], [WithdrawReceipt], []),
  });
  return Token;
};
export const init = ({ IDL }) => {
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
  return [TokenInitArgs, IDL.Principal, IDL.Principal];
};
