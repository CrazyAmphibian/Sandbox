function add_entity_to_list(path,name,category)
	local tab={path,name,category}
	ENTITY_LIST[#ENTITY_LIST+1]=tab
	
	if category then
		if not ENTITIES_BY_CATS[category] then ENTITIES_BY_CATS[category]={} ENTITY_CATEGORIES[#ENTITY_CATEGORIES+1]=category end
		ENTITIES_BY_CATS[category][#ENTITIES_BY_CATS[category]+1]=tab
	end
end


if not ENTITY_LIST then
	ENTITY_LIST={

	}

	ENTITY_CATEGORIES={}

	ENTITIES_BY_CATS={

	}
end

dofile_once("mods/sandbox_mode/files/ui/vanilla_ents.lua")