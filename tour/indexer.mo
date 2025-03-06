import Principal "mo:base/Principal";
import Map "mo:map/Map";
// import { phash } "mo:map/Map";
// import TrieMap "mo:base/TrieMap";

import ICRC1 "mo:icrc1-mo/ICRC1";
import ICRC2 "mo:icrc2-mo/ICRC2";
import { print } "mo:base/Debug";
import Array "mo:base/Array";
import Nat64 "mo:base/Nat64";

/*
    get_blocks : shared query GetBlocksRequest -> async GetBlocksResponse;
    get_fee_collectors_ranges : shared query () -> async FeeCollectorRanges;
    list_subaccounts : shared query ListSubaccountsArgs -> async [SubAccount];
    status : shared query () -> async Status;
*/

shared ({caller = ledgerCanisterId })  actor class Indexer() = this {

    let ledger = actor( Principal.toText(ledgerCanisterId) ): actor {
        icrc1_decimals: shared query () -> async Nat8;
        icrc1_fee: shared query () -> async Nat;
        // icrc1_metadata: shared query () -> async [ICRC1.MetaDatum];
        // icrc1_total_supply: shared query () -> async ICRC1.Balance;
        icrc1_minting_account: shared query () -> async ?ICRC1.Account;
        icrc1_balance_of: shared query ICRC1.Account -> async ICRC1.Balance;
        icrc1_supported_standards: shared query () -> async [ICRC1.SupportedStandard];
        icrc1_transfer: shared ICRC1.TransferArgs -> async ICRC1.TransferResult;
        mint: shared ICRC1.Mint -> async ICRC1.TransferResult;
        burn: shared ICRC1.BurnArgs -> async ICRC1.TransferResult;
        icrc2_allowance: query ICRC2.AllowanceArgs -> async ICRC2.Allowance;
        icrc2_approve: shared ICRC2.ApproveArgs -> async ICRC2.ApproveResponse;
        icrc2_transfer_from: shared ICRC2.TransferFromArgs -> async ICRC2.TransferFromResponse;
        getTransactionRange: query (Nat, ?Nat) -> async [ICRC1.Transaction];
    };

    type TokenTransferredListener = ICRC1.TokenTransferredListener;
    type Account = {owner: Principal; subaccount: ?Blob};

    stable let accountsTransactions = Map.new<Account, GetTransactions>();
    stable var transactions: [ICRC1.Transaction] = [];

    private func pull_missing_transactions(): async () {
        let _transactionsPulled: [ICRC1.Transaction] = await ledger.getTransactionRange(transactions.size(), null);
        var currentIndex = transactions.size();
        transactions := Array.tabulate<ICRC1.Transaction>(
            transactions.size() + _transactionsPulled.size(), 
            func i = if (i < transactions.size()) { transactions[i] } else { _transactionsPulled[i - transactions.size()] }
        );
        for (trx in _transactionsPulled.vals()) {
            index_transaction(trx, currentIndex);
            currentIndex += 1;
        };
    };

    private func index_transaction(trx: ICRC1.Transaction, index: Nat) {
        let accounts = switch (trx.kind) {
            case "TRANSFER" {
                switch (trx.transfer) {
                    case null { [] };
                    case (?data) { [data.from, data.to] }
                };
            };
            case "MINT" {

                switch (trx.mint) {
                    case null { [] };
                    case (?data) { [data.to] }
                }
            };
            case "BURN" {
                switch (trx.burn) {
                    case null { [] };
                    case (?data) { [data.from] }
                }
            };
            case _ { [] }
        };
        for (account in accounts.vals() ){
            let trxsPrevious = Map.get<Account, GetTransactions>(accountsTransactions, ICRC1.ahash, account);
            switch (trxsPrevious) {
                case null {
                    let balance = 0;
                    let transactions = [{id = Nat64.fromNat(index); transaction = trx}];
                    let oldest_tx_id = ?index;
                    ignore Map.put<Account, GetTransactions>(accountsTransactions, ICRC1.ahash, account, {balance; transactions; oldest_tx_id}) 
                };
                case (?trxsPrevious) {
                    let updatedTrxs = Array.tabulate<TransactionWithId>(
                        trxsPrevious.transactions.size() + 1, 
                        func i =   if (i == 0) { {id = Nat64.fromNat(index); transaction = trx} } else { trxsPrevious.transactions[i - 1] }
                    );
                    ignore Map.put(accountsTransactions, ICRC1.ahash, account, {trxsPrevious with transactions = updatedTrxs})  // TODO actualizar balance
                };
            };
        };
    };

    public shared ({ caller }) func on_transaction(trx: ICRC1.Transaction, index: Nat) : () {
        assert( caller == ledgerCanisterId);
        assert( index >= transactions.size());
        if (index == transactions.size()) {
            transactions := Array.tabulate<ICRC1.Transaction>(
                transactions.size() + 1, 
                func i = if (i < transactions.size()) { transactions[i] } else { trx }
            );
            index_transaction(trx, index: Nat)
        } else {
            await pull_missing_transactions();
        }; 
    };

    /////// Get account transactions ///////////

    type GetAccountTransactionsArgs = {
        max_results : Nat;
        start : ?Nat;
        account : Account;
    };

    type TransactionWithId = { 
        id : Nat64;
        transaction : ICRC1.Transaction 
    };

    public type GetTransactions = {
        balance : Nat;
        transactions : [TransactionWithId];
        oldest_tx_id : ?Nat;
    };
    public type GetTransactionsErr = { 
        message : Text 
    };
    public type GetTransactionsResult = {
        #Ok : GetTransactions;
        #Err : GetTransactionsErr;
    };

    public query func get_account_transactions({max_results; start; account}: GetAccountTransactionsArgs): async GetTransactionsResult {
        switch (Map.get<Account, GetTransactions>(accountsTransactions, ICRC1.ahash, account)){
            case null { #Ok({balance = 0; transactions = []; oldest_tx_id = null}) };
            case (?getTransactions) {
                let _start = switch start { case null { transactions.size() }; case (?start) { start } };
                switch (getTransactions.oldest_tx_id){
                    case null {
                        return #Ok({balance = getTransactions.balance; transactions = []; oldest_tx_id = null})
                    };
                    case (?oldest_tx_id) {
                        if (oldest_tx_id >= _start){
                            return #Ok({getTransactions with transactions = []})
                        } else {

                            var filteredTrxs = Array.filter<TransactionWithId>(
                                getTransactions.transactions, 
                                func trx = trx.id < Nat64.fromNat(_start)
                            );
                            if (filteredTrxs.size() <= max_results){
                                return #Ok({getTransactions with transactions = filteredTrxs})
                            } else {
                                let subarray = Array.subArray<TransactionWithId>(filteredTrxs, filteredTrxs.size() - max_results, max_results);
                                return #Ok({getTransactions with transactions = subarray})
                            };         
                        };
                        #Err({message = "sd"})
                    }
                }
                
            };
        };
    };

    public func icrc1_balance_of(a: ICRC1.Account): async ICRC1.Balance{
        await ledger.icrc1_balance_of(a)
    };

    public query func ledger_id(): async Principal{
        ledgerCanisterId
    };
    
}


