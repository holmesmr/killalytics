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

import Native.Endpoint


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

websocketUrl : String -> String
websocketUrl = Native.Endpoint.wsUrl


socket : Socket.Socket msg
socket =
  Socket.init (websocketUrl "socket/websocket")


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
    , viewKillInfo kill
    , p [ Attr.class "cost" ] [ text ("Total killed: " ++ toString kill.value ++ " ISK") ] ]


viewKillFooter : KillMail -> Html msg
viewKillFooter kill =
  let
    baseLinks = [ viewKillMailLink kill ]
    links = case kill.victim of
      PilotAgent _ pilot -> baseLinks ++ [ viewPlayerEveWhoLink pilot, viewPlayerEveGateLink pilot ]
      CorpAgent _ corp -> baseLinks ++ [ viewCorpEveWhoLink corp, viewCorpEveGateLink corp ]
      FactionAgent _ _ -> baseLinks ++ []
  in
    div [Attr.class "panel-footer"] [ul [ Attr.class "list-footer-links" ]
      (List.map (\a -> li [] [a]) links) ]


viewKillInfo : KillMail -> Html msg
viewKillInfo kill =
  div [ Attr.class "kill-info" ]
    (case kill.victim of
      PilotAgent ship pilot ->
        [ h3 [] [ text "Victim" ]
        , p [] [ text "Character: ", viewPlayerKillboardLink pilot ]
        , p [] [ text "Corporation: ", viewCorpKillboardLink pilot.corporation ] ]
        ++ viewAlliance pilot.corporation
        ++ [ p [] [ text ("Ship: " ++ ship.name) ] ]
      CorpAgent ship corp ->
        [ h3 [] [ text "Lost Structure" ]
        , p [] [ text ("Type: " ++ ship.name) ]
        , p [] [ text "Owner: ", viewCorpKillboardLink corp ] ]
        ++ viewAlliance corp
      FactionAgent ship faction -> [])


viewAlliance : Corporation -> List (Html msg)
viewAlliance corp =
  case corp.alliance of
    Just alliance -> [ text "Alliance: ", viewAllianceKillboardLink alliance ]
    Nothing -> []


viewKillMailLink : KillMail -> Html msg
viewKillMailLink kill =
  a
    [ Attr.href ("https://zkillboard.com/kill/" ++ (toString kill.id))
    , Attr.target "_blank" ]

    [text "Killmail"]


viewPlayerKillboardLink : Pilot -> Html msg
viewPlayerKillboardLink pilot =
  viewNewTabLink
    ("https://zkillboard.com/character/" ++ (toString pilot.id))
    pilot.name


viewCorpKillboardLink : Corporation -> Html msg
viewCorpKillboardLink corp =
  viewNewTabLink
    ("https://zkillboard.com/corporation/" ++ (toString corp.id))
    corp.name


viewAllianceKillboardLink : Alliance -> Html msg
viewAllianceKillboardLink alliance =
  viewNewTabLink
    ("https://zkillboard.com/alliance/" ++ (toString alliance.id))
    alliance.name


viewSystemLink : SolarSystem -> Html msg
viewSystemLink system =
  viewNewTabLink
    ("http://evemaps.dotlan.net/system/" ++ (String.split " " system.name |> String.join "_"))
    system.name


viewPlayerEveWhoLink : Pilot -> Html msg
viewPlayerEveWhoLink pilot =
  viewNewTabLink
    ("https://evewho.com/pilot/" ++ (String.split " " pilot.name |> String.join "+"))
    "Eve-Who"


viewPlayerEveGateLink : Pilot -> Html msg
viewPlayerEveGateLink pilot =
  viewNewTabLink
    ("https://gate.eveonline.com/Profile/" ++ pilot.name)
    "Eve-Gate"


viewCorpEveWhoLink : Corporation -> Html msg
viewCorpEveWhoLink corp =
  viewNewTabLink
    ("https://evewho.com/corporation/" ++ (String.split " " corp.name |> String.join "+"))
    "Eve-Who"


viewCorpEveGateLink : Corporation -> Html msg
viewCorpEveGateLink corp =
  viewNewTabLink
    ("https://gate.eveonline.com/Corporation/" ++ corp.name)
    "Eve-Gate"


viewVictimPortrait : GameAgent -> Html msg
viewVictimPortrait agent =
  case agent of
    PilotAgent _ pilot -> viewPlayerPortrait pilot
    CorpAgent _ corp -> viewCorporationPortrait corp
    FactionAgent _ faction -> viewFactionPortrait faction


viewPlayerPortrait : Pilot -> Html msg
viewPlayerPortrait pilot =
  viewPortraitImage "Character" (toString pilot.id) "jpg"


viewCorporationPortrait : Corporation -> Html msg
viewCorporationPortrait corp =
  viewPortraitImage "Corporation" (toString corp.id) "png"


viewFactionPortrait : Faction -> Html msg
viewFactionPortrait faction =
  viewPortraitImage "Alliance" (toString faction.id) "png"


viewPortraitImage : String -> String -> String -> Html msg
viewPortraitImage typeName imageId format =
  img
    [ Attr.style [("width", "128px"), ("height", "128px")]
    , Attr.class "portrait"
    , Attr.src ("https://imageserver.eveonline.com/" ++ typeName ++ "/" ++ imageId ++ "_128." ++ format) ]
    []


viewNewTabLink : String -> String -> Html msg
viewNewTabLink url label =
  a
    [ Attr.href url
    , Attr.target "_blank" ]

    [text label]