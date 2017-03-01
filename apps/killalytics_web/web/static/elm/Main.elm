module Main exposing (main)
{-|
Entry point for Killalytics Web UI.

@docs main
-}


import Html exposing (..)
import Html.Attributes as Attr
import Date exposing (..)

import Json.Decode exposing (..)

import Util.Logging exposing (..)

import Phoenix
import Phoenix.Socket as Socket
import Phoenix.Channel as Channel

import Schemas.KillmailV1 exposing (..)
import Schemas.KillmailV1.Decoder exposing (..)

import Date.Format exposing (format)


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
      let
        _ = logInfo "Successfully parsed killmail" kill
      in
        (List.reverse (List.sortBy (\i -> Date.toTime (.datetime i)) (kill :: kills)), Cmd.none)
    BadKillMail e ->
      let
        _ = logError "Killmail parsing error" e
      in
        (kills, Cmd.none)


parseKillMail : Value -> Msg
parseKillMail json =
  case (decodeValue killMailDecoder json) of
   Ok mail ->
     ParsedKill mail
   Err e ->
     BadKillMail <| Err e


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
    PilotAgent _ pilot ->
      div
        [ Attr.class "panel panel-danger pilot" ]
        [ viewKillHeading "Player" kill
        , div [ Attr.class "panel-body" ] [ viewKillSummary kill ]
        , viewKillFooter kill ]
    CorpAgent _ corp ->
      div
        [ Attr.class "panel panel-danger corp" ]
        [ viewKillHeading "Structure" kill
        , div [Attr.class "panel-body"] [ viewKillSummary kill ]
        , viewKillFooter kill ]
    FactionAgent _ faction ->
      div
        [ Attr.class "panel faction" ]
        [ viewKillHeading "NPC" kill
        , div [Attr.class "panel-body"] [ viewKillSummary kill ]
        , viewKillFooter kill ]


viewKillHeading : String -> KillMail -> Html msg
viewKillHeading victimType kill =
  div [Attr.class "panel-heading"]
    [ span [Attr.class "action"] [text (victimType ++ " kill") ]
    , text (" at " ++ format "%Y/%m/%d %H:%M:%S" kill.datetime ++ " in ")
    , viewSystemLink kill.system ]


viewKillSummary : KillMail -> Html msg
viewKillSummary kill =
  div [ Attr.class "kill-summary" ]
    [ viewVictimPortrait kill.victim
    , p [ Attr.class "cost" ] [ text ("Total killed: " ++ toString kill.value ++ " ISK") ]
    , viewKillInfo kill ]


viewKillFooter : KillMail -> Html msg
viewKillFooter kill =
  let
    baseLinks = [ viewKillMailLink kill ]
    links = case kill.victim of
      PilotAgent _ pilot -> baseLinks ++ [ viewPlayerKillboardLink pilot ]
      CorpAgent _ _ -> baseLinks ++ []
      FactionAgent _ _ -> baseLinks ++ []
  in
    div [Attr.class "panel-footer"] [ul [ Attr.class "list-footer-links" ]
      (List.map (\a -> li [] [a]) links) ]


viewKillInfo : KillMail -> Html msg
viewKillInfo kill =
  div []
    (case kill.victim of
      PilotAgent ship pilot -> [p [] [viewPlayerKillboardLink pilot], p [] [viewCorpKillboardLink pilot.corporation]]
      CorpAgent ship corp -> []
      FactionAgent ship faction -> [])



viewKillMailLink : KillMail -> Html msg
viewKillMailLink kill =
  a
    [ Attr.href ("https://zkillboard.com/kills/" ++ (toString kill.id))
    , Attr.target "_blank" ]

    [text "Killmail"]


viewPlayerKillboardLink : Pilot -> Html msg
viewPlayerKillboardLink pilot =
  viewNewTabLink
    ("https://zkillboard.com/character/" ++ (toString pilot.id))
    ("Victim Killboard")


viewCorpKillboardLink : Corporation -> Html msg
viewCorpKillboardLink corp =
  viewNewTabLink
    ("https://zkillboard.com/corporation/" ++ (toString corp.id))
    corp.name


viewSystemLink : SolarSystem -> Html msg
viewSystemLink system =
  viewNewTabLink
    ("http://evemaps.dotlan.net/system/" ++ (String.split " " system.name |> String.join "_"))
    system.name


viewVictimPortrait : GameAgent -> Html msg
viewVictimPortrait agent =
  case agent of
    PilotAgent _ pilot -> viewPlayerPortrait pilot
    CorpAgent _ corp -> viewCorporationPortrait corp
    FactionAgent _ faction -> viewFactionPortrait faction


viewPlayerPortrait : Pilot -> Html msg
viewPlayerPortrait pilot =
  viewPortraitImage "Character" (toString pilot.id)


viewCorporationPortrait : Corporation -> Html msg
viewCorporationPortrait corp =
  viewPortraitImage "Corporation" (toString corp.id)


viewFactionPortrait : Faction -> Html msg
viewFactionPortrait faction =
  viewPortraitImage "Alliance" (toString faction.id)


viewPortraitImage : String -> String -> Html msg
viewPortraitImage typeName imageId =
  img
    [ Attr.style [("width", "128px"), ("height", "128px")]
    , Attr.class "portrait"
    , Attr.src ("https://imageserver.eveonline.com/" ++ typeName ++ "/" ++ imageId ++ "_128.jpg") ]
    []


viewNewTabLink : String -> String -> Html msg
viewNewTabLink url label =
  a
    [ Attr.href url
    , Attr.target "_blank" ]

    [text label]