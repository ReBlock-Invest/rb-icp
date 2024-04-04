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
