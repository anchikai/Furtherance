local Mod = Furtherance

local CADUCEUS_STAFF = {}

Furtherance.Item.CADUCEUS_STAFF = CADUCEUS_STAFF

CADUCEUS_STAFF.ID = Isaac.GetItemIdByName("Caduceus Staff")

CADUCEUS_STAFF.SFX = Isaac.GetSoundIdByName("CaduceusActivate")
CADUCEUS_STAFF.BASE_CHANCE = 0.05
CADUCEUS_STAFF.CHANCE_MULTIPLIER = 2

---@param ent Entity
---@param flags DamageFlag
function CADUCEUS_STAFF:CaduceusDamage(ent, _, flags, _, _)
	local player = ent:ToPlayer()
	if player and player:HasCollectible(CADUCEUS_STAFF.ID) then
		local rng = player:GetCollectibleRNG(CADUCEUS_STAFF.ID)
		local effects = player:GetEffects()
		local multiplier = effects:GetCollectibleEffectNum(CADUCEUS_STAFF.ID) + 1
		if rng:RandomFloat() <= CADUCEUS_STAFF.BASE_CHANCE * multiplier then
			effects:RemoveCollectibleEffect(CADUCEUS_STAFF.ID, -1)
			Mod.SFXMan:Play(CADUCEUS_STAFF.SFX)
			Mod:GetData(player).CaduceusDamageHeal = true
			Mod:DelayOneFrame(function() Mod:GetData(player).CaduceusDamageHeal = false end)
			return {Damage = 0, DamageFlags = flags | DamageFlag.DAMAGE_FAKE}
		else
			effects:AddCollectibleEffect(CADUCEUS_STAFF.ID)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CADUCEUS_STAFF.CaduceusDamage, EntityType.ENTITY_PLAYER)

---@param ent Entity
function CADUCEUS_STAFF:PostCaduceusDamage(ent)
	local player = ent:ToPlayer()
	local data = Mod:TryGetData(ent)
	if player
		and data
		and data.CaduceusDamageHeal
	then
		local healAmount = 2
		local emptyHealth = player:GetEffectiveMaxHearts() - player:GetHearts() - (player:GetRottenHearts() * 2)
		if emptyHealth <= 1 then
			healAmount = healAmount - emptyHealth
			player:AddSoulHearts(healAmount)
		end
		player:AddHearts(healAmount)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, CADUCEUS_STAFF.PostCaduceusDamage, EntityType.ENTITY_PLAYER)