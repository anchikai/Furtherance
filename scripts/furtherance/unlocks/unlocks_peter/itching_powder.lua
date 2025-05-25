local Mod = Furtherance

local ITCHING_POWDER = {}

Furtherance.Item.ITCHING_POWDER = ITCHING_POWDER

ITCHING_POWDER.ID = Isaac.GetItemIdByName("Itching Powder")

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function ITCHING_POWDER:DelayFakeDamage(ent, amount, flags, source, countdown)
	local player = ent:ToPlayer()
	---@cast player EntityPlayer

	if player:HasCollectible(ITCHING_POWDER.ID) and not Mod:HasBitFlags(flags, DamageFlag.DAMAGE_FAKE) then
		player:GetEffects():AddCollectibleEffect(ITCHING_POWDER.ID, false)
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, ITCHING_POWDER.DelayFakeDamage, EntityType.ENTITY_PLAYER)

---@param player EntityPlayer
function ITCHING_POWDER:DealDelayedDamage(player)
	local effects = player:GetEffects()
	local effect = effects:GetCollectibleEffect(ITCHING_POWDER.ID)
	if effect and effect.Count > 0 and effect.Cooldown % 30 == 0 then
		player:TakeDamage(player:GetCollectibleNum(ITCHING_POWDER.ID), DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(player), 0)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, ITCHING_POWDER.DealDelayedDamage)

---@param player EntityPlayer
---@param itemConfigItem ItemConfigItem
function ITCHING_POWDER:OnEffectRemove(player, itemConfigItem)
	if itemConfigItem:IsCollectible() and itemConfigItem.ID == ITCHING_POWDER.ID then
		player:TakeDamage(player:GetCollectibleNum(ITCHING_POWDER.ID), DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(player), 0)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_EFFECT_REMOVED, ITCHING_POWDER.OnEffectRemove)