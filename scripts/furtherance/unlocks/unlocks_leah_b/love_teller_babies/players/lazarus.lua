local Mod = Furtherance

---@param familiar EntityFamiliar
local function onAnemicAdd(_, familiar)
	local player = familiar.Player
	player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_ANEMIC, true)
end

Mod:AddCallback(Mod.ModCallbacks.POST_LOVE_TELLER_BABY_ADD_EFFECT, onAnemicAdd, PlayerType.PLAYER_LAZARUS)
