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

Mod:AddCallback(Mod.ModCallbacks.PRE_LOVE_TELLER_BABY_ADD_COLLECTIBLE, onMantleAdd, PlayerType.PLAYER_THELOST)

local function stopRemoveMantle()
	return true
end

Mod:AddCallback(Mod.ModCallbacks.PRE_LOVE_TELLER_BABY_REMOVE_COLLECTIBLE, stopRemoveMantle, PlayerType.PLAYER_THELOST)

---@param player EntityPlayer
---@param itemConfig ItemConfigItem
local function onMantleRemove(_, player, itemConfig)
	if itemConfig:IsCollectible()
		and itemConfig.ID == CollectibleType.COLLECTIBLE_HOLY_MANTLE
	then
		Mod.Foreach.Familiar(function(familiar, index)
			local data = Mod:GetData(familiar)
			if data.LostBabyAddedMantle then
				data.LostBabyAddedMantle = nil
				data.LoveTellerPassiveCountdown = Mod.Slot.LOVE_TELLER_BABY.EFFECT_COOLDOWN
				return true
			end
		end, Mod.Slot.LOVE_TELLER.BABY.FAMILIAR)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_EFFECT_REMOVED, onMantleRemove)
