{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}
module Main where

import Web.Spock
import Web.Spock.Config

import Data.Aeson hiding (json)
import  Data.Monoid ((<>))
import  Data.Text (Text, pack)
import  GHC.Generics
import Lib
import Data.IORef



data Transcript = Transcript
  { t :: String
  } deriving (Generic, Show)

data NewReplaceCommand = NewReplaceCommand
  { pattern :: String,
    replacement :: String
  } deriving (Generic, Show)

instance ToJSON Transcript
instance FromJSON Transcript

instance ToJSON NewReplaceCommand
instance FromJSON NewReplaceCommand

type Api = SpockM () () () ()
type ApiAction a = SpockAction () () () a

commands = predefinedCommands

main :: IO ()
main =
    do spockCfg <- defaultSpockCfg () PCNoDatabase ()
       runSpock 8080 (spock spockCfg app)

app :: Api
app =
    do
       post root $ do
         theTranscript <- jsonBody' :: ApiAction Transcript
         text (pack $ (processTranscript commands) (t theTranscript))
       post "add" $ do
         theCommand <- jsonBody' :: ApiAction NewReplaceCommand
         text ("ok")
