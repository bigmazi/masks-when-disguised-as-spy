### AlliedModders thread

https://github.com/bigmazi/masks-when-disguised-as-spy

### What it is about

When a player disguises as a Spy, this player's enemies see this player rendered as a friendly disguised Spy, who is wearing a paper mask. By default the decision of which particular class to render on such a mask is done by game automatically and it is a completely random selection that follows uniform distribution (any one of nine classes may appear on such a mask with equal chance).

What this plugin changes

This plugin allows to tell the game which classes may be selected to be rendered on such a mask and which may not.

### Obvious use case

When a player disguises as a Spy, this player's movement speed remains unchanged. However, if the game picks a mask of a slower class, enemies can spot the dissonance between player's actual speed and the speed a friendly Spy disguised as the class from the mask would have. This is especially easy to notice if the class that appears on the mask is Soldier or Heavy Weapons Guy - these masks are an obvious giveaway of the disguise which player have neither control over nor information about. This plugin may be used to forbid the masks of slower classes from being selected.

###Console variables

```
"sm_spymask_plugin_enabled" = "1" min. 0.000000 max. 1.000000
 - Allows to select masks which Spy's enemies can see when disguised as Spy
"sm_spymask_allow_scout" = "1" min. 0.000000 max. 1.000000
 - When a player is disguised as a Spy, is Scout's mask allowed to be shown to this player's enemies?
"sm_spymask_allow_soldier" = "1" min. 0.000000 max. 1.000000
 - When a player is disguised as a Spy, is Soldier's mask allowed to be shown to this player's enemies?
"sm_spymask_allow_pyro" = "1" min. 0.000000 max. 1.000000
 - When a player is disguised as a Spy, is Pyro's mask allowed to be shown to this player's enemies?
"sm_spymask_allow_demoman" = "1" min. 0.000000 max. 1.000000
 - When a player is disguised as a Spy, is Demoman's mask allowed to be shown to this player's enemies?
"sm_spymask_allow_heavy" = "1" min. 0.000000 max. 1.000000
 - When a player is disguised as a Spy, is Heavy Weapons Guy's mask allowed to be shown to this player's enemies?
"sm_spymask_allow_engineer" = "1" min. 0.000000 max. 1.000000
 - When a player is disguised as a Spy, is Engineer's mask allowed to be shown to this player's enemies?
"sm_spymask_allow_medic" = "1" min. 0.000000 max. 1.000000
 - When a player is disguised as a Spy, is Medic's mask allowed to be shown to this player's enemies?
"sm_spymask_allow_sniper" = "1" min. 0.000000 max. 1.000000
 - When a player is disguised as a Spy, is Sniper's mask allowed to be shown to this player's enemies?
"sm_spymask_allow_spy" = "1" min. 0.000000 max. 1.000000
 - When a player is disguised as a Spy, is Spy's mask allowed to be shown to this player's enemies?
```

### Presets

The plugin ships with several presets implemented in a form of console commands. They may be executed from the terminal or by an admin with RCON rights. These commands set cvar values in bulk to achieve the desired effect. Note, that you may execute a preset command from the autoconfig.

```
"sm_spymask_preset_allow_all"
 - Any class can appear on disguise masks (effectively, no modifications)
"sm_spymask_preset_at_least_soldier_speed"
 - Disguise masks blacklist: Heavy Weapons Guy
"sm_spymask_preset_at_least_demoman_speed"
 - Disguise masks blacklist: Soldier, Heavy Weapons Guy
"sm_spymask_preset_at_least_pyro_speed"
 - Disguise masks blacklist: Soldier, Demoman, Heavy Weapons Guy
"sm_spymask_preset_at_least_spy_speed"
 - Disguise masks whitelist: Scout, Medic, Spy
```
