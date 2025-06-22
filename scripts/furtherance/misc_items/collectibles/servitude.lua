--#region Variables

local Mod = Furtherance

local SERVITUDE = {}

Furtherance.Item.SERVITUDE = SERVITUDE

SERVITUDE.ID = Isaac.GetItemIdByName("Servitude")

SERVITUDE.MAX_CHARGES = Mod.ItemConfig:GetCollectible(SERVITUDE.ID).MaxCharges

local glowingCollectibles = {}

local servitudeSpr = Sprite("gfx/005.100_collectible.anm2", true)
servitudeSpr:ReplaceSpritesheet(1, "gfx/items/collectibles/servitude.png", true)
servitudeSpr:Play("PlayerPickup")
servitudeSpr.Scale = Vector(0.5, 0.5)

--#endregion

--#region Selecting collectibles

---@param player EntityPlayer
function SERVITUDE:GetNearestCollectible(player)
	if #Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, -1, true) == 0 then
		return
	end
	local nearestCollectible = nil
	local nearestDistance

	Mod.Foreach.Pickup(function (pickup, index)
		local distance = player.Position:DistanceSquared(pickup.Position)
		if pickup.SubType ~= CollectibleType.COLLECTIBLE_NULL then
			if not nearestDistance or distance < nearestDistance then
				nearestDistance = distance
				nearestCollectible = pickup
			end
		end
	end, PickupVariant.PICKUP_COLLECTIBLE)

	return nearestCollectible
end

---@param player EntityPlayer
---@return Entity
local function tryGetTarget(player)
	local data = Mod:GetData(player)
	---@type EntityPtr
	local targetItem = data.ServitudeCollectibleTarget
	return targetItem and targetItem.Ref
end

---@param player EntityPlayer
function SERVITUDE:SearchForCollectibleTarget(player)
	if not player:HasCollectible(SERVITUDE.ID) then return end
	local slots = Mod:GetActiveItemCharges(player, SERVITUDE.ID)
	local fullCharge = false
	for _, slotData in ipairs(slots) do
		if slotData.Charge >= SERVITUDE.MAX_CHARGES then
			fullCharge = true
			break
		end
	end
	if not fullCharge then return end
	local item = SERVITUDE:GetNearestCollectible(player)
	if not item then return end
	local data = Mod:GetData(player)
	local targetItem = tryGetTarget(player)
	if not targetItem then
		data.ServitudeCollectibleTarget = EntityPtr(item)
		glowingCollectibles[GetPtrHash(item)] = true
		targetItem = item
	end
	if GetPtrHash(targetItem) ~= GetPtrHash(item) then
		glowingCollectibles[GetPtrHash(targetItem)] = nil
		data.ServitudeCollectibleTarget:SetReference(item)
		glowingCollectibles[GetPtrHash(item)] = true
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, SERVITUDE.SearchForCollectibleTarget)

---@param player EntityPlayer
---@param flags UseFlag
---@param slot ActiveSlot
function SERVITUDE:OnUse(_, _, player, flags, slot)
	if Mod:HasBitFlags(flags, UseFlag.USE_CARBATTERY)
		or not Mod:HasBitFlags(flags, UseFlag.USE_OWNED)
		or player:GetActiveItem(slot) ~= SERVITUDE.ID
	then
		return
	end
	local item = tryGetTarget(player)
	local foundItem = false

	if item and player:GetActiveItemDesc(slot).VarData == 0 then
		player:SetActiveVarData(item.SubType, slot)
		player:SetActiveCharge(player:GetActiveCharge(slot) - 1, slot)
		foundItem = true
		Mod.SFXMan:Play(SoundEffect.SOUND_ANIMA_TRAP)
	end
	return { Discharge = false, ShowAnim = foundItem, Remove = false }
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, SERVITUDE.OnUse, SERVITUDE.ID)

--#endregion

--#region Control charge

---@param player EntityPlayer
function SERVITUDE:OnRoomClear(player)
	local slots = Mod:GetActiveItemSlots(player, SERVITUDE.ID)
	local chargeAmount = Mod.Room():GetRoomShape() >= RoomShape.ROOMSHAPE_2x2 and 2 or 1
	for _, slot in ipairs(slots) do
		local itemDesc = player:GetActiveItemDesc(slot)
		if itemDesc.VarData == 0 then
			player:AddActiveCharge(chargeAmount, slot, true, false, true)
		else
			local newCharge = math.max(0, player:GetActiveCharge(slot) - chargeAmount)
			player:SetActiveCharge(newCharge, slot)
			Mod.SFXMan:Play(SoundEffect.SOUND_BEEP, 1, 2, false, 0.75)
			Mod.HUD:FlashChargeBar(player, slot)
			if newCharge <= 0 then
				Mod.Spawn.Collectible(
					itemDesc.VarData,
					Mod.Room():FindFreePickupSpawnPosition(player.Position, 40, true),
					player,
					player:GetCollectibleRNG(SERVITUDE.ID):Next()
				)
				player:SetActiveVarData(0, slot)
				player:AnimateHappy()
			end
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, CallbackPriority.LATE, SERVITUDE.OnRoomClear)

--#endregion

--#region Reset on taking damage

---@param ent Entity
---@param flag DamageFlag
function SERVITUDE:ResetServitude(ent, amount, flag)
	local player = ent:ToPlayer()
	if player
		and player:HasCollectible(SERVITUDE.ID)
		and (not Mod:HasBitFlags(flag, DamageFlag.DAMAGE_FAKE)
		or not Mod:HasBitFlags(flag, DamageFlag.DAMAGE_NO_PENALTIES))
	then
		local punished = false
		local slots = Mod:GetActiveItemSlots(player, SERVITUDE.ID)
		for _, slot in ipairs(slots) do
			local itemDesc = player:GetActiveItemDesc(slot)
			if itemDesc.VarData > 0 then
				player:SetActiveCharge(0, slot)
				player:SetActiveVarData(0, slot)
				player:AddBrokenHearts(1)
				punished = true
			end
		end
		if punished then
			Mod.SFXMan:Play(SoundEffect.SOUND_THUMBS_DOWN)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, SERVITUDE.ResetServitude, EntityType.ENTITY_PLAYER)

--#endregion

--#region Render target

---@param player EntityPlayer
---@param itemID CollectibleType
function SERVITUDE:StopRenderingOnRemove(player, itemID)
	if not player:HasCollectible(itemID) then
		Mod:ClearTable(glowingCollectibles)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, SERVITUDE.StopRenderingOnRemove, SERVITUDE.ID)

function SERVITUDE:ResetOnNewRoom()
	Mod:ClearTable(glowingCollectibles)
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, SERVITUDE.ResetOnNewRoom)

---@param pickup EntityPickup
---@param offset Vector
function SERVITUDE:ServitudeTarget(pickup, offset)
	local offset2 = Mod.Room():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT and 1 or -1
	local renderPos = Mod:GetEntityRenderPosition(pickup, offset) + Vector(0, 40 * offset2)
	if glowingCollectibles[GetPtrHash(pickup)] then
		servitudeSpr:Render(renderPos)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, SERVITUDE.ServitudeTarget)

--#endregion

--#region Render selcted item

HudHelper.RegisterHUDElement({
	Name = "Servitude Item Render",
	Priority = HudHelper.Priority.NORMAL,
	Condition = function(player, playerHUDIndex, hudLayout, slot)
		---@cast slot ActiveSlot
		return HudHelper.ShouldActiveBeDisplayed(player, SERVITUDE.ID, slot)
			and player:GetActiveItemDesc(slot).VarData > 0
			and not Mod.Room():HasCurseMist()
	end,
	OnRender = function(player, playerHUDIndex, hudLayout, position, alpha, scale, slot)
		---@cast slot ActiveSlot
		local itemID = player:GetActiveItemDesc(slot).VarData
		HudHelper.RenderHUDItem(Mod.ItemConfig:GetCollectible(itemID).GfxFileName, position, scale * 0.5, alpha * 0.5, false, false)
		HudHelper.RenderHUDElements(HudHelper.HUDType.ACTIVE_ID, false, player, playerHUDIndex, hudLayout, position, alpha, scale, slot)
	end
}, HudHelper.HUDType.ACTIVE)

--#endregion