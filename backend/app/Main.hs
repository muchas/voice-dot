{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}
module Main where

import Web.Spock
import Web.Spock.Config

import Control.Monad.Trans
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
  { pat :: String,
    replacement :: String
  } deriving (Generic, Show)

instance ToJSON Transcript
instance FromJSON Transcript

instance ToJSON NewReplaceCommand
instance FromJSON NewReplaceCommand

data AppState = DummyAppState (IORef [Command])
type Api = SpockM () () AppState ()
type ApiAction a = SpockAction () () AppState a


main :: IO ()
main =
    do ref <- newIORef predefinedCommands
       spockCfg <- defaultSpockCfg () PCNoDatabase (DummyAppState ref)
       runSpock 8080 (spock spockCfg app)

app :: Api
app =
    do
       post root $ do
         (DummyAppState ref) <- getState
         commands <- liftIO $ atomicModifyIORef' ref $ \commands -> (commands, commands)
         theTranscript <- jsonBody' :: ApiAction Transcript
         text (pack $ (processTranscript commands) (t theTranscript))
       post "add" $ do
         theCommand <- jsonBody' :: ApiAction NewReplaceCommand
         (DummyAppState ref) <- getState
         commands <- liftIO $ atomicModifyIORef' ref $ \commands -> (addCustomReplaceCommand commands (pat theCommand, replacement theCommand),
                                                                     addCustomReplaceCommand commands (pat theCommand, replacement theCommand))
         text ("ok")
