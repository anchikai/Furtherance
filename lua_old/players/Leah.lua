local Mod = Furtherance
local game = Game()
local rng = RNG()

Mod:SavePlayerData({
	LeahKills = 0,
})

local bhb = Isaac.GetSoundIdByName("BrokenHeartbeat")

COSTUME_LEAH_A_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/Character_001_Leah_Hair.anm2")
COSTUME_LEAH_B_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/Character_001b_Leah_Hair.anm2")

local function IsEnemyNear(player) -- Enemy detection
	for _, enemies in pairs(Isaac.FindInRadius(player.Position, 100)) do
		if enemies:IsVulnerableEnemy() and enemies:IsActiveEnemy() then
			return true
		end
	end
	return false
end

function Mod:OnInit(player)
	local data = Mod:GetData(player)
	data.Init = true

	if player:GetPlayerType() == PlayerType.PLAYER_LEAH then    -- If the player is Leah it will apply her hair
		player:AddNullCostume(COSTUME_LEAH_A_HAIR)
	elseif player:GetPlayerType() == PlayerType.PLAYER_LEAH_B then -- Apply different hair for her tainted variant
		player:AddNullCostume(COSTUME_LEAH_B_HAIR)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Mod.OnInit)

function Mod:GiveLeahItems(player)
	local data = Mod:GetData(player)
	if not data.Init then return end

	if player:GetPlayerType() == PlayerType.PLAYER_LEAH then
		if player.FrameCount == 1 and not Mod.IsContinued then
			player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_HEART_RENOVATOR, ActiveSlot.SLOT_POCKET, false)
		elseif player.FrameCount > 1 then
			data.Init = nil
		end
	elseif player:GetPlayerType() == PlayerType.PLAYER_LEAH_B then
		if player.FrameCount == 1 and not Mod.IsContinued then
			player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_SHATTERED_HEART, ActiveSlot.SLOT_POCKET, false)
		elseif player.FrameCount > 1 then
			data.Init = nil
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Mod.GiveLeahItems)

function Mod:OnUpdate(player)
	local room = game:GetRoom()
	local data = Mod:GetData(player)

	if player:GetPlayerType() == PlayerType.PLAYER_LEAH_B then
		if data.LeahbPower == nil or data.LeahbPower < 0 then
			data.LeahbPower = 0
		end
		if player:GetMaxHearts() > 0 then
			local conv = player:GetMaxHearts()
			player:AddMaxHearts(-conv)
			player:AddBlackHearts(conv)
		end
		player:AddHearts(-player:GetHearts())
		if not IsEnemyNear(player) then
			data.LeahbPower = data.LeahbPower - 1
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
			player:EvaluateItems()
		end
		if player:GetBrokenHearts() == 0 then
			data.LeahSpeed = false
			player:AddCacheFlags(CacheFlag.CACHE_SPEED)
			player:EvaluateItems()
		elseif player:GetBrokenHearts() > 0 then
			data.LeahSpeed = true
			player:AddCacheFlags(CacheFlag.CACHE_SPEED)
			player:EvaluateItems()
		end
	end
	if IsEnemyNear(player) ~= true and ((player:GetPlayerType() == PlayerType.PLAYER_LEAH_B and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) ~= true)
			or player:HasCollectible(CollectibleType.COLLECTIBLE_SHATTERED_HEART)) and player:GetBrokenHearts() ~= 11 and room:GetAliveEnemiesCount() > 0 then
		if game:GetFrameCount() % 120 == 0 then
			SFXManager():Play(bhb)
			player:AddBrokenHearts(1)
		end
	elseif player:GetPlayerType() == PlayerType.PLAYER_LEAH_B and IsEnemyNear(player) ~= true and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and room:GetAliveEnemiesCount() > 0 then
		if game:GetFrameCount() % 120 == 0 then
			if player:GetBrokenHearts() < 6 then
				SFXManager():Play(bhb)
				player:AddBrokenHearts(1)
			elseif player:GetBrokenHearts() > 6 then
				SFXManager():Play(SoundEffect.SOUND_HEARTBEAT)
				player:AddBrokenHearts(-1)
			end
		end
	elseif IsEnemyNear(player) then
		if player:GetPlayerType() == PlayerType.PLAYER_LEAH_B and player.MaxFireDelay <= 40 then
			data.LeahbPower = data.LeahbPower + 1
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
			player:EvaluateItems()
		end
		if game:GetFrameCount() % 30 == 0 and (player:GetPlayerType() == PlayerType.PLAYER_LEAH_B or player:HasCollectible(CollectibleType.COLLECTIBLE_SHATTERED_HEART)) then
			SFXManager():Play(SoundEffect.SOUND_HEARTBEAT)
			player:AddBrokenHearts(-1)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Mod.OnUpdate)

function Mod:Hearts(entity, collider)
	if collider:ToPlayer() then
		local player = collider:ToPlayer()
		if player:GetPlayerType() == PlayerType.PLAYER_LEAH_B then -- Prevent Tainted Leah from obtaining Red Health
			if entity.SubType == HeartSubType.HEART_DOUBLEPACK or entity.SubType == HeartSubType.HEART_FULL or entity.SubType == HeartSubType.HEART_HALF
				or entity.SubType == HeartSubType.HEART_ROTTEN or entity.SubType == HeartSubType.HEART_SCARED then
				return false
			elseif entity.SubType == HeartSubType.HEART_BLENDED then
				if player:GetSoulHearts() + player:GetBoneHearts() * 2 < 24 then
					entity:GetSprite():Play("Collect", true)
					entity:Die()
					SFXManager():Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 0, false)
					player:AddSoulHearts(2)
				end
				return false
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Mod.Hearts, PickupVariant.PICKUP_HEART)

function Mod:leahStats(player, flag)
	local data = Mod:GetData(player)
	if player:GetPlayerType() == PlayerType.PLAYER_LEAH then -- If the player is Leah it will apply her stats
		if flag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay + 1
		end
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage - 0.36
		end
		if flag == CacheFlag.CACHE_RANGE then
			player.TearRange = player.TearRange - 195.6
			player.TearRange = player.TearRange + player:GetBrokenHearts() * 40
			if player.TearRange > 640 then
				player.TearRange = 640
			end
		end
	elseif player:GetPlayerType() == PlayerType.PLAYER_LEAH_B then -- If the player is Tainted Leah it will apply her stats
		if flag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay / 2.5
			if data.LeahbPower == nil then
				data.LeahbPower = 0
			end
			if data.LeahbPower > 0 then
				for _ = 1, data.LeahbPower do
					if player.MaxFireDelay <= 40 then
						player.MaxFireDelay = player.MaxFireDelay * 1.01
					end
				end
			end
		end
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage - 2
		end
		if flag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed + 0.5
			if data.LeahSpeed == nil then
				data.LeahSpeed = false
			end
			if data.LeahSpeed == true and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) == false then
				player.MoveSpeed = player.MoveSpeed - (player:GetBrokenHearts() / 20)
			elseif data.LeahSpeed == true and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
				player.MoveSpeed = player.MoveSpeed - 0.85
				player.MoveSpeed = player.MoveSpeed + (player:GetBrokenHearts() / 20)
			end
		end
		if flag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck - 3
		end
	end
	if data.brokentears == true then
		if flag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_CHARM
			if game:GetFrameCount() % 2 == 0 then
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_BLACK, 0,
					player.Position, Vector.Zero, player)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.leahStats)

function Mod:LeahKill(entity)
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = Mod:GetData(player)
		if player:GetPlayerType() == PlayerType.PLAYER_LEAH then
			if rng:RandomFloat() <= 0.0625 then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SCARED,
					entity.Position, Vector.Zero, player)
			end
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
				data.LeahKills = data.LeahKills + 1
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
				if player:GetBrokenHearts() > 0 then
					if (player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and data.LeahKills >= 10)
						or (player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) == false and data.LeahKills >= 20)
					then
						data.LeahKills = 0
						SFXManager():Play(SoundEffect.SOUND_HEARTBEAT)
						player:AddBrokenHearts(-1)
						data.RenovatorDamage = data.RenovatorDamage + 0.5
						player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
						player:AddCacheFlags(CacheFlag.CACHE_RANGE)
						player:EvaluateItems()
					end
				end
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Mod.LeahKill)

function Mod:LeahbBrokenTears(tear)
	local player = tear.Parent:ToPlayer()
	local data = Mod:GetData(player)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_SHATTERED_HEART) then -- % Chance to charm enemies based off how many broken hearts you have
		local brokenRoll = rng:RandomInt(100) + 1
		if brokenRoll <= (player:GetBrokenHearts() * 5 + 25) then
			data.brokentears = true
			tear.Color = Color(1, 0.588, 0.686, 1, 0, 0, 0)
			player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG)
			player:EvaluateItems()
		else
			data.brokentears = false
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and player:GetPlayerType() == PlayerType.PLAYER_LEAH_B then -- +20% Chance if you have Birthright
			if brokenRoll <= (player:GetBrokenHearts() * 5 + 45) then
				data.brokentears = true
				tear.Color = Color(1, 0.588, 0.686, 1, 0, 0, 0)
				player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG)
				player:EvaluateItems()
			else
				data.brokentears = false
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, Mod.LeahbBrokenTears)

function Mod:ClickerFix(_, _, player)
	player:TryRemoveNullCostume(COSTUME_LEAH_A_HAIR)
	player:TryRemoveNullCostume(COSTUME_LEAH_B_HAIR)
	if player:GetPlayerType() == PlayerType.PLAYER_LEAH then
		player:AddNullCostume(COSTUME_LEAH_A_HAIR)
	elseif player:GetPlayerType() == PlayerType.PLAYER_LEAH_B then
		player:AddNullCostume(COSTUME_LEAH_B_HAIR)
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, Mod.ClickerFix, CollectibleType.COLLECTIBLE_CLICKER)



function Mod:TaintedLeahHome()
	local level = game:GetLevel()
	local room = game:GetRoom()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == PlayerType.PLAYER_LEAH and level:GetCurrentRoomIndex() == 94 and level:GetStage() == LevelStage.STAGE8 and Mod.Unlocks.Leah.Tainted ~= true then
			local RememberPocket = player:GetActiveCharge(ActiveSlot.SLOT_POCKET)
			for _, entity in ipairs(Isaac.GetRoomEntities()) do
				if (((entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE)
						or (entity.Type == EntityType.ENTITY_SHOPKEEPER)) and room:IsFirstVisit())
					or (entity.Type == EntityType.ENTITY_SLOT and entity.Variant == 14) then
					entity:Remove()
					player:ChangePlayerType(PlayerType.PLAYER_LEAH_B)
					Isaac.Spawn(EntityType.ENTITY_SLOT, 14, 0, entity.Position, Vector.Zero, nil)
					player:ChangePlayerType(PlayerType.PLAYER_LEAH)
					player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_HEART_RENOVATOR, ActiveSlot.SLOT_POCKET, false)
					player:SetActiveCharge(RememberPocket, ActiveSlot.SLOT_POCKET)
				end
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Mod.TaintedLeahHome)

function Mod:UnlockTaintedLeah(player)
	if player:GetPlayerType() ~= PlayerType.PLAYER_LEAH or Mod.Unlocks.Leah.Tainted then return end

	for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_SLOT, 14)) do
		local sprite = entity:GetSprite()
		if sprite:IsFinished("PayPrize") then
			Mod.Unlocks.Leah.Tainted = true
			GiantBookAPI.ShowAchievement("achievement_taintedleah.png")
			for _, poof in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.POOF01)) do
				poof:Remove()
			end
			break
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Mod.UnlockTaintedLeah)
