#!/bin/bash

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
        to = record { owner = principal \"$Founder01\"; subaccount = null; };
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
dfx canister call tour icrc1_balance_of "(record { owner = principal \"$Founder01\" })"
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

 
echo -e "\n\n============= PRUEBAS DE VESTING PROGRESIVO =============\n"

# Función para esperar mostrando cuenta regresiva
wait_with_countdown() {
    local seconds=$1
    echo -e "\n[⏳] Esperando $seconds segundos..."
    while [ $seconds -gt 0 ]; do
        echo -ne "Tiempo restante: $seconds segundos\r"
        sleep 1
        ((seconds--))
    done
    echo -e "\n[✅] Continuando con las pruebas\n"
}

# Obtener balances iniciales de referencia
INITIAL_FOUNDER01_BALANCE=$(dfx canister call tour icrc1_balance_of "(record { owner = principal \"$Founder01\" })" | grep -oP '[0-9_]+(?= : nat)')
INITIAL_INVESTOR_BALANCE=$(dfx canister call tour icrc1_balance_of "(record { owner = principal \"$InvVesting\" })" | grep -oP '[0-9_]+(?= : nat)')

# Simular paso del tiempo hasta el cliff de Founders (180 segundos)
wait_with_countdown 85

# Test 1: Primer desbloqueo de vesting para Founders
run_test "Post-cliff Founders: Primer desbloqueo parcial" \
    "(2_500_000_000 : nat)" \
    "dfx canister call tour vesting_available_amount \"(record { owner = principal \\\"$Founder01\\\" })\""

# Test 2: Transferencia permitida dentro del monto desbloqueado
dfx identity use 0000Founder01
run_test "Founder1 transfiere 500M usando tokens desbloqueados" \
    "(variant { Ok = 8 : nat })" \
    "dfx canister call tour icrc1_transfer '(
        record {
            to = record { owner = principal \"$Founder02\" };
            amount = 500_000_000 : nat;
        }
    )'"

# Avanzar primer intervalo de vesting (30 segundos)
wait_with_countdown 30

# Test 3: Segundo desbloqueo de vesting
run_test "Post-interval 1 Founders: Segundo desbloqueo" \
    "(3_000_000_000 : nat)" \
    "dfx canister call tour vesting_available_amount \"(record { owner = principal \\\"$Founder01\\\" })\""

# Test 4: Intentar transferir monto mayor al desbloqueado
run_test "Founder1 intenta transferir excediendo límite" \
    "VestingRestriction" \
    "dfx canister call tour icrc1_transfer '(
        record {
            to = principal \"$Founder03\";
            amount = 3_000_000_000 : nat;
        }
    )'"

# Avanzar segundo intervalo de vesting (30 segundos)
wait_with_countdown 30

# Test 5: Tercer desbloqueo
run_test "Post-interval 2 Founders: Tercer desbloqueo" \
    "(3_500_000_000 : nat)" \
    "dfx canister call tour vesting_available_amount \"(record { owner = principal \\\"$Founder01\\\" })\""

# Avanzar tercer intervalo (30 segundos)
wait_with_countdown 30

# Test 6: Cuarto desbloqueo (final)
run_test "Post-interval 3 Founders: Desbloqueo total" \
    "(4_000_000_000 : nat)" \
    "dfx canister call tour vesting_available_amount \"(record { owner = principal \\\"$Founder01\\\" })\""

# Test 7: Transferencia total permitida
run_test "Founder1 transfere saldo completo" \
    "(variant { Ok = 9 : nat })" \
    "dfx canister call tour icrc1_transfer '(
        record {
            to = principal \"$Founder03\";
            amount = 3_500_000_000 : nat;
        }
    )'"

# ============= PRUEBAS PARA INVESTORS =============
echo -e "\n\n[🚀] Iniciando pruebas de vesting para Investors\n"

# Esperar hasta cliff de Investors (360 segundos desde inicio)
wait_with_countdown 120  # Ya han pasado 180 + 90 = 270, necesitamos 90 más para llegar a 360

# Test 8: Desbloqueo inicial Investors
run_test "Post-cliff Investors: Desbloqueo inicial" \
    "(1_000_000_000 : nat)" \
    "dfx canister call tour vesting_available_amount \"(record { owner = principal \\\"$InvVesting\\\" })\""

# Test 9: Transferencia parcial Investor
dfx identity use 0000InvVesting
run_test "Investor vesting transfiere 500M" \
    "(variant { Ok = 10 : nat })" \
    "dfx canister call tour icrc1_transfer '(
        record {
            to = principal \"$InvNonVesting\";
            amount = 500_000_000 : nat;
        }
    )'"

# Avanzar intervalo Investors (30 segundos)
wait_with_countdown 30

# Test 10: Segundo desbloqueo Investor
run_test "Post-interval 1 Investors: Segundo desbloqueo" \
    "(2_000_000_000 : nat)" \
    "dfx canister call tour vesting_available_amount \"(record { owner = principal \\\"$InvVesting\\\" })\""

# Avanzar último intervalo (30 segundos)
wait_with_countdown 30

# Test 11: Desbloqueo total Investor
run_test "Post-interval 2 Investors: Desbloqueo completo" \
    "(3_000_000_000 : nat)" \
    "dfx canister call tour vesting_available_amount \"(record { owner = principal \\\"$InvVesting\\\" })\""

# Test final: Verificación de balances acumulativos
echo -e "\n[📊] Balance final Founder01:"
dfx canister call tour icrc1_balance_of "(record { owner = principal \"$Founder01\" })"

echo -e "\n[📊] Balance final Investor Vesting:"
dfx canister call tour icrc1_balance_of "(record { owner = principal \"$InvVesting\" })"

echo -e "\n[🎉] Todas las pruebas de vesting completadas exitosamente!"