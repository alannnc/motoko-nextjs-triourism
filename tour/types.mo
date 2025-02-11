import ICRC1 "mo:icrc1-mo/ICRC1";

module {

    // public type CustomArgs = {

    // };

    public type InitialDistribution = {
        allocations : [{ categoryName : Text; holders : [InitialHolder] }];
        vestingSchemme: {
            #timeBasedVesting: TimeBasedVesting;
            #mintBasedVesting: MintBasedVesting;
        }
    };

    public type InitialHolder = {
        owner : Principal;
        allocatedAmount : Nat;
        hasVesting : Bool;
    };

    public type TimeBasedVesting = {
        cliff : ?Nat; // Comienzo del periodo de vesting. Si es null se toma la fecha del deploy
        duration : Nat; // Duración del periodo de vesting desde el cliff
        releaseRate : Nat; // Cantidad de tokens a liberar por periodo luego del periodo de vesting
        releaseInterval : Nat; // Intervalo de tiempo en segundos entre cada liberación
    };

    ///// Revisar regla ////////////////////
    public type MintBasedVesting = {
        triggers : [{ totalSupply : Nat; releaseAmount : Nat }];
        withdrawalRatio : Nat; //relacion entre el totalSupply actual y el maximo que se puede retirar en un solo trigger
    };
    public func mintBasedVestingValidate(mintBasedVesting : MintBasedVesting) : Bool {
        var lastTrigger = { totalSupply = 0; releaseAmount = 0 };
        let ratio = if (mintBasedVesting.withdrawalRatio < 500) {
            500;
        } else {
            mintBasedVesting.withdrawalRatio;
        };
        for (t in mintBasedVesting.triggers.vals()) {
            if (
                t.totalSupply <= lastTrigger.totalSupply or
                t.releaseAmount <= lastTrigger.releaseAmount or
                t.totalSupply < t.releaseAmount * ratio
            ) {
                return false;
            };
            lastTrigger := t;
        };
        true;
    };

    // Custom Errors

    public type TxIndex = Nat;
    public type TransferResult = {
      #Ok : TxIndex;
      #Err : TransferError;
    };
    public type TransferError = ICRC1.TransferError or {
      #VestingRestriction : {
          blocked_amount : Nat;
          available_amount : Nat;
      };
    };
    ////////////////////////////////////////

    public type VestingRule = {
        timeBasedVesting : ?TimeBasedVesting;
        mintBasedVesting : ?MintBasedVesting;
    };

    public type Account = { owner : Principal; subaccount : ?Blob };

    public type ArchiveOptions = {
        num_blocks_to_archive : Nat64;
        max_transactions_per_response : ?Nat64;
        trigger_threshold : Nat64;
        more_controller_ids : ?[Principal];
        max_message_size_bytes : ?Nat64;
        cycles_for_archive_creation : ?Nat64;
        node_max_memory_size_bytes : ?Nat64;
        controller_id : Principal;
    };
    public type FeatureFlags = { icrc2 : Bool };

    public type LedgerArgument = { #Upgrade : ?UpgradeArgs; #Init : InitArgs };

    public type ChangeArchiveOptions = {
        num_blocks_to_archive : ?Nat64;
        max_transactions_per_response : ?Nat64;
        trigger_threshold : ?Nat64;
        more_controller_ids : ?[Principal];
        max_message_size_bytes : ?Nat64;
        cycles_for_archive_creation : ?Nat64;
        node_max_memory_size_bytes : ?Nat64;
        controller_id : ?Principal;
    };

    public type ChangeFeeCollector = { #SetTo : Account; #Unset };

    public type UpgradeArgs = {
        change_archive_options : ?ChangeArchiveOptions;
        token_symbol : ?Text;
        transfer_fee : ?Nat;
        metadata : ?[(Text, MetadataValue)];
        change_fee_collector : ?ChangeFeeCollector;
        max_memo_length : ?Nat;
        token_name : ?Text;
        feature_flags : ?FeatureFlags;
    };

    public type InitArgs = {
        decimals : Nat8;
        token_symbol : Text;
        max_supply : Nat;
        transfer_fee : Nat;
        metadata : [(Text, MetadataValue)];
        minting_account : Account;
        initial_balances : [(Account, Nat)];
        fee_collector_account : ?Account;
        archive_options : ArchiveOptions;
        max_memo_length : ?Nat;
        token_name : Text;
        feature_flags : ?FeatureFlags;
    };

    public type MetadataValue = {
        #Int : Int;
        #Nat : Nat;
        #Blob : Blob;
        #Text : Text;
    };
};
