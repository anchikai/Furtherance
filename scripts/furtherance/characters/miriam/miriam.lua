local Mod = Furtherance

local MIRIAM = {}

Furtherance.Character.MIRIAM = MIRIAM

---@param player EntityPlayer
function MIRIAM:IsMiriam(player)
	return player:GetPlayerType() == Mod.PlayerType.MIRIAM
end

---@param player EntityPlayer
function MIRIAM:MiriamHasBirthright(player)
	return MIRIAM:IsMiriam(player) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
end

---@param player EntityPlayer
function MIRIAM:OnPlayerInit(player)
	if MIRIAM:IsMiriam(player) then
		player:AddInnateCollectible(Mod.Item.POLYDIPSIA.ID)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, MIRIAM.OnPlayerInit, PlayerVariant.PLAYER)

---@param player EntityPlayer
---@param itemConfig ItemConfigItem
function MIRIAM:IgnorePolydipsiaCostume(itemConfig, player)
	if itemConfig.ID == Mod.Item.POLYDIPSIA.ID
		and itemConfig:IsCollectible()
		and MIRIAM:IsMiriam(player)
	then
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_COSTUME, MIRIAM.IgnorePolydipsiaCostume)

Mod.Include("scripts.furtherance.characters.miriam.whirlpool")
Mod.Include("scripts.furtherance.characters.miriam.tambourine")
