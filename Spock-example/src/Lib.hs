module Lib
    ( processTranscript
    ) where

-- someFunc :: IO ()
-- someFunc = putStrLn "someFunc"
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


toggleIgnore :: Context -> Context
toggleIgnore (Context ignore parens) = Context (not ignore) parens


ignoreCmd = Command "ignoruj" (\t c -> if not (ignore c)
                                      then Invocation "" (toggleIgnore c)
                                      else Invocation "ignoruj" (toggleIgnore c))

replaceCmd pattern replacement =
    Command pattern (\t c -> if not (ignore c)
                              then Invocation replacement (Context False (parenthesis c))
                              else Invocation pattern (Context False (parenthesis c)))

dotCmd = replaceCmd "kropka" "."
exclamationMarkCmd = replaceCmd "wykrzyknik" "!"
openParenthesisCmd = replaceCmd "otworz nawias" "("
closeParenthesisCmd = replaceCmd "zamknij nawias" ")"
questionMarkCmd = replaceCmd "znak zapytania" "?"

fitCommand :: [Command] -> String -> Maybe Command
fitCommand commands "" = Nothing
fitCommand [] _ = Nothing
fitCommand (c:cs) value =
  if endswith (pattern c) value
  then Just c
  else fitCommand cs value


transform :: [String] -> String -> [String]
transform ws toReplace =  words $ replace toReplace "" $ intercalate " " ws


processCommands :: [Command] -> Context -> [String] -> [String] -> [String] -> [String]
processCommands commands ctx [] lAcc rAcc = rAcc ++ lAcc
processCommands commands ctx (w:ws) lAcc rAcc =
      let mCmd = fitCommand commands (intercalate " " (lAcc ++ [w]))
      in case mCmd of
       Just cmd -> processCommands commands (context inv) ws [] (rAcc ++ (transform (lAcc ++ [w]) (pattern cmd) ++ words (output inv) ))
                  where inv = execute cmd "" ctx
       Nothing -> processCommands commands ctx ws (lAcc ++ [w]) rAcc


-- processCommands [replaceCmd, ignoreCmd] ["To", "jest", "kropka"] []
--

-- parse :: [Command] -> String -> Maybe Command
-- parse commands transcript =
--   find (\cmd -> pattern cmd == cmdName) commands

--
-- replaceDot = replaceCommand "kropka" "."

cmds = [dotCmd, exclamationMarkCmd, openParenthesisCmd,
        closeParenthesisCmd, questionMarkCmd, ignoreCmd]



processTranscript :: String -> String
processTranscript t = intercalate " " $ processCommands cmds (Context False []) (words t) [] []


--
-- executeCommand :: String -> String
-- executeCommand (ReplaceCommand s) = s
-- executeCommand (IgnoreCommand) = words
