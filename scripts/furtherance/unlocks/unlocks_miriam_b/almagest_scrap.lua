
--All credit for pickup price logic goes to Epiphany

--#region Variables

local Mod = Furtherance

local ALMAGEST_SCRAP = {}

Furtherance.Trinket.ALMAGEST_SCRAP = ALMAGEST_SCRAP

ALMAGEST_SCRAP.ID = Isaac.GetTrinketIdByName("Almagest Scrap")

ALMAGEST_SCRAP.PickupPrice = {
	ONE_BROKEN_HEART = -32,
	TWO_BROKEN_HEARTS = -33
}

--#endregion

--#region helpers

function ALMAGEST_SCRAP:IsAlmagestPrice(pickup)
	return pickup.Price == ALMAGEST_SCRAP.PickupPrice.ONE_BROKEN_HEART
	or pickup.Price == ALMAGEST_SCRAP.PickupPrice.TWO_BROKEN_HEARTS
end

function ALMAGEST_SCRAP:ShouldUpdateTreasureRoom()
	return PlayerManager.AnyoneHasTrinket(ALMAGEST_SCRAP.ID) and not PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_DEVILS_CROWN)
end

local function updateTreasureDoors(filename)
	Mod.Foreach.Door(function (door, doorSlot)
		if door.TargetRoomType == RoomType.ROOM_TREASURE then
			local roomDesc = Mod.Level():GetRoomByIdx(door.TargetRoomIndex)
			--First visit and actually a treasure room
			if roomDesc.VisitedCount == 0
				and roomDesc.Data.Type == RoomType.ROOM_TREASURE
			then
				local sprite = door:GetSprite()
				local anim = sprite:GetAnimation()
				sprite:Load(filename, true)
				sprite:Play(anim)
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, door.Position, Vector.Zero, nil)
			end
		end
	end)
end

--#endregion

--#region Creating Planetarium

function ALMAGEST_SCRAP:UpdateDoors()
	if ALMAGEST_SCRAP:ShouldUpdateTreasureRoom() then
		updateTreasureDoors("gfx/grid/door_00x_planetariumdoor.anm2")
	else
		updateTreasureDoors("gfx/grid/door_02_treasureroomdoor.anm2")
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, ALMAGEST_SCRAP.UpdateDoors, ALMAGEST_SCRAP.ID)
Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_REMOVED, ALMAGEST_SCRAP.UpdateDoors, ALMAGEST_SCRAP.ID)
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	if ALMAGEST_SCRAP:ShouldUpdateTreasureRoom() then
		ALMAGEST_SCRAP:UpdateDoors()
	end
end)

function ALMAGEST_SCRAP:PreEnterPlanetarium(newIndex)
	if Mod.Game:GetFrameCount() == 0 then return end
	local level = Mod.Level()
	local roomDesc = level:GetRoomByIdx(newIndex)
	if ALMAGEST_SCRAP:ShouldUpdateTreasureRoom()
		and roomDesc.VisitedCount == 0
		and roomDesc.Data.Type == RoomType.ROOM_TREASURE
	then
		local rng = PlayerManager.FirstTrinketOwner(ALMAGEST_SCRAP.ID):GetCollectibleRNG(ALMAGEST_SCRAP.ID)
		local shape = roomDesc.Data.Shape
		local planetarium = RoomConfigHolder.GetRandomRoom(rng:GetSeed(), true, StbType.SPECIAL_ROOMS,
			RoomType.ROOM_PLANETARIUM, shape, -1, -1, 0, 10, 1, 0)
		roomDesc.Data = planetarium
		Mod:RoomSave(nil, false, roomDesc.ListIndex).AlmagestPlanetarium = true
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_CHANGE_ROOM, CallbackPriority.LATE, ALMAGEST_SCRAP.PreEnterPlanetarium)

--#endregion

--#region Handle custom prices

---@param pickup EntityPickup
function ALMAGEST_SCRAP:OnPriceInit(pickup)
	pickup.ShopItemId = -3
	pickup.AutoUpdatePrice = false
end

---@param pickup EntityPickup
function ALMAGEST_SCRAP.TurnToAlmagestShopItem(pickup)
	local pickup_save = Mod:PickupSave(pickup)
	local quality = Mod.ItemConfig:GetCollectible(pickup.SubType).Quality
	local price = ALMAGEST_SCRAP.PickupPrice.ONE_BROKEN_HEART
	local mult = PlayerManager.GetTotalTrinketMultiplier(ALMAGEST_SCRAP.ID)
	if quality >= 3 and mult == 1 then
		price = ALMAGEST_SCRAP.PickupPrice.TWO_BROKEN_HEARTS
	end
	pickup_save.Price = price
	if PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_YOUR_SOUL)
		and pickup_save.Price < 0 and pickup_save.Price ~= PickupPrice.PRICE_FREE and pickup_save.Price ~= PickupPrice.PRICE_SPIKES
	then
		pickup.Price = PickupPrice.PRICE_SOUL
	else
		pickup.Price = price
	end
	ALMAGEST_SCRAP:OnPriceInit(pickup)
end

function ALMAGEST_SCRAP:UpdateFirstVisitPlanetarium()
	if ALMAGEST_SCRAP:ShouldUpdateTreasureRoom() then
		updateTreasureDoors("gfx/grid/door_00x_planetariumdoor.anm2")
	end
	local shouldMakeShopItem = PlayerManager.GetTotalTrinketMultiplier(ALMAGEST_SCRAP.ID) >= 3
	if not shouldMakeShopItem and Mod:RoomSave().AlmagestPlanetarium and Mod.Room():IsFirstVisit() then
		Mod.Foreach.Pickup(ALMAGEST_SCRAP.TurnToAlmagestShopItem, PickupVariant.PICKUP_COLLECTIBLE)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, ALMAGEST_SCRAP.UpdateFirstVisitPlanetarium)

---@param pickup EntityPickup
function ALMAGEST_SCRAP:OnPickupUpdate(pickup)
	local pickup_save = Mod:PickupSave(pickup, true)
	if pickup_save.Price then
		if pickup.Touched == false then
			--Purchased Flip pedestals are considered not touched
			if pickup.SubType == 0 and pickup.Price == 0 then
				pickup.Touched = true
				return
			end
			if pickup_save.Price ~= pickup.Price then
				pickup.Price = pickup_save.Price
				ALMAGEST_SCRAP:OnPriceInit(pickup)
			end
			if pickup_save.Price < 0 and pickup_save.Price ~= PickupPrice.PRICE_FREE and pickup_save.Price ~= PickupPrice.PRICE_SPIKES
				and PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_YOUR_SOUL)
			then
				if pickup.Price ~= PickupPrice.PRICE_SOUL then
					pickup.Price = PickupPrice.PRICE_SOUL
					ALMAGEST_SCRAP:OnPriceInit(pickup)
				end
			end
		else
			pickup_save.Price = nil
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, ALMAGEST_SCRAP.OnPickupUpdate, PickupVariant.PICKUP_COLLECTIBLE)

---@function
---@param pickup EntityPickup
---@param ent Entity
function ALMAGEST_SCRAP:OnCollision(pickup, ent)
	local player = ent:ToPlayer()
	if not player or player.Variant ~= 0 then
		return
	end
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		player = player:GetMainTwin()
	end

	if ALMAGEST_SCRAP:IsAlmagestPrice(pickup) then
		if pickup.SubType ~= CollectibleType.COLLECTIBLE_NULL
			and not player:IsHoldingItem()
			and player:CanPickupItem()
			and player:IsExtraAnimationFinished()
			and player.ItemHoldCooldown == 0
			and pickup.Wait == 0
		then
			local brokenHearts = 1
			if pickup.Price == ALMAGEST_SCRAP.PickupPrice.TWO_BROKEN_HEARTS then
				brokenHearts = 2
			end
			player:AddBrokenHearts(brokenHearts)
			Mod:KillChoice(pickup)
		else
			return true
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, ALMAGEST_SCRAP.OnCollision, PickupVariant.PICKUP_COLLECTIBLE)

local PRICE_OFFSET = Vector(0, 10)

---@param pickup EntityPickup
function ALMAGEST_SCRAP:RenderBrokenHeartPrice(pickup, offset)
	if ALMAGEST_SCRAP:IsAlmagestPrice(pickup) then
		local data = Mod:GetData(pickup)
		if not data.AlmagestHeartSprite then
			local sprite = Sprite()
			sprite:Load("gfx/ui/ui_broken_heart_prices.anm2", true)
			if pickup.Price == ALMAGEST_SCRAP.PickupPrice.ONE_BROKEN_HEART then
				sprite:SetFrame("One", 0)
			else
				sprite:SetFrame("Two", 0)
			end
			data.AlmagestHeartSprite = sprite
		end
		if Mod.Room():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT then
			local renderPos = Isaac.WorldToScreen(pickup.Position + pickup.PositionOffset) + offset
			renderPos = renderPos + PRICE_OFFSET
			data.AlmagestHeartSprite:Render(renderPos)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, ALMAGEST_SCRAP.RenderBrokenHeartPrice, PickupVariant.PICKUP_COLLECTIBLE)

--#endregion
