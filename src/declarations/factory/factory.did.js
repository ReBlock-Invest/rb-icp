export const idlFactory = ({ IDL }) => {
  const Time = IDL.Int;
  const PoolInfo = IDL.Record({
    'apr' : IDL.Text,
    'title' : IDL.Text,
    'issuer_picture' : IDL.Text,
    'smart_contract_url' : IDL.Text,
    'total_loan_amount' : IDL.Text,
    'payment_frequency' : IDL.Text,
    'description' : IDL.Text,
    'maturity_date' : Time,
    'loan_term' : IDL.Text,
    'issuer_description' : IDL.Text,
    'secured_by' : IDL.Text,
    'fundrise_end_time' : Time,
    'credit_rating' : IDL.Text,
    'origination_date' : Time,
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
  const PoolArgs = IDL.Record({
    'asset' : IDL.Principal,
    'info' : PoolInfo,
    'token_args' : TokenInitArgs,
    'borrowers' : IDL.Vec(IDL.Principal),
  });
  const PoolStatus = IDL.Variant({
    'active' : IDL.Null,
    'upcoming' : IDL.Null,
    'pending' : IDL.Null,
    'inactive' : IDL.Null,
    'default' : IDL.Null,
  });
  const PoolRecord = IDL.Record({
    'id' : IDL.Principal,
    'apr' : IDL.Text,
    'status' : PoolStatus,
    'title' : IDL.Text,
    'issuer_picture' : IDL.Text,
    'smart_contract_url' : IDL.Text,
    'total_loan_amount' : IDL.Text,
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
  const Factory = IDL.Service({
    'back_loan' : IDL.Func([PoolArgs], [IDL.Principal], []),
    'get_owner' : IDL.Func([], [IDL.Principal], ['query']),
    'get_pool_cycle' : IDL.Func([], [IDL.Nat], ['query']),
    'get_pools' : IDL.Func(
        [IDL.Nat, IDL.Nat],
        [IDL.Vec(PoolRecord)],
        ['query'],
      ),
    'propose_loan' : IDL.Func([PoolArgs], [], ['oneway']),
    'remove_pool' : IDL.Func([IDL.Principal], [IDL.Vec(PoolRecord)], []),
    'set_pool_cycle' : IDL.Func([IDL.Nat], [IDL.Nat], []),
    'transfer_ownership' : IDL.Func([IDL.Principal], [IDL.Principal], []),
    'unback_loan' : IDL.Func([IDL.Principal], [IDL.Principal], []),
  });
  return Factory;
};
export const init = ({ IDL }) => { return []; };
