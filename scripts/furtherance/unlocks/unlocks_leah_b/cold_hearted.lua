local Mod = Furtherance

local COLD_HEARTED = {}

Furtherance.Item.COLD_HEARTED = COLD_HEARTED

COLD_HEARTED.ID = Isaac.GetItemIdByName("Cold Hearted")

COLD_HEARTED.BOSS_SLOW_DURATION = 150

---@param player EntityPlayer
---@param collider Entity
function COLD_HEARTED:OnPlayerCollision(player, collider)
	if player:HasCollectible(COLD_HEARTED.ID) and Mod:IsValidEnemyTarget(collider) then
		if collider:IsBoss() then
			collider:AddSlowing(EntityRef(player), COLD_HEARTED.BOSS_SLOW_DURATION, 0.5, StatusEffectLibrary.StatusColor.SLOW)
		else
			collider:AddEntityFlags(EntityFlag.FLAG_ICE)
			collider.HitPoints = 0
			collider:TakeDamage(1, 0, EntityRef(player), 0)
			collider.Position = collider.Position + (collider.Position - player.Position):Resized(5)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_COLLISION, COLD_HEARTED.OnPlayerCollision, PlayerVariant.PLAYER)