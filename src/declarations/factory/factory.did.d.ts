import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface Account {
  'owner' : Principal,
  'subaccount' : [] | [Subaccount],
}
export interface AdvancedSettings {
  'permitted_drift' : Timestamp,
  'burned_tokens' : Balance,
  'transaction_window' : Timestamp,
}
export type Balance = bigint;
export interface Factory {
  'back_loan' : ActorMethod<[bigint], Principal>,
  'get_default_fee' : ActorMethod<[], Fee__1>,
  'get_default_pool_token_args' : ActorMethod<[], TokenInitArgs__1>,
  'get_loans' : ActorMethod<
    [[] | [LoanStatus__1], bigint, bigint],
    Array<Loan>
  >,
  'get_owner' : ActorMethod<[], Principal>,
  'get_pool_cycle' : ActorMethod<[], bigint>,
  'get_pools' : ActorMethod<
    [[] | [PoolStatus], bigint, bigint],
    Array<PoolRecord>
  >,
  'propose_loan' : ActorMethod<[Loan], ProposeLoanReceipt>,
  'reject_loan' : ActorMethod<[bigint], [] | [Loan]>,
  'set_default_fee' : ActorMethod<[Fee__1], Fee__1>,
  'set_default_pool_token_args' : ActorMethod<
    [TokenInitArgs__1],
    TokenInitArgs__1
  >,
  'set_pool_cycle' : ActorMethod<[bigint], bigint>,
  'transfer_ownership' : ActorMethod<[Principal], Principal>,
}
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
export interface InitFactory { 'fee' : Fee, 'pool_token_args' : TokenInitArgs }
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
export type LoanStatus__1 = { 'active' : null } |
  { 'approved' : null } |
  { 'rejected' : null };
export type LoanValidationErr = { 'InvalidInterestPaymentDeadline' : null } |
  { 'InvalidPrincipalPaymentDeadline' : null } |
  { 'InvalidTotalLoanAmount' : null } |
  { 'InvalidPrincipalPaymentSchedule' : null } |
  { 'InvalidInterestPaymentSchedue' : null };
export interface Loan__1 {
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
export type ProposeLoanReceipt = { 'Ok' : Loan__1 } |
  { 'Err' : LoanValidationErr };
export type Subaccount = Uint8Array | number[];
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
export interface TokenInitArgs__1 {
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
export interface _SERVICE extends Factory {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
