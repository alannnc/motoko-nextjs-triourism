``` 
dfx deploy backend

```
registro de usuario huesped general:

```
dfx canister call backend signUp '(record { 
        name="Juan";
        lastName="Perez";
        phone= null;
        email="juanperez@gmail.com"; 
    }
)'
```

registro de usuario tipo Host

```
dfx canister call backend signUpAsHost '(record { 
        name="Gerardo";
        lastName="Anchorena";
        phone= opt 54221548797;
        email="gerardonchorena@gmail.com";  
    }
)'
```

publicacion de hosting

```
dfx canister call backend publishHousing '(record {
    minReservationLeadTimeNanoSec = 86400000000000;
    address = "San Martin 555";
    description= "Vista al mar, 56 Mts2, silencioso";
    maxCapacity= 6;
    amenities = vec{"Jacuzzi"; "Piscina"; "Gimnasio"};
    prices = vec {
        variant {PerNight = 90};
        variant {PerWeek = 550};
        variant {CustomPeriod = vec {
                record {dais = 15; price = 1000};
                record {dais = 30; price = 1900};
            }
        }
    }; 
    kind = variant {House}}
)'
```

agregar foto a publicacion

```
dfx canister call backend addPhotoToHousing '(record {
    id = 1; 
    photo = blob "00/11/22/33/44/"}
)'
```

agregar foto miniatura (foto principal de tamaño reducido)

```
dfx canister call backend addThumbnailToHousing '(record {
    id = 1; 
    thumbnail = blob "00/66/88/44/45/98/45/98"}
)'
```

actualizacion de precios

```
dfx canister call backend updatePrices '(record {
    id = 1;
    prices = vec {
        variant {PerNight = 400};
        variant {PerWeek = 2800};
    }
})'
```

Solicitud de reserva

```
dfx canister call backend requestReservation '(record {
    id = 1 : nat;
    data = record {
      applicant = principal "epvyw-ddnza-4wy4p-joxft-ciutt-s7pji-cfxm3-khwlb-x2tb7-uo7tc-xae";
      checkIn = 1_729_636_239_000_000_000 : int;
      guest = "Ariel";
      checkOut = 1_729_722_639_000_000_000 : int;
    };
})'
```

