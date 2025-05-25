local Mod = Furtherance

local RUE = {}

Furtherance.Item.RUE = RUE

RUE.ID = Isaac.GetItemIdByName("Rue")

---@param ent Entity
function RUE:RueOnHit(ent)
	local player = ent:ToPlayer()
	if not player or not player:HasCollectible(RUE.ID) then return end
	local ignoredEnemies = {}

	for _ = 1, player:GetCollectibleNum(RUE.ID) do
		local nearestEnemy = Mod:GetClosestEnemy(player.Position, nil, function (npc)
			return Mod:IsValidEnemyTarget(npc) and ignoredEnemies[GetPtrHash(npc)] == nil
		end)
		local delta = RandomVector()
		if nearestEnemy then
			delta = (nearestEnemy.Position - player.Position):Normalized()
			ignoredEnemies[GetPtrHash(nearestEnemy)] = true
		end
		player:FireBrimstone(delta, player, 1)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, RUE.RueOnHit, EntityType.ENTITY_PLAYER)
