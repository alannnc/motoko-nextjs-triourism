import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Ledger "icrc1-custom";

/// Este canister debe ser desplegado antes que el ledger

shared ({ caller = Deployer}) actor class() = this {

  //////////////// Si crece mover a un archivo de tipos ///////
    type Account = {owner: Principal; subaccount: ?Blob};

    public type FeesDispersionTable = {
        toBurnPermille: Nat;
        receivers: [{account: Account; permille: Nat}] // Permille es a mil lo que porcentage a 100
    };

  //////////////// Si crece mover a un modulo de Utils ////////
    
    func feesDispersionValidate(d: FeesDispersionTable): Bool {
        var result =  d.toBurnPermille;
        for (r in d.receivers.vals()) {
          result +=   r.permille
        };
        result < 1000;
    };

  ///////////////////// Variables de estado ///////////////////

    let NULL_ADDRESS = "aaaaa-aa";
    let fees_collector_subaccount: ?Blob = ? "0\\1\\2\\3\\4\\5\\6\\7\\8\\9\\10\\11\\12\\13\\14\\15\\16\\17\\18\\19\\20\\21\\22\\23\\24\\25\\26\\27\\28\\29\\30\\31\\32";

    stable var LedgerActor = actor(NULL_ADDRESS): Ledger.CustomToken;
    stable var OldLedgerActor = actor(NULL_ADDRESS): Ledger.CustomToken; // Junto con restorePreviousLedger posiblemente innecesario
    stable var feesDispersionTable: FeesDispersionTable = {toBurnPermille = 0; receivers = []};
    stable let fee_collector: Account = {owner = Principal.fromActor(this); subaccount = fees_collector_subaccount };

  /////////////////////// Settings //////////////////////////////////////////////////////////////////

    public shared ({ caller }) func setLedger(lerdgerCanisterId: Principal): async {#Ok; #Err: Text}{
        assert(caller == Deployer);
        OldLedgerActor := LedgerActor;
        LedgerActor := actor(Principal.toText(lerdgerCanisterId)): Ledger.CustomToken;
        #Ok
    };

    public shared ({ caller }) func restorePreviousLedger(): async {#Ok; #Err: Text}{
        assert(caller == Deployer);
        if (Principal.fromActor(OldLedgerActor) != Principal.fromText("aaaaa-aa")) {
            LedgerActor := OldLedgerActor;
            OldLedgerActor := actor(NULL_ADDRESS): Ledger.CustomToken;
            return #Ok
        };
        #Err("No hay registros de ledgers configurados previamente al actual")
    };

    public shared ({ caller }) func setFeesDispersionTable(d: FeesDispersionTable): async {#Ok; #Err: Text}{
        assert (caller == Deployer);
        if ( not feesDispersionValidate(d)) { return #Err("La suma de todos los items debe ser menor o igual a 1000") };
        feesDispersionTable := d;
        #Ok
    };

  //////////////////////////////////////  Getters  ///////////////////////////////////////////// epvyw-ddnza-4wy4p-joxft-ciutt-s7pji-cfxm3-khwlb-x2tb7-uo7tc-xae
    
    public query func getFeeCollector(): async Account { 
        fee_collector 
    };

    func ledgerReady(): Bool { 
        Principal.fromActor(LedgerActor) != Principal.fromText(NULL_ADDRESS)    
    };








}