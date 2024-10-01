import Map "mo:map/Map";

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

  ///////////////////////////////// Listing /////////////////////////////////
    
    public type Listing = {
        calendarId: Nat;
        id: Text; // Example L234324
        address: Text;
        price: Price;
        kind: ListingKind;
    };

    type ListingId = Text;

    public type ListingKind = {
        #House;
        #Hotel_room;
        #RoomWithSharedSpaces: [Rules]; //Hostels/Pensiones
    };

    public type Price = {
        #PerNight: Nat;
        #PerWeek: Nat;
        #CustomPeriod: Map.Map<Nat8, Nat> // Cantidad de dias/Precio. Aplicable a partir de 3 por ejemplo
    };

    public type Rules = { // Ejemplo de Rule: {key = "Horarios"; value = "Sin ruidos molestos entre las 22:00 y las 8:00"}
        key: Text;
        value: Text
    };

  ///////////////////////////////// Reservations /////////////////////////////

    public type Reservations = {

    };
    


    type ReviewsId = Text;

} 

    