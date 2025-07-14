local Mod = Furtherance

local LOCK_PICK_CHANCE = 0.1

local lockedChests = {
	PickupVariant.PICKUP_LOCKEDCHEST,
	PickupVariant.PICKUP_MEGACHEST,
	PickupVariant.PICKUP_OLDCHEST
}

---@param pickup EntityPickup
---@param collider Entity
local function chestCollision(_, pickup, collider)
	local player = collider:ToPlayer()
	if not player
		or player:HasCollectible(CollectibleType.COLLECTIBLE_PAY_TO_PLAY)
		or pickup.SubType == ChestSubType.CHEST_OPENED
		or player:GetNumKeys() == 0
	then
		return
	end

	local cainLoveTellerBaby
	local numBabies = 0

	Mod.Foreach.Familiar(function (familiar, index)
		if Mod.Slot.LOVE_TELLER.BABY:IsSubtype(familiar, PlayerType.PLAYER_CAIN)
			and GetPtrHash(familiar.Player) == GetPtrHash(player)
		then
			cainLoveTellerBaby = familiar
			numBabies = numBabies + 1
		end
	end, Mod.Slot.LOVE_TELLER.BABY.FAMILIAR)

	if not cainLoveTellerBaby then return end
	local keys = player:GetNumKeys()
	Mod:DelayOneFrame(function()
		if player:GetNumKeys() < keys
			and cainLoveTellerBaby:GetDropRNG():RandomFloat() <= LOCK_PICK_CHANCE * numBabies
		then
			player:AddKeys(1)
			Mod:GetData(cainLoveTellerBaby).GlitchBabySubtype = nil
		end
	end)
end

for _, variant in ipairs(lockedChests) do
	Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, chestCollision, variant)
end
