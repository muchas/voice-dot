module Lib
    ( processTranscript,
      addCustomReplaceCommand,
      spacesJoin,
      predefinedCommands,
      makeReplaceCommand,
      matchCommand,
      toggleIgnore,
      removeFromBuffer,
      getProcessedBuffer,
      Context(..),
      Command(..),
      Invocation(..),
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


leftParens = ["(", "[", "{"]
leftParenNames = ["nawias okrągły", "nawias kwadratowy", "nawias klamrowy"]
rightParens = [")", "]", "}"]
parens = zip leftParens rightParens
leftParensMapping = zip leftParenNames leftParens
replaceMapping = [("kropka", "."), ("wykrzyknik", "!"), ("znak zapytania", "?")]

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


useIgnore :: String -> Context -> Invocation -> Invocation
useIgnore text ctx invocation =
                      if not (ignore ctx)
                      then invocation
                      else Invocation text (Context False (parenthesis ctx))

makeGenericCommand pattern getInvocation =
  Command pattern (\t ctx -> useIgnore pattern ctx (getInvocation ctx))

makeIgnoreCommand =
  makeGenericCommand
    "ignoruj"
    (\ctx -> Invocation "" (toggleIgnore ctx))

makeOpenParenCommand (pattern, leftParen) =
  makeGenericCommand
    pattern
    (\ctx -> Invocation leftParen (Context False ((parenthesis ctx) ++ [leftParen])))

matchRightParen parens leftParen =
  let match = find (\x -> fst x == leftParen) parens
  in case match of
    Just (left, right) -> right
    Nothing -> error "Could not match right paren!"

makeCloseParenCommand =
  makeGenericCommand
  "zamknij nawias"
  (\ctx ->
      (let parensStack = parenthesis ctx
      in if (not $ null parensStack)
         then Invocation (matchRightParen parens (last parensStack)) (Context (ignore ctx) (init (parenthesis ctx)))
         else Invocation "zamknij nawias" ctx))

makeReplaceCommand (pattern, text) =
  makeGenericCommand pattern (\c -> Invocation text (Context False (parenthesis c)))

predefinedCommands = (makeReplaceCommand <$> replaceMapping)
        ++ (makeOpenParenCommand <$> leftParensMapping)
        ++ [makeIgnoreCommand, makeCloseParenCommand]

addCustomReplaceCommand commands (pattern, replacement) =
   commands ++ [makeReplaceCommand (pattern, replacement)]

processTranscript :: [Command] -> Transcript -> Transcript
processTranscript commands t = spacesJoin $ processCommands commands (Context False []) (words t) [] []
