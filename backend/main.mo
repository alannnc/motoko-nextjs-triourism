import Prim "mo:⛔";
import Map "mo:map/Map";
import Set "mo:map/Set";
import { phash; nhash; thash } "mo:map/Map";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Blob "mo:base/Blob";
import Types "types";
import { now } "mo:base/Time";
import msg "constants";
import { print } "mo:base/Debug";
import Array "mo:base/Array";
import Int "mo:base/Int";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Indexer_icp "./indexer_icp_token";
import AccountIdentifier "mo:account-identifier";

shared ({ caller = DEPLOYER }) actor class Triourism () = this {

    type User = Types.User;
    type HostUser =Types.HostUser;
    type UserData = Types.UserData;
    type SignUpResult = Types.SignUpResult;
    type Calendary = Types.Calendary;
    type Reservation = Types.Reservation;
    type HousingId = Nat;
    type ReviewId = Nat;
    type Review = Types.Review;
    type Housing = Types.Housing;
    type HousingTypeInit = Types.HousingTypeInit;
    type HousingType = Types.HousingType;
    type HousingResponse = Types.HousingResponse;
    type HousingPreview = Types.HousingPreview;
    type HousingCreateData = Types.HousingCreateData;
    type TransactionParams = Types.TransactionParams;
    type DataTransaction = Types.DataTransaction;
    type TransactionResponse = Types.TransactionResponse;

    type UpdateResult = Types.UpdateResult;
    type ResultHousingPaginate = {#Ok: {array: [HousingPreview]; hasNext: Bool}; #Err: Text};
    
  
    // stable let DEPLOYER = caller;

    // /////////////// WARNING modificar estas variables en produccion a los valores reales  ////
    let nanoSecPerDay = 30 * 1_000_000_000;             // Test Transcurso acelerado de los dias
    // let nanoSecPerDay = 86400 * 1_000_000_000;       // Valor real de nanosegundos en un dia
    stable var TimeToPay = 15 * 1_000_000_000;          // Tiempo en nanosegundos para confirmar la reserva mediante pago
    // stable var TimeToPay = 30 * 60 * 1_000_000_000;  // Tiempo sugerido 30 minutos
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
     
    stable let admins = Set.new<Principal>();
    ignore Set.put<Principal>(admins, phash, DEPLOYER);

    stable let users = Map.new<Principal, User>();
    stable let hostUsers = Map.new<Principal, HostUser>();

    stable let housings = Map.new<HousingId, Housing>();
    stable let review = Map.new<ReviewId, Review>();

    stable let reservationsPendingConfirmation = Map.new<Nat, Reservation>();
    stable let reservationsHistory = Map.new<Nat, Reservation>();
    
    stable var lastHousingId = 0;
    stable var lastReviewId = 0;
    stable var lastReservationId = 0;
    
    ///////////////////////////////////// Login Update functions ////////////////////////////////////////

    public shared ({ caller }) func signUpAsUser(data: Types.SignUpData) : async SignUpResult {
        if(Principal.isAnonymous(caller)) { return #Err(msg.NotUser) };

        let user = Map.get(users, phash, caller);
        switch user {
            case (?User) { #Err("User already exists") };
            case null {
                let newUser: User = {
                    data with
                    verified = true;
                    reviewsIssued = List.nil<Nat>();
                    score = 0;
                };
                ignore Map.put(users, phash, caller, newUser);
                #Ok( newUser );
            };
        };
    };

    public shared ({ caller }) func signUpAsHost(data: Types.SignUpData) : async SignUpResult {
        if(Principal.isAnonymous(caller)) { return #Err(msg.NotUser) };
        let hostUser = Map.get(hostUsers, phash, caller);
        switch hostUser {
            case (?User) { #Err("Host User already exists") };
            case null {
                let newHostUser: HostUser = {
                    data with
                    verified = true;
                    score = 0;
                    housingIds = List.nil<Nat>();
                    housingTypes =  Map.new<Text, HousingType>();
                };
                ignore Map.put(hostUsers, phash, caller, newHostUser);
                #Ok(newHostUser);
            };
        };
    };

    public shared query ({ caller }) func loginAsUser(): async {#Ok: UserData; #Err} {
        let user = Map.get<Principal, User>(users, phash, caller); 
        switch user {
            case null { #Err() };
            case ( ?u ) { #Ok(u)}
        };
    };

    public shared query ({ caller }) func loginAsHost(): async {#Ok: UserData; #Err} {
        let hostUser = Map.get<Principal, HostUser>(hostUsers, phash, caller); 
        switch hostUser {
            case null { #Err() };
            case ( ?u ) { #Ok(u)}
        };
    };


    //////////////////////////////// CRUD Data User ///////////////////////////////////

    public shared ({ caller }) func editProfile(data: Types.SignUpData): async {#Ok; #Err}{
        let user = Map.get<Principal, User>(users, phash, caller);
        switch user {
            case null { #Err };
            case (?user){
                ignore Map.put<Principal, User>(users, phash, caller, { user with data});
                #Ok
            };
        };
    };

    ///////////////////////////// Private functions ///////////////////////////////////
    func isAdmin(p: Principal): Bool { Set.has<Principal>(admins, phash, p) };

    func addressEqual(a: Types.Location, b: Types.Location ) : Bool {
        a.country == b.country and
        a.city == b.city and
        a.neighborhood == b.neighborhood and
        a.zipCode == b.zipCode and
        a.externalNumber == b.externalNumber and
        a.internalNumber == b.internalNumber
    };

    let NULL_LOCATION = {
        country = "";
        city = ""; 
        neighborhood = ""; 
        zipCode = 0; street = "";  
        externalNumber = 0; 
        internalNumber = 0
    };

    let defaultHousinValues = {
        active: Bool = false;
        rules: [Types.Rule] = [];
        price: ?Types.Price = null;
        checkIn: Nat = 15;
        checkOut: Nat = 12;
        address: Types.Location = NULL_LOCATION;
        properties: ?HousingType = null;
        housingType: ?Text = null;
        amenities = null;
        reviews = List.nil<Nat>();
    };

    /////////////////////////// Manage admins functions /////////////////////////////////

    public shared ({ caller }) func addAdmin(p: Principal): async  {#Ok; #Err} {
        if(not isAdmin(caller)){ 
            #Err
        } else{
            ignore Set.put<Principal>(admins, phash, p);
            #Ok
        }
    };

    public shared ({ caller }) func removeAdmin(p: Principal): async {#Ok; #Err} {
        if(caller != DEPLOYER){
            #Err;
        } else {
            ignore Set.remove<Principal>(admins, phash, p);
            #Ok
        } 
    };
   
    /////////////////////////// Admin functions ////////////////////////////////////////////// 
    /////////////////////////////// Verification process /////////////////////////////////////
    // TODO actualmente todos los usuarios se inicializan como verificados

    // func userIsVerificated(u: Principal): Bool {
    //     let user = Map.get<Principal,User>(users, phash, u);
    //     switch user{
    //         case null { false };
    //         case (?user) { user.verified};
    //     };
    // };

    //////////////////////////////// CRUD Housing ////////////////////////////////////////////

    public shared ({ caller }) func createHousing(dataInit: HousingCreateData): async {#Ok: Nat; #Err: Text} {
        let hostUser = Map.get<Principal, HostUser>(hostUsers, phash, caller);
        switch hostUser {
            case null {#Err(msg.NotHostUser)};
            case (?hostUser) {

                lastHousingId += 1;
                let newHousing: Housing = {
                    dataInit and 
                    defaultHousinValues with
                    housingId = lastHousingId;
                    owner = caller;
                    calendary = {dayZero = now(); reservations = []};
                    reservationsPending = [];
                    unavailability = { busy = []; pending = [] };
                };
                let housingIdsUser =  List.push<Nat>(lastHousingId, hostUser.housingIds);
                ignore Map.put<Principal, HostUser>(hostUsers, phash, caller, {hostUser with housingIds = housingIdsUser});
                ignore Map.put<HousingId, Housing>(housings, nhash, lastHousingId, newHousing );
                #Ok(lastHousingId)
            }
        }
    };

    func isPublishable(housing: Housing): Bool {
        (housing.price != null) and
        (not addressEqual(housing.address, NULL_LOCATION)) and
        (housing.properties != null)
    };

    public shared ({ caller }) func publishHousing(housingId: HousingId): async {#Ok; #Err: Text}{
        let hostUser = Map.get<Principal, HostUser>(hostUsers, phash, caller);
        switch hostUser {
            case null { #Err(msg.NotUser)};
            case ( ?hostUser ) {
                let housing = Map.get<HousingId, Housing>(housings, nhash, housingId);
                switch housing {
                    case null { #Err(msg.NotHousing)};
                    case ( ?housing ) {
                        if(housing.owner != caller) { return #Err(msg.CallerNotHousingOwner)};
                        if(isPublishable(housing)) {
                            ignore Map.put<HousingId, Housing>(housings, nhash, housingId, {housing with active = true});
                            #Ok
                        } else {
                            #Err(msg.IsNotpublishable)
                        }
                    }
                }
            }
        }

    };

    public shared ({ caller }) func addPhotoToHousing({id: HousingId; photo: Blob}): async {#Ok; #Err: Text} {
        let housing = Map.get<HousingId, Housing>(housings, nhash, id);
        switch housing {
            case null {
                #Err(msg.NotHousing)
            };
            case (?housing) {
                if(housing.owner != caller){
                    return #Err(msg.CallerNotHousingOwner)
                };
                let photos = Prim.Array_tabulate<Blob>(
                    housing.photos.size() +1,
                    func i = if(i < housing.photos.size()) {housing.photos[i]} else {photo}
                );
                ignore Map.put<HousingId, Housing>(housings, nhash, id, {housing with photos});
                print(debug_show({housing with photos}));
                #Ok
            }
        }
    };

    public shared ({ caller }) func addThumbnailToHousing({id: HousingId; thumbnail: Blob}): async {#Ok; #Err: Text} {
        let housing = Map.get<HousingId, Housing>(housings, nhash, id);
        switch housing {
            case null {
                #Err(msg.NotHousing)
            };
            case (?housing) {
                if(housing.owner != caller){
                    return #Err(msg.UnauthorizedCaller)
                };
                ignore Map.put<HousingId, Housing>(housings, nhash, id, {housing with thumbnail});
                #Ok
            }
        }
    };

    public shared ({ caller }) func updatePrices({id: HousingId; price_: Types.Price}): async  UpdateResult{
        let housing = Map.get(housings, nhash, id);
        switch housing {
            case null {
                return #Err(msg.NotHousing);
            };
            case (?housing) {
                if(housing.owner != caller){ return #Err(msg.UnauthorizedCaller) };
                ignore Map.put<HousingId, Housing>(housings, nhash, id, {housing with price = ?price_});
                return #Ok
            };
        } 
    };

    public shared ({ caller }) func setRulesForHousing({id: HousingId; rules: [Types.Rule]}): async {#Ok; #Err: Text}{
        let housing = Map.get(housings, nhash, id);
        switch housing {
            case null {
                return #Err(msg.NotHousing);
            };
            case (?housing) {
                if(housing.owner != caller){ return #Err(msg.UnauthorizedCaller) };
                ignore Map.put<HousingId, Housing>(housings, nhash, id, {housing with rules});
                return #Ok
            };
        } 
    };

    // public shared ({ caller }) func setMinReservationLeadTime({id: HousingId; hours: Nat}):async  {#Ok; #Err: Text} {
    //     let housing = Map.get<HousingId, Housing>(housings, nhash, id);
    //     switch housing {
    //         case null {
    //             return #Err(msg.NotHosting);
    //         };
    //         case (?housing) {
    //             if(housing.owner != caller){
    //                 return #Err(msg.CallerNotHousingOwner);
    //             };
    //             ignore Map.put<HousingId, Housing>(
    //                 housings, 
    //                 nhash, 
    //                 id, 
    //                 {housing with minReservationLeadTimeNanoSeg = hours * NANO_SEG_PER_HOUR});
    //             #Ok;
    //         }

    //     }
    // };

    public shared ({ caller }) func setHousingStatus({id: HousingId; active: Bool}): async {#Ok; #Err: Text}{
        let housing = Map.get<HousingId, Housing>(housings, nhash, id);
        switch housing {
            case null { #Err(msg.NotHousing)};
            case ( ?housing ) {
                if(caller != housing.owner) {
                    return #Err(msg.CallerNotHousingOwner);
                };
                if (not isPublishable(housing)) {
                    return #Err(msg.IsNotpublishable)
                };
                ignore Map.put<HousingId, Housing>(housings, nhash, id, {housing with active});
                #Ok
            }
        }
    };

    public shared ({ caller }) func setChekInCheckOut({housingId: HousingId; checkIn: Nat; checkOut: Nat}): async {#Ok; #Err: Text}{
        if(checkOut >= checkIn) { return #Err(msg.ErrorCheckinCheckout) }; 
        let housing = Map.get<HousingId, Housing>(housings, nhash, housingId);
        switch housing {
            case null { #Err(msg.NotHousing)};
            case ( ?housing ) {
                if(caller != housing.owner) {
                    return #Err(msg.CallerNotHousingOwner);
                };
                ignore Map.put<HousingId, Housing>(housings, nhash, housingId, {housing with checkIn; checkOut});
                #Ok
            }
        }
    };

    public shared ({ caller }) func setAddress({housingId: HousingId; address: Types.Location}): async {#Ok; #Err: Text}{
        let housing = Map.get<HousingId, Housing>(housings, nhash, housingId);
        switch housing {
            case null { #Err(msg.NotHousing)};
            case ( ?housing ) {
                if(caller != housing.owner) {
                    return #Err(msg.CallerNotHousingOwner);
                };
                ignore Map.put<HousingId, Housing>(housings, nhash, housingId, {housing with address});
                #Ok
            }
        }
    };
    
    public shared ({ caller }) func cloneHousingWithProperties({housingId: HousingId; qty: Nat; housingTypeInit: HousingTypeInit}): async {#Ok; #Err: Text} {
        
        let hostUser = Map.get<Principal, HostUser>(hostUsers, phash, caller);
        switch hostUser {
            case null {
                return #Err(msg.NotHostUser)
            };
            case ( ?hostUser ) {
                if (Map.has<Text, HousingType>(hostUser.housingTypes, thash, housingTypeInit.nameType)) {
                    return #Err(msg.HousingTypeExist)
                };
                let housing = Map.get<HousingId, Housing>(housings, nhash, housingId);
                switch housing {
                    case ( null ) { return #Err(msg.NotHousing)};
                    case ( ?housing ) {
                        if(housing.owner != caller) { 
                            return #Err(msg.CallerNotHousingOwner)
                        };
                        //Establecemos el tipo al housing a clonar
                        let housingType: HousingType =  {housingTypeInit with housingIds: [HousingId] = []};
                        ignore Map.put<HousingId, Housing>(
                            housings, 
                            nhash, 
                            housingId, 
                            { housing with properties = ?housingType; housingType = ?housingTypeInit.nameType});

                        var i = qty;
                        var housingIdsOfThisType = Buffer.fromArray<Nat>([housingId]);
                        while (i > 0) {
                            lastHousingId += 1;
                            housingIdsOfThisType.add(lastHousingId);

                            let newHousing: Housing = {
                                defaultHousinValues with
                                owner = caller;
                                housingId = lastHousingId;
                                namePlace = housing.namePlace;
                                nameHost = housing.nameHost;
                                descriptionPlace = housing.descriptionPlace;
                                descriptionHost = housing.descriptionHost;
                                link = housing.link;
                                photos = [];
                                properties = null;
                                housingType = ?housingTypeInit.nameType;
                                thumbnail = housing.thumbnail;
                                calendary = {dayZero = now(); reservations = []};
                                reservationsPending = [];
                                unavailability = { busy = []; pending = [] };
                            };
                            ignore Map.put<HousingId, Housing>(housings, nhash, lastHousingId,  newHousing );
                            i -= 1;
                        };
                        let housingIds = Buffer.toArray<Nat>(housingIdsOfThisType);
                        ignore Map.put<Text, HousingType>(hostUser.housingTypes, thash, housingType.nameType, {housingType with housingIds});
                        #Ok
                    }
                };    
            }
        };
    };
    

    // public shared ({ caller }) func removeHousingType(housingType: Text): async {#Ok; #Err: Text}{
    //     let myHousingTypesMap = Map.get<Principal, HousingTypesMap>(housingTypesByHostOwner, phash, caller);
    //     switch myHousingTypesMap {
    //         case null {#Err("Not housing types")};
    //         case (?housingTypesMap){
    //             let removedType = Map.remove<Text, {properties: Types.HousingType; housingIds: [HousingId]}>(
    //                 housingTypesMap, thash, housingType
    //             );
    //             switch removedType {
    //                 case null { #Err("Not housing type")};
    //                 case (?removedType) {#Ok}
    //             }
    //         }  
    //     }
    // };

    public shared ({ caller }) func setAmenities(amenities: Types.Amenities, housingId: HousingId): async {#Ok; #Err: Text}{
       let housing = Map.get<HousingId, Housing>(housings, nhash, housingId);
        switch housing {
            case null { #Err(msg.NotHousing)};
            case ( ?housing ) {
                if(caller != housing.owner) {
                    return #Err(msg.CallerNotHousingOwner);
                };
                ignore Map.put<HousingId, Housing>(
                    housings, 
                    nhash, 
                    housingId, 
                    {housing with amenities = ?amenities});
                #Ok
            }
        } 
    };
    
    ///////////////////////////////////////// Getters ////////////////////////////////////////

    public query func getHousingPaginate({page: Nat; qtyPerPage: Nat}): async ResultHousingPaginate {
        if(Map.size(housings) < page * qtyPerPage){
            return #Err(msg.PaginationOutOfRange)
        };
        let values = Map.toArray<HousingId, Housing>(housings);
        let bufferHousingPreview = Buffer.fromArray<Housing>([]);
        var index = page * qtyPerPage;
        while (index < values.size() and index < (page + 1) * qtyPerPage){
            if(values[index].1.active){
                bufferHousingPreview.add(values[index].1);
            };
            index += 1;
        };
        let array = Buffer.toArray<Housing>(bufferHousingPreview);
        #Ok{
            array;
            hasNext = ((page + 1) * qtyPerPage < array.size())
        }
    };

    public shared query ({ caller }) func getCalendarById(id: Nat): async {#Ok: Calendary; #Err: Text}{
        switch (Map.get<HousingId, Housing>(housings, nhash, id)) {
            case (?housing) {
                if (housing.owner != caller ) {return #Err(msg.CallerNotHousingOwner)};
                let { calendary } = updateCalendary(id);
                #Ok(calendary)
            };
            case null { return #Err(msg.NotHousing)};   
        };
    };

    public shared ({ caller }) func getHousingById({housingId: HousingId;  photoIndex: Nat}): async {#Ok: HousingResponse; #Err: Text} {
        let housing = Map.get<HousingId, Housing>(housings, nhash, housingId);
        
        return switch housing {
            case null { #Err(msg.NotHousing)};
            case (?housing) {
                let reservationsPending = cleanPendingVerifications(housingId, housing.reservationsPending);
                if(not housing.active and housing.owner != caller) {
                    return #Err(msg.InactiveHousing)
                };
                let { unavailability } = updateCalendary(housingId);
                if(photoIndex == 0){
                    let housingResponse: HousingResponse = #Start({
                        housing with
                        reservationsPending;
                        calendary = {dayZero = 0 ; reservations = []}; //Informacion omitida para el publico
                        unavailability;
                        photos = if(housing.photos.size() > 0) { [housing.photos[0]] } else { [] };
                        hasNextPhoto = (housing.photos.size() > photoIndex + 1)
                    });
                    #Ok(housingResponse);
                } else {
                    if (photoIndex >= housing.photos.size()) { return #Err(msg.PaginationOutOfRange)};
                    let housingResponse: HousingResponse = #OnlyPhoto({
                        photo = housing.photos[photoIndex];
                        hasNextPhoto = (housing.photos.size() > photoIndex + 1)
                    });
                    print(debug_show(housing.photos));
                    #Ok(housingResponse)
                }
            };
        }
    };

    public shared ({ caller }) func getMyHousingTypes(): async {#Ok: [{typeName: Text; housingIds: [Nat]}]; #Err: Text}{
        let hostUser = Map.get<Principal, HostUser>(hostUsers, phash, caller);
        switch hostUser {
            case null {#Err(msg.NotHostUser)};
            case (?hostUser) {
                #Ok(
                    Array.map<(Text, HousingType),{ typeName: Text; housingIds: [Nat]} >(
                        Map.toArray<Text, HousingType>(hostUser.housingTypes),
                        func x = {typeName = x.0; housingIds = x.1.housingIds}
                    ) 
                )           
            };
        }
    };

    public shared query ({ caller }) func getMyHousingsByType({housingType: Text; page: Nat}): async ResultHousingPaginate{
        let hostUser = Map.get<Principal, HostUser>(hostUsers, phash, caller);
        switch hostUser {
            case null {#Err(msg.NotHostUser)};
            case (?hostUser) {
                switch (Map.get<Text, HousingType>(hostUser.housingTypes, thash, housingType)){
                    case null { return #Err(msg.HousingTypeNoExist)};
                    case ( ?housingType ) {
                        getPaginateHousings(housingType.housingIds, page)
                    }
                }           
            };
        }
    };

    func getPaginateHousings(ids: [HousingId], page: Nat): ResultHousingPaginate {
        let resultBuffer = Buffer.fromArray<HousingPreview>([]);
        var index = page * 10;
        while(index < (page + 1)* 10 and index < ids.size()){
            switch (Map.get<HousingId, Housing>(housings, nhash, ids[index])) {
                case null {};
                case (?housing) {          
                    resultBuffer.add( 
                        { 
                            active = housing.active;
                            housingId = ids[index];
                            address = housing.address;
                            thumbnail = housing.thumbnail;
                            price = housing.price;
                        }
                    )
                }
            };
            index += 1;
        };
        let hasNext = ids.size() > (page + 1)* 10;
        #Ok({array = Buffer.toArray<HousingPreview>(resultBuffer); hasNext: Bool});
    };

    func getHousingsPaginateByOwner(owner: Principal, page: Nat, qtyPerPage: Nat, onlyActives: Bool): ResultHousingPaginate {
        let hostUser = Map.get<Principal, HostUser>(hostUsers, phash, owner);

        switch hostUser {
            case null { #Err(msg.NotHostUser)};
            case ( ?hostUser ) { 
                // let housingArray = List.toArray<HousingId>(hostUser.housingIds);
                let housingPreviewBuffer = Buffer.fromArray<HousingPreview>([]);
                for(id in List.toIter(hostUser.housingIds)){
                    switch (Map.get<HousingId, Housing>(housings, nhash, id)){
                        case (?housing) {
                            if(not onlyActives or housing.active){
                               housingPreviewBuffer.add(housing) 
                            } 
                        };
                        case _ { }
                    };
                };
                let arrayHousingPreview = Buffer.toArray(housingPreviewBuffer);
                if ( arrayHousingPreview.size() < page * qtyPerPage){
                    return #Err(msg.PaginationOutOfRange);
                };
                let (size: Nat, hasNext: Bool) = if (arrayHousingPreview.size() >= (page + 1)  * qtyPerPage){
                    (qtyPerPage, arrayHousingPreview.size() > (page + 1))
                } else {
                    (arrayHousingPreview.size() % qtyPerPage, false)
                };
                return #Ok({array = Array.subArray(arrayHousingPreview, page * qtyPerPage, size); hasNext : Bool})

            }
        }
    };

    public shared query ({ caller }) func getMyHousingsPaginate({page: Nat; qtyPerPage: Nat}): async ResultHousingPaginate{
        getHousingsPaginateByOwner(caller, page, qtyPerPage, false)
    };

    public shared query ({ caller }) func getMyActiveHousings({page: Nat; qtyPerPage: Nat}): async ResultHousingPaginate{
        getHousingsPaginateByOwner(caller, page, qtyPerPage, true)
        
    };

    public shared query func getHousingByHostUser({host: Principal; page: Nat; qtyPerPage: Nat}): async ResultHousingPaginate{
        getHousingsPaginateByOwner(host, page, qtyPerPage, true)
    };

    type UpdateCalendaryResponse = {
        calendary: Calendary;
        unavailability: {busy: [Int]; pending: [Int]};
    };

    func updateCalendary(housingId: HousingId): UpdateCalendaryResponse{
        switch (Map.get<HousingId, Housing>(housings, nhash, housingId)){
            case null {
                assert false; // La siguiente linea no se ejecuta nunca pero se requiere que todas las ramificaciones tengan una ultima linea con una expresion del tipo de retorno
                { calendary = {dayZero = 0; reservations = []} ; unavailability = {busy = []; pending = []}};
            };
            case ( ?housing ) {
                let startOfCurrentDayGMT = now() - now() % nanoSecPerDay ; // Timestamp inicio del dia actual en GTM + 0
                let daysSinceLastUpdate = (startOfCurrentDayGMT - housing.calendary.dayZero) / nanoSecPerDay;
                // El siguiente bloque funciona bien pero se puede acomodar mejor
                if(daysSinceLastUpdate > 0){      
                    var updateArray = Array.filter<Reservation>(
                        housing.calendary.reservations, 
                        func(x: Reservation): Bool {x.checkOut >= daysSinceLastUpdate}
                    );
                    updateArray := Prim.Array_tabulate<Reservation>(
                        updateArray.size(),
                        func x {{
                            updateArray[x] with 
                            checkIn = updateArray[x].checkIn - daysSinceLastUpdate;
                            checkOut = updateArray[x].checkOut -daysSinceLastUpdate    
                        }}
                    );
                    let busy = getUnaviabilityFromReservations(#ReservationType(updateArray));
                    let pending = getUnaviabilityFromReservations(#IdsReservation(housing.reservationsPending));
                    let unavailability = {busy; pending};
                    let calendary = {dayZero = startOfCurrentDayGMT; reservations = updateArray};
                    let housingUpdate = {housing with calendary; unavailability};
                    ignore Map.put<HousingId, Housing>(housings, nhash, housingId, housingUpdate);
                    return {calendary; unavailability};
                } else {
                    let busy = getUnaviabilityFromReservations(#ReservationType(housing.calendary.reservations));
                    let pending = getUnaviabilityFromReservations(#IdsReservation(housing.reservationsPending));
                    let unavailability = {busy; pending};
                    return {calendary = housing.calendary; unavailability }
                };
            }
        }
    };

    func getUnaviabilityFromReservations(input: {#ReservationType: [Reservation]; #IdsReservation : [Nat]}): [Int] {
        let bufferDaysUnavailable = Buffer.fromArray<Int>([]);
        let reservationsArray = switch input {
            case ( #ReservationType(reservationsArray)){ reservationsArray };
            case ( #IdsReservation(idsArray) ) {
                let bufferReservations = Buffer.fromArray<Reservation>([]);
                for (id in idsArray.vals()) {
                    switch (Map.get<Nat, Reservation>(reservationsPendingConfirmation, nhash, id)) {
                        case null { };
                        case (?reservation) { bufferReservations.add(reservation)}
                    };
                };
                Buffer.toArray<Reservation>(bufferReservations);
            }
        };       
        for (r in reservationsArray.vals()) {
            var dayOccuped = r.checkIn;
            while(dayOccuped < r.checkOut ) {
                bufferDaysUnavailable.add(dayOccuped);
                dayOccuped += 1;
            }
        };
        Array.sort(Buffer.toArray(bufferDaysUnavailable), Int.compare);    
            
        
    };

    func cleanPendingVerifications(housingId: Nat, ids: [Nat]): [Nat] { //Remueve las solicitudes no confirmadas y con el tiempo de confirmacion transcurrido;
        // TODO Esta funcion viola los principios solid ya que se encarga de limpiar las solicitudes pendientes tanto del Map general
        // como tambien los id de solicitudes de dentro de las estructuras de los housing y ademas devuelve un array con los ids vigentes 
        // correspondientes al HousingID pasado por parametro. Ealuar alguna refactorizacion
        var reservationsPendingForId = ids;
        for ((id, reservation) in Map.toArray<Nat, Reservation>(reservationsPendingConfirmation).vals()) {
            if (now() > reservation.date + TimeToPay) {
                print("Solicitud de reserva " # Nat.toText(id) # " Eliminada por timeout");
                ignore Map.remove<Nat, Reservation>(reservationsPendingConfirmation, nhash, id);
                let housing = Map.get<HousingId, Housing>(housings, nhash, reservation.housingId);
                switch housing {
                    case null { };
                    case (?housing) {
                        let reservationsPending = Array.filter<Nat>(
                            housing.reservationsPending,
                            func x = x != id
                        );
                        print("Id de solicitud " # Nat.toText(id) # " borrado\nreservas pendientes: ");
                        print(debug_show(reservationsPending)); // revisar el filter
                        if (id == housingId ) {
                            reservationsPendingForId := reservationsPending;
                            print("Id de reserva: " # Nat.toText(housingId));
                            print(debug_show(reservationsPendingForId))
                        };
                        ignore Map.put<HousingId, Housing>(housings, nhash, reservation.housingId, {housing with reservationsPending});
                    }
                }
            }
        };
        reservationsPendingForId
    };

    func getPendingReservations(ids: [Nat]): {pendings: [Reservation]; pendingReservUpdate: [Nat]}{
        let bufferReservations = Buffer.fromArray<Reservation>([]);
        let bufferReservUpdate = Buffer.fromArray<Nat>([]); 
        for (id in ids.vals()) {
            switch (Map.get<Nat, Reservation>(reservationsPendingConfirmation, nhash, id)) {
                case null {bufferReservUpdate.add(id)};
                case ( ?reservation ) {
                    // Si la solicitud es antigua se elimina del map y se devuelte el id para limpiar
                    if ( now() > reservation.date + TimeToPay) {
                        ignore Map.remove<Nat, Reservation>(reservationsPendingConfirmation, nhash, id);
                        print("reserva " # Nat.toText(id) # " eliminada");
                    } else {
                        bufferReservations.add(reservation);
                        bufferReservUpdate.add(id);
                    }  
                };
            };
        };
        {pendings = Buffer.toArray(bufferReservations); pendingReservUpdate = Buffer.toArray(bufferReservUpdate)}
    };

    func checkDisponibility(housingId: HousingId, chechIn: Int, checkOut: Int): Bool {
        switch (Map.get<HousingId, Housing>(housings, nhash, housingId)) {
            case (?housing) { 
                if(not housing.active) { return false } 
                else {
                    // let updatedCalendary = updateCalendary(housing.calendary);
                    let { calendary } = updateCalendary(housingId);
                    var checkDay = chechIn;
                    let {pendings; pendingReservUpdate} = getPendingReservations(housing.reservationsPending);
                    ignore Map.put<HousingId, Housing>(housings, nhash, housingId, {housing with reservationsPending = pendingReservUpdate});
                    while (checkDay < checkOut) {
                        for (occuped in calendary.reservations.vals()){
                            if(checkDay >= occuped.checkIn and checkDay < occuped.checkOut) {
                                return false;
                            };
                        };
                        if (pendingReservUpdate.size() > 0) {
                            print("Hay " # Nat.toText(pendingReservUpdate.size()) # " reservations pendientes");
                            for (bloqued in pendings.vals()){
                                print(debug_show(bloqued));
                                if(checkDay >= bloqued.checkIn and checkDay < bloqued.checkOut) {
                                    return false;
                                }; 
                            }
                        };
                        checkDay += 1;
                    };
                    return true
                }
            };
            case  _ { return false }
        };            
    };
    ////////// view reservations pendding /////////////////
    public query func endingReserv(): async () {
        print(debug_show(Map.toArray<Nat, Reservation>(reservationsPendingConfirmation)))
    };

    //////////////////////////////////////////////////////
    public shared query ({ caller }) func getMyHousingDisponibility({checkIn: Nat; checkOut: Nat; page: Nat; qtyPerPage: Nat}): async ResultHousingPaginate{
        let response = getHousingsPaginateByOwner(caller, page, qtyPerPage, true);
        switch response {
            case (#Ok({array; hasNext} )){
                let bufferResults = Buffer.fromArray<HousingPreview>([]);
                for(hostPreview in array.vals()){
                    if(checkDisponibility(hostPreview.housingId, checkIn, checkOut)){
                       bufferResults.add(hostPreview);
                    };
                };
                #Ok({array = Buffer.toArray<HousingPreview>(bufferResults); hasNext})
            };
            case (#Err(msg)) { #Err(msg) }
        }
    };

    // public func getDisponibilityById(housingId: Nat, period: {#M30; #M60; #M90; #M120} ): async {#Ok: [Int]; #Err: Text} { //Devuelve los dias no disponibles
    //   //TODO marcar los dias pendientes de confirmacion de reserva
    //     let housing = Map.get<HousingId, Housing>(housings, nhash, housingId);
    //     let maxPeriod: Int = switch period {
    //         case ( #M30 ) { 30 }; 
    //         case ( #M60 ) { 60 }; 
    //         case ( #M90 ) { 90 }; 
    //         case ( #M120) { 120 };
    //     };
    //     switch housing {
    //         case null { #Err(msg.NotHousing)};
    //         case (?housing) {
    //             if(not housing.active) { return #Err(msg.InactiveHousing)};
    //             let bufferDaysOccuped = Buffer.fromArray<Int>([]);
    //             let { calendary; unavailability } = updateCalendary(housingId);
    //             print(debug_show(calendary));
    //             for(reservation in calendary.reservations.vals()){
    //                 var dayOccuped = reservation.checkIn;
    //                 while (dayOccuped <= reservation.checkOut and dayOccuped < maxPeriod) {
    //                     bufferDaysOccuped.add(dayOccuped);
    //                     dayOccuped += 1;
    //                 };
    //                 if (dayOccuped >= maxPeriod) {return #Ok(Buffer.toArray(bufferDaysOccuped))}
    //             };
    //             #Ok(Buffer.toArray(bufferDaysOccuped))      
    //         }
    //     }
    // };

    public query func getAmenities({housingId: HousingId}): async ?Types.Amenities {
        let housing = Map.get<HousingId, Housing>(housings, nhash, housingId);
        switch housing {
            case null { null };
            case (?housing) {
                housing.amenities
            }
        }
    };

    ///////////////////////////// Reservations ////////////////////////////

    func blobToText(t: Blob): Text {
        var result = "";
        let chars = ["0", "1" , "2" , "3" ,"4" , "5" , "6" , "7" , "8" , "9" , "a" , "b" , "c" , "d" , "e" , "f"];
        for (c in Blob.toArray(t).vals()){
            result #= chars[Nat8.toNat(c) / 16];
            result #= chars[Nat8.toNat(c) % 16] 
        };
        result
    };

    func calculatePrice(price: ?Types.Price, days: Nat): Nat {
        switch price {
            case null {assert (false); 0 };
            case (?price) {
                var currentDiscount = 0;
                let discounts = Array.sort<{minimumDays: Nat; discount: Nat}>(
                    price.discountTable,
                    func (a, b) = if (a.minimumDays < b.minimumDays) { #less } else { #greater } 
                );
                for(discount in discounts.vals()){
                    print(debug_show(discount));
                    if(days < discount.minimumDays) { return (price.base * days) - (price.base * days * currentDiscount / 100) };
                    currentDiscount := discount.discount;   
                };
                return (price.base * days) - (price.base * days * currentDiscount / 100);
            }
        }
    };

    func putRequestReservationToHousing(housingId: HousingId, requestId: Nat) {
        let housing = Map.get<HousingId, Housing>(housings, nhash, housingId);
        switch housing {
            case null {assert false};
            case ( ?housing ) {
                let reservationsPending = Prim.Array_tabulate<Nat>(
                    housing.reservationsPending.size() + 1,
                    func x = if( x == 0 ) {requestId} else {housing.reservationsPending[x - 1]}
                );
                ignore Map.put<HousingId, Housing>(housings, nhash, housingId, {housing with reservationsPending});
            }
        } 
    };

    public shared ({ caller = requester }) func requestReservation({housingId: HousingId; checkIn: Nat; checkOut: Nat; guest: Text}): async TransactionResponse {
        let housing = Map.get<HousingId, Housing>(housings, nhash, housingId);
        if ( not Map.has<Principal, User>(users, phash, requester)) { return #Err(msg.NotUser)};
        switch housing {
            case null { #Err(msg.NotHousing)};
            case ( ?housing ) {
                if(checkDisponibility(housingId, checkIn, checkOut)){
                    lastReservationId += 1;
                    let amount = calculatePrice(housing.price, checkOut - checkIn);
                    let reservation: Reservation = {
                        date = now();
                        housingId;
                        reservationId = lastReservationId;
                        requester;
                        checkIn;
                        checkOut;
                        guest;
                        confirmated = false;
                        amount;
                        dataTransaction = null;
                    };
                    ignore Map.put<Nat, Reservation>(reservationsPendingConfirmation, nhash, lastReservationId, reservation);
                    putRequestReservationToHousing(housingId, lastReservationId);
                    
                    let dataTransaction: TransactionParams = {
                        // Se toma el account por defecto correspondiente al principal del dueño del Host
                        // Se puede establecer otro account proporcionado por el usuario 
                        to = blobToText(AccountIdentifier.accountIdentifier(housing.owner, AccountIdentifier.defaultSubaccount()));
                        amount = Nat64.fromNat(amount);
                    };
                    #Ok({transactionParams = dataTransaction; reservationId = lastReservationId});
                } else {
                    #Err(msg.NotAvalableAllDays)
                };           
            }
        } 
    };

    func verifyTransaction({from; to; amount}: DataTransaction, registeredAmount: Nat64): async Bool {
        // TODO Verificar tambien aca 
        return true; // Test
        if(amount != registeredAmount) { return false };
        let indexer_icp = actor("qhbym-qaaaa-aaaaa-aaafq-cai"): actor {
                get_account_identifier_transactions : 
                    shared query Indexer_icp.GetAccountIdentifierTransactionsArgs -> async Indexer_icp.GetAccountIdentifierTransactionsResult;
        };
        let result = await indexer_icp.get_account_identifier_transactions({max_results = 10; start = null; account_identifier = from});
        switch result {
            case (#Ok(response)) {
                for (transaction in response.transactions.vals()) {
                    let operation = transaction.transaction.operation;
                    switch operation {
                        case( #Transfer(tx)) {
                            if (tx.from == from and
                            tx.to == to and
                            tx.amount.e8s >= amount){
                                return true
                            }
                        };
                        case ( _ ) { }
                    }; 
                };
                false
            };
            case (#Err(_)) { false }
        }
    };

    public shared ({ caller }) func confirmReservation({reservationId: Nat; txData: DataTransaction}): async {#Ok: Reservation; #Err: Text} {
        let reservation = Map.remove<Nat, Reservation>(reservationsPendingConfirmation, nhash, reservationId);
        switch reservation {
            case null { #Err(msg.NotReservation)};
            case ( ?reservation ){
                if (await verifyTransaction(txData, Nat64.fromNat(reservation.amount))){
                    if(reservation.requester != caller) { 
                        return #Err(msg.CallerIsNotRequester # Nat.toText(reservationId))
                    };
                    let housing = Map.get<HousingId, Housing>(housings, nhash, reservation.housingId);
                    switch housing {
                        case null { #Err(msg.NotHousing)};
                        case ( ?housing ) {
                            let calendary = {
                                housing.calendary with
                                reservations = Prim.Array_tabulate<Reservation>(
                                housing.calendary.reservations.size() + 1,
                                func x = if (x == 0) { 
                                    {   
                                        reservation with 
                                        confirmated = true; 
                                        dataTransaction = ?txData 
                                    } 
                                    } else { 
                                        housing.calendary.reservations[x - 1] 
                                    }
                                )
                            };
                            print(debug_show(calendary));
                            let reservationsPending = Array.filter<Nat>(
                                housing.reservationsPending,
                                func x = x !=reservationId
                            );
                            ignore Map.put<HousingId, Housing>(
                                housings, 
                                nhash, 
                                reservation.housingId, 
                                { housing with calendary; reservationsPending }
                            );
                            #Ok({ reservation with confirmated = true })
                        }
                    }
                } else {
                    #Err(msg.TransactionNotVerified)
                };        
            }
        }
        
    };

    // public shared query ({ caller }) func getReservations({housingId: Nat}): async {#Ok: [(Nat, Reservation)]; #Err: Text}{
    //     let housing = Map.get<HousingId, Housing>(housings, nhash, housingId);
    //     switch housing {
    //         case null {#Err(msg.NotHousing)};
    //         case ( ?housing ) {
    //             if(housing.owner != caller ){
    //                 return #Err(msg.CallerNotHousingOwner);
    //             };
    //             #Ok(Map.toArray<Nat, Reservation>(housing.reservationRequests))
    //         }
    //     }
    // }
  

};

