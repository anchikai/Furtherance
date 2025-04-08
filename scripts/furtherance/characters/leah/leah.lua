local Mod = Furtherance

local LEAH = {}

Furtherance.Character.LEAH = LEAH

LEAH.SCARED_HEART_CHANCE = 0.0625

Mod.Include("scripts.furtherance.characters.leah.heart_renovator")

---@param npc EntityNPC
function LEAH:ScaredHeartOnDeath(npc)
	local player = PlayerManager.FirstPlayerByType(Mod.PlayerType.LEAH)
	if player then
		local hrRNG = player:GetCollectibleRNG(Mod.Item.HEART_RENOVATOR.ID)
		if npc:IsActiveEnemy(true) then
			if hrRNG:RandomFloat() <= LEAH.SCARED_HEART_CHANCE then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SCARED,
				npc.Position, Vector.Zero, player)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, LEAH.ScaredHeartOnDeath)

---@param player EntityPlayer
function LEAH:AddRange(player)
	if player:GetPlayerType() == Mod.PlayerType.LEAH then
		player.TearRange = player.TearRange + player:GetBrokenHearts() * Mod.RANGE_BASE_MULT
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, LEAH.AddRange, CacheFlag.CACHE_RANGE)