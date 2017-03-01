module Schemas.KillmailV1.Decoder exposing ( killMailDecoder, gameAgentDecoder
                                           , pilotDecoder, corporationDecoder, allianceDecoder
                                           , shipDecoder, solarSystemDecoder, factionDecoder
                                           )

import Schemas.KillmailV1 exposing (..)

import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (decode, required, optional)

import Util.Decoder exposing (date)

-- JSON Decoders
killMailDecoder : Decoder KillMail
killMailDecoder =
  decode KillMail
    |> Json.Decode.Pipeline.required "id"        int
    |> Json.Decode.Pipeline.required "victim"    gameAgentDecoder
    |> Json.Decode.Pipeline.required "value"     float
    |> Json.Decode.Pipeline.required "attackers" (Json.Decode.list gameAgentDecoder)
    |> Json.Decode.Pipeline.required "system"    solarSystemDecoder
    |> Json.Decode.Pipeline.required "datetime"  date


gameAgentDecoder : Decoder GameAgent
gameAgentDecoder =
   Json.Decode.andThen gameAgentDecoderWithShip (field "ship" shipDecoder)

gameAgentDecoderWithShip : Ship -> Decoder GameAgent
gameAgentDecoderWithShip ship =
   Json.Decode.andThen (gameAgentDecodeByType ship) (field "type" string)

gameAgentDecodeByType : Ship -> String -> Decoder GameAgent
gameAgentDecodeByType ship typeName =
  case typeName of
    "pilot" ->
      Json.Decode.map (PilotAgent ship) (field "agent" pilotDecoder)
    "corp" ->
      Json.Decode.map (CorpAgent ship) (field "agent" corporationDecoder)
    "faction" ->
      Json.Decode.map (FactionAgent ship) (field "agent" factionDecoder)
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


factionDecoder : Decoder Faction
factionDecoder =
  decode Faction
    |> Json.Decode.Pipeline.required "id"          int
    |> Json.Decode.Pipeline.required "name"        string

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
