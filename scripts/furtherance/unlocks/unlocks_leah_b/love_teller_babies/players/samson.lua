local Mod = Furtherance

---@param familiar EntityFamiliar
local function onBloodyLustAdd(_, familiar)
	local player = familiar.Player
	player:SetBloodLustCounter(player:GetBloodLustCounter() + 3)
end

Mod:AddCallback(Mod.ModCallbacks.POST_LOVE_TELLER_BABY_ADD_EFFECT, onBloodyLustAdd, PlayerType.PLAYER_SAMSON)

---@param familiar EntityFamiliar
local function onBloodyLustRemove(_, familiar)
	local player = familiar.Player
	player:SetBloodLustCounter(player:GetBloodLustCounter() - 3)
	player:AddCacheFlags(CacheFlag.CACHE_COLOR, true)
end

Mod:AddCallback(Mod.ModCallbacks.POST_LOVE_TELLER_BABY_REMOVE_EFFECT, onBloodyLustRemove, PlayerType.PLAYER_SAMSON)
