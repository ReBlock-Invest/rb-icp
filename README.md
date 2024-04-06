# ReBlock Canister

## Canister Principal

- [Dummy USDC: o24ms-4yaaa-aaaal-ad7wq-cai](https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.icp0.io/?id=o24ms-4yaaa-aaaal-ad7wq-cai)
- [RB Pool: m3fyl-yqaaa-aaaal-ad73a-cai ](https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.icp0.io/?id=m3fyl-yqaaa-aaaal-ad73a-cai)

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
