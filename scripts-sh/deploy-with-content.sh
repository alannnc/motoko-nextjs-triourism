#!/bin/bash
# ------------ Usuario deployer ------------
dfx identity new 0000TestUser0
dfx identity use 0000TestUser0
dfx deploy backend

# ------------ Usuario Host 1 --------------
dfx identity new 0000TestUser1
dfx identity use 0000TestUser1
dfx canister call backend signUpAsHost '(record {
    firstName="Alberto";
    lastName="Campos";
    email="null";
    phone = opt 542238780892
})'
# CreateHousing 1

dfx canister call backend createHousing '(record {
    namePlace="Far West";
    nameHost="Alberto Campos";
    descriptionPlace="Lugar tranquilo y seguro";
    descriptionHost="Al lado de Far West disco bar y apuestas";
    link="https://media.istockphoto.com/id/2045383950/photo/digital-render-of-a-serene-bedroom-oasis-with-natural-light.jpg?s=2048x2048&w=is&k=20&c=2Rw4fqnC08kfiuc58jhzbCAOYwPp9V8w4e3Ma2TY984=";
    photos = vec {};
    thumbnail = blob "Qk06AAAAAAAAADYAAAAoAAAAAQAAAAEAAAABAAEAAAA"
})'
# Update Prices housing 1
dfx canister call backend updatePrices '(record {
  id = 1 : nat;
  prices = vec {
    variant { PerNight = 30 : nat };
    variant { PerWeek = 200 : nat };
  };
})'

#Assing housing Type

dfx canister call backend assignHousingType '(record {
  housingId = 1 : nat;
  qty = 1 : nat;
  propertiesOfType = record {
    extraGuest = 2 : nat;
    bathroom = record {
      shower = true;
      sink = true;
      toilette = true;
      isShared = false;
      bathtub = true;
    };
    beds = vec { variant { Matrimonial = 1 : nat } };
    maxGuest = 4 : nat;
    nameType = "Standard";
  };
})'

#Set Address Housing 1

dfx canister call backend setAddress '(record {
  housingId = 1 : nat;
  address = record {
    street = "9 de Julio";
    externalNumber = 1207;
    internalNumber = 43;
    city = "Mar del Plata";
    neighborhood = "Centro";
    country = "Argentina";
    zipCode = 7600 ;
  };
})'

dfx canister call backend setHousingStatus '(record {
  id = 1 : nat;
  active = true;
})'

dfx canister call backend publishHousing 1

# CreateHousing 2

dfx canister call backend createHousing '(record {
    namePlace="";
    nameHost="Alberto Campos";
    descriptionPlace="Lugar tranquilo y seguro";
    descriptionHost="Espacioso y luminoso con vista al mar";
    link="https://media.istockphoto.com/id/1837566278/photo/scandinavian-style-apartment-interior.jpg?s=2048x2048&w=is&k=20&c=ZT-ZoefdikBU9DhdEg4fV6bW-SdZi_HLRFg_mupNd9E=";
    photos = vec {};
    thumbnail = blob "Qk06AAAAAAAAADYAAAAoAAAAAQAAAAEAAAABAAEAALKLKAKHUJHAA"
})'




# ------------ Usuario Host 2 -------------- 
dfx identity new 0000TestUser2
dfx identity use 0000TestUser2
dfx canister call backend signUpAsHost '(record {
    firstName="Lucila";
    lastName="Peralta";
    email="lucilaperalta@live.com";
    phone = opt 542298712438
})'

# ------------ Usuario Host 3 -------------- 
dfx identity new 0000TestUser3
dfx identity use 0000TestUser3
dfx canister call backend signUpAsHost '(record {
    firstName="Claudia";
    lastName="Gimenez";
    email="claugimenez@gmail.com";
    phone = opt 558789878522
})'

# ------------ Usuario Host 4 -------------- 
dfx identity new 0000TestUser4
dfx identity use 0000TestUser4
dfx canister call backend signUpAsHost '(record {
    firstName="Mario";
    lastName="Pappa";
    email="mariopapa@gmail.com";
    phone = opt 542235227692
})'

# ------------ Usuario Host 5 -------------- 
dfx identity new 0000TestUser5
dfx identity use 0000TestUser5
dfx canister call backend signUpAsHost '(record {
    firstName="Rodolfo";
    lastName="Anchorena";
    email="rodolfoanchorena.com";
    phone = opt 542278795421
})'

# ------------ Usuario Host 6 -------------- 
dfx identity new 0000TestUser6
dfx identity use 0000TestUser6
dfx canister call backend signUpAsHost '(record {
    firstName="Carlos";
    lastName="Maldonado";
    email="carlosmaldonado.com";
    phone = opt 5422145789544
})'



