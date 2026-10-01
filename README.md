# GatherMate (Aethro)

GatherMate v.1.25 for WoW WotLK 3.3.5a, with support for Aethro's custom outdoor zone **Azshara Crater** (map ID 1005).

Stock GatherMate treats that map as continent `-1` / zone `0` (and may unregister in instances). This fork records herbs, ore, gas, fish, and treasure there and shows them on the minimap and world map.

## Install

Download **GatherMate_Aethro.zip** from [Releases](https://github.com/SultonMRP/GatherMate_Aethro/releases) and extract it into:

`World of Warcraft/Interface/AddOns`

You should end up with:

- `Interface/AddOns/GatherMate`

Then `/reload` in-game.

## Usage

Gather as normal. Nodes in Azshara Crater are stored under that zone name and stay after logout and `/reload`.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) and [Releases](https://github.com/SultonMRP/GatherMate_Aethro/releases).

### v1.25-aethro.2

Fixed leftover Azshara Crater pins after `.v back` (Guild Village) to a city. Orgrimmar minimap and world map no longer show the crater node set.

## Notes

- Based on GatherMate v.1.25 (`## Interface: 30300`)
- Azshara Crater is a private-server map, not a stock Blizzard zone
- Zone name is **Azshara Crater**. Map ID is **1005**.
