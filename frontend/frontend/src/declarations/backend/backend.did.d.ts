import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type BedKind = { 'Matrimonial' : bigint } |
  { 'SofaBed' : bigint } |
  { 'Single' : bigint };
export interface CalendaryPart {
  'day' : bigint,
  'reservation' : [] | [Reservation__1],
  'available' : boolean,
}
export interface HousingDataInit {
  'maxCapacity' : bigint,
  'kind' : HousingKind,
  'description' : string,
  'properties' : { 'bathroom' : boolean, 'beds' : Array<BedKind> },
  'amenities' : Array<string>,
  'address' : string,
  'prices' : Array<Price>,
  'minReservationLeadTimeNanoSec' : bigint,
  'rules' : Array<string>,
}
export type HousingId = bigint;
export type HousingId__1 = bigint;
export type HousingKind = { 'Hotel_room' : string } |
  { 'RoomWithSharedSpaces' : Array<Rules> } |
  { 'House' : null };
export interface HousingPreview {
  'id' : bigint,
  'thumbnail' : Uint8Array | number[],
  'address' : string,
  'prices' : Array<Price>,
}
export type HousingResponse = {
    'Start' : {
      'id' : bigint,
      'reviews' : Array<string>,
      'thumbnail' : Uint8Array | number[],
      'owner' : Principal,
      'maxCapacity' : bigint,
      'kind' : HousingKind,
      'description' : string,
      'properties' : { 'bathroom' : boolean, 'beds' : Array<BedKind> },
      'amenities' : Array<string>,
      'calendar' : Array<CalendaryPart>,
      'address' : string,
      'prices' : Array<Price>,
      'photo' : Uint8Array | number[],
      'minReservationLeadTimeNanoSec' : bigint,
      'rules' : Array<string>,
      'hasNextPhoto' : boolean,
    }
  } |
  {
    'OnlyPhoto' : { 'photo' : Uint8Array | number[], 'hasNextPhoto' : boolean }
  };
export type Price = {
    'CustomPeriod' : Array<{ 'dais' : bigint, 'price' : bigint }>
  } |
  { 'PerNight' : bigint } |
  { 'PerWeek' : bigint };
export type PublishResult = { 'Ok' : HousingId } |
  { 'Err' : string };
export interface Reservation {
  'applicant' : Principal,
  'checkIn' : bigint,
  'guest' : string,
  'checkOut' : bigint,
}
export interface ReservationDataInput {
  'checkIn' : bigint,
  'guest' : string,
  'checkOut' : bigint,
}
export type ReservationResult = {
    'Ok' : {
      'msg' : string,
      'housingId' : HousingId,
      'data' : Reservation,
      'paymentCode' : bigint,
      'reservationId' : bigint,
    }
  } |
  { 'Err' : string };
export interface Reservation__1 {
  'applicant' : Principal,
  'checkIn' : bigint,
  'guest' : string,
  'checkOut' : bigint,
}
export type ResultHousingPaginate = {
    'Ok' : { 'hasNext' : boolean, 'array' : Array<HousingPreview> }
  } |
  { 'Err' : string };
export type ReviewsId = string;
export interface Rules { 'key' : string, 'value' : string }
export interface SignUpData {
  'email' : string,
  'phone' : [] | [bigint],
  'lastName' : string,
  'firstName' : string,
}
export type SignUpResult = { 'Ok' : User } |
  { 'Err' : string };
export interface Triourism {
  'addAdmin' : ActorMethod<[Principal], { 'Ok' : null } | { 'Err' : null }>,
  'addPhotoToHousing' : ActorMethod<
    [{ 'id' : HousingId, 'photo' : Uint8Array | number[] }],
    { 'Ok' : null } |
      { 'Err' : string }
  >,
  'addThumbnailToHousing' : ActorMethod<
    [{ 'id' : HousingId, 'thumbnail' : Uint8Array | number[] }],
    { 'Ok' : null } |
      { 'Err' : string }
  >,
  'confirmReservation' : ActorMethod<
    [{ 'reservId' : bigint, 'txHash' : bigint, 'hostId' : HousingId }],
    { 'Ok' : null } |
      { 'Err' : string }
  >,
  'editProfile' : ActorMethod<[SignUpData], { 'Ok' : null } | { 'Err' : null }>,
  'getHousingById' : ActorMethod<
    [{ 'photoIndex' : bigint, 'housingId' : HousingId }],
    { 'Ok' : HousingResponse } |
      { 'Err' : string }
  >,
  'getHousingPaginate' : ActorMethod<[bigint], ResultHousingPaginate>,
  'getMyHousingDisponibility' : ActorMethod<
    [{ 'days' : Array<bigint>, 'page' : bigint }],
    ResultHousingPaginate
  >,
  'getMyHousingsPaginate' : ActorMethod<
    [{ 'page' : bigint }],
    ResultHousingPaginate
  >,
  'getReservations' : ActorMethod<
    [{ 'housingId' : bigint }],
    { 'Ok' : Array<[bigint, Reservation]> } |
      { 'Err' : string }
  >,
  'logIn' : ActorMethod<[], { 'Ok' : User__1 } | { 'Err' : null }>,
  'publishHousing' : ActorMethod<[HousingDataInit], PublishResult>,
  'removeAdmin' : ActorMethod<[Principal], { 'Ok' : null } | { 'Err' : null }>,
  'requestReservation' : ActorMethod<
    [{ 'housingId' : HousingId, 'data' : ReservationDataInput }],
    ReservationResult
  >,
  'setHousingStatus' : ActorMethod<
    [{ 'id' : HousingId, 'active' : boolean }],
    { 'Ok' : null } |
      { 'Err' : string }
  >,
  'setMinReservationLeadTime' : ActorMethod<
    [{ 'id' : HousingId, 'hours' : bigint }],
    { 'Ok' : null } |
      { 'Err' : string }
  >,
  'signUp' : ActorMethod<[SignUpData], SignUpResult>,
  'signUpAsHost' : ActorMethod<[SignUpData], SignUpResult>,
  'updateHosting' : ActorMethod<
    [{ 'id' : bigint, 'data' : HousingDataInit }],
    { 'Ok' : null } |
      { 'Err' : string }
  >,
  'updatePrices' : ActorMethod<
    [{ 'id' : HousingId, 'prices' : Array<Price> }],
    UpdateResult
  >,
}
export type UpdateResult = { 'Ok' : null } |
  { 'Err' : string };
export interface User {
  'verified' : boolean,
  'email' : string,
  'score' : bigint,
  'phone' : [] | [bigint],
  'lastName' : string,
  'kinds' : Array<UserKind>,
  'firstName' : string,
}
export type UserKind = { 'Guest' : Array<ReviewsId> } |
  { 'Host' : Array<HousingId__1> } |
  { 'Initial' : null };
export interface User__1 {
  'verified' : boolean,
  'email' : string,
  'score' : bigint,
  'phone' : [] | [bigint],
  'lastName' : string,
  'kinds' : Array<UserKind>,
  'firstName' : string,
}
export interface _SERVICE extends Triourism {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
