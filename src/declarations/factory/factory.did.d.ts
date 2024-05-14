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
  'back_loan' : ActorMethod<[PoolArgs], Principal>,
  'get_owner' : ActorMethod<[], Principal>,
  'get_pool_cycle' : ActorMethod<[], bigint>,
  'get_pools' : ActorMethod<[bigint, bigint], Array<PoolRecord>>,
  'propose_loan' : ActorMethod<[PoolArgs], undefined>,
  'remove_pool' : ActorMethod<[Principal], Array<PoolRecord>>,
  'set_pool_cycle' : ActorMethod<[bigint], bigint>,
  'transfer_ownership' : ActorMethod<[Principal], Principal>,
  'unback_loan' : ActorMethod<[Principal], Principal>,
}
export interface PoolArgs {
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
export interface PoolRecord {
  'id' : Principal,
  'apr' : string,
  'status' : PoolStatus,
  'title' : string,
  'issuer_picture' : string,
  'smart_contract_url' : string,
  'total_loan_amount' : string,
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
export type PoolStatus = { 'active' : null } |
  { 'upcoming' : null } |
  { 'pending' : null } |
  { 'inactive' : null } |
  { 'default' : null };
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
export interface _SERVICE extends Factory {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
