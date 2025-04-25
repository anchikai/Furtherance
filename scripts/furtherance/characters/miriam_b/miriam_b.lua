local Mod = Furtherance

local MIRIAM_B = {}

Furtherance.Character.MIRIAM_B = MIRIAM_B

---@param player EntityPlayer
function MIRIAM_B:IsMiriam(player)
	return player:GetPlayerType() == Mod.PlayerType.MIRIAM_B
end

---@param player EntityPlayer
function MIRIAM_B:OnPlayerInit(player)
	if MIRIAM_B:IsMiriam(player) then
		player:AddInnateCollectible(Mod.Item.SPIRITUAL_WOUND.ID)
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT) then
			player:AddInnateCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT)
			player:RemoveCostume(Mod.ItemConfig:GetCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT))
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, MIRIAM_B.OnPlayerInit, PlayerVariant.PLAYER)

Mod.Include("scripts.furtherance.characters.miriam_b.spiritual_wound")
Mod.Include("scripts.furtherance.characters.miriam_b.polarity_shift")
