import Prim "mo:⛔";
import Map "mo:map/Map";
import Set "mo:map/Set";
import { phash; nhash } "mo:map/Map";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Blob "mo:base/Blob";
import Types "types";
import Int "mo:base/Int";
import { now } "mo:base/Time";
import Rand "mo:random/Rand";
import msg "constants";

////////////// Debug imports ////////////////
import { print } "mo:base/Debug";
 
shared ({ caller }) actor class Triourism () = this {

    type User = Types.User;
    type UserKind = Types.UserKind;
    type SignUpResult = Types.SignUpResult;
    type CalendaryPart = Types.CalendaryPart;
    type Reservation = Types.Reservation;
    type HousingId = Types.HousingId;
    type HousingDataInit = Types.HousingDataInit;
    type Housing = Types.Housing;
    type HousingResponse = Types.HousingResponse;
    type HousingPreview = Types.HousingPreview;

    type UpdateResult = Types.UpdateResult;
    type ResultHousingPaginate = {#Ok: {array: [HousingPreview]; next: Bool}; #Err: Text};
    type PublishResult = {#Ok: HousingId; #Err: Text};

    type ReservationResult = {
        #Ok: {
            reservationId: Nat;
            houstingId: HousingId;
            data: Reservation;
            paymentCode: Nat;
            msg: Text;   
        };
        #Err: Text;        
    };

    // TODO revisar day, actualemnte es el timestamp de una hora especifica que delimita el comienzo del dia 
    
  
    stable let DEPLOYER = caller;
    let NANO_SEG_PER_HOUR = 60 * 60 * 1_000_000_000;
    let ramdomGenerator = Rand.Rand();

    // stable var minReservationLeadTime = 24 * 60 * 60 * 1_000_000_000; // 24 horas en nanosegundos
    
    stable let admins = Set.new<Principal>();
    ignore Set.put<Principal>(admins, phash, caller);
    stable let users = Map.new<Principal, User>();
    stable let housings = Map.new<HousingId, Housing>();
    // stable let calendars = Map.new<HousingId, Calendar>();

    stable var lastHousingId = 0;
    

  ///////////////////////////////////// Update functions ////////////////////////////////////////

    public shared ({ caller }) func signUp(data: Types.SignUpData) : async SignUpResult {
        if(Principal.isAnonymous(caller)){
            return #Err(msg.NotUser)
        };
        let user = Map.get(users, phash, caller);
        switch user {
            case (?User) { #Err("User already exists") };
            case null {
                let newUser: User = {
                    userKind: [UserKind] = [];
                    name = data.name;
                    email = data.email;
                    verified = true;
                    score = 0;
                    avatar = data.avatar;
                };
                ignore Map.put(users, phash, caller, newUser);
                #Ok(newUser);
            };
        };
    };

    public shared query ({ caller }) func logIn(): async {#Ok: User; #Err} {
        let user = Map.get<Principal, User>(users, phash, caller);
        switch user {
            case null { #Err };
            case ( ?u ) { #Ok(u)}
        };
    };

    //////////////////////////////// CRUD Data User ///////////////////////////////////

    public shared ({ caller }) func loadAvatar(avatar: Blob): async {#Ok; #Err: Text} {
        let user = Map.get<Principal, User>(users, phash, caller);
        switch user {
            case null {#Err(msg.NotUser)};
            case(?user) {
                ignore Map.put<Principal, User>(users, phash, caller, {user with avatar = ?avatar});
                #Ok
            }
        }
    };
    // TODO
    ///////////////////////////////////////////////////////////////////////////////////

  ///////////////////////////// Private functions ///////////////////////////////////
    func isAdmin(p: Principal): Bool { Set.has<Principal>(admins, phash, p) };

    func isUser(p: Principal): Bool { Map.has<Principal, User>(users, phash, p)};

    func initCalendary(): [var CalendaryPart]{
        Prim.Array_init<CalendaryPart>(
            30,
            {day= 0; available = true; reservation = null}
        )
    };

    func freezeCalendar(c: [var CalendaryPart]): [CalendaryPart]{
        Prim.Array_tabulate<CalendaryPart>(c.size(), func i = c[i])
    };

    func updateCalendar(c: [var CalendaryPart]): [var CalendaryPart] {
        var indexDay = 0;
        var displace = 0;
        while(now() + NANO_SEG_PER_HOUR * 24 > c[indexDay].day){
            displace += 1;
            indexDay += 1;
        };
        let outPutArray = c;
        var index = 0;
        while(index + displace <= c.size()){
            outPutArray[index] := c[index + displace];
            outPutArray[index + displace] := {day =  0; available = true; reservation = null};
            index += 1;
        };
        outPutArray;
    };

    func availableAllDaysResquest(checkin: Int, checkout: Int): Bool{
        // Consultar caledario del Hosting y reservationRequests
        true
    };

    func intToNat(x: Int): Nat{
        Prim.nat64ToNat(Prim.intToNat64Wrap(x))
    };
    /////////// Probar ////////////
    func insertReservationToCalendar(_calendar: [var CalendaryPart], reserv: Reservation): {#Ok: [var CalendaryPart]; #Err }{
        let calendar = updateCalendar(_calendar); // Nos aseguramos de que el primer elemnto del array sea el dia actual
        let checkInDay = intToNat((reserv.checkIn - now())) / 24 * NANO_SEG_PER_HOUR;
        let daysQty = intToNat(reserv.checkOut - reserv.checkIn) / 24 * NANO_SEG_PER_HOUR;
        var index = checkInDay;
        var okBaby = true;
        while (index < checkInDay + daysQty){
            if (not calendar[index].available) { 
                okBaby := false;
                index += daysQty;
            };
            index += 1;
        };
        if( okBaby ) {
            index := checkInDay;
            while (index < checkInDay + daysQty){
                let calendaryPart: CalendaryPart = { 
                    reservation = ?reserv;
                    day = index * 24 * NANO_SEG_PER_HOUR;
                    available = false;
                };
                calendar[index] := calendaryPart;
                index += 1;
            };
            #Ok(calendar)
        } else {
            #Err
        }

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

    func userIsVerificated(u: Principal): Bool {
        let user = Map.get<Principal,User>(users, phash, u);
        switch user{
            case null { false };
            case (?user) { user.verified};
        };
    };

  //////////////////////////////// CRUD Housing ////////////////////////////////////////////

    public shared ({ caller }) func publishHousing(data: HousingDataInit): async PublishResult {     
        let user = Map.get<Principal, User>(users, phash, caller);
        switch user {
            case null {
                return #Err(msg.NotUser);
            };
            case (?user){
                if(not userIsVerificated(caller)){
                    return #Err(msg.NotVerifiedUser);
                };
                lastHousingId += 1;
                let newHousing: Housing = {
                    reservationRequests = Map.new<Nat, Reservation>();
                    owner = caller;
                    minReservationLeadTimeNanoSeg = data.minReservationLeadTimeHours * NANO_SEG_PER_HOUR;
                    id = lastHousingId;
                    calendar: [var CalendaryPart] = initCalendary();
                    photos: [Blob] = [];
                    thumbnail: Blob = "";
                    address = data.address;
                    prices = data.prices;
                    kind = data.kind;
                };
                var updateHousingArray: [HousingId] = [];
                var notPrevious = true;
                var position = 0;
                var i = 0;
                while(i < user.userKind.size()){
                    switch (user.userKind[i]){
                        case(#Host(housingIdArray)){
                            notPrevious := false;
                            position := i;
                            updateHousingArray := Prim.Array_tabulate<HousingId>( 
                                housingIdArray.size() + 1,
                                func x {
                                    if(x != housingIdArray.size()){
                                       housingIdArray[x];
                                    }
                                    else {newHousing.id}
                                }
                            )
                        };
                        case(_){};
                    };
                    i += 1;
                };
                if(notPrevious){ updateHousingArray := [newHousing.id] };
                let updateKinds = Prim.Array_tabulate<UserKind>(
                    user.userKind.size() + (if(notPrevious){ 1 } else { 0 }),
                    func i { if(i == position) {
                            #Host(updateHousingArray)
                        }
                        else {
                            user.userKind[i]
                        }
                    }
                );
                ignore Map.put<HousingId, Housing>(housings, nhash, lastHousingId, newHousing);
                ignore Map.put<Principal,User>(users, phash, caller, {user with userKind = updateKinds});
                return #Ok(newHousing.id)
            }
        };
    };

    public shared ({ caller }) func addPhotoToHousing({id: HousingId; photo: Blob}): async {#Ok; #Err: Text} {
        let housing = Map.get<HousingId, Housing>(housings, nhash, id);
        switch housing {
            case null {
                #Err("Invalid Housing Id")
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
                #Ok
            }
        }
    };

    public shared ({ caller }) func addThumbnailToHousing({id: HousingId; thumbnail: Blob}): async {#Ok; #Err: Text} {
        let housing = Map.get<HousingId, Housing>(housings, nhash, id);
        switch housing {
            case null {
                #Err(msg.NotHosting)
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

    public shared ({ caller }) func updatePrices({id: HousingId; prices: [Types.Price]}): async  UpdateResult{
        let housing = Map.get(housings, nhash, id);
        switch housing {
            case null {
                return #Err(msg.NotHosting);
            };
            case (?housing) {
                if(housing.owner != caller){ return #Err(msg.UnauthorizedCaller) };
                ignore Map.put<HousingId, Housing>(housings, nhash, id, {housing with prices});
                return #Ok
            };
        } 
    };

    public shared ({ caller }) func setMinReservationLeadTime({id: HousingId; hours: Nat}):async  {#Ok; #Err: Text} {
        let housing = Map.get<HousingId, Housing>(housings, nhash, id);
        switch housing {
            case null {
                return #Err(msg.NotHosting);
            };
            case (?housing) {
                if(housing.owner != caller){
                    return #Err(msg.CallerNotHousingOwner);
                };
                ignore Map.put<HousingId, Housing>(
                    housings, 
                    nhash, 
                    id, 
                    {housing with minReservationLeadTimeNanoSeg = hours * NANO_SEG_PER_HOUR});
                #Ok;
            }

        }
    };


  ////////////////////////////////// Getters ///////////////////////////////////////////////

    public query func getHousingPaginate(page: Nat): async ResultHousingPaginate {
        if(Map.size(housings) < page * 10){
            return #Err(msg.PaginationOutOfRange)
        };
        let values = Map.toArray<HousingId, Housing>(housings);
        let bufferHousingPreview = Buffer.fromArray<Housing>([]);
        var index = page * 10;
        while (index < values.size() and index < (page + 1) * 10){
            bufferHousingPreview.add(values[index].1);
            index += 1;
        };
        #Ok{
            array = Buffer.toArray<Housing>(bufferHousingPreview);
            next = ((page + 1) * 10 < values.size())
        }
    };

    public query func getHousingById({housingId: HousingId;  photoIndex: Nat}): async {#Ok: HousingResponse; #Err: Text} {
        let housing = Map.get<HousingId, Housing>(housings, nhash, housingId);
        return switch housing {
            case null { #Err(msg.NotHosting)};
            case (?housing) {
                if(photoIndex == 0){
                    let housingResponse: HousingResponse = #Start({
                        housing with
                        calendar = freezeCalendar(housing.calendar);
                        photo = housing.photos[photoIndex];
                        hasNextPhoto = photoIndex < housing.photos.size()
                    });
                    #Ok(housingResponse);
                } else {
                    let housingResponse: HousingResponse = #OnlyPhoto({
                        housing with
                        photo = housing.photos[photoIndex];
                        hasNextPhoto = photoIndex < housing.photos.size()
                    });
                    #Ok(housingResponse)
                }
            };
        }
    };

  ///////////////////////////////// Reservations ///////////////////////////////////////////

    public shared ({ caller }) func requestReservation({hostId: HousingId; data: Reservation}):async ReservationResult {
        let housing = Map.get<HousingId, Housing>(housings, nhash, hostId);
        switch housing {
            case null {
                #Err(msg.NotHosting);
            };
            case (?housing) {
                /////// housing calendar update / housing Map update //////
                let calendar = updateCalendar(housing.calendar);
                ignore Map.put<HousingId, Housing>(housings, nhash, hostId, {housing with calendar});

                ///////////////////////////////////////////////////// DEBUGIN //////////////////////////////////////////////////////////
                print("Momento actual en NanoSeg:  " # Int.toText(now()));
                print("horas de anticipacio:       " # Int.toText(housing.minReservationLeadTimeNanoSeg ));
                print("Reserva a partir de fecha:  " # Int.toText((now() + housing.minReservationLeadTimeNanoSeg)));
                print("Fecha de ingreso silicitada " # Int.toText(data.checkIn));
                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

                if(now() + housing.minReservationLeadTimeNanoSeg > data.checkIn){ 
                    return #Err("Reservations are requested at least " #
                    Int.toText(housing.minReservationLeadTimeNanoSeg /(NANO_SEG_PER_HOUR)) #
                    " hours in advance.");
                };
                if(availableAllDaysResquest(data.checkIn, data.checkOut)){
                    let reservationId = await ramdomGenerator.randRange(1_000_000_000, 9_999_999_999);
                    let responseReservation = {
                        houstingId = hostId;
                        reservationId;
                        data;
                        msg = msg.PayRequest;
                        paymentCode = await ramdomGenerator.randRange(1_000_000_000_000_000_000_000, 9_999_999_999_999_999_999_999)
                    };
                    ignore Map.put<Nat, Reservation>(housing.reservationRequests, nhash, reservationId, data );
                    #Ok( responseReservation )
                } else {
                    #Err( msg.NotAvalableAllDays);
                }
            };
        }    
    };

    func paymentVerification(txHash: Nat):async Bool{
        // TODO protocolo de verificacion de pago
        true
    };

    public shared ({ caller }) func confirmReservation({reservId: Nat; hostId: HousingId; txHash: Nat}): async {#Ok; #Err: Text}{
        let housing = Map.get<HousingId, Housing>(housings, nhash, hostId);
        switch housing {
            case null { #Err(msg.NotHosting) };
            case ( ?housing ) {
                let updatedCalendar = updateCalendar(housing.calendar);
                ignore Map.put<HousingId, Housing>(housings, nhash, hostId, {housing with updatedCalendar}); 
                let reserv = Map.remove<Nat, Reservation>(housing.reservationRequests, nhash, reservId);
                switch reserv {
                    case null { #Err(msg.NotReservation) };
                    case ( ?reserv ) {
                        if(caller != reserv.applicant) {
                            return #Err(msg.CallerIsNotrequester)
                        };
                        // TODO Verificacion datos de pago a traves del txHhahs
                        if (await paymentVerification(txHash)){
                            let calendar = insertReservationToCalendar(updatedCalendar, reserv);
                            switch calendar {
                                case (#Ok(calendar)) {

                                    ignore Map.put<HousingId, Housing>(housings, nhash, hostId, {housing with calendar});
                                    return #Ok
                                };
                                case (_) { 
                                    ignore Map.put<Nat, Reservation>(housing.reservationRequests, nhash, reservId, reserv);
                                    return #Err("Error") 
                                }
                            }
                        };
                        #Err("Incorrect payment verification")

                    }
                }
            }
        }

        
    };

};
