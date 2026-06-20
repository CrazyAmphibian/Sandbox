# Sandbox Mode

## For users

### what are the mod's features?
Adds a dedicated game mode, and uses the game's native save slot system to allow for multiple concurent worlds that do not interfere with your main game's run.
In sandbox mode, the player is granted with the following:
* True invincibility
* The perks edit wands everywhere, unlimited spells, and all seeing eye
* the ability to spawn in certain entities
* the ability to edit wand stats
* the ability to spawn perks and spells
* the ability to spawn in potions and pouches with specific materials
* the ability to teleport to arbitrary locations, save locations for later, as well as some presets.
* some other powers, like unlimited gold, or being able to restore health or spell charges


## For other modders

### how do i integrate my content with this mod?
if it is a **spell**, **perk**, or **material**, this process is done automatically via the game's existing APIs and data.

custom **wands** with lua scripts attached are safe to modify with this mod's wand editor, and any non-standard components are ignored

for **entities**, you will have to manually register each entity you want to be able to spawn. This is done by modyfying the file `mods/sandbox_mode/files/ui/entity_list.lua`, using the added function `add_entity_to_list(entity_path,entity_name,category)`. current entity categories can be seen in `/files/ui/vanilla_ents.lua` or in game. as it is now, there is `props` `wands` `enemies` `bosses` `pickups` `items`. you don't have to use one of the existing categories, though it is recomended in order to reduce UI clutter.
```lua
ModTextFileSetContent("mods/sandbox_mode/files/ui/entity_list.lua",ModTextFileGetContent("mods/sandbox_mode/files/ui/entity_list.lua")..[[
add_entity_to_list("mods/my_mod/files/my_entity.xml","Cool Thing","item")
]]
)
```

### how do i add custom actions?
the `misc` tab is your best bet for general purpose functions. this will require modifying the source file `/files/ui/ui_main.lua` using `ModTextFileSetContent` and `ModTextFileGetContent`.

### how do i add custom teleportation locations?
Similarly to actions, you will have to modify the source file. the table `hardcodelocations` is locally defined in the teleport menu logic section, and uses the syntax of `hardcodelocations[category]={location1,location2}`, with each location having the following syntax:
```lua
{
  name="dispaly name",
  x=0,
  y=0,
  pw=false, --defaults to false, optional. if true, teleportation is done relative to the player's PW instead of absolute position
  no_ngp=false, --defaults to false, optional. if true, the location is disabled if the player is in new game+
}
```
custom logic can also be used to insert locations that have more complex conditions