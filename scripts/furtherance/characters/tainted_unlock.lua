local Mod = Furtherance

local TAINTED_UNLOCK = {}

function TAINTED_UNLOCK:OnClosetEntry()
	if not REPENTOGON then return end
	local level = Mod.Level()
	local room = Mod.Room()

	if level:GetStage() == LevelStage.STAGE8 --Home
		and level:GetCurrentRoomIndex() == 94 --Closet
		and room:IsFirstVisit()
	then
		local player = Isaac.GetPlayer()
		local playerType = player:GetPlayerType()
		local unlock_table = Mod.PlayerTypeToCompletionTable[playerType]
		if unlock_table then
			local tainted = unlock_table[Mod.CompletionType.TAINTED]
			if tainted and not Mod.PersistGameData:Unlocked(tainted) then
				local innerChild = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_INNER_CHILD)[1]
				local shopKeeper = Isaac.FindByType(EntityType.ENTITY_SHOPKEEPER)[1]

				if innerChild then
					innerChild:Remove()
				elseif shopKeeper then
					shopKeeper:Remove()
				end

				Isaac.Spawn(EntityType.ENTITY_SLOT, SlotVariant.HOME_CLOSET_PLAYER, playerType, room:GetCenterPos(), Vector.Zero, player)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, TAINTED_UNLOCK.OnClosetEntry)

---@param slot EntitySlot
function TAINTED_UNLOCK:CryingTaintedSpriteOnInit(slot)
	local player = Isaac.GetPlayer()
	if Mod.PlayerTypeToCompletionTable[player:GetPlayerType()] then
		local sprite = slot:GetSprite()
		sprite:ReplaceSpritesheet(0, player:GetEntityConfigPlayer():GetTaintedCounterpart():GetSkinPath(), true)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_SLOT_INIT, TAINTED_UNLOCK.CryingTaintedSpriteOnInit, SlotVariant.HOME_CLOSET_PLAYER)

---@param slot EntitySlot
function TAINTED_UNLOCK:UnlockTainted(slot)
	local player = Isaac.GetPlayer()
	local unlock_table = Mod.PlayerTypeToCompletionTable[player:GetPlayerType()]
	if unlock_table then
		local sprite = slot:GetSprite()
        local tainted = unlock_table[Mod.CompletionType.TAINTED]
		if tainted and sprite:IsFinished("PayPrize") then
			Mod.PersistGameData:TryUnlock(tainted)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, TAINTED_UNLOCK.UnlockTainted, SlotVariant.HOME_CLOSET_PLAYER)
