import Map "mo:map/Map";
import Nat "mo:base/Nat";
module {
  ////////////////////////////// Users /////////////////////////////////////

    public type SignUpData = {
        firstName: Text;
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


    public type HousingCreateData = {
        namePlace: Text;
        nameHost: Text;
        descriptionPlace: Text;
        descriptionHost: Text;
        link: Text;
        photos: [Blob];
        thumbnail: Blob;

    };

    public type Rule = {
        #PetsAllowed: Bool;
        #SmookingAllowed: Bool;
        #PartiesAllowed: Bool;
        #AdditionalGuests: Bool;
        #NoiseAfter10pm: Bool;
        #ParkOnTheStreet: Bool;
        #CustomRule: {rule: Text; allowed: Bool};
    };

    public type Housing = HousingCreateData and {
        active: Bool;
        id: Nat;
        prices: [Price];
        owner: Principal;
        rules: [Rule];
        checkIn: Int;
        checkOut: Int;
        address: Text;
        properties: [Property];
        amenities: [Text]      
    };


    public type Property = {
        nameType: Text;
        beds: [BedKind]; 
        bathroom: Bool;
        maxGuest: Nat;
        extraGuest: Nat;
    };

    // public type HousingDataInit = {
    //     minReservationLeadTimeNanoSec: Int; //valor en nanoSeg de anticipación para efectuar una reserva
    //     address: Text;
    //     prices: [Price];
    //     kind: HousingKind;
    //     maxCapacity: Nat;
    //     description: Text;
    //     rules: [Text];
    //     amenities: [Text];
    //     properties: [Property];
    // };

    // public type Housing = HousingDataInit and {

    //     id: Nat; // Example L234324
    //     owner: Principal;
    //     calendar: [var CalendaryPart];
    //     reservationRequests: Map.Map<Nat, Reservation>;
    //     reviews: [Text];
    //     photos: [Blob];
    //     thumbnail: Blob; // Se recomienda la foto principal en tamaño reducido
    //     active: Bool;
    // };

    type BedKind = {
        #Single: Nat;
        #Matrimonial: Nat;
        #SofaBed: Nat;
        // Agregar mas variantes
    };

    public type HousingResponse = {
        #Start : Housing and {
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

    // public type HousingKind = {
    //     #House;
    //     #Hotel_room: Text; //Ejemplo #Hotel_room("Single Room")
    //     #RoomWithSharedSpaces: [Rule]; //Hostels/Pensiones
    // };

    public type Price = {
        #PerNight: Nat;
        #PerWeek: Nat;
        #CustomPeriod: [{dais: Nat; price: Nat}];
    };

    // public type Rules = { // Ejemplo de Rule: {key = "Horarios"; value = "Sin ruidos molestos entre las 22:00 y las 8:00"}
    //     key: Text;
    //     value: Text
    // };

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


    public type CalendaryPart = Disponibility and {reservation: ?Reservation};




} 

    