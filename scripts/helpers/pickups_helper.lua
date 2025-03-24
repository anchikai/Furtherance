--Full credit to Epiphany
local Mod = Furtherance

---Returns the lowest options pickup index not used by any pickups in the room, starting from startIndex
---@param startIndex? integer @default 1
---@return integer
---@function
function Furtherance:GetFreeOptionsPickupIndex(startIndex)
	startIndex = startIndex or 1
	local takenIndexes = {}
	for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
		takenIndexes[ent:ToPickup().OptionsPickupIndex] = true
	end

	while takenIndexes[startIndex] do
		startIndex = startIndex + 1
	end

	return startIndex
end

---Grants the player an item from a pedestal
---@param pickup EntityPickup
---@param player EntityPlayer
---@function
function Furtherance:AwardPedestalItem(pickup, player)
	local itemId = pickup.SubType
	if itemId ~= CollectibleType.COLLECTIBLE_NULL then
		local configitem = Mod.ItemConfig:GetCollectible(itemId)
		player:AnimateCollectible(itemId)
		player:QueueItem(configitem, pickup.Charge, pickup.Touched)
		player.QueuedItem.Item = configitem
		Mod.SFXMan:Play(SoundEffect.SOUND_CHOIR_UNLOCK, 0.5)
		pickup.Touched = true
		pickup.SubType = 0
		local sprite = pickup:GetSprite()
		sprite:Play("Empty", true)
		sprite:ReplaceSpritesheet(4, "blank", true)
		sprite:LoadGraphics()
		Mod.HUD:ShowItemText(player, Isaac:GetItemConfig():GetCollectible(itemId))
		Mod:KillChoice(pickup)
	end
end

local questionMarkPedestalSprite = Sprite()
questionMarkPedestalSprite:Load("gfx/005.100_collectible.anm2", true)
questionMarkPedestalSprite:ReplaceSpritesheet(1, "gfx/items/collectibles/questionmark.png")
questionMarkPedestalSprite:LoadGraphics()

-- taken from eid

---@param pedestal EntityPickup
---@return boolean
function Furtherance:IsBlindPedestal(pedestal)
	if REPENTOGON and pedestal:IsBlind() then
		return true
	end
	local pedestalSprite = pedestal:GetSprite()
	questionMarkPedestalSprite:SetFrame(pedestalSprite:GetAnimation(), pedestalSprite:GetFrame())
	for i = -70, 0, 2 do
		local qcolor = questionMarkPedestalSprite:GetTexel(Vector(0, i), Vector.Zero, 1, 1)
		local ecolor = pedestalSprite:GetTexel(Vector(0, i), Vector.Zero, 1, 1)
		if qcolor.Red ~= ecolor.Red or qcolor.Green ~= ecolor.Green or qcolor.Blue ~= ecolor.Blue then
			return false
		end
	end

	return true
end

---@param pickup EntityPickup
function Furtherance:IsDevilDealItem(pickup)
	return pickup.Price < 0 and pickup.Price ~= PickupPrice.PRICE_FREE and pickup.Price ~= PickupPrice.PRICE_SPIKES
end

--- Finds the closest pedestal
---@param Position Vector
---@param OnlyFree? boolean
---@return EntityPickup|nil
function Furtherance:FindClosestPedestal(Position, OnlyFree)
	local lowest_distance = -1
	local closestPedestal = nil

	for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
		local pickup = entity:ToPickup() ---@cast pickup EntityPickup
		local curr_dist = Position:Distance(pickup.Position)

		if (curr_dist < lowest_distance or lowest_distance == -1)
			and pickup.SubType ~= CollectibleType.COLLECTIBLE_NULL
			and (not OnlyFree or pickup.Price == 0)
			and not Mod:IsQuestItem(pickup.SubType)
		then
			closestPedestal = entity:ToPickup()
			lowest_distance = curr_dist
		end
	end
	return closestPedestal
end

---@param rng? RNG
---@return Vector
function Furtherance:PickupVelocity(rng)
	rng = rng or Mod.GENERIC_RNG
	return Vector.FromAngle(rng:RandomFloat() * 360):Resized(rng:RandomFloat() * 5 + 2)
end