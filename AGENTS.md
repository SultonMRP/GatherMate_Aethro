# GatherMate (WotLK 3.3.5a / Aethro)

GatherMate **v.1.25** (`## Interface: 30300`) for Aethro. Folder: `D:\Warcrafts\Aethro\Interface\AddOns\GatherMate`. Client is **3.3.5a**. Lua 5.1 + FrameXML. No retail/Cata+ APIs unless guarded (`wow40 = select(4, GetBuildInfo()) >= 40000`).

This fork adds **Azshara Crater** (Aethro map ID **1005**). Stock GatherMate ignores that map.

Keep it in the Aethro AddOns tree. Do not pull retail GatherMate2.

## User chat: `\reload` = WoW `/reload`

The user writes **`\reload`** on purpose. That is the in-game WoW UI reload command **`/reload`**.

Cursor treats a leading `/` as a skill / slash-command. A backslash avoids that. Do **not** “fix” `\reload` to `/reload` in chat.

- User says `\reload` → they will (or did) type `/reload` in WoW.
- When you tell them to reload the addon, write **`\reload`**, never `/reload`.
- `\reload` loads Lua/XML/TOC from disk.

## What this addon is

Lightweight gather tracker: herbs, mines, gas clouds, fishing, some treasure. Nodes go on the **minimap** and **world map**. No HUD (that is Gatherer_HUD).

Nodes are stored by **localized zone name** → GatherMate zone ID. SavedVariables: `GatherMateHerbDB`, `GatherMateMineDB`, `GatherMateFishDB`, `GatherMateGasDB`, `GatherMateTreasureDB`, plus `GatherMateDB` for profile/settings.

## Azshara Crater (required context)

Aethro custom outdoor map. Not in `GetMapContinents()` / `GetMapZones()`. Stock APIs report:

| API | Crater value |
|-----|----------------|
| `GetCurrentMapContinent()` | `-1` |
| `GetCurrentMapZone()` | `0` |
| `GetCurrentMapAreaID()` | `1005` (Aethro-added; guard with `if GetCurrentMapAreaID then`) |
| `GetMapInfo()` | `AzsharaCrater` / `Azshara_Crater` / `ACrater` / `AZ_Crater` |
| `GetRealZoneText()` | `Azshara Crater` |
| `GetPlayerMapPosition("player")` | Works after `SetMapToCurrentZone()` |
| `SetMapZoom(1005, …)` | Invalid — do not call |

`IsInInstance()` may be true. Stock GatherMate then **unregisters collect + display**. Treat the crater as outdoor via `GatherMate.CustomZones.ShouldTreatAsOutdoor()`.

Do **not** put the crater in `specialZones` (Frozen Sea / North Sea). That path keeps `0,0` when the world map is open to another zone. Crater rule: if `x,y` are `0`, use last position; if only zone is `0` and coords are valid, use live position.

GatherMate zone ID is **1005** (stock IDs stop at 143). Do **not** use `37` — that is Hinterlands in `zone_data`. Server map IDs `37` and `268` are crater **aliases** only, and only when continent `<= 0`.

Yard size (estimated 3:2, same as Gatherer): `5070.886912363937 x 3381.22554790382`. World-map pins use 0–1 coords and do not depend on this; minimap range and cleanup do.

### CustomZones API (`CustomZones.lua`)

- `GetDefinitionForPlayer()` — zone name first; map file / map ID only if continent `<= 0`
- `GetPlayerZoneName()` — canonical `Azshara Crater` when in the crater
- `IsCustomOutdoorZone(name)`
- `ShouldTreatAsOutdoor()` — true in crater even if `IsInInstance()`
- `ResolveViewedZone()` — viewed map file / map ID for world-map pins
- `Register()` — injects names into `GatherMate.zoneData` after `Constants.lua` builds stock tables

Do not learn `GetMapInfo()` as a crater file while the world map is on a stock continent (that would record Elwynn as the crater).

## Layout

| Path | Role |
|------|------|
| `GatherMate.toc` | `Interface: 30300`. Loads `CustomZones.lua` after `Constants.lua`, before `Config.lua`. |
| `GatherMate.lua` | Core DB: add/remove/find nodes, zone size/ID. |
| `Display.lua` | Minimap + world-map pins. Crater: outdoor override, zone-0 position, `ResolveViewedZone`. |
| `Collector.lua` | Spell/loot hooks. Crater: keep events on; store under `Azshara Crater`. |
| `Constants.lua` | `zone_data` sizes/IDs (includes crater map files), node IDs, icons. |
| `CustomZones.lua` | Aethro crater detection + `zoneData` inject. |
| `Config.lua` | AceConfig options. Zone dropdown is `pairs(GatherMate.zoneData)`. |
| `Locales/` | AceLocale. Zone name comes from the client, not these files. |
| `Libs/` | Bundled Ace3. Do not replace with retail Ace. |
| `AGENTS.md` | This file. |

## 3.3.5a constraints

- Lua 5.1. No `continue`. No `C_Timer`, no Cata profession API.
- Tracking: `GetNumSkillLines` / `GetSkillLineInfo` / `GetTrackingTexture` (gated off when `wow40`).
- Combat log uses the 3.3.5 argument order (`srcGUID, srcName, …`).
- `GetCurrentMapAreaID` is Aethro-only here. Always guard; fall back to `GetMapInfo()` / `GetRealZoneText()`.
- Textures: BLP/TGA only.
- Ace3 is already bundled. Copy from Aethro addons if needed — do not download retail Ace.

## Related addons (read-only unless asked)

- `D:\Warcrafts\Aethro\Interface\AddOns\Gatherer` — confirmed crater remap (`GatherCustomZones.lua`, Astrolabe). Reference only.
- `D:\Warcrafts\Aethro\Interface\AddOns\Gatherer_HUD` — HUD uses Gatherer’s remapped position. GatherMate has no HUD.
- `D:\Warcrafts\Aethro\Interface\AddOns\TomTom` — crater remap lives there (`TomTomCustomZones.lua`, Astrolabe-0.4 rev 110). GatherMate pin → TomTom uses `TomTom:GetViewedCZ()`.
- `D:\Warcrafts\Aethro\Interface\AddOns\Cartographer` — crater in LibBabble-Zone / LibTourist, plus `Cartographer_CustomZones.lua`. GatherMate pin → Cartographer uses `BZR[zone] or pin.zone`.

## Out of scope unless asked

- Editing Gatherer / Gatherer_HUD
- Measuring true crater yard size in-game
- Importing Gatherer node data into GatherMate
- TomTom / Cartographer waypoint targeting for map 1005
- Other Aethro custom maps

## Product rules

- Talk through behavior before large edits when the request is a design change.
- Do not copy Astrolabe into GatherMate. Zone keys stay localized names + CustomZones helpers.
- After Lua/TOC/XML changes, tell the user to `\reload`.
- In-crater check: gather herb/ore → minimap pin → crater world map pins → survive `\reload` under zone ID 1005 → stock zones still work after leaving.
