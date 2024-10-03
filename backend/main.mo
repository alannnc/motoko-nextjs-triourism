import Map "mo:map/Map";
import { phash; nhash } "mo:map/Map";
import Principal "mo:base/Principal";
import Types "types";

actor {

    type User = Types.User;
    type UserKind = Types.UserKind;
    type SignUpResult = Types.SignUpResult;
    type Calendar = Types.Calendar;
    type ListingId = Nat;
    type ListingDataInit = Types.ListingDataInit;
    type Listing = Types.Listing;

    type PublishResult = {#Ok: ListingId; #Err: Text};
    

    stable let users = Map.new<Principal, User>();
    stable let listings = Map.new<ListingId, Listing>();
    // stable let calendars = Map.new<ListingId, Calendar>();

    stable var lastListingId = 0;
    

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
                    verified = false;
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

    /////////////////////////////// Verification process //////////////////////////////
    // TODO

    func userIsVerificated(u: Principal): Bool {
        let user = Map.get<Principal,User>(users, phash, u);
        switch user{
            case null { false };
            case (?user) { user.verified};
        };
    };
    ///////////////////////////////////////////////////////////////////////////////////

    //////////////////////////////// CRUD Listing /////////////////////////////////////

    public shared ({ caller }) func publishListing(data: ListingDataInit): async PublishResult {
        
        let user = Map.get<Principal, User>(users, phash, caller);
        switch user {
            case null {return #Err("Usuario no registrado")};
            case (?User){
                if(not userIsVerificated(caller)){ return #Err("Usuario no verificado") };
                lastListingId += 1;
                let newListing: Listing = {
                    owner = caller;
                    id = lastListingId;
                    calendar: Calendar = {reservations = []};
                    address = data.address;
                    price = data.price;
                    kind = data.kind;
                };

                ignore Map.put<ListingId, Listing>(listings, nhash, lastListingId, newListing);


            }
        };


        


        /* init
         public type ListingDataInit = {
            owner: Principal;
            address: Text;
            price: Price;
            kind: ListingKind;
        };
        */



    }



};
