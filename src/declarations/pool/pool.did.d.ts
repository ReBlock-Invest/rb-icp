import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface Account {
  'owner' : Principal,
  'subaccount' : [] | [Subaccount],
}
export interface Account__1 {
  'owner' : Principal,
  'subaccount' : [] | [Subaccount],
}
export interface AdvancedSettings {
  'permitted_drift' : Timestamp,
  'burned_tokens' : Balance,
  'transaction_window' : Timestamp,
}
export interface ArchivedTransaction {
  'callback' : QueryArchiveFn,
  'start' : TxIndex,
  'length' : bigint,
}
export type Balance = bigint;
export type Balance__1 = bigint;
export type BlockIndex = bigint;
export interface Burn {
  'from' : Account,
  'memo' : [] | [Uint8Array | number[]],
  'created_at_time' : [] | [bigint],
  'amount' : Balance,
}
export interface BurnArgs {
  'memo' : [] | [Uint8Array | number[]],
  'from_subaccount' : [] | [Subaccount],
  'created_at_time' : [] | [bigint],
  'amount' : Balance,
}
export type DepositErr = {
    'GenericError' : { 'message' : string, 'error_code' : bigint }
  } |
  { 'TemporarilyUnavailable' : null } |
  { 'InsufficientAllowance' : { 'allowance' : Tokens } } |
  { 'BadBurn' : { 'min_burn_amount' : Tokens } } |
  { 'Duplicate' : { 'duplicate_of' : BlockIndex } } |
  { 'TransferFailure' : null } |
  { 'FundriseTimeEnded' : null } |
  { 'BadFee' : { 'expected_fee' : Tokens } } |
  { 'CreatedInFuture' : { 'ledger_time' : bigint } } |
  { 'BalanceLow' : null } |
  { 'TooOld' : null } |
  { 'InsufficientFunds' : { 'balance' : Tokens } };
export type DepositReceipt = { 'Ok' : bigint } |
  { 'Err' : DepositErr };
export type DrawdownErr = {
    'GenericError' : { 'message' : string, 'error_code' : bigint }
  } |
  { 'BeforeOriginationDate' : null } |
  { 'InvalidDrawdown' : null } |
  { 'TemporarilyUnavailable' : null } |
  { 'BadBurn' : { 'min_burn_amount' : Tokens } } |
  { 'Duplicate' : { 'duplicate_of' : BlockIndex } } |
  { 'TransferFailure' : null } |
  { 'NotAuthorized' : null } |
  { 'BadFee' : { 'expected_fee' : Tokens } } |
  { 'CreatedInFuture' : { 'ledger_time' : bigint } } |
  { 'BalanceLow' : null } |
  { 'TooOld' : null } |
  { 'InsufficientFunds' : { 'balance' : Tokens } };
export type DrawdownReceipt = { 'Ok' : bigint } |
  { 'Err' : DrawdownErr };
export interface Fee {
  'fee' : bigint,
  'fee_basis_point' : bigint,
  'treasury' : Principal,
}
export interface Fee__1 {
  'fee' : bigint,
  'fee_basis_point' : bigint,
  'treasury' : Principal,
}
export interface GetTransactionsRequest { 'start' : TxIndex, 'length' : bigint }
export interface GetTransactionsRequest__1 {
  'start' : TxIndex,
  'length' : bigint,
}
export interface GetTransactionsResponse {
  'first_index' : TxIndex,
  'log_length' : bigint,
  'transactions' : Array<Transaction>,
  'archived_transactions' : Array<ArchivedTransaction>,
}
export interface InitPool {
  'fee' : Fee,
  'owner' : Principal,
  'loan' : Loan,
  'factory' : Principal,
  'token_args' : TokenInitArgs,
}
export interface Loan {
  'status' : [] | [LoanStatus],
  'asset' : Principal,
  'finder_fee' : bigint,
  'info' : LoanInfo,
  'total_loan_amount' : bigint,
  'maturity_date' : Time,
  'late_fee' : bigint,
  'interest_rate' : bigint,
  'interest_schedule' : Array<bigint>,
  'principal_schedule' : Array<bigint>,
  'index' : [] | [bigint],
  'fundrise_end_time' : Time,
  'origination_date' : Time,
  'principal_payment_deadline' : Array<Time>,
  'borrowers' : Array<Principal>,
  'interest_payment_deadline' : Array<Time>,
}
export interface LoanInfo {
  'apr' : string,
  'title' : string,
  'issuer_picture' : string,
  'payment_frequency' : string,
  'description' : string,
  'loan_term' : string,
  'issuer_description' : string,
  'secured_by' : string,
  'credit_rating' : string,
}
export type LoanStatus = { 'active' : null } |
  { 'approved' : null } |
  { 'rejected' : null };
export type MetaDatum = [string, Value];
export interface Mint {
  'to' : Account,
  'memo' : [] | [Uint8Array | number[]],
  'created_at_time' : [] | [bigint],
  'amount' : Balance,
}
export interface Mint__1 {
  'to' : Account,
  'memo' : [] | [Uint8Array | number[]],
  'created_at_time' : [] | [bigint],
  'amount' : Balance,
}
export interface Pool {
  'balance_of' : ActorMethod<[Principal], bigint>,
  'burn' : ActorMethod<[BurnArgs], TransferResult>,
  'convert_to_assets' : ActorMethod<[bigint], bigint>,
  'convert_to_shares' : ActorMethod<[bigint], bigint>,
  'deposit' : ActorMethod<[bigint], DepositReceipt>,
  'drawdown' : ActorMethod<[], DrawdownReceipt>,
  'fee_calc' : ActorMethod<[bigint], bigint>,
  'get_asset' : ActorMethod<[], Principal>,
  'get_borrower' : ActorMethod<[], Array<Principal>>,
  'get_decimal_offset' : ActorMethod<[], number>,
  'get_deposit_address' : ActorMethod<[], string>,
  'get_factory' : ActorMethod<[], Principal>,
  'get_fee' : ActorMethod<[], Fee__1>,
  'get_fee_asset' : ActorMethod<[], bigint>,
  'get_info' : ActorMethod<[], PoolRecord>,
  'get_outstanding_loan' : ActorMethod<[], bigint>,
  'get_owner' : ActorMethod<[], Principal>,
  'get_pool_transaction' : ActorMethod<[bigint], PoolTxRecord>,
  'get_pool_transactions' : ActorMethod<[bigint, bigint], Array<PoolTxRecord>>,
  'get_repayment_index' : ActorMethod<
    [],
    { 'total' : bigint, 'index' : bigint }
  >,
  'get_total_fund' : ActorMethod<[], bigint>,
  'get_transaction' : ActorMethod<[TxIndex__1], [] | [Transaction__1]>,
  'get_transactions' : ActorMethod<
    [GetTransactionsRequest],
    GetTransactionsResponse
  >,
  'get_user_transactons' : ActorMethod<
    [Principal, bigint, bigint],
    Array<PoolTxRecord>
  >,
  'history_size' : ActorMethod<[], bigint>,
  'icrc1_balance_of' : ActorMethod<[Account__1], Balance__1>,
  'icrc1_decimals' : ActorMethod<[], number>,
  'icrc1_fee' : ActorMethod<[], Balance__1>,
  'icrc1_metadata' : ActorMethod<[], Array<MetaDatum>>,
  'icrc1_minting_account' : ActorMethod<[], [] | [Account__1]>,
  'icrc1_name' : ActorMethod<[], string>,
  'icrc1_supported_standards' : ActorMethod<[], Array<SupportedStandard>>,
  'icrc1_symbol' : ActorMethod<[], string>,
  'icrc1_total_supply' : ActorMethod<[], Balance__1>,
  'icrc1_transfer' : ActorMethod<[TransferArgs], TransferResult>,
  'mint' : ActorMethod<[Mint], TransferResult>,
  'next_interest_repayment' : ActorMethod<[], bigint>,
  'next_interest_repayment_deadline' : ActorMethod<[], [] | [Time]>,
  'next_principal_repayment' : ActorMethod<[], bigint>,
  'next_principal_repayment_deadline' : ActorMethod<[], [] | [Time]>,
  'remove_borrower' : ActorMethod<[Principal], undefined>,
  'repay_interest' : ActorMethod<[], RepayInterestReceipt>,
  'repay_principal' : ActorMethod<[], RepayPrincipalReceipt>,
  'set_borrower' : ActorMethod<[Principal], undefined>,
  'set_decimal_offset' : ActorMethod<[number], number>,
  'set_factory' : ActorMethod<[Principal], Principal>,
  'set_fee' : ActorMethod<[Fee__1], Fee__1>,
  'set_fee_asset' : ActorMethod<[bigint], bigint>,
  'set_fundrise_end_time' : ActorMethod<[Time], Time>,
  'set_maturity_date' : ActorMethod<[Time], Time>,
  'set_origination_date' : ActorMethod<[Time], Time>,
  'transfer_ownership' : ActorMethod<[Principal], Principal>,
  'trigger_closed' : ActorMethod<[], PoolStatus>,
  'trigger_default' : ActorMethod<[], PoolStatus>,
  'withdraw' : ActorMethod<[bigint], WithdrawReceipt>,
}
export type PoolOperation = { 'withdraw' : null } |
  { 'init' : null } |
  { 'repayPrincipal' : null } |
  { 'deposit' : null } |
  { 'drawdown' : null } |
  { 'repayInterest' : null };
export interface PoolRecord {
  'id' : Principal,
  'apr' : string,
  'status' : PoolStatus__1,
  'title' : string,
  'issuer_picture' : string,
  'smart_contract_url' : string,
  'total_loan_amount' : bigint,
  'payment_frequency' : string,
  'description' : string,
  'maturity_date' : Time,
  'loan_term' : string,
  'issuer_description' : string,
  'timestamp' : Time,
  'secured_by' : string,
  'fundrise_end_time' : Time,
  'credit_rating' : string,
  'origination_date' : Time,
  'borrowers' : Array<Principal>,
}
export type PoolStatus = { 'closed' : null } |
  { 'active' : null } |
  { 'pending' : null } |
  { 'open' : null } |
  { 'default' : null };
export type PoolStatus__1 = { 'closed' : null } |
  { 'active' : null } |
  { 'pending' : null } |
  { 'open' : null } |
  { 'default' : null };
export interface PoolTxRecord {
  'op' : PoolOperation,
  'to' : Principal,
  'fee' : bigint,
  'status' : TxStatus,
  'from' : Principal,
  'timestamp' : Time,
  'caller' : [] | [Principal],
  'index' : bigint,
  'amount' : bigint,
}
export type QueryArchiveFn = ActorMethod<
  [GetTransactionsRequest__1],
  TransactionRange
>;
export type RepayInterestErr = {
    'GenericError' : { 'message' : string, 'error_code' : bigint }
  } |
  { 'TemporarilyUnavailable' : null } |
  { 'InsufficientAllowance' : { 'allowance' : Tokens } } |
  { 'BadBurn' : { 'min_burn_amount' : Tokens } } |
  { 'Duplicate' : { 'duplicate_of' : BlockIndex } } |
  { 'TransferFailure' : null } |
  { 'BadFee' : { 'expected_fee' : Tokens } } |
  { 'CreatedInFuture' : { 'ledger_time' : bigint } } |
  { 'BalanceLow' : null } |
  { 'TooOld' : null } |
  { 'ZeroAmountTransfer' : null } |
  { 'InsufficientFunds' : { 'balance' : Tokens } };
export type RepayInterestReceipt = { 'Ok' : bigint } |
  { 'Err' : RepayInterestErr };
export type RepayPrincipalErr = {
    'GenericError' : { 'message' : string, 'error_code' : bigint }
  } |
  { 'TemporarilyUnavailable' : null } |
  { 'InsufficientAllowance' : { 'allowance' : Tokens } } |
  { 'BadBurn' : { 'min_burn_amount' : Tokens } } |
  { 'Duplicate' : { 'duplicate_of' : BlockIndex } } |
  { 'TransferFailure' : null } |
  { 'BadFee' : { 'expected_fee' : Tokens } } |
  { 'CreatedInFuture' : { 'ledger_time' : bigint } } |
  { 'BalanceLow' : null } |
  { 'TooOld' : null } |
  { 'ZeroAmountTransfer' : null } |
  { 'InsufficientFunds' : { 'balance' : Tokens } };
export type RepayPrincipalReceipt = { 'Ok' : bigint } |
  { 'Err' : RepayPrincipalErr };
export type Subaccount = Uint8Array | number[];
export interface SupportedStandard { 'url' : string, 'name' : string }
export type Time = bigint;
export type Timestamp = bigint;
export interface TokenInitArgs {
  'fee' : Balance,
  'advanced_settings' : [] | [AdvancedSettings],
  'decimals' : number,
  'minting_account' : [] | [Account],
  'name' : string,
  'initial_balances' : Array<[Account, Balance]>,
  'min_burn_amount' : Balance,
  'max_supply' : Balance,
  'symbol' : string,
}
export type Tokens = bigint;
export interface Transaction {
  'burn' : [] | [Burn],
  'kind' : string,
  'mint' : [] | [Mint__1],
  'timestamp' : Timestamp,
  'index' : TxIndex,
  'transfer' : [] | [Transfer],
}
export interface TransactionRange { 'transactions' : Array<Transaction> }
export interface Transaction__1 {
  'burn' : [] | [Burn],
  'kind' : string,
  'mint' : [] | [Mint__1],
  'timestamp' : Timestamp,
  'index' : TxIndex,
  'transfer' : [] | [Transfer],
}
export interface Transfer {
  'to' : Account,
  'fee' : [] | [Balance],
  'from' : Account,
  'memo' : [] | [Uint8Array | number[]],
  'created_at_time' : [] | [bigint],
  'amount' : Balance,
}
export interface TransferArgs {
  'to' : Account,
  'fee' : [] | [Balance],
  'memo' : [] | [Uint8Array | number[]],
  'from_subaccount' : [] | [Subaccount],
  'created_at_time' : [] | [bigint],
  'amount' : Balance,
}
export type TransferError = {
    'GenericError' : { 'message' : string, 'error_code' : bigint }
  } |
  { 'TemporarilyUnavailable' : null } |
  { 'BadBurn' : { 'min_burn_amount' : Balance } } |
  { 'Duplicate' : { 'duplicate_of' : TxIndex } } |
  { 'BadFee' : { 'expected_fee' : Balance } } |
  { 'CreatedInFuture' : { 'ledger_time' : Timestamp } } |
  { 'TooOld' : null } |
  { 'InsufficientFunds' : { 'balance' : Balance } };
export type TransferResult = { 'Ok' : TxIndex } |
  { 'Err' : TransferError };
export type TxIndex = bigint;
export type TxIndex__1 = bigint;
export type TxStatus = { 'failed' : null } |
  { 'succeeded' : null };
export type Value = { 'Int' : bigint } |
  { 'Nat' : bigint } |
  { 'Blob' : Uint8Array | number[] } |
  { 'Text' : string };
export type WithdrawErr = {
    'GenericError' : { 'message' : string, 'error_code' : bigint }
  } |
  { 'TemporarilyUnavailable' : null } |
  { 'BadBurn' : { 'min_burn_amount' : Tokens } } |
  { 'Duplicate' : { 'duplicate_of' : BlockIndex } } |
  { 'TransferFailure' : null } |
  { 'WithdrawBeforeMaturityDate' : null } |
  { 'BadFee' : { 'expected_fee' : Tokens } } |
  { 'CreatedInFuture' : { 'ledger_time' : bigint } } |
  { 'BalanceLow' : null } |
  { 'TooOld' : null } |
  { 'InsufficientFunds' : { 'balance' : Tokens } };
export type WithdrawReceipt = { 'Ok' : bigint } |
  { 'Err' : WithdrawErr };
export interface _SERVICE extends Pool {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
