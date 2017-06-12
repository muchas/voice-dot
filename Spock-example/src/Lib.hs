module Lib
    ( processTranscript
    ) where

import Data.List
import Data.List.Utils

data Invocation = Invocation
    { output :: String
    , context :: Context
    } deriving Show

data Command = Command
    { pattern :: String
    , execute :: String -> Context -> Invocation
    }

data Context = Context
    { ignore :: Bool
    , parenthesis :: [String]
    } deriving Show


type WordList = [String]
type Buffer = [String]
type Transcript = String

spacesJoin = intercalate " "

toggleIgnore :: Context -> Context
toggleIgnore (Context ignore parens) = Context (not ignore) parens

-- to jest otworz nawias  <-- otworz nawias to komenda
matchCommand :: [Command] -> String -> Maybe Command
matchCommand commands "" = Nothing
matchCommand [] _ = Nothing
matchCommand (c:cs) value =
  if endswith (pattern c) value
  then Just c
  else matchCommand cs value

removeFromBuffer :: Buffer -> String -> Buffer
removeFromBuffer ws toReplace =  words $ replace toReplace "" $ spacesJoin ws

getProcessedBuffer :: Buffer -> Command -> Invocation -> Buffer
getProcessedBuffer acc cmd inv = removeFromBuffer acc (pattern cmd) ++ words (output inv)

processCommands :: [Command] -> Context -> WordList -> Buffer -> Buffer -> WordList
processCommands commands ctx [] lAcc rAcc = rAcc ++ lAcc
processCommands commands ctx (w:ws) lAcc rAcc =
      let acc = lAcc ++ [w]
      in case matchCommand commands (spacesJoin acc) of
         Just cmd -> processCommands commands (context inv) ws [] (rAcc ++ getProcessedBuffer acc cmd inv)
                     where inv = execute cmd "" ctx
         Nothing -> processCommands commands ctx ws acc rAcc


makeIgnoreCommand = Command "ignoruj" (\t c -> if not (ignore c)
                                             then Invocation "" (toggleIgnore c)
                                             else Invocation "ignoruj" (toggleIgnore c))

-- makeOpenParenCommand pattern leftParen =
--     Command pattern (\t c -> if not (ignore c)
--                              then Invocation leftParen (Context False (parenthesis c ++ [leftParen])) )
-- makeCloseParenCommand pattern rightParen =
--     Command pattern (\t c -> if not (ignore c)
--                              then

makeReplaceCommand (pattern, replacement) =
   Command pattern (\t c -> if not (ignore c)
                            then Invocation replacement (Context False (parenthesis c))
                            else Invocation pattern (Context False (parenthesis c)))

parens = [("(", ")"), ("[", "]"), ("{", "}")]

replaceMapping = [("kropka", "."), ("wykrzyknik", "!"), ("otwórz nawias", "("),
                 ("zamknij nawias", ")"), ("znak zapytania", "?")]

commands = (makeReplaceCommand <$> replaceMapping) ++ [makeIgnoreCommand]
        -- ++ (makeCloseParenCommand (\x -> snd x) parens) ++ (makeOpenParenCommand (\x -> fst x) parens)

processTranscript :: Transcript -> Transcript
processTranscript t = spacesJoin $ processCommands commands (Context False []) (words t) [] []
