export const idlFactory = ({ IDL }) => {
  const PoolStatus = IDL.Variant({
    'active' : IDL.Null,
    'upcoming' : IDL.Null,
    'pending' : IDL.Null,
    'inactive' : IDL.Null,
    'default' : IDL.Null,
  });
  const Time = IDL.Int;
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
    'borrower' : IDL.Principal,
    'maturity_date' : Time,
    'loan_term' : IDL.Text,
    'issuer_description' : IDL.Text,
    'timestamp' : Time,
    'secured_by' : IDL.Text,
    'fundrise_end_time' : Time,
    'credit_rating' : IDL.Text,
    'origination_date' : Time,
  });
  const PoolInfo = IDL.Record({
    'apr' : IDL.Text,
    'title' : IDL.Text,
    'issuer_picture' : IDL.Text,
    'smart_contract_url' : IDL.Text,
    'total_loan_amount' : IDL.Text,
    'payment_frequency' : IDL.Text,
    'description' : IDL.Text,
    'borrower' : IDL.Principal,
    'maturity_date' : Time,
    'loan_term' : IDL.Text,
    'issuer_description' : IDL.Text,
    'secured_by' : IDL.Text,
    'fundrise_end_time' : Time,
    'credit_rating' : IDL.Text,
    'origination_date' : Time,
  });
  return IDL.Service({
    'get_pools' : IDL.Func(
        [IDL.Nat, IDL.Nat],
        [IDL.Vec(PoolRecord)],
        ['query'],
      ),
    'proposePool' : IDL.Func([PoolInfo], [IDL.Principal], []),
  });
};
export const init = ({ IDL }) => { return []; };
