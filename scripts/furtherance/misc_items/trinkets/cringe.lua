local Mod = Furtherance

local CRINGE = {}

Furtherance.Trinket.CRINGE = CRINGE

CRINGE.ID = Isaac.GetTrinketIdByName("Cringe")

CRINGE.BRUH = Isaac.GetSoundIdByName("Bruh")
CRINGE.FREEZE_DURATION = 60

---@param ent Entity
function CRINGE:CringeDMG(ent)
	local player = ent:ToPlayer()
	if player and player:HasTrinket(CRINGE.ID) then
		Mod.Foreach.NPC(function (npc, index)
			local duration = CRINGE.FREEZE_DURATION
			local extraDuration = duration * (player:GetTrinketMultiplier(CRINGE.ID) - 1)
			npc:AddFreeze(EntityRef(player), duration + extraDuration)
		end, nil, nil, nil, {UseEnemySearchParams = true})
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, CRINGE.CringeDMG, EntityType.ENTITY_PLAYER)

function CRINGE:ReplaceHurtSFX(id, volume, frameDelay, loop, pitch, pan)
	if PlayerManager.AnyoneHasTrinket(CRINGE.ID) then
		return {CRINGE.BRUH, volume, frameDelay, loop, pitch, pan}
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY, CRINGE.ReplaceHurtSFX, SoundEffect.SOUND_ISAAC_HURT_GRUNT)