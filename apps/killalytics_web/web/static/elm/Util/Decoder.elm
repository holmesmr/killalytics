module Util.Decoder exposing (date, dateDecode)
-- Simple Date decoder (probably not robust)

import Date exposing (..)

import Json.Decode exposing (..)

date : Decoder Date.Date
date = string |> Json.Decode.andThen dateDecode

dateDecode : String -> Decoder Date.Date
dateDecode dateString =
  case (Date.fromString dateString) of
    Ok date -> succeed date
    _ -> fail "Couldn't parse date correctly!"

