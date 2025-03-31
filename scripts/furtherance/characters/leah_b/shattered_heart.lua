local Mod = Furtherance

local SHATTERED_HEART = {}

Furtherance.Item.SHATTERED_HEART = SHATTERED_HEART

SHATTERED_HEART.ID = Isaac.GetItemIdByName("Shattered Heart")

---@param player EntityPlayer
function SHATTERED_HEART:OnUse(_, _, player)
	if player:GetBrokenHearts() > 0 then
		Mod.SFXMan:Play(SoundEffect.SOUND_HEARTBEAT)
		player:AddBrokenHearts(-1)
	end
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, SHATTERED_HEART.OnUse, SHATTERED_HEART.ID)
