# voice-dot
Project for functional programming classes.

VoiceDot works as a chrome extension - it's a simple command voice control tool, lets you dictate words like "kropka", "wykrzyknik" and instatly replaces them with ".", "!". 

Moreover you can dynamically define your own commands. In order to ignore implemented command pattern, there's ignore command which pattern is specified as "ignoruj".

For now above functionality works only for polish language.

Backend is written in Haskell with usage of Spock rest framework.


Running backend:

`cd backend`

`stack build --fast`

`stack exec Spock-example-exe`


Running tests:

`cd backend`

`stack test`
