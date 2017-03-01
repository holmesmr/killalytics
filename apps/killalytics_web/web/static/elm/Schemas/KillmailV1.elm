module Schemas.KillmailV1 exposing ( KillMail, Pilot, Corporation, Alliance, Ship
                                   , Faction, SolarSystem, GameAgent(..)
                                   )

import Date exposing (..)

type alias KillID        = Int
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

type alias Faction =
  { id       : AllianceID
  , name     : String
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
  = PilotAgent Ship Pilot
  | CorpAgent Ship Corporation
  | FactionAgent Ship Faction


type alias KillMail =
    { id       : Int
    , victim   : GameAgent
    , value    : Float
    , killers  : List GameAgent
    , system   : SolarSystem
    , datetime : Date
    }