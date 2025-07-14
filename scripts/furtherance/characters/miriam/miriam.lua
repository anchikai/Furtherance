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
		Mod:GetData(player).IsMiriam = true
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, MIRIAM.OnPlayerInit)

---@param player EntityPlayer
function MIRIAM:RemovePolydipsia(player)
	local data = Mod:GetData(player)
	if data.IsMiriam and not MIRIAM:IsMiriam(player) then
		local spoofList = player:GetSpoofedCollectiblesList()
		local POLYDIPSIA = Mod.Item.POLYDIPSIA.ID

		if spoofList[POLYDIPSIA] and spoofList[POLYDIPSIA].AppendedCount > 0 then
			player:AddInnateCollectible(POLYDIPSIA, -1)
			local itemConfigItem = Mod.ItemConfig:GetCollectible(POLYDIPSIA)
			if not player:HasCollectible(POLYDIPSIA, true, true) then
				player:RemoveCostume(itemConfigItem)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, MIRIAM.RemovePolydipsia)

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
