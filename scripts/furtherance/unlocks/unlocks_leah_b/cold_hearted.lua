local Mod = Furtherance

local COLD_HEARTED = {}

Furtherance.Item.COLD_HEARTED = COLD_HEARTED

COLD_HEARTED.ID = Isaac.GetItemIdByName("Cold Hearted")

---@param player EntityPlayer
---@param collider Entity
function COLD_HEARTED:OnPlayerCollision(player, collider)
	if player:HasCollectible(COLD_HEARTED.ID) and Mod:IsValidEnemyTarget(collider) and not collider:IsBoss() then
		collider:AddEntityFlags(EntityFlag.FLAG_ICE)
		collider:TakeDamage(1, 0, EntityRef(player), 0)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_COLLISION, COLD_HEARTED.OnPlayerCollision, PlayerVariant.PLAYER)