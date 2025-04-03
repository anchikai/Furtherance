local Mod = Furtherance

local ITCHING_POWDER = {}

Furtherance.Item.ITCHING_POWDER = ITCHING_POWDER

ITCHING_POWDER.ID = Isaac.GetItemIdByName("Itching Powder")

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function ITCHING_POWDER:DelayFakeDamage(ent, amount, flags, source, countdown)
	local player = ent:ToPlayer()
	---@cast player EntityPlayer

	if player:HasCollectible(ITCHING_POWDER.ID) and not Mod:HasBitFlags(flags, DamageFlag.DAMAGE_FAKE) then
		Isaac.CreateTimer(function() player:TakeDamage(0, flags | DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(player), countdown) end, 30, 1, true)
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, ITCHING_POWDER.DelayFakeDamage, EntityType.ENTITY_PLAYER)