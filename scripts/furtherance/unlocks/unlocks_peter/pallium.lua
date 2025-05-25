local Mod = Furtherance

local PALLIUM = {}

Furtherance.Item.PALLIUM = PALLIUM

PALLIUM.ID = Isaac.GetItemIdByName("Pallium")

---@param player EntityPlayer
function PALLIUM:OnRoomClear(player)
	if player:HasCollectible(PALLIUM.ID) then
		local rng = player:GetCollectibleRNG(PALLIUM.ID)
		local numPallium = player:GetCollectibleNum(PALLIUM.ID)
		local numStart = 1 + numPallium
		local numToSpawn = (rng:RandomInt(3) + 1) + numPallium
		for _ = numStart, numToSpawn do
			local PalliumMinisaac = player:AddMinisaac(player.Position, true)
			Mod:FloorSave(PalliumMinisaac).PalliumMinisaac = true
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, CallbackPriority.LATE, PALLIUM.OnRoomClear)

function PALLIUM:RemoveMinisaacs()
	Mod.Foreach.Familiar(function (familiar, index)
		local familiar_floor_save = Mod.SaveManager.TryGetFloorSave(familiar)
		if familiar_floor_save and familiar_floor_save.PalliumMinisaac then
			familiar:Remove()
		end
	end, FamiliarVariant.MINISAAC)
end

Mod:AddCallback(Mod.SaveManager.SaveCallbacks.PRE_FLOOR_DATA_RESET, PALLIUM.RemoveMinisaacs)
