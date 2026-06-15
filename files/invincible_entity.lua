local ONE_HP=0.05
function damage_received( damage, desc, entity_who_caused, is_fatal )
	--print( damage, desc, entity_who_caused, is_fatal )
	if not is_fatal then return end
	local entity_id = GetUpdatedEntityID()
	local dmgmodel=EntityGetComponentIncludingDisabled(entity_id,"DamageModelComponent")[1]
	ComponentSetValue2(dmgmodel,"hp",damage+ONE_HP/10)
end