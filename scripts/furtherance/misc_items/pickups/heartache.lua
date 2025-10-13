local Mod = Furtherance

local HEARTACHE = {}

Furtherance.Pill.HEARTACHE = HEARTACHE

HEARTACHE.ID_UP = Isaac.GetPillEffectByName("Heartache Up")
HEARTACHE.ID_DOWN = Isaac.GetPillEffectByName("Heartache Down")

function HEARTACHE:HeartacheUp(pillEffect, player, flags)
	player:AnimateSad()
	player:AddBrokenHearts(1)
end

Mod:AddCallback(ModCallbacks.MC_USE_PILL, HEARTACHE.HeartacheUp, HEARTACHE.ID_UP)

function HEARTACHE:HeartacheDown(pillEffect, player, flags)
	player:AnimateHappy()
	player:AddBrokenHearts(-1)
end

Mod:AddCallback(ModCallbacks.MC_USE_PILL, HEARTACHE.HeartacheDown, HEARTACHE.ID_DOWN)

---Callback doesn't return the player (which is the dumbest thing because ItemPool:GetPillEffect DOES have an argument for the player)
---
---So this is the best I can do. FF does the same.
---@param pillEffect PillEffect
function HEARTACHE:AssignOpposites(pillEffect)
	local shouldBePositive = PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT)
		or PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_VIRGO)
		or PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_PHD)
		or Mod.Foreach.Player(function (player)
			if player:GetZodiacEffect() == CollectibleType.COLLECTIBLE_VIRGO then
				return true
			end
		end)
	local shouldBeNegative = PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_FALSE_PHD)
	if shouldBeNegative and shouldBePositive then
		return
	end
	if shouldBePositive and pillEffect == HEARTACHE.ID_UP then
		return HEARTACHE.ID_DOWN
	elseif shouldBeNegative and pillEffect == HEARTACHE.ID_DOWN then
		return HEARTACHE.ID_UP
	end
end

Mod:AddCallback(ModCallbacks.MC_GET_PILL_EFFECT, HEARTACHE.AssignOpposites, HEARTACHE.ID_DOWN)
Mod:AddCallback(ModCallbacks.MC_GET_PILL_EFFECT, HEARTACHE.AssignOpposites, HEARTACHE.ID_UP)