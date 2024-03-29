#!/bin/bash

```bash
cd src/DIP20/
#remove old content
dfx stop
rm -rf .dfx
#create canisters
dfx canister --no-wallet create --all
# create principal idea that is inital owner of tokens
ROOT_HOME=$(mktemp -d)  
ROOT_PUBLIC_KEY="principal \"$(HOME=$ROOT_HOME dfx identity get-principal)\""
#build token canister
dfx build
# deploy token
dfx canister install dummy_usdc --argument="(\"https://seeklogo.com/images/U/usd-coin-usdc-logo-CB4C5B1C51-seeklogo.com.png\", \"Dummy USDC\", \"DUSDC\", 8, 10000000000000000, principal \"x24eu-2jbtp-gqxjp-g7qeo-4bxy3-itz4h-4v7zw-gzva2-jm7oc-gac6g-7qe\", 10000)"

# set fee structure. Need Home prefix since this is location of our identity
HOME=$ROOT_HOME  dfx canister  call DIP20 setFeeTo "($ROOT_PUBLIC_KEY)"
#deflationary
HOME=$ROOT_HOME dfx canister  call DIP20 setFee "(420)" 
# get balance. Congrats you are rich
HOME=$ROOT_HOME dfx canister --no-wallet call DIP20 balanceOf "($ROOT_PUBLIC_KEY)"
``` 

dfx canister call dummy_usdc balanceOf "principal \"6cgi3-xxb7q-44fnk-zbipl-lseh5-u3eza-lab5h-adsdu-5fzrr-2ripn-rae\""

dfx canister call dummy_usdc transfer "(principal \"pgnkx-ni6qy-vo72n-ubskw-pt4pi-7ftdk-np5wv-zsbnn-fey4m-7tnmq-2ae\", 5_000_000_000_000_000)"
dfx canister call dummy_usdc transfer "(principal \"swdh7-mgsq6-6x3kl-j22oa-hemcw-zbjds-xrc6s-4gbaw-u4kg3-7bsk5-vae\", 5_000_000_000_000)"
dfx canister call dummy_usdc transfer "(principal \"6cgi3-xxb7q-44fnk-zbipl-lseh5-u3eza-lab5h-adsdu-5fzrr-2ripn-rae\", 100_000_000_000)"

dfx canister status --network ic --wallet o55kg-raaaa-aaaal-ad7wa-cai

# deploy wallet
dfx ledger create-canister x24eu-2jbtp-gqxjp-g7qeo-4bxy3-itz4h-4v7zw-gzva2-jm7oc-gac6g-7qe --amount 0.25 --network ic
dfx identity --network ic deploy-wallet o55kg-raaaa-aaaal-ad7wa-cai


dfx deploy rbpro_backend --argument '(record { name = "ReBlock Token Pool"; symbol = "RBX"; decimals = 8; fee = 1_000_000; max_supply = 1_000_000_000_000_000_000; initial_balances = vec {}; min_burn_amount = 0; }, principal "qwnep-krhyp-dhcck-wkqco-etadf-wijbq-c6iat-bqr3a-tbzsp-hbywq-eae", principal "be2us-64aaa-aaaaa-qaabq-cai")'

# borrower = qwnep-krhyp-dhcck-wkqco-etadf-wijbq-c6iat-bqr3a-tbzsp-hbywq-eae
# lender = swdh7-mgsq6-6x3kl-j22oa-hemcw-zbjds-xrc6s-4gbaw-u4kg3-7bsk5-vae
# messi = fcqo5-se6eb-qgbif-pbgvf-fux7c-zceqw-gyhbo-55w26-2a6io-oiy6o-4ae

# deposit USDC from lender
dfx canister call dummy_usdc approve "(principal \"bw4dl-smaaa-aaaaa-qaacq-cai\", 1_000_000_000)"
dfx canister call rbpro_backend deposit "(900_000_000)"

dfx canister call rbpro_backend icrc1_balance_of '(record { owner = principal "fcqo5-se6eb-qgbif-pbgvf-fux7c-zceqw-gyhbo-55w26-2a6io-oiy6o-4ae"; subaccount = null })'
dfx canister call dummy_usdc balanceOf 'principal "bw4dl-smaaa-aaaaa-qaacq-cai"'

# drawdown USDC from borrower
dfx canister call rbpro_backend drawdown "(900_000_000)"
dfx canister call dummy_usdc balanceOf 'principal "qwnep-krhyp-dhcck-wkqco-etadf-wijbq-c6iat-bqr3a-tbzsp-hbywq-eae"'

# repayment USDC from borrower
dfx canister call dummy_usdc approve "(principal \"bw4dl-smaaa-aaaaa-qaacq-cai\", 100_010_000)"
dfx canister call rbpro_backend repay_interest "(100_010_000)"
dfx canister call dummy_usdc approve "(principal \"bw4dl-smaaa-aaaaa-qaacq-cai\", 500_010_000)"
dfx canister call rbpro_backend repay_principal "(500_010_000)"
dfx canister call dummy_usdc balanceOf 'principal "qwnep-krhyp-dhcck-wkqco-etadf-wijbq-c6iat-bqr3a-tbzsp-hbywq-eae"'

dfx canister call dummy_usdc balanceOf 'principal "bw4dl-smaaa-aaaaa-qaacq-cai"'

# withdraw USDC from lender
dfx canister call rbpro_backend withdraw "(100_010_000)"
dfx canister call dummy_usdc balanceOf 'principal "swdh7-mgsq6-6x3kl-j22oa-hemcw-zbjds-xrc6s-4gbaw-u4kg3-7bsk5-vae"'


# update setting
dfx canister call dummy_usdc setFee "(0)"

dfx canister call rbpro_backend set_borrower '(principal "j6opj-lgtdp-xyqfx-uqclw-25kr2-kg3ku-cdwbq-vqlxy-qvfk6-532rn-4ae")'