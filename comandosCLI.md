``` 
dfx deploy backend

```
registro de usuario sin foto:

```
dfx canister call backend signUp '(record { 
    name="Usuario de Prueba"; 
    email=opt "usuario_prueba@gmail.com"; 
    avatar= null}
)'
```

registro de usuario con foto:

```
dfx canister call backend signUp '(record { 
    name="Usuario de Prueba"; 
    email=opt "usuario_prueba2@gmail.com"; 
    avatar= opt blob "11/44/67/87/45/34/09/87/56"}
)'
```

publicacion de hosting

```
dfx canister call backend publishHousing '(record {
    address = "San Martin 555";
    minReservationLeadTime = 24;
    prices = vec {
        variant {PerNight = 50};
        variant {PerWeek = 550}
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

