import Test.HUnit
import Lib


testSpacesJoin1 = TestCase (assertEqual "for spacesJoin"
                    (spacesJoin ["test1", "1", "test2"]) "test1 1 test2")

testSpacesJoin2 = TestCase (assertEqual "for spacesJoin empty"
                    (spacesJoin []) "")


testMatchCommand1 = TestCase (
  let com1 = Command "kropka" (\o c -> Invocation o c)
      com2 = Command "nawias" (\o c -> Invocation o c)
            in assertEqual "for MatchCommand"
                  (fmap pattern (matchCommand [com1, com2] "Sample text kropka"))  (Just "kropka"))

testMatchCommand2 = TestCase (
  let com1 = Command "kropka" (\o c -> Invocation o c)
      com2 = Command "nawias" (\o c -> Invocation o c)
            in assertEqual "for MatchCommand Empty"
                  (fmap pattern (matchCommand [com1, com2] "Sample text"))  Nothing)


testToggleIgnore = TestCase (
  let ctx = (Context True [])
            in assertEqual "for toggleignore" (ignore (toggleIgnore ctx)) False)

testRemoveFromBuffer = TestCase(
  let buf = ["Sample", "test", "sentence", "test", "kropka"]
            in assertEqual "for removeFromBuffer" (removeFromBuffer buf "test") ["Sample","sentence","kropka"])

testGetProcessedBuffer = TestCase(
  let buf = ["Sample", "test", "sentence", "test", "kropka"]
      com = Command "kropka" (\o c -> Invocation "." c)
      inv = Invocation "." (Context False [])
            in assertEqual "for getProcessedBuffer" (getProcessedBuffer buf com inv) ["Sample", "test", "sentence", "test", "."])


testProcessTranscript1 = TestCase (
            assertEqual "for processTranscript kropka"
                  (processTranscript predefinedCommands "Test kropka") "Test .")

testProcessTranscript2 = TestCase (
            assertEqual "for processTranscript otwórz nawias kropka"
                  (processTranscript predefinedCommands  "Test otwórz nawias kropka") "Test ( .")

testProcessTranscript3 = TestCase (
            assertEqual "for processTranscript ignoruj"
                  (processTranscript  predefinedCommands "Test ignoruj otwórz nawias otwórz nawias") "Test otwórz nawias (")


tests = TestList [TestLabel "spacesJoin1" testSpacesJoin1,
                  TestLabel "spacesJoin2" testSpacesJoin2,
                  TestLabel "testMatchCommand1" testMatchCommand1,
                  TestLabel "testMatchCommand2" testMatchCommand2,
                  TestLabel "testToggleIgnore" testToggleIgnore,
                  TestLabel "testRemoveFromBuffer" testRemoveFromBuffer,
                  TestLabel "testGetProcessedBuffer" testGetProcessedBuffer,
                  TestLabel "processTranscript1" testProcessTranscript1,
                  TestLabel "processTranscript2" testProcessTranscript2,
                  TestLabel "processTranscript3" testProcessTranscript3]

main = runTestTT tests
