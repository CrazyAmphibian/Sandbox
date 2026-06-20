dofile_once("data/scripts/lib/utilities.lua")

--for spell indexing
dofile_once("data/scripts/gun/gun_enums.lua")
dofile_once("data/scripts/gun/gun_actions.lua")

--perk spawns
dofile_once("data/scripts/perks/perk.lua")
dofile_once( "data/scripts/perks/perk_list.lua" )

--wand spawning
dofile_once("data/scripts/gun/procedural/gun_procedural.lua")

--entities
dofile_once("mods/sandbox_mode/files/ui/entity_list.lua")


dofile_once("mods/sandbox_mode/files/tableserial.lua")



function get_held_wand(entity) --thanks graham
	local inv2comp = EntityGetFirstComponentIncludingDisabled(player, "Inventory2Component")
	if inv2comp then
        local activeitem = ComponentGetValue2(inv2comp, "mActiveItem")
		EntityHasTag(activeitem, "wand")
		return activeitem
    end
	return nil
end

function vertial_incrementation_overlays(x,y,value,inc1,inc2,inc3,min,max)
	local _=value
	
	if GuiButton(sandbox_mode_ui,gui_next_id(),x,y-10,"+") then _=value+inc1 end
	if GuiButton(sandbox_mode_ui,gui_next_id(),x,y-20,"++") then _=value+inc2 end
	if GuiButton(sandbox_mode_ui,gui_next_id(),x,y-30,"+++") then _=value+inc3 end
	
	if GuiButton(sandbox_mode_ui,gui_next_id(),x,y+10,"-") then _=value-inc1 end
	if GuiButton(sandbox_mode_ui,gui_next_id(),x,y+20,"--") then _=value-inc2 end
	if GuiButton(sandbox_mode_ui,gui_next_id(),x,y+30,"---") then _=value-inc3 end
	
	if min then
		_=math.max(_,min)
	end
	if max then
		_=math.min(_,max)
	end
	
	return _
end

function vertial_incrementation4_overlays(x,y,value,inc1,inc2,inc3,inc4,min,max)
	local _=value
	
	if GuiButton(sandbox_mode_ui,gui_next_id(),x,y-10,"+") then _=value+inc1 end
	if GuiButton(sandbox_mode_ui,gui_next_id(),x,y-20,"++") then _=value+inc2 end
	if GuiButton(sandbox_mode_ui,gui_next_id(),x,y-30,"+++") then _=value+inc3 end
	if GuiButton(sandbox_mode_ui,gui_next_id(),x,y-40,"+++++") then _=value+inc4 end
	
	if GuiButton(sandbox_mode_ui,gui_next_id(),x,y+10,"-") then _=value-inc1 end
	if GuiButton(sandbox_mode_ui,gui_next_id(),x,y+20,"--") then _=value-inc2 end
	if GuiButton(sandbox_mode_ui,gui_next_id(),x,y+30,"---") then _=value-inc3 end
	if GuiButton(sandbox_mode_ui,gui_next_id(),x,y+40,"----") then _=value-inc4 end
	
	if min then
		_=math.max(_,min)
	end
	if max then
		_=math.min(_,max)
	end
	
	return _
end

function should_spell_be_shown(spelldata)
	if menudata.spelloptions.hidenotunlocked and spelldata.spawn_requires_flag and (not HasFlagPersistent(spelldata.spawn_requires_flag)) then return false end
	if menudata.spelloptions.hideunobtainable and (spelldata.spawn_level=="" or spelldata.spawn_probability=="" or spelldata.spawn_probability=="0") then return false end

	if spelldata.type==ACTION_TYPE_PROJECTILE then return menudata.spelloptions.showproj end
	if spelldata.type==ACTION_TYPE_STATIC_PROJECTILE then return menudata.spelloptions.showstatic end
	if spelldata.type==ACTION_TYPE_MODIFIER then return menudata.spelloptions.showmod end
	if spelldata.type==ACTION_TYPE_UTILITY then return menudata.spelloptions.showutil end
	if spelldata.type==ACTION_TYPE_MATERIAL then return menudata.spelloptions.showmaterial end
	if spelldata.type==ACTION_TYPE_DRAW_MANY then return menudata.spelloptions.showmulti end
	if spelldata.type==ACTION_TYPE_PASSIVE then return menudata.spelloptions.showpassive end
	if spelldata.type==ACTION_TYPE_OTHER then return menudata.spelloptions.showother end
	
	return true --fallback in case there's an invalid or new spell type i guess
end
function display_spell(spelldata,x,y)
	local colorlookups={
		default={r=.5,g=.5,b=.5},
		[ACTION_TYPE_PROJECTILE]={r=.353,g=.125,b=.125},
		[ACTION_TYPE_STATIC_PROJECTILE]={r=.553,g=.247,b=.094},
		[ACTION_TYPE_MODIFIER]={r=.176,g=.228,b=.448},
		[ACTION_TYPE_UTILITY]={r=.482,g=.165,b=.455},
		[ACTION_TYPE_MATERIAL]={r=53/255,g=111/255,b=68/255},
		[ACTION_TYPE_DRAW_MANY]={r=28/255,g=109/255,b=115/255},
		[ACTION_TYPE_PASSIVE]={r=33/255,g=47/255,b=38/255},
		[ACTION_TYPE_OTHER]={r=113/255,g=75/255,b=51/255},
	}
	local c=colorlookups[spelldata.type or ""] or colorlookups.default
	GuiColorSetForNextWidget(sandbox_mode_ui ,c.r,c.g,c.b,1 )
	GuiZSetForNextWidget(sandbox_mode_ui,1)
	if GuiImageButton(sandbox_mode_ui,gui_next_id(),x,y,"","mods/sandbox_mode/files/ui/16pxsquare.png") then
		--spawn spell.
		if player then
			local pos_x, pos_y = EntityGetTransform( player )
			CreateItemActionEntity( spelldata.id, pos_x, pos_y )
			--print("SPAWN "..spelldata.id,pos_x,pos_y)
		end
	end
	
	
	_,_,hovered=GuiGetPreviousWidgetInfo(sandbox_mode_ui)
	if hovered then
		GuiZSetForNextWidget(sandbox_mode_ui,-1)
		GuiText(sandbox_mode_ui,x,y-10,GameTextGetTranslatedOrNot(spelldata.name) )
		GuiZSetForNextWidget(sandbox_mode_ui,-1)
		GuiColorSetForNextWidget(sandbox_mode_ui,.5,.5,.5,1)
		GuiText(sandbox_mode_ui,x,y+16,spelldata.id)
	end
	
	GuiZSetForNextWidget(sandbox_mode_ui,0)
	GuiImageButton( sandbox_mode_ui, gui_next_id(), x, y, "", spelldata.sprite )
end


function should_perk_be_shown(perk)
	if (not perk.not_in_default_perk_pool) and (not menudata.perkoptions.show_hm) then return false end
	if (perk.not_in_default_perk_pool) and (not menudata.perkoptions.show_nothm) then return false end
	
	if (not perk.one_off_effect) and (not menudata.perkoptions.show_notoneoff) then return false end
	if (perk.one_off_effect) and (not menudata.perkoptions.show_oneoff) then return false end
	return true
end

function display_perk(perk,x,y)
	if GuiImageButton(sandbox_mode_ui,gui_next_id(),x,y,"",perk.perk_icon) then
		if player then
			local pos_x, pos_y = EntityGetTransform( player )
			perk_spawn( pos_x, pos_y, perk.id ,true)	
		end
	end
	
	_,_,hovered=GuiGetPreviousWidgetInfo(sandbox_mode_ui)
	if hovered then
		GuiZSetForNextWidget(sandbox_mode_ui,-1)
		GuiText(sandbox_mode_ui,x,y-10,GameTextGetTranslatedOrNot(perk.ui_name) )
		GuiZSetForNextWidget(sandbox_mode_ui,-1)
		GuiColorSetForNextWidget(sandbox_mode_ui,.5,.5,.5,1)
		GuiText(sandbox_mode_ui,x,y+16,perk.id)
	end
end


if not sandbox_mode_ui then
	sandbox_mode_ui=GuiCreate()
	sandbox_ui_open=false
	menudata={active_menu=nil,
		spelloptions={showproj=true,showstatic=true,showmod=true,showutil=true,showmaterial=true,showmulti=true,showpassive=true,showother=true,hidenotunlocked=false,hideunobtainable=false,page=0},
		
		teleportoptions={storedx=0,storedy=0,prevx=0,prevy=0,savedlocations={},selectedcat=nil,relativetopw=false},
		
		perkoptions={show_hm=true,show_nothm=true,show_oneoff=true,show_notoneoff=true},
		
		potionoptions={show_liquid=true,show_gas=true,show_sand=true,show_solids=true,show_static=false,show_fx=false,targetmatcount=1000,spawnitem="potion",page=0},
		
		wandoptions={shuffle=false,capacity=3,mana=100,recharge=50,reload=30,fire=15,cast=1,spread=0},
		
		entityoptions={category=nil,page=0},
	}
	svd=GlobalsGetValue("sandboxmode_saved_tp_locations")
	--print(svd)
	local tt=menudata.teleportoptions.savedlocations
	for e in svd:gmatch("[^\x1F]+") do
		--print(e)
		tt[#tt+1]=deserialtable(e)
	end
	
	
end

local width,height=GuiGetScreenDimensions(sandbox_mode_ui)
local gui_id=1 --if it starts at 0 then it creates this weird bug where closing the sandbox menu shoots your wand.
function gui_next_id() gui_id=gui_id+1 return gui_id end

GuiOptionsAdd(sandbox_mode_ui,GUI_OPTION.Align_HorizontalCenter)


if GuiButton(sandbox_mode_ui,gui_next_id(),width/2,5,"SANDBOX") then
	sandbox_ui_open=not sandbox_ui_open
end

if sandbox_ui_open then
	
	local menus={"spells","wands","perks","entities","potions","teleport","misc"}
	for i=1,#menus do
		local m=menus[i]
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2-50*((#menus+1)/2-i),40,menudata.active_menu==m and "["..m.."]" or m) then menudata.active_menu=m end
	end
	
	if menudata.active_menu=="spells" then
		local lc,rc=false,false
		--spell type filtering. yep, it's a mess, i know.
		lc,rc=GuiButton(sandbox_mode_ui,gui_next_id(),width/2-280,55,"Projectile [".. (menudata.spelloptions.showproj and "X]" or " ]"))
		if lc then menudata.spelloptions.showproj=not menudata.spelloptions.showproj menudata.spelloptions.page=0 elseif rc then for i in pairs(menudata.spelloptions) do if i:find("show")==1 then menudata.spelloptions[i]=false end end menudata.spelloptions.showproj=true menudata.spelloptions.page=0 end
		
		lc,rc=GuiButton(sandbox_mode_ui,gui_next_id(),width/2-280,65,"Static Proj [".. (menudata.spelloptions.showstatic and "X]" or " ]"))
		if lc then menudata.spelloptions.showstatic=not menudata.spelloptions.showstatic menudata.spelloptions.page=0
		elseif rc then for i in pairs(menudata.spelloptions) do if i:find("show")==1 then menudata.spelloptions[i]=false end end menudata.spelloptions.showstatic=true menudata.spelloptions.page=0 end
		
		lc,rc=GuiButton(sandbox_mode_ui,gui_next_id(),width/2-210,55,"Modifier [".. (menudata.spelloptions.showmod and "X]" or " ]")) 
		if lc then menudata.spelloptions.showmod=not menudata.spelloptions.showmod menudata.spelloptions.page=0 elseif rc then for i in pairs(menudata.spelloptions) do if i:find("show")==1 then menudata.spelloptions[i]=false end end menudata.spelloptions.showmod=true menudata.spelloptions.page=0 end
		
		lc,rc=GuiButton(sandbox_mode_ui,gui_next_id(),width/2-210,65,"Passive [".. (menudata.spelloptions.showpassive and "X]" or " ]"))
		if lc then menudata.spelloptions.showpassive=not menudata.spelloptions.showpassive menudata.spelloptions.page=0 elseif rc then for i in pairs(menudata.spelloptions) do if i:find("show")==1 then menudata.spelloptions[i]=false end end menudata.spelloptions.showpassive=true menudata.spelloptions.page=0 end
		
		lc,rc=GuiButton(sandbox_mode_ui,gui_next_id(),width/2-140,55,"Utility [".. (menudata.spelloptions.showutil and "X]" or " ]"))
		if lc then menudata.spelloptions.showutil=not menudata.spelloptions.showutil menudata.spelloptions.page=0 elseif rc then for i in pairs(menudata.spelloptions) do if i:find("show")==1 then menudata.spelloptions[i]=false end end menudata.spelloptions.showutil=true menudata.spelloptions.page=0 end
		
		lc,rc=GuiButton(sandbox_mode_ui,gui_next_id(),width/2-140,65,"Other [".. (menudata.spelloptions.showother and "X]" or " ]"))
		if lc then menudata.spelloptions.showother=not menudata.spelloptions.showother menudata.spelloptions.page=0 elseif rc then for i in pairs(menudata.spelloptions) do if i:find("show")==1 then menudata.spelloptions[i]=false end end menudata.spelloptions.showother=true menudata.spelloptions.page=0 end
		
		lc,rc=GuiButton(sandbox_mode_ui,gui_next_id(),width/2-70,55,"Material [".. (menudata.spelloptions.showmaterial and "X]" or " ]"))
		if lc then menudata.spelloptions.showmaterial=not menudata.spelloptions.showmaterial menudata.spelloptions.page=0 elseif rc then for i in pairs(menudata.spelloptions) do if i:find("show")==1 then menudata.spelloptions[i]=false end end menudata.spelloptions.showmaterial=true menudata.spelloptions.page=0 end
		
		lc,rc=GuiButton(sandbox_mode_ui,gui_next_id(),width/2-70,65,"Multicast [".. (menudata.spelloptions.showmulti and "X]" or " ]"))
		if lc then menudata.spelloptions.showmulti=not menudata.spelloptions.showmulti menudata.spelloptions.page=0 elseif rc then for i in pairs(menudata.spelloptions) do if i:find("show")==1 then menudata.spelloptions[i]=false end end menudata.spelloptions.showmulti=true menudata.spelloptions.page=0 end
		--end type filtering
		
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2+100,55,"Hide locked spells [".. (menudata.spelloptions.hidenotunlocked and "X]" or " ]")) then menudata.spelloptions.hidenotunlocked=not menudata.spelloptions.hidenotunlocked menudata.spelloptions.page=0 end
		
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2+200,55,"Hide non-spawning spells [".. (menudata.spelloptions.hideunobtainable and "X]" or " ]")) then menudata.spelloptions.hideunobtainable=not menudata.spelloptions.hideunobtainable menudata.spelloptions.page=0 end
		
		local n=0
		for i=1+menudata.spelloptions.page*180,#actions do
			local spell=actions[i]
			if should_spell_be_shown(spell) then
				if n<180 then
				display_spell(spell,width/2 + 20*((n)%20-10),90+ 30*math.floor((n)/20) )
				end
				n=n+1
			end
			--if n>=180 then break end
		end
		n=n+menudata.spelloptions.page*180
		
		GuiText(sandbox_mode_ui,width/2,65,string.format("page %i/%i",menudata.spelloptions.page+1,math.ceil(n/180) ) )
		GuiText(sandbox_mode_ui,width/2,55,string.format("%i spells",n) )
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2-30,65,"<-") then menudata.spelloptions.page=math.max(menudata.spelloptions.page-1,0) end
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2+30,65,"->") then menudata.spelloptions.page=math.min(menudata.spelloptions.page+1,math.ceil(n/180)-1) end
		
		
	elseif menudata.active_menu=="wands" then
		--wandoptions={shuffle=false,capacity=3,mana=100,recharge=50,reload=30,fire=15,cast=1,spread=0}
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2-245,85,menudata.wandoptions.shuffle and "shuffle [X]" or "shuffle [ ]") then menudata.wandoptions.shuffle=not menudata.wandoptions.shuffle end
		
		GuiText(sandbox_mode_ui,width/2-175,85,"spells/cast "..menudata.wandoptions.cast)
		menudata.wandoptions.cast=vertial_incrementation_overlays(width/2-175,85,menudata.wandoptions.cast,1,2,5,1)
		
		GuiText(sandbox_mode_ui,width/2-105,85, string.format("cast delay %.2f",menudata.wandoptions.fire/60) )
		menudata.wandoptions.fire=vertial_incrementation_overlays(width/2-105,85,menudata.wandoptions.fire,1,5,15)
		
		GuiText(sandbox_mode_ui,width/2-35,85, string.format("recharge %.2f",menudata.wandoptions.reload/60))
		menudata.wandoptions.reload=vertial_incrementation_overlays(width/2-35,85,menudata.wandoptions.reload,1,5,15)
		
		GuiText(sandbox_mode_ui,width/2+35,85,"max mana "..menudata.wandoptions.mana)
		menudata.wandoptions.mana=vertial_incrementation_overlays(width/2+35,85,menudata.wandoptions.mana,1,10,100,1)
		
		GuiText(sandbox_mode_ui,width/2+105,85,"mana charge "..menudata.wandoptions.recharge)
		menudata.wandoptions.recharge=vertial_incrementation_overlays(width/2+105,85,menudata.wandoptions.recharge,1,5,25,0)
		
		GuiText(sandbox_mode_ui,width/2+175,85,"capacity "..menudata.wandoptions.capacity)
		menudata.wandoptions.capacity=vertial_incrementation_overlays(width/2+175,85,menudata.wandoptions.capacity,1,2,5,1)
		
		GuiText(sandbox_mode_ui,width/2+245,85,"spread "..menudata.wandoptions.spread)
		menudata.wandoptions.spread=vertial_incrementation_overlays(width/2+245,85,menudata.wandoptions.spread,.1,1,5)
		
		
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2-150,135, "[clear held wand alwayscasts]") then 
			local wandent=get_held_wand(player)
			if wandent then
				local spells=EntityGetAllChildren(wandent,"card_action")
				for i=1,#spells do
					local s=spells[i]
					local item_component=EntityGetFirstComponentIncludingDisabled(s,"ItemComponent")
					if ComponentGetValue2( item_component, "permanently_attached") then
						EntityRemoveFromParent(s)
						EntityKill(S)
						
						local ability_comp = EntityGetFirstComponentIncludingDisabled( wandent, "AbilityComponent" )
						if ability_comp then
							ComponentObjectSetValue2( ability_comp, "gun_config", "deck_capacity", ComponentObjectGetValue2( ability_comp, "gun_config", "deck_capacity" )-1 )
						end
					end
				end
			end
		end
		
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2-150,150, "[add nearby spells to held wand alwayscast]") then 
			local wandent=get_held_wand(player)
			if wandent then
				local pos_x,pos_y=EntityGetTransform(player)
				ents=EntityGetInRadiusWithTag(pos_x,pos_y,10,"card_action")
				for i=1,#ents do
					local e=ents[i]
					if EntityGetRootEntity(e)==e then
						local spc=EntityGetFirstComponentIncludingDisabled(e,"ItemActionComponent")
						if spc then
							local spid=ComponentGetValue2(spc,"action_id")
							AddGunActionPermanent(wandent,spid)
							EntityKill(e)
						end
					end
				end
			end
		end
		  
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2+150,135, "[copy held wand stats]") then 
			local wandent=get_held_wand(player)
			if wandent then
				local ability_comp = EntityGetFirstComponentIncludingDisabled( wandent, "AbilityComponent" )
				
				menudata.wandoptions.cast=ComponentObjectGetValue2( ability_comp, "gun_config", "actions_per_round")
				menudata.wandoptions.reload=ComponentObjectGetValue2( ability_comp, "gun_config", "reload_time")
				menudata.wandoptions.capacity=ComponentObjectGetValue2( ability_comp, "gun_config", "deck_capacity")
				menudata.wandoptions.shuffle=ComponentObjectGetValue2( ability_comp, "gun_config", "shuffle_deck_when_empty")==1
				menudata.wandoptions.fire=ComponentObjectGetValue2( ability_comp, "gunaction_config", "fire_rate_wait")
				menudata.wandoptions.spread=ComponentObjectGetValue2( ability_comp, "gunaction_config", "spread_degrees")
				menudata.wandoptions.recharge=ComponentGetValue2( ability_comp, "mana_charge_speed")
				menudata.wandoptions.mana=ComponentGetValue2( ability_comp, "mana_max")
			end
		end
		
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2+150,150, "[spawn new wand]") and player then 
			local x, y = EntityGetTransform(player)
			local wandent=EntityLoad("mods/sandbox_mode/files/blank_wand.xml",x,y)
			
			local ability_comp = EntityGetFirstComponent( wandent, "AbilityComponent" )
			ComponentObjectSetValue2( ability_comp, "gun_config", "actions_per_round", menudata.wandoptions.cast )
			ComponentObjectSetValue2( ability_comp, "gun_config", "reload_time", menudata.wandoptions.reload )
			ComponentObjectSetValue2( ability_comp, "gun_config", "deck_capacity", menudata.wandoptions.capacity )
			ComponentObjectSetValue2( ability_comp, "gun_config", "shuffle_deck_when_empty", menudata.wandoptions.shuffle)
			ComponentObjectSetValue2( ability_comp, "gunaction_config", "fire_rate_wait", menudata.wandoptions.fire )
			ComponentObjectSetValue2( ability_comp, "gunaction_config", "spread_degrees", menudata.wandoptions.spread )
			ComponentObjectSetValue2( ability_comp, "gunaction_config", "speed_multiplier", 1.0 )
			ComponentSetValue2( ability_comp, "mana_charge_speed", menudata.wandoptions.recharge)
			ComponentSetValue2( ability_comp, "mana_max", menudata.wandoptions.mana)
			ComponentSetValue2( ability_comp, "mana", menudata.wandoptions.mana)
			ComponentSetValue2( ability_comp, "gun_level", 1 )

			ComponentSetValue2( ability_comp, "item_recoil_recovery_speed", 15.0 )
			
			local w=wands[math.random(1,#wands)]
			SetWandSprite( wandent, ability_comp, w.file, w.grip_x, w.grip_y, (w.tip_x - w.grip_x), (w.tip_y - w.grip_y) )
		end
		
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2+150,165, "[apply to held wand]") then 
			local wandent=get_held_wand(player)
			if wandent then
				local ability_comp = EntityGetFirstComponentIncludingDisabled( wandent, "AbilityComponent" )
				ComponentObjectSetValue2( ability_comp, "gun_config", "actions_per_round", menudata.wandoptions.cast )
				ComponentObjectSetValue2( ability_comp, "gun_config", "reload_time", menudata.wandoptions.reload )
				ComponentObjectSetValue2( ability_comp, "gun_config", "deck_capacity", menudata.wandoptions.capacity )
				ComponentObjectSetValue2( ability_comp, "gun_config", "shuffle_deck_when_empty", menudata.wandoptions.shuffle )
				ComponentObjectSetValue2( ability_comp, "gunaction_config", "fire_rate_wait", menudata.wandoptions.fire )
				ComponentObjectSetValue2( ability_comp, "gunaction_config", "spread_degrees", menudata.wandoptions.spread )
				ComponentSetValue2( ability_comp, "mana_charge_speed", menudata.wandoptions.recharge)
				ComponentSetValue2( ability_comp, "mana_max", menudata.wandoptions.mana)
				ComponentSetValue2( ability_comp, "mana", menudata.wandoptions.mana)
			end
		end
		
	elseif menudata.active_menu=="perks" then
		
		
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2+90,55,"Show HM perks [".. (menudata.perkoptions.show_hm and "X]" or " ]")) then menudata.perkoptions.show_hm=not menudata.perkoptions.show_hm end
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2+90,65,"Show non-HM perks [".. (menudata.perkoptions.show_nothm and "X]" or " ]")) then menudata.perkoptions.show_nothm=not menudata.perkoptions.show_nothm end
		
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2+220,55,"Show One-off perks [".. (menudata.perkoptions.show_oneoff and "X]" or " ]")) then menudata.perkoptions.show_oneoff=not menudata.perkoptions.show_oneoff end
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2+220,65,"Show non-One-off perks [".. (menudata.perkoptions.show_notoneoff and "X]" or " ]")) then menudata.perkoptions.show_notoneoff=not menudata.perkoptions.show_notoneoff end
		
		local pc=0
		for i=1,#perk_list do --should add pages, but i'm lazy and don't feel like it. should be big enough.
			local perk=perk_list[i]
			if should_perk_be_shown(perk) then
				display_perk(perk,width/2+ 20*(pc%20-10),90+32*math.floor(pc/20))
				pc=pc+1
			end
		end
		
		GuiText(sandbox_mode_ui,width/2,55,string.format("%i perks",pc) )
		
		
	elseif menudata.active_menu=="potions" then
		--potionoptions={show_liquid=true,show_gas=true,show_sand=true,show_solids=true,show_static=false,show_fx=false,targetmatcount=1000,spawnitem="potion",page=0}
		--option selection
		lc=GuiButton(sandbox_mode_ui,gui_next_id(),width/2-150,55,"Liquids [".. (menudata.potionoptions.show_liquid and "X]" or " ]"))
		if lc then menudata.potionoptions.show_liquid=not menudata.potionoptions.show_liquid menudata.potionoptions.page=0 end
		
		lc=GuiButton(sandbox_mode_ui,gui_next_id(),width/2-150,65,"Sands [".. (menudata.potionoptions.show_sand and "X]" or " ]"))
		if lc then menudata.potionoptions.show_sand=not menudata.potionoptions.show_sand menudata.potionoptions.page=0 end
		
		lc=GuiButton(sandbox_mode_ui,gui_next_id(),width/2-75,55,"Gasses [".. (menudata.potionoptions.show_gas and "X]" or " ]"))
		if lc then menudata.potionoptions.show_gas=not menudata.potionoptions.show_gas menudata.potionoptions.page=0 end
		
		lc=GuiButton(sandbox_mode_ui,gui_next_id(),width/2-75,65,"Solids [".. (menudata.potionoptions.show_solids and "X]" or " ]"))
		if lc then menudata.potionoptions.show_solids=not menudata.potionoptions.show_solids menudata.potionoptions.page=0 end
		
		lc=GuiButton(sandbox_mode_ui,gui_next_id(),width/2-250,65,"Show static (advanced) [".. (menudata.potionoptions.show_static and "X]" or " ]"))
		if lc then menudata.potionoptions.show_static=not menudata.potionoptions.show_static menudata.potionoptions.page=0 end
		
		lc=GuiButton(sandbox_mode_ui,gui_next_id(),width/2-250,55,"Show FX (advanced) [".. (menudata.potionoptions.show_fx and "X]" or " ]"))
		if lc then menudata.potionoptions.show_fx=not menudata.potionoptions.show_fx menudata.potionoptions.page=0 end
		--end options
		
		--spawning selectors
		local itemtypes={
			{"potion","data/entities/items/pickup/potion_empty.xml"},
			{"pouch","data/entities/items/pickup/powder_stash.xml"},
		}
		local ITEM_SPAWN_PATH=nil
		for i=1,#itemtypes do
			local item=itemtypes[i]
			if GuiButton(sandbox_mode_ui,gui_next_id(),width/2+10+55*i,65,item[1] == menudata.potionoptions.spawnitem and item[1].."[X]" or item[1].."[ ]" ) then
				menudata.potionoptions.spawnitem=item[1]
			end
			if item[1] == menudata.potionoptions.spawnitem then ITEM_SPAWN_PATH=item[2] end
		end
		
		GuiText(sandbox_mode_ui,width/2+150,55, menudata.potionoptions.targetmatcount.."px")
		local countselectors={1,10,100,1000}
		local ofst=0
		for i=1,#countselectors do
			local c=countselectors[i]
			ofst=ofst+#tostring(c)+2
			if GuiButton(sandbox_mode_ui,gui_next_id(),width/2+160+5*ofst,55, "+"..c ) then
				menudata.potionoptions.targetmatcount=menudata.potionoptions.targetmatcount+c
			end
			if GuiButton(sandbox_mode_ui,gui_next_id(),width/2+140-5*ofst,55, "-"..c ) then
				menudata.potionoptions.targetmatcount=math.max(0,menudata.potionoptions.targetmatcount-c)
			end
			--menudata.potionoptions.targetmatcount
		end
		
		--end spawn selectors
		
		local matids={}
		if menudata.potionoptions.show_liquid or menudata.potionoptions.show_all then
			local t=CellFactory_GetAllLiquids(menudata.potionoptions.show_static,menudata.potionoptions.show_fx)
			for i=1,#t do
				matids[#matids+1]=t[i]
			end
		end
		if menudata.potionoptions.show_sand or menudata.potionoptions.show_all then
			local t=CellFactory_GetAllSands(menudata.potionoptions.show_static,menudata.potionoptions.show_fx)
			for i=1,#t do
				matids[#matids+1]=t[i]
			end
		end
		if menudata.potionoptions.show_gas or menudata.potionoptions.show_all then
			local t=CellFactory_GetAllGases(menudata.potionoptions.show_static,menudata.potionoptions.show_fx)
			for i=1,#t do
				matids[#matids+1]=t[i]
			end
		end
		if menudata.potionoptions.show_solids or menudata.potionoptions.show_all then
			local t=CellFactory_GetAllSolids(menudata.potionoptions.show_static,menudata.potionoptions.show_fx)
			for i=1,#t do
				matids[#matids+1]=t[i]
			end
		end
		if menudata.potionoptions.show_fx then
			local t=CellFactory_GetAllFires(menudata.potionoptions.show_static,menudata.potionoptions.show_fx)
			for i=1,#t do
				matids[#matids+1]=t[i]
			end
		end
		local cols,rows=4,13
		local i=0
		for n=1+menudata.potionoptions.page*cols*rows,#matids do
			local mat=matids[n]
			i=i+1
			local lc=GuiButton(sandbox_mode_ui,gui_next_id(),width/2+ 160*((i-1)%cols -((cols-1)/2)),90+20*math.floor((i-1)/cols),GameTextGetTranslatedOrNot(CellFactory_GetUIName(CellFactory_GetType(mat))))
			GuiColorSetForNextWidget(sandbox_mode_ui,.5,.5,.5,1)
			lc=lc or GuiButton(sandbox_mode_ui,gui_next_id(),width/2+ 160*((i-1)%cols -((cols-1)/2)),97+20*math.floor((i-1)/cols),"["..mat.."]")
			
			if lc and player and ITEM_SPAWN_PATH then --spawn object
				local x, y = EntityGetTransform(player)
				local ent=EntityLoad(ITEM_SPAWN_PATH,x,y)
				--remove materials if they exist
				local comp=EntityGetFirstComponentIncludingDisabled(ent, "MaterialInventoryComponent")
				local cv=ComponentGetValue2(comp,"count_per_material_type")
				for i=1, #cv do
					AddMaterialInventoryMaterial(ent, CellFactory_GetName(i-1) ,0) --remove however much material is in there.
				end
				AddMaterialInventoryMaterial(ent, mat ,menudata.potionoptions.targetmatcount)
			end
			
			if i>=cols*rows then break end
		end
		
		GuiText(sandbox_mode_ui,width/2,65,string.format("page %i/%i",menudata.potionoptions.page+1,math.ceil(#matids/cols/rows) ) )
		GuiText(sandbox_mode_ui,width/2,55,string.format("%i materials",#matids) )
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2-30,65,"<-") then menudata.potionoptions.page=math.max(menudata.potionoptions.page-1,0) end
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2+30,65,"->") then menudata.potionoptions.page=math.min(menudata.potionoptions.page+1,math.ceil(#matids/cols/rows)-1) end
		
		
	elseif menudata.active_menu=="teleport" and player then
		local SIZE_PW = BiomeMapGetSize() * 512
		--pw = if teleporting here is relative to your current PW instead of absolute
		local cats={"bosses","orbs","quests","misc","saved"}
		local hardcodelocations={
			
			misc={
				{name="Spawn",x=227,y=-79,pw=true},
				{name="Nullifying altar",x=14000,y=7552,pw=true,no_ngp=true},
				{name="Race track",x=3390,y=2472,pw=true,no_ngp=true},
				{name="Gold (East)",x=15000,y=-3340,pw=true,no_ngp=true},
				{name="Gold (West)",x=-14000,y=16600,pw=true},
				{name="The Tower (start)",x=9739,y=9197,pw=true,no_ngp=true},
				{name="The Tower (end)",x=9985,y=4373,pw=true,no_ngp=true},
				{name="Gourd cave",x=-16100,y=-6344,},
				{name="Rainbow trail",x=-14000,y=-2843,},
				{name="Portal travel room",x=3828,y=7539,pw=true},
				{name="Experimental wand (machine gun)",x=16088,y=10004,pw=true,no_ngp=true},
			},
			quests={
				{name="Mountain altar",x=782,y=-1150,pw=true},
				{name="The work",x=6397,y=15163,pw=true},
				{name="Hiisi Anvil",x=1532,y=6062,pw=true,no_ngp=true},
				{name="End of everything",x=-4865,y=15000,pw=true},
				{name="Choral chest",x=11517,y=-4862,pw=true},
				{name="Dark chest",x=3838,y=15618,pw=true},
				{name="Music stone",x=-3333,y=3333,pw=true,no_ngp=true},
				{name="Moon",x=255,y=-26100},
				{name="Dark moon",x=255,y=37517},
				{name="Essence of Spirits",x=-14080,y=13583,pw=true,},
				{name="Essence of Air",x=-13056,y=-5359,pw=true,},
				{name="Essence of Fire",x=-14063,y=368,},
				{name="Essence of Earth",x=16127,y=-1793,pw=true,},
				{name="Essence of Water",x=-5377,y=16648,pw=true,},
				{name="Essence eater (west)",x=-6843,y=-244,pw=true,},
				{name="Essence eater (east)",x=12600,y=-35,pw=true,},
				{name="Kantele",x=-1635,y=-778},
				{name="Ocarina",x=-9980,y=-6479,pw=true,},
			},
			orbs={
			
			},
			bosses={
				{name="Kolmisilmä (Three-Eye)",x=3400,y=13040},
				{name="Ylialkemisti (High alchemist)",x=-4705,y=820,pw=true,no_ngp=true},
				{name="Sauvojen tuntija (connoisseur of wands/Bridge boss)",x=4351,y=897,no_ngp=true},
				{name="Kolmisilmän Koipi (Three-Eye's legs/Pyramid boss)",x=9788,y=-874,no_ngp=true},
				{name="Suomuhauki (Dragon)",x=2333,y=7380,pw=true,no_ngp=true},
				{name="Veska, Molari, Mokke, Seula (Gate guardians)",x=2727,y=11575,pw=true,no_ngp=true},
				{name="Mestarien mestari (Master of masters/Wizard)",x=12308,y=15159,pw=true,no_ngp=true},
				{name="Kolmisilmän silmä (Three-Eye's eye/Mecha Kolmi)",x=13856,y=11040,pw=true,no_ngp=true},
				{name="Limatoukka (Slime maggot/Tiny)",x=14682,y=16170},
				{name="Syväolento (Leviathan)",x=-13982,y=9779},
				{name="Unohdettu (The Forgotten)",x=-11288,y=13108,pw=true,no_ngp=true},
				{name="Kolmisilmän sydän (Three-Eye's heart/Meat boss)",x=6672,y=8476,pw=true,no_ngp=true},
				{name="Tapion vasalli (Tapio's vassal/Deer boss)",x=-13767,y=171},
				{name="Kivi (Rock)",x=7387,y=-5046},
			},
			
		}
		
		if newgamepluscount=="0" then
			hardcodelocations.orbs={
				{name="Orb 0 (mountain)",x=781,y=-1073},
				{name="Orb 1 (pyramid)",x=9986,y=-1167},
				{name="Orb 2 (frozen vault)",x=-9985,y=2945},
				{name="Orb 3 (lava lake)",x=3474,y=1906},
				{name="Orb 4 (sandcave)",x=9984,y=2947},
				{name="Orb 5 (magical temple)",x=-4353,y=3960},
				{name="Orb 6 (lukki lair)",x=-3840,y=10115},
				{name="Orb 7 (wand connoisseur)",x=4351,y=897},
				{name="Orb 8 (hell)",x=-256,y=16257},
				{name="Orb 9 (snowy chasm)",x=-8961,y=14721},
				{name="Orb 10 (wizard's den)",x=10495,y=16256},
			}
			
			hardcodelocations.misc[#hardcodelocations.misc+1]={name="Holy mountain 1",x=-573,y=1386,pw=true}
			hardcodelocations.misc[#hardcodelocations.misc+1]={name="Holy mountain 2",x=-573,y=2922,pw=true}
			hardcodelocations.misc[#hardcodelocations.misc+1]={name="Holy mountain 3",x=-573,y=4970,pw=true}
			hardcodelocations.misc[#hardcodelocations.misc+1]={name="Holy mountain 4",x=-573,y=6506,pw=true}
			hardcodelocations.misc[#hardcodelocations.misc+1]={name="Holy mountain 5",x=-573,y=8554,pw=true}
			hardcodelocations.misc[#hardcodelocations.misc+1]={name="Holy mountain 6",x=-573,y=10602,pw=true}
			hardcodelocations.misc[#hardcodelocations.misc+1]={name="Holy mountain 7",x=2019,y=13159,pw=true}
			
		else --todo: make orb detection work with NG+
			hardcodelocations.orbs={
				{name="Orb 0 (mountain)",x=781,y=-1073},
				{name="Orb 1 (pyramid)",x=9986,y=-1167},
			}
			
			
			hardcodelocations.misc[#hardcodelocations.misc+1]={name="Holy mountain 1",x=-573,y=1386,pw=true}
			hardcodelocations.misc[#hardcodelocations.misc+1]={name="Holy mountain 2",x=-573,y=2922,pw=true}
			hardcodelocations.misc[#hardcodelocations.misc+1]={name="Holy mountain 3",x=-573,y=6506,pw=true}
			hardcodelocations.misc[#hardcodelocations.misc+1]={name="Holy mountain 4",x=-573,y=10602,pw=true}
			hardcodelocations.misc[#hardcodelocations.misc+1]={name="Holy mountain 5",x=2019,y=13159,pw=true}
		end
		hardcodelocations.saved=menudata.teleportoptions.savedlocations
		
		
		local pos_x, pos_y = EntityGetTransform( player )
		GuiText(sandbox_mode_ui,width/2,55,string.format("current pos: x=%+i y=%+i (PW %+i)",pos_x,pos_y,check_parallel_pos(pos_x)) )
		
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2-25,65,"-1 PW") then
			EntitySetTransform(player,pos_x-SIZE_PW,pos_y)
		end
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2+25,65,"+1 PW") then
			EntitySetTransform(player,pos_x+SIZE_PW,pos_y)
		end
		
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2+150,55,"save position" ) then
			local t=menudata.teleportoptions.savedlocations
			local y,mo,d,h,m,s = GameGetDateAndTimeLocal()
			local mt={"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec",}
			t[#t+1]={x=pos_x,y=pos_y,name=string.format("(%+i(%+i),%+i)@%i-%s-%i, %02i:%02i:%02i",pos_x,check_parallel_pos(pos_x),pos_y,d,mt[mo],y,h,m,s) }
			local savestr=""
			for i=1,#t do
				savestr=savestr..serialtable(t[i]).."\x1F"
			end
			GlobalsSetValue("sandboxmode_saved_tp_locations",savestr)
		end
		
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2+150,65,string.format("go to last (%+i (PW %+i),%+i)",menudata.teleportoptions.prevx,check_parallel_pos(menudata.teleportoptions.prevx),menudata.teleportoptions.prevy) ) then
			EntitySetTransform(player,menudata.teleportoptions.prevx,menudata.teleportoptions.prevy)
			menudata.teleportoptions.prevx=pos_x
			menudata.teleportoptions.prevy=pos_y
		end
		
		
		GuiText(sandbox_mode_ui,width/2-275,90,string.format("x:%+i (PW %+i)",menudata.teleportoptions.storedx,check_parallel_pos(menudata.teleportoptions.storedx) ) )
		menudata.teleportoptions.storedx=vertial_incrementation4_overlays(width/2-275,90,menudata.teleportoptions.storedx,1,10,100,1000)
		
		GuiText(sandbox_mode_ui,width/2-200,90,string.format("y:%+i",menudata.teleportoptions.storedy ) )
		menudata.teleportoptions.storedy=vertial_incrementation4_overlays(width/2-200,90,menudata.teleportoptions.storedy,1,10,100,1000)
		
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2-237,155,"[set to current pos]" ) then
			menudata.teleportoptions.storedx,menudata.teleportoptions.storedy=EntityGetTransform(player)
		end
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2-237,170,"[teleport player to]" ) then
			EntitySetTransform(player,menudata.teleportoptions.storedx,menudata.teleportoptions.storedy)
			menudata.teleportoptions.prevx=pos_x
			menudata.teleportoptions.prevy=pos_y
		end
		
		
		for i=1,#cats do
			local cat=cats[i]
			if GuiButton(sandbox_mode_ui,gui_next_id(),width/2+(i-(#cats/2) )*50,75,cat==menudata.teleportoptions.selectedcat and ("["..cat.."]") or cat) then
				menudata.teleportoptions.selectedcat=cat
			end
		end
		
		if menudata.teleportoptions.selectedcat then
			local n=0
			for i=1,#hardcodelocations[menudata.teleportoptions.selectedcat] do
				local loc=hardcodelocations[menudata.teleportoptions.selectedcat][i]
				if loc.no_ngp and newgamepluscount~="0" then
				else
					n=n+1
					local lc,rc=GuiButton(sandbox_mode_ui,gui_next_id(),width/2,90+n*10,loc.name)
					if lc then
						menudata.teleportoptions.prevx=pos_x
						menudata.teleportoptions.prevy=pos_y
						if loc.pw then
							EntitySetTransform(player,(loc.x)+SIZE_PW*check_parallel_pos(pos_x) ,loc.y)
						else
							EntitySetTransform(player,loc.x,loc.y)
						end
					elseif rc then --right click to remove a custom location
						for i=1,#menudata.teleportoptions.savedlocations do
							if loc.name==menudata.teleportoptions.savedlocations.name then
								table.remove(menudata.teleportoptions.savedlocations,i)
								local savestr=""
								for i=1,#t do
									savestr=savestr..serialtable(t[i]).."\x1F"
								end
								GlobalsSetValue("sandboxmode_saved_tp_locations",savestr)
								break
							end
						end
					end
				end
			end
		end
		
		
	elseif menudata.active_menu=="misc" then
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2,65,"[refresh all spells]") then
			GameRegenItemActionsInPlayer(player)
		end
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2,75,"[restore HP]") then
			local hpc=EntityGetFirstComponentIncludingDisabled(player,"DamageModelComponent")
			ComponentSetValue2(hpc,"hp",ComponentGetValue2(hpc,"max_hp"))
		end
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2,85,"[add 100,000 gold]") then
			local hpc=EntityGetFirstComponentIncludingDisabled(player,"WalletComponent")
			ComponentSetValue2(hpc,"money",100000+ComponentGetValue2(hpc,"money"))
		end
		if GuiButton(sandbox_mode_ui,gui_next_id(),width/2,95,"[set infinite gold]") then
			local hpc=EntityGetFirstComponentIncludingDisabled(player,"WalletComponent")
			ComponentSetValue2(hpc,"mHasReachedInf",true)
			ComponentSetValue2(hpc,"money",0x7FFFFFFFFFFFFFFF)
		end
		
	
	elseif menudata.active_menu=="entities" then
		--entityoptions={category=nil,page=0},
		for i=1,#ENTITY_CATEGORIES do
			local cat=ENTITY_CATEGORIES[i]
			if GuiButton(sandbox_mode_ui,gui_next_id(),width/2+60*(i-.5-#ENTITY_CATEGORIES/2),60, menudata.entityoptions.category==cat and ("["..cat.."]") or cat) then
				menudata.entityoptions.category=cat
				menudata.entityoptions.page=0
			end
		end
		
		
		
		if menudata.entityoptions.category then
			ents=ENTITIES_BY_CATS[menudata.entityoptions.category]
			local cols=1
			local rows=26
			
			local n=0
			for i=1+menudata.entityoptions.page*rows, math.min(#ents,(1+menudata.entityoptions.page)*rows) do
				local ent=ents[i]
				n=n+1
				local lc
				lc=GuiButton(sandbox_mode_ui,gui_next_id(),width/2,85+(n-1)*10, ent[2] ) and player
				--GuiColorSetForNextWidget(sandbox_mode_ui,.5,.5,.5,1)
				--lc=GuiButton(sandbox_mode_ui,gui_next_id(),width/2+tw/4,85+(i-1)*10, "["..ent[1].."]" ) and player
				if lc then
					local x,y=EntityGetTransform(player)
					EntityLoad(ent[1],x,y)
				end
				
				GuiTooltip(sandbox_mode_ui,ent[1],"")
			end
		
			GuiText(sandbox_mode_ui,width/2,70,string.format("page %i/%i",menudata.entityoptions.page+1,math.ceil(#ents/cols/rows) ) )
			if GuiButton(sandbox_mode_ui,gui_next_id(),width/2-30,70,"<-") then menudata.entityoptions.page=math.max(menudata.entityoptions.page-1,0) end
			if GuiButton(sandbox_mode_ui,gui_next_id(),width/2+30,70,"->") then menudata.entityoptions.page=math.min(menudata.entityoptions.page+1,math.ceil(#ents/cols/rows)-1) end
		end

		
	end
	
end

newgamepluscount=SessionNumbersGetValue("NEW_GAME_PLUS_COUNT") or "0"
player=EntityGetWithTag("player_unit")[1] or EntityGetWithTag("polymorphed_player")[1]

GuiStartFrame(sandbox_mode_ui)
