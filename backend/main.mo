import Prim "mo:⛔";
import Map "mo:map/Map";
import Set "mo:map/Set";
import { phash; nhash } "mo:map/Map";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Blob "mo:base/Blob";
import Types "types";

shared ({ caller }) actor class Triourism () = this {

    type User = Types.User;
    type UserKind = Types.UserKind;
    type SignUpResult = Types.SignUpResult;
    type Calendar = Types.Calendar;
    type HousingId = Types.HousingId;
    type HousingDataInit = Types.HousingDataInit;
    type Housing = Types.Housing;
    type UpdateResult = Types.UpdateResult;
    type HousingPreview = Types.HousingPreview;
    type ResultHousingPaginate = {#Ok: {array: [HousingPreview]; next: Bool}; #Err: Text};

    type PublishResult = {#Ok: HousingId; #Err: Text};

    stable let DEPLOYER = caller;
    
    stable let admins = Set.new<Principal>();
    ignore Set.put<Principal>(admins, phash, caller);
    stable let users = Map.new<Principal, User>();
    stable let housings = Map.new<HousingId, Housing>();
    // stable let calendars = Map.new<HousingId, Calendar>();

    stable var lastHousingId = 0;
    

    ///////////////////////////////////// Update functions ////////////////////////////////////////

    public shared ({ caller }) func signUp(data: Types.SignUpData) : async SignUpResult {
        if(Principal.isAnonymous(caller)){
            return #Err("User not autenthicated")
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
    // TODO
    ///////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////// Private functions ///////////////////////////////////
    func isAdmin(p: Principal): Bool { Set.has<Principal>(admins, phash, p) };

    func isUser(p: Principal): Bool { Map.has<Principal, User>(users, phash, p)};


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

    
  /////////////////////////////// Verification process //////////////////////////////
    // TODO actualmente todos los usuarios se inicializan como verificados

    func userIsVerificated(u: Principal): Bool {
        let user = Map.get<Principal,User>(users, phash, u);
        switch user{
            case null { false };
            case (?user) { user.verified};
        };
    };

  //////////////////////////////// CRUD Housing /////////////////////////////////////

    public shared ({ caller }) func publishHousing(data: HousingDataInit): async PublishResult {     
        let user = Map.get<Principal, User>(users, phash, caller);
        switch user {
            case null {
                return #Err("Usuario no registrado");
            };
            case (?user){
                if(not userIsVerificated(caller)){
                    return #Err("Usuario no verificado");
                };
                lastHousingId += 1;
                let newHousing: Housing = {
                    owner = caller;
                    id = lastHousingId;
                    calendar: Calendar = {reservations = []};
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
                    return #Err("The caller is not the owner of the housing")
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
                #Err("Invalid Housing Id")
            };
            case (?housing) {
                if(housing.owner != caller){
                    return #Err("The caller is not the owner of the housing")
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
                return #Err("Error Housing ID");
            };
            case (?housing) {
                if(housing.owner != caller){ return #Err("Unauthorized caller") };
                ignore Map.put<HousingId, Housing>(housings, nhash, id, {housing with prices});
                return #Ok
            };
        } 
    };


  ////////////////////////////////// Getters ///////////////////////////////////////////

    public query func getHousingPaginate(page: Nat): async ResultHousingPaginate {
        if(Map.size(housings) < page * 10){
            return #Err("Pagination index out of range")
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

    public query func getHousingById(id: HousingId): async {#Ok: Housing; #Err: Text} {
        let housing = Map.get<HousingId, Housing>(housings, nhash, id);
        return switch housing {
            case null { #Err("Error Housing ID")};
            case (?housing) {
                #Ok(housing);
            };
        }
    };



};
