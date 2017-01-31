# Killalytics

Suite of things that do stuff with live killmails. Currently just a dumb stream to terminal.

## Installation

You'll need Elixir 1.4 and the Hex package manager (installable through `mix local.hex`).

Clone this Git repository and run
```bash
mix deps.get
```

to fetch the dependencies, followed by
```bash
elixir --no-halt -S mix run
```

to run the killfeed indefinitely in the console.

Please note that ZKillboard occasionally reprocesses kills and these are fed to RedisQ,
which this doesn't currently filter; old killmails may be replayed in the console as a result.

## Flow of Killmails
```
Killmails are piped in from RedisQ by the Killalytics.KillmailFeed process
    -> KillmailFeed parses and 
```
