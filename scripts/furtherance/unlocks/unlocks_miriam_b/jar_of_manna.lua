local Mod = Furtherance

local JAR_OF_MANNA = {}

Furtherance.Item.JAR_OF_MANNA = JAR_OF_MANNA

JAR_OF_MANNA.ID = Isaac.GetItemIdByName("Jar of Manna")

JAR_OF_MANNA.EFFECT = Isaac.GetEntityVariantByName("Manna Orb")
JAR_OF_MANNA.MAX_CHARGES = Mod.ItemConfig:GetCollectible(JAR_OF_MANNA.ID).MaxCharges
JAR_OF_MANNA.EFFECT_RADIUS = 20

JAR_OF_MANNA.StatTable = {
	{ Name = "MoveSpeed",    Flag = CacheFlag.CACHE_SPEED,     Buff = 0.10 },
	{ Name = "Damage",       Flag = CacheFlag.CACHE_DAMAGE,    Buff = 0.25 },
	{ Name = "MaxFireDelay", Flag = CacheFlag.CACHE_FIREDELAY, Buff = 0.5 }, -- MaxFireDelay buffs should be negative!
	{ Name = "TearRange",    Flag = CacheFlag.CACHE_RANGE,     Buff = 0.5 * Mod.RANGE_BASE_MULT },
	{ Name = "ShotSpeed",    Flag = CacheFlag.CACHE_SHOTSPEED, Buff = 0.25 },
	{ Name = "Luck",         Flag = CacheFlag.CACHE_LUCK,      Buff = 0.5 },
}

---@param player EntityPlayer
function JAR_OF_MANNA:GetNeededChargeSlot(player)
	local slots = Mod:GetActiveItemCharges(player, JAR_OF_MANNA.ID)
	for _, itemData in ipairs(slots) do
		if itemData.Charge < JAR_OF_MANNA.MAX_CHARGES then
			return itemData.Slot
		end
	end
end

---@param rng RNG
---@param player EntityPlayer
function JAR_OF_MANNA:OnUse(_, rng, player)
	local pickupTable = player:GetGlyphOfBalanceDrop()
	local variant, subtype = pickupTable[1], pickupTable[2]
	if variant == -1 then
		local player_run_save = Mod:RunSave(player)
		player_run_save.JarOfMannaStatUps = player_run_save.JarOfMannaStatUps or {}
		---@type number[]
		local playerStats = {}
		for _, statInfo in ipairs(JAR_OF_MANNA.StatTable) do
			local score = Furtherance:GetStatScore(player, statInfo.Flag)
			Furtherance.Insert(playerStats, score)
		end
		local lowestStats = {}
		local lowestStat
		if player.MoveSpeed < 2 then
			lowestStats = { 1 }
			lowestStat = playerStats[1]
		end
		for i = 2, #playerStats do
			if lowestStat and playerStats[i] == lowestStat then
				table.insert(lowestStats, i)
			elseif not lowestStat or playerStats[i] < lowestStat then
				lowestStats = { i }
				lowestStat = playerStats[i]
			end
		end
		local statIndex = lowestStats[rng:RandomInt(#lowestStats) + 1]
		local key = tostring(statIndex)
		local flag = JAR_OF_MANNA.StatTable[statIndex].Flag
		player_run_save.JarOfMannaStatUps[key] = (player_run_save.JarOfMannaStatUps[key] or 0) + 1
		player:AddCacheFlags(flag, true)
	else
		Mod.Spawn.Pickup(variant, subtype, Mod.Room():FindFreePickupSpawnPosition(player.Position, 40), nil, player, rng:Next())
	end

	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, JAR_OF_MANNA.OnUse, JAR_OF_MANNA.ID)

-- Spawn manna --
---@param ent EntityNPC
function JAR_OF_MANNA:SpawnManaOnDeath(ent)
	if not PlayerManager.AnyoneHasCollectible(JAR_OF_MANNA.ID)
		or not Mod:IsDeadEnemy(ent)
	then
		return
	end
	local needsCharge = Mod.Foreach.Player(function(player)
		if JAR_OF_MANNA:GetNeededChargeSlot(player) then
			return true
		end
	end)

	if needsCharge then
		Isaac.Spawn(EntityType.ENTITY_EFFECT, JAR_OF_MANNA.EFFECT, 0,
			ent.Position, Vector.Zero, nil):ToEffect().Timeout = 75
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, JAR_OF_MANNA.SpawnManaOnDeath)

---@param effect EntityEffect
function JAR_OF_MANNA:MannaPickup(effect)
	local sprite = effect:GetSprite()

	if effect.Timeout <= 0 and not sprite:IsPlaying("Collect") then
		sprite:Play("Collect")
	end
	if sprite:IsFinished("Collect") then
		effect:Remove()
		return
	end
	if effect.Timeout <= 30 and sprite:IsPlaying("Idle") then
		sprite:SetAnimation("Blink", false)
	end
	if sprite:GetAnimation() == "Collect" then return end

	Mod.Foreach.PlayerInRadius(effect.Position, JAR_OF_MANNA.EFFECT_RADIUS, function(player, index)
		local slot = JAR_OF_MANNA:GetNeededChargeSlot(player)
		if slot then
			local c = player:GetColor()
			player:SetColor(Color(c.R, c.G, c.B, c.A, 0.25, 0.25, 0.25), 5, 1, true, false)
			player:AddActiveCharge(1, slot, true, false, true)
		end
		effect.Timeout = 0
		sprite:Play("Collect")
	end)
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, JAR_OF_MANNA.MannaPickup, JAR_OF_MANNA.EFFECT)

---@param player EntityPlayer
function JAR_OF_MANNA:StatBuffs(player, flag)
	local player_run_save = Mod:RunSave(player)
	if not player_run_save.JarOfMannaStatUps then return end

	for i, buffCount in pairs(player_run_save.JarOfMannaStatUps) do
		local stat = JAR_OF_MANNA.StatTable[tonumber(i)]

		if stat.Flag == flag then
			if flag == CacheFlag.CACHE_FIREDELAY then
				player[stat.Name] = Mod:TearsUp(player[stat.Name], buffCount * stat.Buff)
			else
				player[stat.Name] = player[stat.Name] + buffCount * stat.TempBuff
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, JAR_OF_MANNA.StatBuffs)
