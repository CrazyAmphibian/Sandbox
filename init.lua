
-- all functions below are optional and can be left out

function OnModPreInit()
	--print("Mod - OnModPreInit()") -- First this is called for all mods
end

function OnModInit()
	dofile("mods/sandbox_mode/files/start_pixel_scene/append.lua")
	--print("Mod - OnModInit()") -- After that this is called for all mods
end

function OnModPostInit()
	
	
	
	
	--print("Mod - OnModPostInit()") -- Then this is called for all mods
end

function OnPlayerSpawned( player_entity ) -- This runs when player entity has been created
	--GamePrint( "OnPlayerSpawned() - Player entity id: " .. tostring(player_entity) )
	
end

function OnWorldInitialized() -- This is called once the game world is initialized. Doesn't ensure any world chunks actually exist. Use OnPlayerSpawned to ensure the chunks around player have been loaded or created.
	--GamePrint( "OnWorldInitialized() " .. tostring(GameGetFrameNum()) )
end

function OnWorldPreUpdate() -- This is called every time the game is about to start updating the world
	--GamePrint( "Pre-update hook " .. tostring(GameGetFrameNum()) )
	local player=EntityGetWithTag("player_unit")[1] or EntityGetWithTag("polymorphed_player")[1]
	if not player then return end
	if EntityHasTag(player,"sandbox_mode_GODMODE") then
	
	else
		local script_c_id=EntityAddComponent(player,"LuaComponent",
		{
			script_damage_received="mods/sandbox_mode/files/invincible_entity.lua",
		})
		
		EntityAddTag(player,"sandbox_mode_GODMODE")
	end
end

function OnWorldPostUpdate() -- This is called every time the game has finished updating the world
	--GamePrint( "Post-update hook " .. tostring(GameGetFrameNum()) )
	dofile("mods/sandbox_mode/files/ui/ui_main.lua")
end


function OnMagicNumbersAndWorldSeedInitialized() -- this is the last point where the Mod* API is available. after this materials.xml will be loaded.
	
end


--print("Example mod init done")