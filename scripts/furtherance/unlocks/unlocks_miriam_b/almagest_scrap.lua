local Mod = Furtherance

local ALMAGEST_SCRAP = {}

Furtherance.Trinket.ALMAGEST_SCRAP = ALMAGEST_SCRAP

ALMAGEST_SCRAP.ID = Isaac.GetTrinketIdByName("Almagest Scrap")

local function updateTreasureDoors(filename)
	local room = Mod.Room()
	for i = DoorSlot.NO_DOOR_SLOT + 1, DoorSlot.NUM_DOOR_SLOTS - 1 do
		local door = room:GetDoor(i)
		if door and door.TargetRoomType == RoomType.ROOM_TREASURE then
			local roomDesc = Mod.Level():GetRoomByIdx(door.TargetRoomIndex)
			--First visit and actually a treasure room
			if roomDesc.VisitedCount == 0
				and roomDesc.Data.Type == RoomType.ROOM_TREASURE
			then
				local sprite = door:GetSprite()
				local anim = sprite:GetAnimation()
				sprite:Load(filename, true)
				sprite:Play(anim)
			end
		end
	end
end

function ALMAGEST_SCRAP:UpdateDoors()
	if PlayerManager.AnyoneHasTrinket(ALMAGEST_SCRAP.ID) then
		updateTreasureDoors("gfx/grid/door_00x_planetariumdoor.anm2")
	else
		updateTreasureDoors("gfx/grid/door_02_treasureroomdoor.anm2")
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, ALMAGEST_SCRAP.UpdateDoors, ALMAGEST_SCRAP.ID)
Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_REMOVED, ALMAGEST_SCRAP.UpdateDoors, ALMAGEST_SCRAP.ID)
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, ALMAGEST_SCRAP.UpdateDoors)

local updatedRoom = false

---@param room Room
---@param roomDesc RoomDescriptor
function ALMAGEST_SCRAP:PreEnterPlanetarium(room, roomDesc)
	if PlayerManager.AnyoneHasTrinket(ALMAGEST_SCRAP.ID)
		and room:IsFirstVisit()
		and room:GetType() == RoomType.ROOM_TREASURE
	then
		local rng = PlayerManager.FirstTrinketOwner(ALMAGEST_SCRAP.ID):GetCollectibleRNG(ALMAGEST_SCRAP.ID)
		local shape = roomDesc.Data.Shape
		local allowedDoors = roomDesc.AllowedDoors
		local numDoors = 0
		for doorSlot = DoorSlot.NO_DOOR_SLOT + 1, DoorSlot.NUM_DOOR_SLOTS - 1 do
			if Mod:HasBitFlags(allowedDoors, doorSlot) then
				numDoors = numDoors + 1
			end
		end
		local planetarium = RoomConfigHolder.GetRandomRoom(rng:GetSeed(), true, StbType.SPECIAL_ROOMS, RoomType.ROOM_PLANETARIUM, shape,
			-1, -1, 0, 10, numDoors, -1, Mod:GetRoomMode())
		roomDesc.Data = planetarium
		updatedRoom = true
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, ALMAGEST_SCRAP.PreEnterPlanetarium)

function ALMAGEST_SCRAP:UpdateFirstVisitPlanetarium()
	if updatedRoom then
		updatedRoom = false
		updateTreasureDoors("gfx/grid/door_00x_planetariumdoor.anm2")
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, ALMAGEST_SCRAP.UpdateFirstVisitPlanetarium)

--[[

function Mod:ConvertToPlanetarium()
    if not isTreasureRoom() then return end

    local room = game:GetRoom()
    local level = game:GetLevel()
    local roomIndex = level:GetCurrentRoomIndex()

    if not convertedRooms[roomIndex] and not (room:IsFirstVisit() and someoneHasAlmagest()) then return end
    convertedRooms[roomIndex] = true

    game:ShowHallucination(0, BackdropType.PLANETARIUM)
    SFXManager():Stop(SoundEffect.SOUND_DEATH_CARD)

    local entities = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, -1, false, false)

    local itemConfig = Isaac.GetItemConfig()
    for _, entity in ipairs(entities) do
        local collectible = entity:ToPickup()
        local data = Mod:GetData(collectible)
        local configItem = itemConfig:GetCollectible(collectible.SubType)
        collectible.Price = -10
        collectible.AutoUpdatePrice = false
        if configItem.Quality == 0 or configItem.Quality == 1 then
            data.BrokenHeartsPrice = 1
        elseif configItem.Quality == 2 or configItem.Quality == 3 then
            data.BrokenHeartsPrice = 2
        elseif configItem.Quality == 4 then
            data.BrokenHeartsPrice = 3
        end
    end
end
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Mod.ConvertToPlanetarium)

local pickupOffset = Vector(0, 20)

function Mod:RenderBrokenHeartPrice(pickup)
    local data = Mod:GetData(pickup)
    local room = game:GetRoom()
    if data.BrokenHeartsPrice then
        local sprite = Sprite()
        sprite:Load("gfx/ui/ui_broken_heart_prices.anm2", true)
        if data.BrokenHeartsPrice == 1 then
            sprite:SetFrame("One", 0)
        elseif data.BrokenHeartsPrice == 2 then
            sprite:SetFrame("Two", 0)
        elseif data.BrokenHeartsPrice == 3 then
            sprite:SetFrame("Three", 0)
        end
        sprite:Render(room:WorldToScreenPosition(pickup.Position) + pickupOffset, Vector.Zero, Vector.Zero)
    end
end
Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, Mod.RenderBrokenHeartPrice)

local qualityPriceMap = {
    [0] = 1,
    [1] = 1,
    [2] = 2,
    [3] = 2,
    [4] = 3,
}

--[[function mod:PlanetariumPickupSpawned(pickup)
    if isTreasureRoom() and someoneHasAlmagest() and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
        local itemConfig = Isaac.GetItemConfig()
        local pickupQuality = itemConfig:GetCollectible(pickup.SubType).Quality

        -- get the price for pickup to data
        local data = mod:GetData(pickup)
        data.BrokenHeartsPrice = qualityPriceMap[pickupQuality]
        print(data.BrokenHeartsPrice)
        -- add a broken hearts price graphic (wip)
    end


end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.PostPlanetariumPool)

function Mod:PrePickupCollision(pickup, collider)
    local player = collider:ToPlayer()
    if not player then return end

    if isTreasureRoom() and someoneHasAlmagest() and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
        -- check whether the pickup's price
        local data = Mod:GetData(pickup)
        local price = data.BrokenHeartsPrice
        if price == nil then
            return nil
        elseif player:GetBrokenHearts() >= price then
            player:AddBrokenHearts(-price)
            return nil
        else
            return false
        end
    end

end
Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Mod.PrePickupCollision) ]]