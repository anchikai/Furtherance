local Mod = Furtherance

---@param familiar EntityFamiliar
local function allowCooldown(_, familiar)
	local data = Mod:GetData(familiar)
	data.LoveTellerActiveWait = nil
end

Mod:AddCallback(Mod.ModCallbacks.POST_LOVE_TELLER_BABY_ADD_EFFECT, allowCooldown, Mod.PlayerType.MIRIAM)
