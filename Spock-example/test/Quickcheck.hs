{-# LANGUAGE TemplateHaskell #-}
import Test.QuickCheck
import Test.QuickCheck.All
import Data.List.Utils
import Lib


instance Arbitrary Context where
   arbitrary = elements [Context False [], Context True []]


matchCommand_ = matchCommand predefinedCommands

prop_toggle_spaces_join xs = concat (map words xs) == (words $ spacesJoin xs)

prop_toggle_ignore ctx = ignore ctx == (ignore $ toggleIgnore $ toggleIgnore ctx)

prop_match_command name =
  case matchCommand_ name of
    Just cmd -> endswith (pattern cmd) name
    Nothing -> not $ elem name [pattern cmd | cmd <- predefinedCommands]


return []
runTests = $quickCheckAll
main = runTests
