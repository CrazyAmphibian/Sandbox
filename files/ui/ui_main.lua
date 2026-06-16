dofile_once("data/scripts/lib/utilities.lua")
--for spell indexing
dofile_once("data/scripts/gun/gun_enums.lua")
dofile_once("data/scripts/gun/gun_actions.lua")
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
		GuiText(sandbox_mode_ui,x,y+16,spelldata.id)
	end
	
	GuiZSetForNextWidget(sandbox_mode_ui,0)
	GuiImageButton( sandbox_mode_ui, gui_next_id(), x, y, "", spelldata.sprite )
end

if not sandbox_mode_ui then
	sandbox_mode_ui=GuiCreate()
	sandbox_ui_open=false
	menudata={active_menu=nil,
		spelloptions={showproj=true,showstatic=true,showmod=true,showutil=true,showmaterial=true,showmulti=true,showpassive=true,showother=true,hidenotunlocked=false,hideunobtainable=false,page=0},
	}
	ticks=0
end
ticks=ticks+1
local width,height=GuiGetScreenDimensions(sandbox_mode_ui)
local gui_id=0
function gui_next_id() gui_id=gui_id+1 return gui_id end

GuiOptionsAdd(sandbox_mode_ui,GUI_OPTION.Align_HorizontalCenter)

local spinnytable={"|","/","-","\\"}
local c=spinnytable[( math.floor(ticks/15)%#spinnytable)+1]
if GuiButton(sandbox_mode_ui,gui_next_id(),width/2,5,sandbox_ui_open and c.." SANDBOX "..c or "SANDBOX") then
	sandbox_ui_open=not sandbox_ui_open
end

if sandbox_ui_open then
	
	if GuiButton(sandbox_mode_ui,gui_next_id(),width/2-100,40,menudata.active_menu=="spells" and "[spells]" or "spells") then menudata.active_menu="spells" end
	if GuiButton(sandbox_mode_ui,gui_next_id(),width/2-50,40,menudata.active_menu=="entities" and "[entities]" or "entities")  then menudata.active_menu="entities" end
	if GuiButton(sandbox_mode_ui,gui_next_id(),width/2,40,menudata.active_menu=="potions" and "[potions]" or "potions")  then menudata.active_menu="potions" end
	if GuiButton(sandbox_mode_ui,gui_next_id(),width/2+50,40,menudata.active_menu=="teleport" and "[teleport]" or "teleport")  then menudata.active_menu="teleport" end
	if GuiButton(sandbox_mode_ui,gui_next_id(),width/2+100,40,menudata.active_menu=="extra" and "[extra]" or "extra")  then menudata.active_menu="extra" end
	
	
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
		
	elseif menudata.active_menu=="entities" then
		
	elseif menudata.active_menu=="potions" then
		
	elseif menudata.active_menu=="teleport" then
		
	elseif menudata.active_menu=="extra" then
		
	end
	
end

player=EntityGetWithTag("player_unit")[1] or EntityGetWithTag("polymorphed_player")[1]

GuiStartFrame(sandbox_mode_ui)
