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

dfx canister install dummy_usdc --argument="(\"https://i.ibb.co/XVMhZM2/reblock.jpg\", \"Dummy USDC\", \"DUSDC\", 8, 10000000000000000, principal \"x24eu-2jbtp-gqxjp-g7qeo-4bxy3-itz4h-4v7zw-gzva2-jm7oc-gac6g-7qe\", 10000)"

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
dfx canister call dummy_usdc transfer "(principal \"ezp3d-dn22j-wyyra-ctgbg-tly7k-khzap-lqbat-gimyf-2ckmf-6uzv7-wae\", 100_000_000_000)" --network ic

dfx canister call rbt_token transfer "(principal \"6cgi3-xxb7q-44fnk-zbipl-lseh5-u3eza-lab5h-adsdu-5fzrr-2ripn-rae\", 10_000_000_000_000_000_000)"

dfx canister call rbt_token balanceOf "principal \"x24eu-2jbtp-gqxjp-g7qeo-4bxy3-itz4h-4v7zw-gzva2-jm7oc-gac6g-7qe\"" --network ic

dfx canister status --network ic --wallet o55kg-raaaa-aaaal-ad7wa-cai

# deploy wallet
dfx ledger create-canister x24eu-2jbtp-gqxjp-g7qeo-4bxy3-itz4h-4v7zw-gzva2-jm7oc-gac6g-7qe --amount 0.25 --network ic
dfx identity --network ic deploy-wallet o55kg-raaaa-aaaal-ad7wa-cai


dfx deploy rbpro_backend --argument '(record { name = "ReBlock Token Pool"; symbol = "RBX"; decimals = 8; fee = 0; max_supply = 1_000_000_000_000_000_000; initial_balances = vec {}; min_burn_amount = 0; }, principal "qwnep-krhyp-dhcck-wkqco-etadf-wijbq-c6iat-bqr3a-tbzsp-hbywq-eae", principal "be2us-64aaa-aaaaa-qaabq-cai")'

# borrower = qwnep-krhyp-dhcck-wkqco-etadf-wijbq-c6iat-bqr3a-tbzsp-hbywq-eae
# lender = swdh7-mgsq6-6x3kl-j22oa-hemcw-zbjds-xrc6s-4gbaw-u4kg3-7bsk5-vae
# messi = fcqo5-se6eb-qgbif-pbgvf-fux7c-zceqw-gyhbo-55w26-2a6io-oiy6o-4ae

# deposit USDC from lender
dfx canister call dummy_usdc approve "(principal \"aovwi-4maaa-aaaaa-qaagq-cai\", 1_000_000_000)"
dfx canister call pool deposit "(1_000_000_000)"

dfx canister call pool icrc1_balance_of '(record { owner = principal "x24eu-2jbtp-gqxjp-g7qeo-4bxy3-itz4h-4v7zw-gzva2-jm7oc-gac6g-7qe"; subaccount = null })'
dfx canister call dummy_usdc balanceOf 'principal "aovwi-4maaa-aaaaa-qaagq-cai"'

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

dfx canister call rbpro_backend set_borrower '(principal "ezp3d-dn22j-wyyra-ctgbg-tly7k-khzap-lqbat-gimyf-2ckmf-6uzv7-wae")' --network ic

# get transactions
dfx canister call rbpro_backend get_pool_transactions "(0,5)"


# propose pool

dfx canister call factory get_pools "(0,5)"

dfx canister call factory proposePool '(record {apr = "5.5%"; title = "Retail Government Bonds (ORI)"; issuer_picture = "https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Logo_kementerian_keuangan_republik_indonesia.png/120px-Logo_kementerian_keuangan_republik_indonesia.png"; smart_contract_url = "https://i.ibb.co/XVMhZM2/reblock.jpg"; total_loan_amount = "250,000.00"; payment_frequency = "MONTHLY"; description = "ORI is a retail investment instrument in the form of government bonds that can be traded on the secondary market. ORI also has a fixed coupon in the form of monthly yields paid to the investor who purchases it"; borrower = principal "ezp3d-dn22j-wyyra-ctgbg-tly7k-khzap-lqbat-gimyf-2ckmf-6uzv7-wae"; maturity_date = 1000000000000; loan_term = "12 MONTHS"; issuer_description = "Indonesia Ministry of Finance"; secured_by = "Indonesia Ministry of Finance"; fundrise_end_time = 5000000000; credit_rating = "A"; origination_date = 1000000000})' --network ic


dfx deploy icrc1_ledger_canister --argument "(variant {Init = record {token_symbol = \"RBT\"; token_name = \"ReBlock Token\";minting_account = record { owner = principal \"x24eu-2jbtp-gqxjp-g7qeo-4bxy3-itz4h-4v7zw-gzva2-jm7oc-gac6g-7qe\" };transfer_fee = 10_000;metadata = vec {};feature_flags = opt record{icrc2 = true};initial_balances = vec { record { record { owner = principal \"x24eu-2jbtp-gqxjp-g7qeo-4bxy3-itz4h-4v7zw-gzva2-jm7oc-gac6g-7qe\"; }; 100_000_000; }; };archive_options = record {num_blocks_to_archive = 1000;trigger_threshold = 2000;controller_id = principal \"x24eu-2jbtp-gqxjp-g7qeo-4bxy3-itz4h-4v7zw-gzva2-jm7oc-gac6g-7qe\";cycles_for_archive_creation = opt 10000000000000;};}})"

dfx canister install rbt_token --argument="(\"https://i.ibb.co/XVMhZM2/reblock.jpg\", \"ReBlock Token\", \"RBT\", 8, 10000000000000000, principal \"x24eu-2jbtp-gqxjp-g7qeo-4bxy3-itz4h-4v7zw-gzva2-jm7oc-gac6g-7qe\", 10000)" --network ic


dfx deploy factory 

dfx canister call factory back_loan '(record { info = record {apr = "5.5%"; title = "Retail Government Bonds (ORI)"; issuer_picture = "https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Logo_kementerian_keuangan_republik_indonesia.png/120px-Logo_kementerian_keuangan_republik_indonesia.png"; total_loan_amount = "250,000.00"; payment_frequency = "MONTHLY"; description = "ORI is a retail investment instrument in the form of government bonds that can be traded on the secondary market. ORI also has a fixed coupon in the form of monthly yields paid to the investor who purchases it"; maturity_date = 1746164164; loan_term = "12 MONTHS"; issuer_description = "Indonesia Ministry of Finance"; secured_by = "Indonesia Ministry of Finance"; fundrise_end_time = 5000000000; credit_rating = "A"; origination_date = 1714628164}; token_args = record {name = "ReBlock Token Pool"; symbol = "RB01"; decimals = 8; fee = 0; max_supply = 1_000_000_000_000_000_000; initial_balances = vec {}; min_burn_amount = 0;}; borrowers = vec { principal "qwnep-krhyp-dhcck-wkqco-etadf-wijbq-c6iat-bqr3a-tbzsp-hbywq-eae"; principal "fcqo5-se6eb-qgbif-pbgvf-fux7c-zceqw-gyhbo-55w26-2a6io-oiy6o-4ae"; }; asset = principal "be2us-64aaa-aaaaa-qaabq-cai"; })' 

dfx canister call pool withdraw "(1_000_000_000)"