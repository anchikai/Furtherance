local Mod = Furtherance

---@param familiar EntityFamiliar
local function checkExistingStew(_, familiar)
	local player = familiar.Player
	if player:GetRedStewBonusDuration() > 0 then
		local data = Mod:GetData(familiar)
		data.EsauBabyHadStew = true
	end
end

Mod:AddCallback(Mod.ModCallbacks.PRE_LOVE_TELLER_BABY_ADD_COLLECTIBLE, checkExistingStew, PlayerType.PLAYER_ESAU)

---@param familiar EntityFamiliar
local function minimizeRedStew(_, familiar)
	local player = familiar.Player
	local data = Mod:GetData(familiar)
	if data.EsauBabyHadStew then
		player:SetRedStewBonusDuration(math.min(5400,
			player:GetRedStewBonusDuration() + Mod.Slot.LOVE_TELLER.BABY.EFFECT_COOLDOWN))
	else
		player:SetRedStewBonusDuration(Mod.Slot.LOVE_TELLER.BABY.EFFECT_COOLDOWN)
	end
end

Mod:AddCallback(Mod.ModCallbacks.POST_LOVE_TELLER_BABY_ADD_COLLECTIBLE, minimizeRedStew, PlayerType.PLAYER_ESAU)

---@param familiar EntityFamiliar
local function removeRedStewEffect(_, familiar)
	local player = familiar.Player
	local data = Mod:GetData(familiar)
	if not data.EsauBabyHadStew then
		player:SetRedStewBonusDuration(0)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
	end
	data.EsauBabyHadStew = nil
end

Mod:AddCallback(Mod.ModCallbacks.POST_LOVE_TELLER_BABY_REMOVE_COLLECTIBLE, removeRedStewEffect, PlayerType.PLAYER_ESAU)
