import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Ledger "icrc1-custom";
import ICRC1 "mo:icrc1-mo/ICRC1";
import { print } "mo:base/Debug";

/// Este canister debe ser desplegado despues de Triourism y antes del Tour ledger. 
// Luego de desplegado el Ledger ejecutar setLedger con el ledeger canister ID

shared ({ caller = Deployer}) actor class Minter({triourismCanisterId: Principal}) = this {


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
   
    let fees_collector_subaccount: ?Blob = ? "FeeCollector00000000000000000000"; // El Blob del subaccount tiene que medir 32 Bytes


    stable var LedgerActor = actor(NULL_ADDRESS): Ledger.CustomToken;
    stable let TriourismCanisterId = triourismCanisterId;
    stable var OldLedgerActor = actor(NULL_ADDRESS): Ledger.CustomToken; // Junto con restorePreviousLedger posiblemente innecesario
    stable var feesDispersionTable: FeesDispersionTable = {toBurnPermille = 0; receivers = []};
    

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

    func ledgerReady(): Bool { 
        Principal.fromActor(LedgerActor) != Principal.fromText(NULL_ADDRESS)    
    };

    // func isAllowedToMint(p: Principal): Bool {
    //   p == TriourismCanisterId or false
    // };


  //////////////////////////////////////  Getters Fees dispersion  section ///////////////////////////////////////////// 
    
    public query func getFeeCollector(): async Account { 
        {owner = Principal.fromActor(this); subaccount = fees_collector_subaccount} 
    };

    public shared func getFeeCollectorBalance(): async Nat {
      await LedgerActor.icrc1_balance_of({owner = Principal.fromActor(this); subaccount = fees_collector_subaccount})
    };

    public shared ({ caller }) func getFeesDispersionTable(): async FeesDispersionTable{
      assert(caller == Deployer);
      feesDispersionTable
    };

    public query func getLedgerCanisterId(): async Principal {
      Principal.fromActor(LedgerActor);
    };

  /////////////////////////////////////// Mint section ////////////////////////////////////////////////////////////////

    public shared ({ caller }) func rewardMint(args: ICRC1.Mint): async ICRC1.TransferResult{
      print("Minter recibiendo llamada");
      assert(caller == TriourismCanisterId and ledgerReady());
      print("Llamada aceptada");
      await LedgerActor.mint(args);
    };








}