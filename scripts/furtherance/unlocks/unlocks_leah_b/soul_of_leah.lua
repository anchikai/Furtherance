local Mod = Furtherance

local SOUL_OF_LEAH = {}

Furtherance.Rune.SOUL_OF_LEAH = SOUL_OF_LEAH

SOUL_OF_LEAH.ID = Isaac.GetCardIdByName("Soul of Leah")

---@param ent EntityPlayer
---@param amount integer
---@param flags DamageFlag
function SOUL_OF_LEAH:OnMortalDamage(ent, amount, flags, source, countdown)
	local player = ent:ToPlayer()
	---@cast player EntityPlayer

	if Mod:GetEffectiveHitPoints(player) - amount <= 0
		and not Mod:HasBitFlags(flags, DamageFlag.DAMAGE_FAKE)
	then
		for i = PillCardSlot.PRIMARY, PillCardSlot.QUATERNARY do
			if player:GetCard(i) == SOUL_OF_LEAH.ID then
				player:UseCard(SOUL_OF_LEAH.ID, UseFlag.USE_OWNED | UseFlag.USE_NOANIM | UseFlag.USE_REMOVEACTIVE)
				player:RemovePocketItem(i)
				return {DamageFlags = flags | DamageFlag.DAMAGE_FAKE}
			end
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, SOUL_OF_LEAH.OnMortalDamage, EntityType.ENTITY_PLAYER)

---@param player EntityPlayer
---@param flags DamageFlag
function SOUL_OF_LEAH:OnUse(_, player, flags)
	player:AddBrokenHearts(2)
	if not Mod:HasBitFlags(flags, UseFlag.USE_REMOVEACTIVE) then
		player:TakeDamage(1, DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(player), 0)
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, SOUL_OF_LEAH.OnUse, SOUL_OF_LEAH.ID)