
controller = x24eu-2jbtp-gqxjp-g7qeo-4bxy3-itz4h-4v7zw-gzva2-jm7oc-gac6g-7qe
borrower = qwnep-krhyp-dhcck-wkqco-etadf-wijbq-c6iat-bqr3a-tbzsp-hbywq-eae
lender = swdh7-mgsq6-6x3kl-j22oa-hemcw-zbjds-xrc6s-4gbaw-u4kg3-7bsk5-vae

rb_pool = m3fyl-yqaaa-aaaal-ad73a-cai
usdc = o24ms-4yaaa-aaaal-ad7wq-cai

dfx canister call dummy_usdc transfer "(principal \"swdh7-mgsq6-6x3kl-j22oa-hemcw-zbjds-xrc6s-4gbaw-u4kg3-7bsk5-vae\", 10_000_000_000)" --network ic

# USDC balance
dfx canister call dummy_usdc balanceOf 'principal "x24eu-2jbtp-gqxjp-g7qeo-4bxy3-itz4h-4v7zw-gzva2-jm7oc-gac6g-7qe"' --network ic 
dfx canister call dummy_usdc balanceOf 'principal "qwnep-krhyp-dhcck-wkqco-etadf-wijbq-c6iat-bqr3a-tbzsp-hbywq-eae"' --network ic 
dfx canister call dummy_usdc balanceOf 'principal "swdh7-mgsq6-6x3kl-j22oa-hemcw-zbjds-xrc6s-4gbaw-u4kg3-7bsk5-vae"' --network ic 
dfx canister call dummy_usdc balanceOf 'principal "m3fyl-yqaaa-aaaal-ad73a-cai"' --network ic 

# pool token balance
dfx canister call rbpro_backend icrc1_balance_of '(record { owner = principal "swdh7-mgsq6-6x3kl-j22oa-hemcw-zbjds-xrc6s-4gbaw-u4kg3-7bsk5-vae"; subaccount = null })' --network ic

# pool settings
dfx canister call rbpro_backend set_borrower '(principal "j6opj-lgtdp-xyqfx-uqclw-25kr2-kg3ku-cdwbq-vqlxy-qvfk6-532rn-4ae")' --network ic
dfx canister call rbpro_backend get_borrower '()' --network ic

dfx canister call rbpro_backend set_currency '(principal "o24ms-4yaaa-aaaal-ad7wq-cai")' --network ic
dfx canister call rbpro_backend get_currency '()' --network ic

# op1: LENDER deposit usdc to pool 
dfx canister call dummy_usdc approve "(principal \"m3fyl-yqaaa-aaaal-ad73a-cai\", 10_000_000_000)" --network ic
dfx canister call rbpro_backend deposit "(10_000_000_000)" --network ic

# op2: BORROWER drawdown usdc from pool 
dfx canister call rbpro_backend drawdown "(10_000_000_000)" --network ic

# op3: BORROWER repay interest to pool 
dfx canister call dummy_usdc approve "(principal \"m3fyl-yqaaa-aaaal-ad73a-cai\", 1_000_000_000)" -network ic
dfx canister call rbpro_backend repay_interest "(1_000_000_000)" --network ic

# op4: BORROWER repay principal to pool 
dfx canister call dummy_usdc approve "(principal \"m3fyl-yqaaa-aaaal-ad73a-cai\", 9_000_000_000)" -network ic
dfx canister call rbpro_backend repay_interest "(9_000_000_000)" -network ic

# op5: LENDER withdraw usdc from pool 
dfx canister call rbpro_backend withdraw "(10_000_000_000)" -network ic