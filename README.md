# ReBlock Canister

## Canister Principal

- [Dummy USDC: o24ms-4yaaa-aaaal-ad7wq-cai](https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.icp0.io/?id=o24ms-4yaaa-aaaal-ad7wq-cai)
- [RB Pool: m3fyl-yqaaa-aaaal-ad73a-cai ](https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.icp0.io/?id=m3fyl-yqaaa-aaaal-ad73a-cai)
- [Pool Factory: rugve-6qaaa-aaaal-ajafq-cai ](https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.icp0.io/?id=rugve-6qaaa-aaaal-ajafq-cai)

## Total Supply (pool balance)

```bash
# target RB Pool canister
icrc1_total_supply()
```

## Check Borrower

```bash
# target RB Pool canister
get_borrower()
```

## LENDER deposit asset

```bash
# as a LENDER

# target Dummy USDC canister
approve([RB pool principal], amount)

# target RB Pool canister
deposit(amount)
```


## BORROWER drawdown asset

```bash
# as a BORROWER

# target RB Pool canister
drawdown(amount)
```


## BORROWER repay interest

```bash
# as a BORROWER

# target Dummy USDC canister
approve([RB pool principal], amount)

# target RB Pool canister
repay_interest(amount)
```

## BORROWER repay principal

```bash
# as a BORROWER

# target Dummy USDC canister
approve([RB pool principal], amount)

# target RB Pool canister
repay_principal(amount)
```

## LENDER withdraw asset
```bash
# as a LENDER

# target RB Pool canister
withdraw(amount)
```

# Transactions

## History Size

```bash
# target RB Pool canister
history_size()

# result
(5 : nat)

```

## Get Transactions

```bash
# target RB Pool canister
get_pool_transactions([start], [limit])


# result
(
  vec {
    record {
      op = variant { init };
      to = principal "x24eu-2jbtp-gqxjp-g7qeo-4bxy3-itz4h-4v7zw-gzva2-jm7oc-gac6g-7qe";
      fee = 0 : nat;
      status = variant { succeeded };
      from = principal "x24eu-2jbtp-gqxjp-g7qeo-4bxy3-itz4h-4v7zw-gzva2-jm7oc-gac6g-7qe";
      timestamp = 1_712_400_038_606_515_289 : int;
      caller = opt principal "x24eu-2jbtp-gqxjp-g7qeo-4bxy3-itz4h-4v7zw-gzva2-jm7oc-gac6g-7qe";
      index = 0 : nat;
      amount = 0 : nat;
    };
    record {
      op = variant { deposit };
      to = principal "bw4dl-smaaa-aaaaa-qaacq-cai";
      fee = 0 : nat;
      status = variant { succeeded };
      from = principal "swdh7-mgsq6-6x3kl-j22oa-hemcw-zbjds-xrc6s-4gbaw-u4kg3-7bsk5-vae";
      timestamp = 1_712_406_141_954_423_513 : int;
      caller = opt principal "swdh7-mgsq6-6x3kl-j22oa-hemcw-zbjds-xrc6s-4gbaw-u4kg3-7bsk5-vae";
      index = 1 : nat;
      amount = 1_000_000_000 : nat;
    };
    record {
      op = variant { drawdown };
      to = principal "qwnep-krhyp-dhcck-wkqco-etadf-wijbq-c6iat-bqr3a-tbzsp-hbywq-eae";
      fee = 0 : nat;
      status = variant { succeeded };
      from = principal "bw4dl-smaaa-aaaaa-qaacq-cai";
      timestamp = 1_712_406_752_341_203_296 : int;
      caller = opt principal "qwnep-krhyp-dhcck-wkqco-etadf-wijbq-c6iat-bqr3a-tbzsp-hbywq-eae";
      index = 2 : nat;
      amount = 1_000_000_000 : nat;
    };
    record {
      op = variant { repayPrincipal };
      to = principal "bw4dl-smaaa-aaaaa-qaacq-cai";
      fee = 0 : nat;
      status = variant { succeeded };
      from = principal "qwnep-krhyp-dhcck-wkqco-etadf-wijbq-c6iat-bqr3a-tbzsp-hbywq-eae";
      timestamp = 1_712_406_971_308_030_147 : int;
      caller = opt principal "qwnep-krhyp-dhcck-wkqco-etadf-wijbq-c6iat-bqr3a-tbzsp-hbywq-eae";
      index = 3 : nat;
      amount = 1_000_000_000 : nat;
    };
    record {
      op = variant { withdraw };
      to = principal "swdh7-mgsq6-6x3kl-j22oa-hemcw-zbjds-xrc6s-4gbaw-u4kg3-7bsk5-vae";
      fee = 0 : nat;
      status = variant { succeeded };
      from = principal "bw4dl-smaaa-aaaaa-qaacq-cai";
      timestamp = 1_712_407_017_891_755_134 : int;
      caller = opt principal "swdh7-mgsq6-6x3kl-j22oa-hemcw-zbjds-xrc6s-4gbaw-u4kg3-7bsk5-vae";
      index = 4 : nat;
      amount = 1_000_000_000 : nat;
    };
  },
)
```


## Get Transactions by User/principal

```bash
# target RB Pool canister
get_user_transactons([user principal], [start], [limit])


# result
(
  vec {
    record {
      op = variant { deposit };
      to = principal "bw4dl-smaaa-aaaaa-qaacq-cai";
      fee = 0 : nat;
      status = variant { succeeded };
      from = principal "swdh7-mgsq6-6x3kl-j22oa-hemcw-zbjds-xrc6s-4gbaw-u4kg3-7bsk5-vae";
      timestamp = 1_712_406_141_954_423_513 : int;
      caller = opt principal "swdh7-mgsq6-6x3kl-j22oa-hemcw-zbjds-xrc6s-4gbaw-u4kg3-7bsk5-vae";
      index = 1 : nat;
      amount = 1_000_000_000 : nat;
    };
    record {
      op = variant { withdraw };
      to = principal "swdh7-mgsq6-6x3kl-j22oa-hemcw-zbjds-xrc6s-4gbaw-u4kg3-7bsk5-vae";
      fee = 0 : nat;
      status = variant { succeeded };
      from = principal "bw4dl-smaaa-aaaaa-qaacq-cai";
      timestamp = 1_712_407_017_891_755_134 : int;
      caller = opt principal "swdh7-mgsq6-6x3kl-j22oa-hemcw-zbjds-xrc6s-4gbaw-u4kg3-7bsk5-vae";
      index = 4 : nat;
      amount = 1_000_000_000 : nat;
    };
  },
)
```

# Pool Factory

## Get Pools

```bash
# target RB factory canister
get_pools([start], [limit])

# result
(
  vec {
    record {
      id = principal "rbbej-7yaaa-aaaal-ajaga-cai";
      apr = "5.5%";
      status = variant { pending };
      title = "Retail Government Bonds (ORI)";
      issuer_picture = "https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Logo_kementerian_keuangan_republik_indonesia.png/120px-Logo_kementerian_keuangan_republik_indonesia.png";
      smart_contract_url = "https://i.ibb.co/XVMhZM2/reblock.jpg";
      total_loan_amount = "250,000.00";
      payment_frequency = "MONTHLY";
      description = "ORI is a retail investment instrument in the form of government bonds that can be traded on the secondary market. ORI also has a fixed coupon in the form of monthly yields paid to the investor who purchases it";
      borrower = principal "ezp3d-dn22j-wyyra-ctgbg-tly7k-khzap-lqbat-gimyf-2ckmf-6uzv7-wae";
      maturity_date = 1_000_000_000_000 : int;
      loan_term = "12 MONTHS";
      issuer_description = "Indonesia Ministry of Finance";
      timestamp = 1_713_785_557_115_973_080 : int;
      secured_by = "Indonesia Ministry of Finance";
      fundrise_end_time = 5_000_000_000 : int;
      credit_rating = "A";
      origination_date = 1_000_000_000 : int;
    };
  },
)
```

## Create Pool

```bash
# target RB factory canister
back_loan: (record {asset:principal; info:record {apr:text; title:text; issuer_picture:text; total_loan_amount:text; payment_frequency:text; description:text; maturity_date:int; loan_term:text; issuer_description:text; secured_by:text; fundrise_end_time:int; credit_rating:text; origination_date:int}; token_args:record {fee:nat; advanced_settings:opt record {permitted_drift:nat64; burned_tokens:nat; transaction_window:nat64}; decimals:nat8; minting_account:opt record {owner:principal; subaccount:opt vec nat8}; name:text; initial_balances:vec record {record {owner:principal; subaccount:opt vec nat8}; nat}; min_burn_amount:nat; max_supply:nat; symbol:text}; borrowers:vec principal}) → (principal) 

# result
(principal "xxx")
```

## Transfer Ownership

```bash
# target RB factory canister
transfer_ownership: (principal) → (principal) 

# result
(principal "xxx")
```

## Set Default Pool Cycle

```bash
# target RB factory canister
set_pool_cycle: (nat) → (nat) 

```