module Util.Logging exposing ( log, logVerbose, logInfo
                             , logWarning, logError
                             )


import Logger

import Native.Logger


nativeLog : Logger.ExternalLoggingFunction a
nativeLog level message value =
  Native.Logger.log (Logger.levelString level) (toColor level) message value

loggerConfig : Logger.Config a
loggerConfig =
    Logger.customConfig Logger.Info nativeLog


log : String -> a -> a
log =
  Logger.log loggerConfig Logger.Debug


logVerbose : String -> a -> a
logVerbose =
  Logger.log loggerConfig Logger.Verbose


logInfo : String -> a -> a
logInfo =
  Logger.log loggerConfig Logger.Info


logWarning : String -> a -> a
logWarning =
  Logger.log loggerConfig Logger.Warning


logError : String -> a -> a
logError =
  Logger.log loggerConfig Logger.Error

toColor : Logger.Level -> String
toColor logLevel =
  case logLevel of
    Logger.Error ->
      "red"

    Logger.Warning ->
      "orange"

    Logger.Info ->
      "green"

    Logger.Debug ->
      "purple"

    Logger.Verbose ->
      "LightBlue"