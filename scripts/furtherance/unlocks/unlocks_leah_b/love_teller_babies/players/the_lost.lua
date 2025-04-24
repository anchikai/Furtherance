local Mod = Furtherance

---@param familiar EntityFamiliar
local function onMantleAdd(_, familiar)
	local data = Mod:GetData(familiar)
	if not data.LostBabyAddedMantle then
		data.LostBabyAddedMantle = true
		familiar.Player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, true)
	end
	return true
end

Mod:AddCallback(Mod.ModCallbacks.PRE_LOVE_TELLER_BABY_ADD_EFFECT, onMantleAdd, PlayerType.PLAYER_THELOST)

local function stopRemoveMantle()
	return true
end

Mod:AddCallback(Mod.ModCallbacks.PRE_LOVE_TELLER_BABY_REMOVE_EFFECT, stopRemoveMantle, PlayerType.PLAYER_THELOST)

---@param player EntityPlayer
---@param itemConfig ItemConfigItem
local function onMantleRemove(_, player, itemConfig)
	if itemConfig:IsCollectible()
		and itemConfig.ID == CollectibleType.COLLECTIBLE_HOLY_MANTLE
	then
		for _, familiar in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, Mod.Slot.LOVE_TELLER.BABY.FAMILIAR)) do
			local data = Mod:GetData(familiar)
			if data.LostBabyAddedMantle then
				data.LostBabyAddedMantle = nil
				data.LoveTellerPassiveCountdown = nil
				break
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_EFFECT_REMOVED, onMantleRemove)
