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
export type DepositErr = { 'TransferFailure' : null } |
  { 'BalanceLow' : null };
export type DepositReceipt = { 'Ok' : bigint } |
  { 'Err' : DepositErr };
export type DrawdownErr = { 'TransferFailure' : null } |
  { 'NotAuthorized' : null } |
  { 'BalanceLow' : null };
export type DrawdownReceipt = { 'Ok' : bigint } |
  { 'Err' : DrawdownErr };
export interface FeeArgs {
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
  'drawdown' : ActorMethod<[bigint], DrawdownReceipt>,
  'fee_calc' : ActorMethod<[bigint], bigint>,
  'get_asset' : ActorMethod<[], Principal>,
  'get_borrower' : ActorMethod<[], Array<Principal>>,
  'get_decimal_offset' : ActorMethod<[], number>,
  'get_deposit_address' : ActorMethod<[], string>,
  'get_fee' : ActorMethod<[], FeeArgs>,
  'get_info' : ActorMethod<[], PoolInfo>,
  'get_pool_transaction' : ActorMethod<[bigint], PoolTxRecord>,
  'get_pool_transactions' : ActorMethod<[bigint, bigint], Array<PoolTxRecord>>,
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
  'remove_borrower' : ActorMethod<[Principal], undefined>,
  'repay_interest' : ActorMethod<[bigint], RepayInterestReceipt>,
  'repay_principal' : ActorMethod<[bigint], RepayPrincipalReceipt>,
  'set_borrower' : ActorMethod<[Principal], undefined>,
  'set_decimal_offset' : ActorMethod<[number], number>,
  'set_fee' : ActorMethod<[FeeArgs], FeeArgs>,
  'set_info' : ActorMethod<[PoolInfo], PoolInfo>,
  'withdraw' : ActorMethod<[bigint], WithdrawReceipt>,
}
export interface PoolArgs {
  'fee' : FeeArgs,
  'asset' : Principal,
  'info' : PoolInfo,
  'token_args' : TokenInitArgs,
  'borrowers' : Array<Principal>,
}
export interface PoolInfo {
  'apr' : string,
  'title' : string,
  'issuer_picture' : string,
  'smart_contract_url' : string,
  'total_loan_amount' : string,
  'payment_frequency' : string,
  'description' : string,
  'maturity_date' : Time,
  'loan_term' : string,
  'issuer_description' : string,
  'secured_by' : string,
  'fundrise_end_time' : Time,
  'credit_rating' : string,
  'origination_date' : Time,
}
export type PoolOperation = { 'withdraw' : null } |
  { 'init' : null } |
  { 'repayPrincipal' : null } |
  { 'deposit' : null } |
  { 'drawdown' : null } |
  { 'repayInterest' : null };
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
export type RepayInterestErr = { 'TransferFailure' : null } |
  { 'BalanceLow' : null };
export type RepayInterestReceipt = { 'Ok' : bigint } |
  { 'Err' : RepayInterestErr };
export type RepayPrincipalErr = { 'TransferFailure' : null } |
  { 'BalanceLow' : null };
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
export type WithdrawErr = { 'TransferFailure' : null } |
  { 'BalanceLow' : null };
export type WithdrawReceipt = { 'Ok' : bigint } |
  { 'Err' : WithdrawErr };
export interface _SERVICE extends Pool {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
