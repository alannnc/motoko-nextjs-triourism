
dfx identity new triourism
dfx identity use triourism

# Deploy del canister principal
dfx deploy backend
export backend=$(dfx canister id backend)

# Deploy del Minter Canister
dfx deploy icrc1_minter_canister --argument '(
    record {triourismCanisterId = principal "'$backend'"}
)'
export minterCanister=$(dfx canister id icrc1_minter_canister)

# Referencia al Minter en el backend
echo "Seteando referencia al canister minter en el canister backend..."
dfx canister call backend setMinter '(principal "'$minterCanister'")'

echo -e "\n\nSiguientes pasos: 
  // Deploy del canister Ledger 
    npm run deploy-token
  // Referenciar el ledger en el canister minter 
    dfx canister call icrc1_minter_canister setLedger '(principal "'$(dfx canister id tour)'")'
  // Referenciar el canister Minter en el canister principal
    dfx canister call backend setMinter '(principal "'$(dfx canister id icrc1_minter_canister)'")'
"
echo "Deploy del canister Ledger"
npm run deploy-token
echo "Referenciar el ledger en el canister minter"
dfx canister call icrc1_minter_canister setLedger '(principal "'$(dfx canister id tour)'")'
echo "Referenciar el canister Minter en el canister principal"
dfx canister call backend setMinter '(principal "'$(dfx canister id icrc1_minter_canister)'")'
# 
