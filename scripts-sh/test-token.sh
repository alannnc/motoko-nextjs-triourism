#!/bin/bash

# Función para ejecutar pruebas con colores
run_test() {
    DESCRIPTION="$1"
    EXPECTED="$2"
    COMMAND="$3"

    echo "--------------  $DESCRIPTION  --------------"
    echo "Valor esperado: $EXPECTED"

    # Ejecutar el comando y capturar la salida
    RESULT=$(eval "$COMMAND")

    echo "Valor obtenido: $RESULT"

    # Verificar si el resultado contiene el valor esperado
    if echo "$RESULT" | grep -q "$EXPECTED"; then
        echo -e "\e[32m✔ Test exitoso\e[0m"  # Verde
    else
        echo -e "\e[31m✘ Test fallido\e[0m"  # Rojo
    fi
    echo ""
}

# Configuración de identidades
dfx identity use 0000InvNonVesting
export InvNonVesting=$(dfx identity get-principal) 

dfx identity use 0000InvVesting
export InvVesting=$(dfx identity get-principal)

dfx identity use 0000Founder01
export Founder01=$(dfx identity get-principal)

dfx identity use 0000Founder02
export Founder02=$(dfx identity get-principal)

dfx identity use 0000Founder03
export Founder03=$(dfx identity get-principal)

dfx identity use 0000Minter
export Minter=$(dfx identity get-principal)

dfx identity use 0000FeeCollector
export FeeCollector=$(dfx identity get-principal)

dfx identity use 0000Controller
export Controller=$(dfx identity get-principal)

# Test balance luego de distribución
run_test "Test total_supply luego de distribución" \
    "(7_703_000_000 : nat)" \
    "dfx canister call tour icrc1_total_supply"

# Test usuario con vesting intentando transferir tokens
dfx identity use 0000InvVesting
run_test "Test usuario con vesting quiere transferir 500_000_000 tokens" \
    "(
    variant {
        Err = variant {
        VestingRestriction = record {
            blocked_amount = 4_000_000_000 : nat;
            available_amount = 0 : nat;
        }
        }
    },
    )" \
    "dfx canister call tour icrc1_transfer '(
      record {
        to = record { owner = principal \"smdkv-lcdvc-ukvh6-dhgfm-fej7o-76jhm-zbpoj-lq3jh-lfcn7-62pow-2qe\"; subaccount = null; };
        fee = null;
        memo = null;
        from_subaccount = null;
        created_at_time = null;
        amount = 500_000_000 : nat;
      },
    )'"

# Test usuario sin vesting realizando transferencia
dfx identity use 0000InvNonVesting
run_test "Test usuario sin vesting quiere transferir 500_000_000 tokens a founder1" \
    "(variant { Ok = 5 : nat })" \
    "dfx canister call tour icrc1_transfer '(
      record {
        to = record { owner = principal \"$Founder01\"; subaccount = null; };
        fee = null;
        memo = null;
        from_subaccount = null;
        created_at_time = null;
        amount = 500_000_000 : nat;
      },
    )'"

# Test mint y verificación de balance
dfx identity use 0000Minter
run_test "El minter hace un mint de 2_000_000_000 tokens en favor de founder1" \
    "(variant { Ok = 6 : nat })" \
    "dfx canister call tour mint '(
      record {
        to = record { owner = principal \"$Founder01\"; subaccount = null; };
        memo = null;
        created_at_time = null;
        amount = 2_000_000_000 : nat;
      },
    )'"
run_test "Check total_supply luego del mint" \
    "(9_703_000_000 : nat)" \
    "dfx canister call tour icrc1_total_supply"
run_test "Verificación de balance de founder1" \
    "(3_734_000_000 : nat)" \
    "dfx canister call tour icrc1_balance_of '(
      record { owner = principal \"$Founder01\" },
    )'"

run_test "Verificación de balance de inversor sin vesting luego de su transferencia hacia founder1" \
    "(499_990_000 : nat)" \
    "dfx canister call tour icrc1_balance_of '(
      record { owner = principal \"$InvNonVesting\" },
    )'"

# Founder 1 intenta transferir más de lo permitido
dfx identity use 0000Founder01
run_test "Founder 1 quiere transferir 3_000_000_000 a founder 2 (bloqueado por vesting)" \
    "(
        variant {
            Err = variant {
            VestingRestriction = record {
                blocked_amount = 1_234_000_000 : nat;
                available_amount = 2_500_000_000 : nat;
            }
            }
        },
    )" \
    "dfx canister call tour icrc1_transfer '(
      record {
        to = record { owner = principal \"$Founder02\"; subaccount = null; };
        fee = null;
        memo = null;
        from_subaccount = null;
        created_at_time = null;
        amount = 3_000_000_000 : nat;
      },
    )'"

run_test "Founder 1 quiere transferir 2_500_000_000 a founder 2 (bloqueado por vesting)" \
    "(
        variant {
            Err = variant {
            VestingRestriction = record {
                blocked_amount = 1_234_000_000 : nat;
                available_amount = 2_500_000_000 : nat;
            }
            }
        },
    )" \
    "dfx canister call tour icrc1_transfer '(
      record {
        to = record { owner = principal \"$Founder02\"; subaccount = null; };
        fee = null;
        memo = null;
        from_subaccount = null;
        created_at_time = null;
        amount = 2_500_000_000 : nat;
      },
    )'"

run_test "Founder 1 quiere transferir 2_499_990_000 a founder 2 (exitosa)" \
    "(variant { Ok = 7 : nat })" \
    "dfx canister call tour icrc1_transfer '(
      record {
        to = record { owner = principal \"$Founder02\"; subaccount = null; };
        fee = null;
        memo = null;
        from_subaccount = null;
        created_at_time = null;
        amount = 2_499_990_000 : nat;
      },
    )'"

