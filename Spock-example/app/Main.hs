{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}
module Main where

import Web.Spock
import Web.Spock.Config

import Data.Aeson hiding (json)
import  Data.Monoid ((<>))
import  Data.Text (Text, pack)
import  GHC.Generics


data Transcript = Transcript
  { t :: Text
  } deriving (Generic, Show)

instance ToJSON Transcript

instance FromJSON Transcript

type Api = SpockM () () () ()
type ApiAction a = SpockAction () () () a

main :: IO ()
main =
    do spockCfg <- defaultSpockCfg () PCNoDatabase ()
       runSpock 8080 (spock spockCfg app)

app :: Api
app =
    do
       post root $ do
         theTranscript <- jsonBody' :: ApiAction Transcript
         text (t theTranscript)
