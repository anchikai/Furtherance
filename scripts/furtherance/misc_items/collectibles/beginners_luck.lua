local Mod = Furtherance

local BEGINNERS_LUCK = {}

Furtherance.Item.BEGINNERS_LUCK = BEGINNERS_LUCK

BEGINNERS_LUCK.ID = Isaac.GetItemIdByName("Beginner's Luck")

BEGINNERS_LUCK.LUCK_BONUS = 10

---@param player EntityPlayer
function BEGINNERS_LUCK:BonusOnNewLevel(player)
	if player:HasCollectible(BEGINNERS_LUCK.ID) then
		local effects = player:GetEffects()
		local numItems = player:GetCollectibleNum(BEGINNERS_LUCK.ID)
		local numEffects = effects:GetCollectibleEffectNum(BEGINNERS_LUCK.ID)
		local expectedNum = BEGINNERS_LUCK.LUCK_BONUS + (BEGINNERS_LUCK.LUCK_BONUS * 0.5 * (numItems - 1))
		effects:AddCollectibleEffect(BEGINNERS_LUCK.ID, false, expectedNum - numEffects)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, BEGINNERS_LUCK.BonusOnNewLevel)

function BEGINNERS_LUCK:PostNewExploredRoom()
	local room = Mod.Room()
	Mod:ForEachPlayer(function(player)
		local effects = player:GetEffects()
		if effects:HasCollectibleEffect(BEGINNERS_LUCK.ID) and room:IsFirstVisit() then
			effects:RemoveCollectibleEffect(BEGINNERS_LUCK.ID)
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BEGINNERS_LUCK.PostNewExploredRoom)

---@param player EntityPlayer
function BEGINNERS_LUCK:GetBeginnersLuck(player, flag)
	local effects = player:GetEffects()
	if effects:HasCollectibleEffect(BEGINNERS_LUCK.ID) then
		local effectNum = effects:GetCollectibleEffectNum(BEGINNERS_LUCK.ID)
		player.Luck = player.Luck + effectNum
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, BEGINNERS_LUCK.GetBeginnersLuck, CacheFlag.CACHE_LUCK)
