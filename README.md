# Status - `Smashing Bugs`
Current Version - 2.0

# NightCrawlerGO
NightCrawler Mod for CS:GO

# Description

> At round start, random player(s) are chosen to be NightCrawlers. NightCrawlers have more speed, less gravity, a custom knife, are invisible, can climb walls, can teleport, etc. The objective of the NightCrawlers is to kill the Humans.

> The Humans can choose any primary and secondary weapons in the game. They can also choose from a variety of different useful and unique items. These items include - Laser Sight, Suicide Bomb, Poison Scout Bullets, Adrenaline, Healthshots, etc. Their objective is to defend themselves by any means possible.

# Includes
- [overlays.inc](https://github.com/shanapu/overlays.inc)
- [multicolors.inc](https://github.com/Bara/Multi-Colors/)

# CVARs

| CVAR | Input | Description |
|:--- |:---:|:--- |
| `nc_ratio` | amount | X:1 Ratio of players that are nightcrawlers where X is the number of Humans per 1 NightCrawler.
| `nc_human_max_health` | amount | Max health of a Human.
| `nc_health` | amount | Base health of a NightCrawler.
| `nc_gravity` | amount | Base gravity of a NightCrawler.
| `nc_speed` | amount | Base speed of a NightCrawler.
| `nc_visible_time` | seconds | Duration for which NightCrawlers are visible upon taking damage.
| `nc_health` | health | How much health nightcrawlers spawn with.
| `nc_gravity` | gravity | How much gravity nightcrawlers spawn with.
| `nc_speed` | speed | How much speed nightcrawlers have.
| `nc_teleport_count` | amount | Amount of starting teleports given to a NightCrawler.
| `nc_teleport_delay` | seconds | Minimum required delay between two consecutive teleports.
| `nc_lighting` | letter | Level of lighting in the map. a = pitch black, z = bright like a star.
| `nc_adrenaline_uses` | amount | Amount of uses of Adrenaline.
| `nc_adrenaline_time` | seconds | Duration for which Adrenaline lasts.
| `nc_adrenaline_speed` | speed | Speed during Adrenaline use.
| `nc_adrenaline_health` | health | Amount of health given by adrenaline shot.
| `nc_suicide_damage` | damage | Amount of damage done by Suicide Bomber.
| `nc_suicide_radius` | distance | Distance / Radius from the player in which damage can be taken.
| `nc_suicide_time` | seconds | Delay before exploding.
| `nc_poison_amount` | amount | Number of times a player is affected by poison.
| `nc_poison_interval` | seconds | Interval between two consecutive poison hurts.
| `nc_poison_damage` | damage | Maximum damage done by a poison hurt.
| `nc_trip_mine_count` | amount | Amount of trip mines.
| `nc_trip_mine_mode` | mode | 0 = Trip Laser, 1 = Trip Mine.
| `nc_frost_nade_count` | amount | Amount of Frost Nades.
| `nc_frost_nade_radius` | distance | Distance / Radius from the grenade explosion in which NightCrawlers are frozen.
| `nc_frost_nade_time` | seconds | Duration for which NightCrawlers are frozen.
| `nc_napalm_nade_count` | amount | Amount of Napalm Nades.
| `nc_napalm_nade_radius` | distance | Distance / Radius from the grenade explosion in which NightCrawlers are burnt.
| `nc_napalm_nade_time` | seconds | Duration for which NightCrawlers are burnt.
| `nc_ammo_mode` | mode | 0 = Limited, 1 = Restock ammo on reload, 2 = Restock ammo only on kill.


# Inspired by Nightcrawler Mod for CS 1.6 by H3avY Ra1n
