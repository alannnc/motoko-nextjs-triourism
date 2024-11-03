import Map "mo:map/Map";
module {
  ////////////////////////////// Users /////////////////////////////////////

    public type SignUpData = {
        name: Text;
        lastName: Text;
        phone: ?Nat;
        email: Text;
        //avatar: ?Blob;
    };

    public type User = SignUpData and {
        // id: Nat;
        kinds: [UserKind];
        // userKind: UserKind;
        verified: Bool;
        score: Nat;    
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
        minReservationLeadTimeNanoSec: Int; //valor en nanoSeg de anticipación para efectuar una reserva
        address: Text;
        prices: [Price];
        kind: HousingKind;
        maxCapacity: Nat;
        description: Text; 
        amenities: [Text];
    };


    public type Housing = HousingDataInit and {

        id: Nat; // Example L234324
        owner: Principal;
        calendar: [var CalendaryPart];
        reservationRequests: Map.Map<Nat, Reservation>;
        reviews: [Text];
        photos: [Blob];
        thumbnail: Blob; // Se recomienda la foto principal en tamaño reducido
        active: Bool;
    };

    public type HousingResponse = {
        #Start : {id: Nat;
            owner: Principal;
            calendar: [CalendaryPart];
            photo: Blob;
            thumbnail: Blob;
            prices: [Price];
            kind: HousingKind;
            maxCapacity: Nat;
            description: Text;
            amenities: [Text]; 
            hasNextPhoto: Bool;
            reviews: [Text];
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
        #Hotel_room: Text; //Ejemplo #Hotel_room("Single Room")
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

    public type ReservationDataInput = {
        checkIn: Int;   //Timestamp NanoSeg
        checkOut: Int;  //Temestamp NanoSeg
        guest: Text;
    };
        
    public type Reservation = ReservationDataInput and {
        applicant: Principal;
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

    