local Mod = Furtherance
local bruh = Isaac.GetSoundIdByName("Bruh")

function Mod:CringeDMG(entity)
	local player = entity:ToPlayer()
	if player and player:HasTrinket(TrinketType.TRINKET_CRINGE, false) then
		SFXManager():Play(bruh)
		for _, ent in ipairs(Isaac.GetRoomEntities()) do
			if ent:IsActiveEnemy(false) then
				ent:AddFreeze(EntityRef(player), 30)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Mod.CringeDMG, EntityType.ENTITY_PLAYER)

function Mod:HurtSound()
	if SFXManager():IsPlaying(bruh) == true then
		SFXManager():Stop(SoundEffect.SOUND_ISAAC_HURT_GRUNT)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, Mod.HurtSound)
