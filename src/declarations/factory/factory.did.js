export const idlFactory = ({ IDL }) => {
  const Fee = IDL.Record({
    'fee' : IDL.Nat,
    'fee_basis_point' : IDL.Nat,
    'treasury' : IDL.Principal,
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
  const InitFactory = IDL.Record({
    'fee' : Fee,
    'pool_token_args' : TokenInitArgs,
  });
  const Fee__1 = IDL.Record({
    'fee' : IDL.Nat,
    'fee_basis_point' : IDL.Nat,
    'treasury' : IDL.Principal,
  });
  const TokenInitArgs__1 = IDL.Record({
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
  const LoanStatus__1 = IDL.Variant({
    'active' : IDL.Null,
    'approved' : IDL.Null,
    'rejected' : IDL.Null,
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
  const PoolStatus = IDL.Variant({
    'closed' : IDL.Null,
    'active' : IDL.Null,
    'pending' : IDL.Null,
    'open' : IDL.Null,
    'default' : IDL.Null,
  });
  const PoolStatus__1 = IDL.Variant({
    'closed' : IDL.Null,
    'active' : IDL.Null,
    'pending' : IDL.Null,
    'open' : IDL.Null,
    'default' : IDL.Null,
  });
  const PoolRecord = IDL.Record({
    'id' : IDL.Principal,
    'apr' : IDL.Text,
    'status' : PoolStatus__1,
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
  const Loan__1 = IDL.Record({
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
  const LoanValidationErr = IDL.Variant({
    'InvalidInterestPaymentDeadline' : IDL.Null,
    'InvalidPrincipalPaymentDeadline' : IDL.Null,
    'InvalidTotalLoanAmount' : IDL.Null,
    'InvalidPrincipalPaymentSchedule' : IDL.Null,
    'InvalidInterestPaymentSchedue' : IDL.Null,
  });
  const ProposeLoanReceipt = IDL.Variant({
    'Ok' : Loan__1,
    'Err' : LoanValidationErr,
  });
  const Factory = IDL.Service({
    'back_loan' : IDL.Func([IDL.Nat], [IDL.Principal], []),
    'get_default_fee' : IDL.Func([], [Fee__1], ['query']),
    'get_default_pool_token_args' : IDL.Func([], [TokenInitArgs__1], ['query']),
    'get_loans' : IDL.Func(
        [LoanStatus__1, IDL.Nat, IDL.Nat],
        [IDL.Vec(Loan)],
        ['query'],
      ),
    'get_owner' : IDL.Func([], [IDL.Principal], ['query']),
    'get_pool_cycle' : IDL.Func([], [IDL.Nat], ['query']),
    'get_pools' : IDL.Func(
        [PoolStatus, IDL.Nat, IDL.Nat],
        [IDL.Vec(PoolRecord)],
        ['query'],
      ),
    'propose_loan' : IDL.Func([Loan], [ProposeLoanReceipt], []),
    'reject_loan' : IDL.Func([IDL.Nat], [IDL.Opt(Loan)], []),
    'set_default_fee' : IDL.Func([Fee__1], [Fee__1], []),
    'set_default_pool_token_args' : IDL.Func(
        [TokenInitArgs__1],
        [TokenInitArgs__1],
        [],
      ),
    'set_pool_cycle' : IDL.Func([IDL.Nat], [IDL.Nat], []),
    'transfer_ownership' : IDL.Func([IDL.Principal], [IDL.Principal], []),
  });
  return Factory;
};
export const init = ({ IDL }) => {
  const Fee = IDL.Record({
    'fee' : IDL.Nat,
    'fee_basis_point' : IDL.Nat,
    'treasury' : IDL.Principal,
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
  const InitFactory = IDL.Record({
    'fee' : Fee,
    'pool_token_args' : TokenInitArgs,
  });
  return [InitFactory];
};
