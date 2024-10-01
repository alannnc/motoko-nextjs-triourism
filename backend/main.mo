import Map "mo:map/Map";
import { phash } "mo:map/Map";
import Types "types";

actor {

    type User = Types.User;
    type UserKind = Types.UserKind;
    type ResultSignUp = { #Ok : User; #Err : User };

    stable let users = Map.new<Principal, User>();

    ///////////////////////////////////// Update functions ////////////////////////////////////////

    public shared ({ caller }) func signUp(data: Types.SignUpData) : async ResultSignUp {
        let user = Map.get(users, phash, caller);
        switch user {
            case (?User) { #Err(User) };
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
    ///////////////////////////////////////////////////////////////////////////////////

    //////////////////////////////// CRUD Listing /////////////////////////////////////

    



};
