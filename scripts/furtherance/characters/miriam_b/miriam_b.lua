local Mod = Furtherance

local MIRIAM_B = {}

Furtherance.Character.MIRIAM_B = MIRIAM_B


---@param player EntityPlayer
function MIRIAM_B:IsMiriamB(player)
	return player:GetPlayerType() == Mod.PlayerType.MIRIAM_B
end

---@param player EntityPlayer
function MIRIAM_B:MiriamBHasBirthright(player)
	return MIRIAM_B:IsMiriamB(player) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
end

---@param player EntityPlayer
function MIRIAM_B:OnPlayerInit(player)
	if MIRIAM_B:IsMiriamB(player) then
		player:AddInnateCollectible(Mod.Item.SPIRITUAL_WOUND.ID)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, MIRIAM_B.OnPlayerInit, PlayerVariant.PLAYER)

Mod.Include("scripts.furtherance.characters.miriam_b.spiritual_wound")
Mod.Include("scripts.furtherance.characters.miriam_b.polarity_shift")
