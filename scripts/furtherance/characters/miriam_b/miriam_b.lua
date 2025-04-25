local Mod = Furtherance

local MIRIAM_B = {}

Furtherance.Character.MIRIAM_B = MIRIAM_B

local INNATE_COLLECTIBLES = {
	CollectibleType.COLLECTIBLE_MONSTROS_LUNG,
	CollectibleType.COLLECTIBLE_TECHNOLOGY,
	CollectibleType.COLLECTIBLE_SOY_MILK
}

---@param player EntityPlayer
function MIRIAM_B:IsMiriam(player)
	return player:GetPlayerType() == Mod.PlayerType.MIRIAM_B
end

---@param player EntityPlayer
function MIRIAM_B:OnPlayerInit(player)
	if MIRIAM_B:IsMiriam(player) then
		player:AddInnateCollectible(Mod.Item.SPIRITUAL_WOUND.ID)
		for _, itemID in ipairs(INNATE_COLLECTIBLES) do
			player:AddInnateCollectible(itemID)
			local itemConfigItem = Mod.ItemConfig:GetCollectible(itemID)
			if not player:HasCollectible(itemID, true, true) then
				player:RemoveCostume(itemConfigItem)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, MIRIAM_B.OnPlayerInit, PlayerVariant.PLAYER)

Mod.Include("scripts.furtherance.characters.miriam_b.spiritual_wound")
Mod.Include("scripts.furtherance.characters.miriam_b.polarity_shift")
