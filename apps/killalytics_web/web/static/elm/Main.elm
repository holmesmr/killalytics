module Main exposing (main)
{-|
Entry point for Killalytics Web UI.

@docs main
-}


import Html exposing (..)
import Date exposing (..)

import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (decode, required, optional)

import Debug exposing (crash)

import Phoenix
import Phoenix.Socket as Socket
import Phoenix.Channel as Channel


type alias CharacterID   = Int
type alias CorporationID = Int
type alias AllianceID    = Int
type alias ShipTypeID    = Int
type alias ItemID        = Int
type alias RegionID      = Int


type alias Pilot =
  { id          : CharacterID
  , name        : String
  , corporation : Corporation
  }


type alias Corporation =
  { id       : CorporationID
  , name     : String
  , alliance : Maybe Alliance
  , ticker   : String
  }


type alias Alliance =
  { id       : AllianceID
  , name     : String
  , ticker   : String
  }


type alias Ship =
  { id       : ShipTypeID
  , name     : String
  }


type alias SolarSystem =
  { id     : RegionID
  , name   : String
  , region : String
  }


type GameAgent
  = PilotAgent Pilot
  | CorpAgent Corporation


type alias KillMail =
    { victim     : GameAgent
    , value      : Float
    , ship       : Ship
    , killers    : List Pilot
    , system     : SolarSystem
    , datetime   : Date
    }

-- Simple Date decoder (probably not robust)
date : Decoder Date.Date
date = string |> Json.Decode.andThen dateDecode

dateDecode : String -> Decoder Date.Date
dateDecode dateString =
  case (Date.fromString dateString) of
    Ok date -> succeed date
    _ -> fail "Couldn't parse date correctly!"


-- JSON Decoders
killMailDecoder : Decoder KillMail
killMailDecoder =
  decode KillMail
    |> Json.Decode.Pipeline.required "victim"    gameAgentDecoder
    |> Json.Decode.Pipeline.required "value"     float
    |> Json.Decode.Pipeline.required "ship"      shipDecoder
    |> Json.Decode.Pipeline.required "attackers" (Json.Decode.list pilotDecoder)
    |> Json.Decode.Pipeline.required "system"    solarSystemDecoder
    |> Json.Decode.Pipeline.required "datetime"  date


gameAgentDecoder : Decoder GameAgent
gameAgentDecoder =
  field "type" string
    |> Json.Decode.andThen gameAgentDecodeByType

gameAgentDecodeByType : String -> Decoder GameAgent
gameAgentDecodeByType typeName =
  case typeName of
    "pilot" ->
      Json.Decode.map PilotAgent (field "agent" pilotDecoder)
    "corp" ->
      Json.Decode.map CorpAgent (field "agent" corporationDecoder)
    _ ->
      fail <|
        "Trying to decode GameAgent, but agent type "
        ++ typeName ++ " is not known"


pilotDecoder : Decoder Pilot
pilotDecoder =
  decode Pilot
    |> Json.Decode.Pipeline.required "id"          int
    |> Json.Decode.Pipeline.required "name"        string
    |> Json.Decode.Pipeline.required "corporation" corporationDecoder


corporationDecoder : Decoder Corporation
corporationDecoder =
  decode Corporation
    |> Json.Decode.Pipeline.required "id"       int
    |> Json.Decode.Pipeline.required "name"     string
    |> Json.Decode.Pipeline.optional "alliance" (nullable allianceDecoder) Nothing
    |> Json.Decode.Pipeline.required "ticker"   string


allianceDecoder : Decoder Alliance
allianceDecoder =
  decode Alliance
    |> Json.Decode.Pipeline.required "id"     int
    |> Json.Decode.Pipeline.required "name"   string
    |> Json.Decode.Pipeline.required "ticker" string


shipDecoder : Decoder Ship
shipDecoder =
  decode Ship
    |> Json.Decode.Pipeline.required "id"   int
    |> Json.Decode.Pipeline.required "name" string


solarSystemDecoder : Decoder SolarSystem
solarSystemDecoder =
  decode SolarSystem
    |> Json.Decode.Pipeline.required "id"     int
    |> Json.Decode.Pipeline.required "name"   string
    |> Json.Decode.Pipeline.required "region" string


parseKillMail : Value -> Msg
parseKillMail json =
  case (decodeValue killMailDecoder json) of
   Ok mail ->
     ParsedKill mail
   Err e ->
     BadKillMail <| Err e


{-| The entry point for the web app. -}
main : Program Never Model Msg
main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL


type alias Model = List KillMail


init : (Model, Cmd Msg)
init =
    ([], Cmd.none)


-- UPDATE


type Msg
  = NewKill Value
  | ParsedKill KillMail
  | BadKillMail (Result String Int)


update : Msg -> Model -> (Model, Cmd Msg)
update msg kills =
  case msg of
    NewKill val ->
      update (parseKillMail val) kills
    ParsedKill kill ->
      (List.sortBy (\i -> Date.toTime (.datetime i)) (kill :: kills), Cmd.none)
    BadKillMail e ->
      case e of
        Err inner ->
          -- TODO: Something other than crash
          crash "Error parsing killmail"
        _ ->
          (kills, Cmd.none)


-- SUBSCRIPTIONS


socket : Socket.Socket msg
socket =
  Socket.init "ws://localhost:4000/socket/websocket"


channel : Channel.Channel Msg
channel =
  Channel.init "killfeed"
    -- register an handler for messages with a "new_msg" event
    |> Channel.on "new_kill" NewKill


subscriptions : Model -> Sub Msg
subscriptions model =
  Phoenix.connect socket [channel]


-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ div [] (List.map viewKill model) ]


viewKill : KillMail -> Html msg
viewKill kill =
  case kill.victim of
    PilotAgent pilot ->
      p [] [ text pilot.name ]
    CorpAgent corporation ->
      p [] [ text corporation.name ]