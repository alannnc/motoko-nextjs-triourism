
module {
  ////////////////////////////// Users /////////////////////////////////////

    public type SignUpData = {
        name: Text;
        email: ?Text;
        avatar: ?Blob;
    };

    public type User = {
        // id: Nat;
        userKind: [UserKind];   //Un user Host puede ser ademas un User 
        name: Text;
        email: ?Text;
        verified: Bool;
        score: Nat;
        avatar: ?Blob;
        
    };

    public type UserKind = {
        #Initial;
        #Guest: [ReviewsId];
        #Host: [ListingId];
    };

    public type SignUpResult = { #Ok : User; #Err : Text };
    // type GetProfileError = {
    //     #userNotAuthenticated;
    //     #profileNotFound;
    // };

    // type CreateProfileError = {
    //     #profileAlreadyExists;
    //     #userNotAuthenticated;
    // };

  ///////////////////////////////// Listing /////////////////////////////////
    
    public type ListingDataInit = {
        // owner: Principal;
        address: Text;
        price: Price;
        kind: ListingKind;
        photos: [Blob];
    };


    public type Listing = {
        id: Nat; // Example L234324
        owner: Principal;
        calendar: Calendar;
        address: Text;
        photos: [Blob];
        price: Price;
        kind: ListingKind;
    };

    public type ListingPreview = {
        id: Nat;
        address: Text;
        photos: [Blob];
        price: Price;
    };

    public type ListingId = Nat;

    public type UpdateResult = {
        #Ok;
        #Err: Text;
    };

    public type ListingKind = {
        #House;
        #Hotel_room;
        #RoomWithSharedSpaces: [Rules]; //Hostels/Pensiones
    };

    public type Price = {
        #PerNight: Nat;
        #PerWeek: Nat;
        #CustomPeriod: [{dais: Nat; price: Nat}];
    };

    public type Rules = { // Ejemplo de Rule: {key = "Horarios"; value = "Sin ruidos molestos entre las 22:00 y las 8:00"}
        key: Text;
        value: Text
    };

  ///////////////////////////////// Reservations /////////////////////////////

    public type Reservation = {
        checkIn: Int; //Timestamp
        checkOut: Int;
        applicant: Principal;
        guest: Text;
    };

    type ReviewsId = Text;

    type Node<T> = {
        value: T;
        rigth: ?Node<T>;
        left: ?Node<T>;
    };

    // public func initTree<T>(value: T): Node<T> {
    //     {value; rigth = null; left = null};
    // };

    // public func put<T>(value: T, f: (T,T) -> {#before; #after}): {#before; #after} {
        
    // };

    public type Calendar = {
        //LinstingId: Nat;
        reservations: [Reservation]; //TODO La lista debe estar ordenada y sin solapamientos ver metodos de inserción

    }

} 

    