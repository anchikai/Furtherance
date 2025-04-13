local Mod = Furtherance

local LEAH = {}

Furtherance.Character.LEAH = LEAH

LEAH.SCARED_HEART_CHANCE = 0.0625
LEAH.TEARS_PER_BROKEN = 0.2

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
function LEAH:TearsUp(player)
	if player:GetPlayerType() == Mod.PlayerType.LEAH then
		print(player.MaxFireDelay)
		local tears = Mod:Delay2Tears(player.MaxFireDelay)
		print(tears)
		tears = tears + LEAH.TEARS_PER_BROKEN * player:GetBrokenHearts()
		print(tears)
		player.MaxFireDelay = Mod:Tears2Delay(tears)
		print(player.MaxFireDelay)
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, LEAH.TearsUp, CacheFlag.CACHE_FIREDELAY)