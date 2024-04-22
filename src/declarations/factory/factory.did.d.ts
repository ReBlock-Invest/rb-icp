import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface PoolInfo {
  'apr' : string,
  'title' : string,
  'issuer_picture' : string,
  'smart_contract_url' : string,
  'total_loan_amount' : string,
  'payment_frequency' : string,
  'description' : string,
  'borrower' : Principal,
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
  'borrower' : Principal,
  'maturity_date' : Time,
  'loan_term' : string,
  'issuer_description' : string,
  'timestamp' : Time,
  'secured_by' : string,
  'fundrise_end_time' : Time,
  'credit_rating' : string,
  'origination_date' : Time,
}
export type PoolStatus = { 'active' : null } |
  { 'upcoming' : null } |
  { 'pending' : null } |
  { 'inactive' : null } |
  { 'default' : null };
export type Time = bigint;
export interface _SERVICE {
  'get_pools' : ActorMethod<[bigint, bigint], Array<PoolRecord>>,
  'proposePool' : ActorMethod<[PoolInfo], Principal>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
