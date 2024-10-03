import Prim "mo:⛔";
import Map "mo:map/Map";
import { phash; nhash } "mo:map/Map";
import Principal "mo:base/Principal";
import Types "types";

actor {

    type User = Types.User;
    type UserKind = Types.UserKind;
    type SignUpResult = Types.SignUpResult;
    type Calendar = Types.Calendar;
    type ListingId = Types.ListingId;
    type ListingDataInit = Types.ListingDataInit;
    type Listing = Types.Listing;
    type UpdateResult = Types.UpdateResult;
    type ListingPreview = Types.ListingPreview;

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
            case null {
                return #Err("Usuario no registrado");
            };
            case (?user){
                if(not userIsVerificated(caller)){
                    return #Err("Usuario no verificado");
                };
                lastListingId += 1;
                let newListing: Listing = {
                    owner = caller;
                    id = lastListingId;
                    calendar: Calendar = {reservations = []};
                    photos = data.photos;
                    address = data.address;
                    price = data.price;
                    kind = data.kind;
                };
                var updateListingArray: [ListingId] = [];
                var notPrevious = true;
                var position = 0;
                var i = 0;
                while(i < user.userKind.size()){
                    switch (user.userKind[i]){
                        case(#Host(listingIdArray)){
                            notPrevious := false;
                            position := i;
                            updateListingArray := Prim.Array_tabulate<ListingId>( 
                                listingIdArray.size() + 1,
                                func x {
                                    if(x != listingIdArray.size()){
                                       listingIdArray[x];
                                    }
                                    else {newListing.id}
                                }
                            )
                        };
                        case(_){};
                    };
                    i += 1;
                };
                if(notPrevious){ updateListingArray := [newListing.id] };
                let updateKinds = Prim.Array_tabulate<UserKind>(
                    user.userKind.size() + (if(notPrevious){ 1 } else { 0 }),
                    func i { if(i == position) {
                            #Host(updateListingArray)
                        }
                        else {
                            user.userKind[i]
                        }
                    }
                );
                ignore Map.put<ListingId, Listing>(listings, nhash, lastListingId, newListing);
                ignore Map.put<Principal,User>(users, phash, caller, {user with userKind = updateKinds});
                return #Ok(newListing.id)
            }
        };
    };

    public func getListingPreviews(): async [ListingPreview] {
        let values = Map.toArray<ListingId, Listing>(listings);
        Prim.Array_tabulate<ListingPreview>(
            values.size(),
            func x {
                {
                    id = values[x].1.id;
                    address = values[x].1.address;
                    photos = values[x].1.photos;
                    price =values[x].1.price;
                }
            }

        );
    };

    public shared ({ caller }) func updatePrices(id: ListingId, updatedPrices: Types.Price): async  UpdateResult{
        let listing = Map.get(listings, nhash, id);
        switch listing {
            case null {
                return #Err("Error Listing ID");
            };
            case (?listing) {
                if(listing.owner != caller){ return #Err("Unauthorized caller") };
                ignore Map.put<ListingId, Listing>(listings, nhash, id, {listing with prices = updatedPrices});
                return #Ok
            };
        } 
    };
    



};
