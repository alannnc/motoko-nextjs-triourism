export const idlFactory = ({ IDL }) => {
  const HousingId = IDL.Nat;
  const SignUpData = IDL.Record({
    'email' : IDL.Text,
    'phone' : IDL.Opt(IDL.Nat),
    'lastName' : IDL.Text,
    'firstName' : IDL.Text,
  });
  const Rules = IDL.Record({ 'key' : IDL.Text, 'value' : IDL.Text });
  const HousingKind = IDL.Variant({
    'Hotel_room' : IDL.Text,
    'RoomWithSharedSpaces' : IDL.Vec(Rules),
    'House' : IDL.Null,
  });
  const BedKind = IDL.Variant({
    'Matrimonial' : IDL.Nat,
    'SofaBed' : IDL.Nat,
    'Single' : IDL.Nat,
  });
  const Reservation__1 = IDL.Record({
    'applicant' : IDL.Principal,
    'checkIn' : IDL.Int,
    'guest' : IDL.Text,
    'checkOut' : IDL.Int,
  });
  const CalendaryPart = IDL.Record({
    'day' : IDL.Int,
    'reservation' : IDL.Opt(Reservation__1),
    'available' : IDL.Bool,
  });
  const Price = IDL.Variant({
    'CustomPeriod' : IDL.Vec(
      IDL.Record({ 'dais' : IDL.Nat, 'price' : IDL.Nat })
    ),
    'PerNight' : IDL.Nat,
    'PerWeek' : IDL.Nat,
  });
  const HousingResponse = IDL.Variant({
    'Start' : IDL.Record({
      'id' : IDL.Nat,
      'reviews' : IDL.Vec(IDL.Text),
      'thumbnail' : IDL.Vec(IDL.Nat8),
      'owner' : IDL.Principal,
      'maxCapacity' : IDL.Nat,
      'kind' : HousingKind,
      'description' : IDL.Text,
      'properties' : IDL.Record({
        'bathroom' : IDL.Bool,
        'beds' : IDL.Vec(BedKind),
      }),
      'amenities' : IDL.Vec(IDL.Text),
      'calendar' : IDL.Vec(CalendaryPart),
      'address' : IDL.Text,
      'prices' : IDL.Vec(Price),
      'photo' : IDL.Vec(IDL.Nat8),
      'minReservationLeadTimeNanoSec' : IDL.Int,
      'rules' : IDL.Vec(IDL.Text),
      'hasNextPhoto' : IDL.Bool,
    }),
    'OnlyPhoto' : IDL.Record({
      'photo' : IDL.Vec(IDL.Nat8),
      'hasNextPhoto' : IDL.Bool,
    }),
  });
  const HousingPreview = IDL.Record({
    'id' : IDL.Nat,
    'thumbnail' : IDL.Vec(IDL.Nat8),
    'address' : IDL.Text,
    'prices' : IDL.Vec(Price),
  });
  const ResultHousingPaginate = IDL.Variant({
    'Ok' : IDL.Record({
      'hasNext' : IDL.Bool,
      'array' : IDL.Vec(HousingPreview),
    }),
    'Err' : IDL.Text,
  });
  const Reservation = IDL.Record({
    'applicant' : IDL.Principal,
    'checkIn' : IDL.Int,
    'guest' : IDL.Text,
    'checkOut' : IDL.Int,
  });
  const ReviewsId = IDL.Text;
  const HousingId__1 = IDL.Nat;
  const UserKind = IDL.Variant({
    'Guest' : IDL.Vec(ReviewsId),
    'Host' : IDL.Vec(HousingId__1),
    'Initial' : IDL.Null,
  });
  const User__1 = IDL.Record({
    'verified' : IDL.Bool,
    'email' : IDL.Text,
    'score' : IDL.Nat,
    'phone' : IDL.Opt(IDL.Nat),
    'lastName' : IDL.Text,
    'kinds' : IDL.Vec(UserKind),
    'firstName' : IDL.Text,
  });
  const HousingDataInit = IDL.Record({
    'maxCapacity' : IDL.Nat,
    'kind' : HousingKind,
    'description' : IDL.Text,
    'properties' : IDL.Record({
      'bathroom' : IDL.Bool,
      'beds' : IDL.Vec(BedKind),
    }),
    'amenities' : IDL.Vec(IDL.Text),
    'address' : IDL.Text,
    'prices' : IDL.Vec(Price),
    'minReservationLeadTimeNanoSec' : IDL.Int,
    'rules' : IDL.Vec(IDL.Text),
  });
  const PublishResult = IDL.Variant({ 'Ok' : HousingId, 'Err' : IDL.Text });
  const ReservationDataInput = IDL.Record({
    'checkIn' : IDL.Int,
    'guest' : IDL.Text,
    'checkOut' : IDL.Int,
  });
  const ReservationResult = IDL.Variant({
    'Ok' : IDL.Record({
      'msg' : IDL.Text,
      'housingId' : HousingId,
      'data' : Reservation,
      'paymentCode' : IDL.Nat,
      'reservationId' : IDL.Nat,
    }),
    'Err' : IDL.Text,
  });
  const User = IDL.Record({
    'verified' : IDL.Bool,
    'email' : IDL.Text,
    'score' : IDL.Nat,
    'phone' : IDL.Opt(IDL.Nat),
    'lastName' : IDL.Text,
    'kinds' : IDL.Vec(UserKind),
    'firstName' : IDL.Text,
  });
  const SignUpResult = IDL.Variant({ 'Ok' : User, 'Err' : IDL.Text });
  const UpdateResult = IDL.Variant({ 'Ok' : IDL.Null, 'Err' : IDL.Text });
  const Triourism = IDL.Service({
    'addAdmin' : IDL.Func(
        [IDL.Principal],
        [IDL.Variant({ 'Ok' : IDL.Null, 'Err' : IDL.Null })],
        [],
      ),
    'addPhotoToHousing' : IDL.Func(
        [IDL.Record({ 'id' : HousingId, 'photo' : IDL.Vec(IDL.Nat8) })],
        [IDL.Variant({ 'Ok' : IDL.Null, 'Err' : IDL.Text })],
        [],
      ),
    'addThumbnailToHousing' : IDL.Func(
        [IDL.Record({ 'id' : HousingId, 'thumbnail' : IDL.Vec(IDL.Nat8) })],
        [IDL.Variant({ 'Ok' : IDL.Null, 'Err' : IDL.Text })],
        [],
      ),
    'confirmReservation' : IDL.Func(
        [
          IDL.Record({
            'reservId' : IDL.Nat,
            'txHash' : IDL.Nat,
            'hostId' : HousingId,
          }),
        ],
        [IDL.Variant({ 'Ok' : IDL.Null, 'Err' : IDL.Text })],
        [],
      ),
    'editProfile' : IDL.Func(
        [SignUpData],
        [IDL.Variant({ 'Ok' : IDL.Null, 'Err' : IDL.Null })],
        [],
      ),
    'getHousingById' : IDL.Func(
        [IDL.Record({ 'photoIndex' : IDL.Nat, 'housingId' : HousingId })],
        [IDL.Variant({ 'Ok' : HousingResponse, 'Err' : IDL.Text })],
        ['query'],
      ),
    'getHousingPaginate' : IDL.Func(
        [IDL.Nat],
        [ResultHousingPaginate],
        ['query'],
      ),
    'getMyHousingDisponibility' : IDL.Func(
        [IDL.Record({ 'days' : IDL.Vec(IDL.Nat), 'page' : IDL.Nat })],
        [ResultHousingPaginate],
        ['query'],
      ),
    'getMyHousingsPaginate' : IDL.Func(
        [IDL.Record({ 'page' : IDL.Nat })],
        [ResultHousingPaginate],
        [],
      ),
    'getReservations' : IDL.Func(
        [IDL.Record({ 'housingId' : IDL.Nat })],
        [
          IDL.Variant({
            'Ok' : IDL.Vec(IDL.Tuple(IDL.Nat, Reservation)),
            'Err' : IDL.Text,
          }),
        ],
        ['query'],
      ),
    'logIn' : IDL.Func(
        [],
        [IDL.Variant({ 'Ok' : User__1, 'Err' : IDL.Null })],
        ['query'],
      ),
    'publishHousing' : IDL.Func([HousingDataInit], [PublishResult], []),
    'removeAdmin' : IDL.Func(
        [IDL.Principal],
        [IDL.Variant({ 'Ok' : IDL.Null, 'Err' : IDL.Null })],
        [],
      ),
    'requestReservation' : IDL.Func(
        [
          IDL.Record({
            'housingId' : HousingId,
            'data' : ReservationDataInput,
          }),
        ],
        [ReservationResult],
        [],
      ),
    'setHousingStatus' : IDL.Func(
        [IDL.Record({ 'id' : HousingId, 'active' : IDL.Bool })],
        [IDL.Variant({ 'Ok' : IDL.Null, 'Err' : IDL.Text })],
        [],
      ),
    'setMinReservationLeadTime' : IDL.Func(
        [IDL.Record({ 'id' : HousingId, 'hours' : IDL.Nat })],
        [IDL.Variant({ 'Ok' : IDL.Null, 'Err' : IDL.Text })],
        [],
      ),
    'signUp' : IDL.Func([SignUpData], [SignUpResult], []),
    'signUpAsHost' : IDL.Func([SignUpData], [SignUpResult], []),
    'updateHosting' : IDL.Func(
        [IDL.Record({ 'id' : IDL.Nat, 'data' : HousingDataInit })],
        [IDL.Variant({ 'Ok' : IDL.Null, 'Err' : IDL.Text })],
        [],
      ),
    'updatePrices' : IDL.Func(
        [IDL.Record({ 'id' : HousingId, 'prices' : IDL.Vec(Price) })],
        [UpdateResult],
        [],
      ),
  });
  return Triourism;
};
export const init = ({ IDL }) => { return []; };
