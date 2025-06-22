local Mod = Furtherance

local KARETH = {}

Furtherance.Item.KARETH = KARETH

KARETH.ID = Isaac.GetItemIdByName("Kareth")

---@param pickup EntityPickup
function KARETH:ReplacePedestalWithTrinkets(pickup)
	if not PlayerManager.AnyoneHasCollectible(KARETH.ID)
		or Mod.Game:GetLevel():GetDimension() == Dimension.DEATH_CERTIFICATE
	then
		return
	end
	local itemConfig = Mod.ItemConfig:GetCollectible(pickup.SubType)
	if itemConfig:HasTags(ItemConfig.TAG_QUEST) then
		return
	end
	local numTrinkets = itemConfig.Quality == 3 and 2 or Mod:Clamp(itemConfig.Quality, 1, 3)
	for _ = 1, numTrinkets do
		local trinket = Mod.Spawn.Trinket(NullPickupSubType.ANY, Mod.Room():FindFreePickupSpawnPosition(pickup.Position), nil, pickup.SpawnerEntity)
		if pickup:IsShopItem() then
			trinket:MakeShopItem(-1)
		end
		Mod:DelayOneFrame(function() trinket.OptionsPickupIndex = pickup.OptionsPickupIndex end)
	end
	Mod:DelayOneFrame(function() pickup:Remove() end)
end

Mod:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_INIT, CallbackPriority.LATE, KARETH.ReplacePedestalWithTrinkets, PickupVariant.PICKUP_COLLECTIBLE)

---@param pickup EntityPickup
---@param collider Entity
function KARETH:SmeltOnPickup(pickup, collider)
	local player = collider:ToPlayer()
	if player and player:HasCollectible(KARETH.ID) and Mod:CanPlayerBuyShopItem(player, pickup) then
		player:AddSmeltedTrinket(pickup.SubType, pickup.Touched)
		Mod.HUD:ShowItemText(player, Mod.ItemConfig:GetTrinket(pickup.SubType))
		pickup:GetSprite():Play("PlayerPickupSparkle")
		player:AnimatePickup(pickup:GetSprite())
		Mod:PickupShopKill(player, pickup)
		Mod:PayPickupPrice(player, pickup)
		Mod:KillChoice(pickup)
		Mod:TryStartAmbush()
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, KARETH.SmeltOnPickup, PickupVariant.PICKUP_TRINKET)
