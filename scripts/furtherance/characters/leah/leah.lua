local Mod = Furtherance

local LEAH = {}

Furtherance.Character.LEAH = LEAH

LEAH.SCARED_HEART_CHANCE = 0.0625
LEAH.TEARS_PER_BROKEN = 0.2
LEAH.BIRTHRIGHT_KILL_THRESHOLD = 20

Mod.Include("scripts.furtherance.characters.leah.heart_renovator")

---@param player EntityPlayer
function LEAH:IsLeah(player)
	return player:GetPlayerType() == Mod.PlayerType.LEAH
end

---@param player EntityPlayer
function LEAH:LeahHasBirthright(player)
	return LEAH:IsLeah(player) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
end

---@param npc EntityNPC
function LEAH:ScaredHeartOnDeath(npc)
	local player = PlayerManager.FirstPlayerByType(Mod.PlayerType.LEAH)
	if player then
		local hrRNG = player:GetCollectibleRNG(Mod.Item.HEART_RENOVATOR.ID)
		if npc:IsActiveEnemy(true) then
			if hrRNG:RandomFloat() <= LEAH.SCARED_HEART_CHANCE then
				Mod.Spawn.Heart(HeartSubType.HEART_SCARED, npc.Position, nil, player, npc:GetDropRNG():GetSeed())
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, LEAH.ScaredHeartOnDeath)

---@param player EntityPlayer
function LEAH:OnBrokenHeartAdd(player)
	if player:GetPlayerType() == Mod.PlayerType.LEAH then
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_HEARTS, LEAH.OnBrokenHeartAdd, AddHealthType.BROKEN)

---@param player EntityPlayer
function LEAH:TearsUp(player)
	if player:GetPlayerType() == Mod.PlayerType.LEAH then
		player.MaxFireDelay = Mod:TearsUp(player.MaxFireDelay, LEAH.TEARS_PER_BROKEN * player:GetBrokenHearts())
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, LEAH.TearsUp, CacheFlag.CACHE_FIREDELAY)

---@param ent Entity
---@param damage number
---@param flags DamageFlag
---@param source EntityRef
function LEAH:BirthrightDamageKillCredit(ent, damage, flags, source)
	if not ent:IsActiveEnemy(true) then return end
	local player = Mod:TryGetPlayer(source)
	if player
		and LEAH:LeahHasBirthright(player)
	then
		Mod:GetData(ent).LeahBirthrightKill = EntityPtr(player)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, LEAH.BirthrightDamageKillCredit)

---@param npc EntityNPC
function LEAH:BirthrightDamageOnKill(npc)
	local data = Mod:GetData(npc)

	if data and data.LeahBirthrightKill then
		---@type Entity?
		local ref = data.LeahBirthrightKill.Ref
		if ref then
			local player = ref:ToPlayer()
			---@cast player EntityPlayer
			local run_save = Mod:RunSave(player)
			run_save.LeahBirthrightKills = (run_save.LeahBirthrightKills or 0) + 1
			if run_save.LeahBirthrightKills % LEAH.BIRTHRIGHT_KILL_THRESHOLD == 0 then
				run_save.HeartRenovatorDamage = run_save.HeartRenovatorDamage + 0.5
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, LEAH.BirthrightDamageOnKill)