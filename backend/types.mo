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
        #Host: [HousingId];
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

  ///////////////////////////////// Housing /////////////////////////////////
    
    public type HousingDataInit = {
        // owner: Principal;
        minReservationLeadTimeHours: Int; //valor en horas de anticipación para efectuar una reserva
        address: Text;
        prices: [Price];
        kind: HousingKind;
    };


    public type Housing = {
        id: Nat; // Example L234324
        owner: Principal;
        calendar: [var CalendaryPart];
        reservationRequests: Map.Map<Nat, Reservation>; 
        minReservationLeadTimeNanoSeg: Int; // valor en nanosegundos de anticipacion para efectuar una reserva
        address: Text;
        photos: [Blob];
        thumbnail: Blob; // Se recomienda la foto principal en tamaño reducido
        prices: [Price];
        kind: HousingKind;
    };

    public type HousingResponse = {
        #Start : {id: Nat;
            owner: Principal;
            calendar: [CalendaryPart];
            photo: Blob;
            thumbnail: Blob;
            prices: [Price];
            kind: HousingKind;
            hasNextPhoto: Bool;
        };
        #OnlyPhoto :{
            photo: Blob;
            hasNextPhoto: Bool;
        }
    };

    public type HousingPreview = {
        id: Nat;
        address: Text;
        thumbnail: Blob;
        prices: [Price];
    };

    public type HousingId = Nat;

    public type UpdateResult = {
        #Ok;
        #Err: Text;
    };

    public type HousingKind = {
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

    public type ReviewsId = Text;
  ///////////////////////////////// Reservations /////////////////////////////

    public type Reservation = {
        checkIn: Int;   //Timestamp NanoSeg
        checkOut: Int;  //Temestamp NanoSeg 
        applicant: Principal;
        guest: Text;
    };

    // La primer posicion es siempre el dia actual con lo cual cada vez que se consulta se tiene que actualizar antes
    // Para facilitar la implementacion inicial se considera una lista de Disponibility mutable de 30 posiciones
    public type Disponibility = {day: Int; available: Bool};
    // public type Calendar = [var Disponibility];

    // El rango de no disponibilidad se establece con el campo day y el campo checkOut de reservation
    public type CalendaryPart = Disponibility and {reservation: ?Reservation};
    // public type Calendary = [var CalendaryPart];

    // public type FrozenCalendar = [CalendaryPart]



} 

    