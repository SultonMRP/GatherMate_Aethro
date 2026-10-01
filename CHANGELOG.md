# GatherMate Aethro changelog

## v1.25-aethro.2

Fixed leftover Azshara Crater pins after leaving via Guild Village (`.v back`).

- Stopped treating a city (Orgrimmar) as the crater when continent / `GetMapInfo()` were still stale
- Stopped learning city names and map files as crater aliases
- Minimap no longer keeps the crater node set after a zone change
- World map no longer draws crater 0–1 pins on the Orgrimmar city map
- Crater nodes still store and show under **Azshara Crater** / map ID **1005**

## v1.25-aethro

Initial Aethro fork: record and show gather nodes in Azshara Crater.
