--#region Variables

local Mod = Furtherance

local SERVITUDE = {}

Furtherance.Item.SERVITUDE = SERVITUDE

SERVITUDE.ID = Isaac.GetItemIdByName("Servitude")

--#endregion

--#region Selecting collectibles

---@param player EntityPlayer
function SERVITUDE:GetNearestCollectible(player)
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
---@param flags UseFlag
---@param slot ActiveSlot
function SERVITUDE:OnUse(_, _, player, flags, slot)
	if Mod:HasBitFlags(flags, UseFlag.USE_CARBATTERY)
		or not Mod:HasBitFlags(flags, UseFlag.USE_OWNED)
		or player:GetActiveItem(slot) ~= SERVITUDE.ID
	then
		return
	end
	local item = SERVITUDE:GetNearestCollectible(player)
	local player_run_save = Mod:RunSave(player)
	local counter = player_run_save.ServitudeCounter
	local foundItem = false

	if item and (not counter or counter == 0) then
		player:SetActiveVarData(item.SubType, slot)
		player:SetActiveCharge(player:GetActiveCharge(slot) - 1, slot)
		foundItem = true
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
			local newCharge = player:GetActiveCharge(slot) - 1
			player:SetActiveCharge(newCharge, slot)
			if newCharge == 0 then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, itemDesc.VarData,
					Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, player)
				player:SetActiveVarData(0, slot)
			end
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, CallbackPriority.LATE, SERVITUDE.OnRoomClear)

--#endregion

--#region Resset on taking damage

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

--[[ ---@param player EntityPlayer
function SERVITUDE:SelectClosestCollectible(player)
	if not player:HasCollectible(SERVITUDE.ID) or #Isaac.FindByType(5, 100) == 0 then return end
	local item = SERVITUDE:GetNearestCollectible(player)
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, SERVITUDE.SelectClosestCollectible)

---@param pickup EntityPickup
function SERVITUDE:ServitudeTarget(pickup)

	local room = game:GetRoom()
	for p = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(p)
		local data = Mod:GetData(player)

		local item = SERVITUDE:GetNearestCollectible(player)
		if player:HasCollectible(SERVITUDE.ID) and item ~= nil and data.ServitudeCounter == 0 then
			local sprite = Sprite()
			sprite:Load("gfx/effect_spiritual_wound_target.anm2", true)
			sprite:Play("Idle", true)
			sprite:Render(room:WorldToScreenPosition(item.Position, Vector.Zero, Vector.Zero))
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, SERVITUDE.ServitudeTarget) ]]

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
		HudHelper.RenderHUDItem(Mod.ItemConfig:GetCollectible(itemID).GfxFileName, position, scale, alpha, false, false)
		HudHelper.RenderHUDElements(HudHelper.HUDType.ACTIVE_ID, false, player, playerHUDIndex, hudLayout, position, alpha, scale * 0.5, slot)
	end
}, HudHelper.HUDType.ACTIVE)

--#endregion