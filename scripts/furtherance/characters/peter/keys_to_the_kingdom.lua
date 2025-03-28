local Mod = Furtherance
local game = Game()

local spareTime = 30 * 30
local finalBossIDs = {
	[6] = true,
	[8] = true,
	[24] = true,
	[25] = true,
	[39] = true,
	[40] = true,
	[54] = true,
	[55] = true,
	[63] = true,
	[70] = true,
	[88] = true,
	[99] = true,
	[100] = true
}

local statObjs = {
	{ Name = "Damage",       Flag = CacheFlag.CACHE_DAMAGE,    Buff = 0.5,    TempBuff = 0.1 },
	{ Name = "MaxFireDelay", Flag = CacheFlag.CACHE_FIREDELAY, Buff = -0.5 * 5, TempBuff = -0.1 * 5 }, -- MaxFireDelay buffs should be negative!
	{ Name = "TearRange",    Flag = CacheFlag.CACHE_RANGE,     Buff = 0.5 * 40, TempBuff = 0.1 * 40 },
	{ Name = "ShotSpeed",    Flag = CacheFlag.CACHE_SHOTSPEED, Buff = 0.125,  TempBuff = 0.025 },
	{ Name = "MoveSpeed",    Flag = CacheFlag.CACHE_SPEED,     Buff = 0.5,    TempBuff = 0.1 },
	{ Name = "Luck",         Flag = CacheFlag.CACHE_LUCK,      Buff = 0.5,    TempBuff = 0.1 }
}

local ALL_BUFFED_FLAGS = 0
for _, obj in ipairs(statObjs) do
	ALL_BUFFED_FLAGS = ALL_BUFFED_FLAGS | obj.Flag
end

local maxCharges = Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_KEYS_TO_THE_KINGDOM).MaxCharges

local function defaultBuffs()
	local default = {}
	for i = 1, #statObjs do
		default[i] = 0
	end

	return default
end


Mod:SavePlayerData({
	KTTKBuffs = defaultBuffs,
	KTTKTempBuffs = Mod.SaveNil,
})

-- Blacklisted enemies --
local function KTTKignores(enemy)
	if not (
			(enemy.Type == EntityType.ENTITY_VIS and enemy.Variant == 22)
			or (enemy.Type == EntityType.ENTITY_GEMINI and enemy.Variant == 20)
			or (enemy.Type == EntityType.ENTITY_GRUB and enemy.Parent ~= nil)
			or enemy.Type == EntityType.ENTITY_BLOOD_PUPPY
			or ((enemy.Type == EntityType.ENTITY_MRMAW or enemy.Type == EntityType.ENTITY_SWINGER or enemy.Type == EntityType.ENTITY_HOMUNCULUS
				or enemy.Type == EntityType.ENTITY_BEGOTTEN or enemy.Type == EntityType.ENTITY_MR_MINE or enemy.Type == EntityType.ENTITY_BIG_BONY
				or enemy.Type == EntityType.ENTITY_EVIS or enemy.Type == EntityType.ENTITY_VISAGE) and enemy.Variant == 10)
		) then
		return true
	end
end

-- Determine effect --
function Mod:UseKTTK(_, _, player, _, slot, _)
	local data = Mod:GetData(player)
	local room = game:GetRoom()
	local roomType = room:GetType()
	local hasSpareTarget = false
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		SpareTimeOffset = 30 * 15
	else
		SpareTimeOffset = 0
	end

	-- Free Devil items
	if roomType == RoomType.ROOM_DEVIL then
		-- TODO: only make one item takeable
		player:UseCard(Card.CARD_CREDIT, 257)

		-- Get key piece / random item in Angel room
	elseif roomType == RoomType.ROOM_ANGEL then
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1) then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE,
				CollectibleType.COLLECTIBLE_KEY_PIECE_1, Isaac.GetFreeNearPosition(room:GetCenterPos(), 0), Vector.Zero,
				player)
		elseif not player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2) then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE,
				CollectibleType.COLLECTIBLE_KEY_PIECE_2, Isaac.GetFreeNearPosition(room:GetCenterPos(), 0), Vector.Zero,
				player)
		else -- Random item
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 0,
				Isaac.GetFreeNearPosition(room:GetCenterPos(), 0), Vector.Zero, player)
		end

		-- Give the charge back if the room is cleared
	elseif room:GetAliveEnemiesCount() == 0 then
		return { Discharge = false, ShowAnim = false, Remove = false }
	else
		-- Give Holy Mantle effect in final boss rooms and don't do anything else
		if finalBossIDs[room:GetBossID()]
			or #Isaac.FindByType(EntityType.ENTITY_DOGMA) > 0
			or #Isaac.FindByType(EntityType.ENTITY_BEAST) > 0
		then
			player:UseCard(Card.CARD_HOLY, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
			return true
		end

		local buffs = data.KTTKTempBuffs
		if buffs == nil then
			buffs = defaultBuffs()
			data.KTTKTempBuffs = buffs
		end

		for _, enemy in pairs(Isaac.GetRoomEntities()) do
			if enemy:IsActiveEnemy(false) and not enemy:IsInvincible() then -- This makes stonies and other fuckers not get spared so don't change it :)
				-- Spare timer for bosses
				if enemy:IsBoss() then
					local enemyData = Mod:GetData(enemy)
					if hasSpareTarget == false
						and ((enemy.Type ~= EntityType.ENTITY_LARRYJR
							and enemy.Type ~= EntityType.ENTITY_CHUB
							and enemy.Type ~= EntityType.ENTITY_PIN
							and enemy.Type ~= EntityType.ENTITY_TURDLET
						) or enemy.Parent == nil
						) and not enemyData.spareTimer
					then
						enemyData.spareTimer = spareTime - SpareTimeOffset

						-- Spotlight
						if not enemyData.spareSpotlight then
							local spareSpotlight = Isaac.Spawn(EntityType.ENTITY_EFFECT, 7887, 200, enemy.Position,
								Vector.Zero, nil):ToEffect()
							spareSpotlight = Isaac.Spawn(EntityType.ENTITY_EFFECT, 7887, 200, enemy.Position, Vector
							.Zero, nil):ToEffect()
							spareSpotlight:GetSprite():Play("LightAppear", true)
							spareSpotlight.Parent = enemy
							spareSpotlight:FollowParent(enemy)
							spareSpotlight:GetSprite().Scale = Vector(0.75 + (spareTime - SpareTimeOffset) * 0.001, 1.25)
							enemyData.spareSpotlight = spareSpotlight
						end
						hasSpareTarget = true
					end


					-- Spare regular enemies
				elseif KTTKignores(enemy) == true then
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.GROUND_GLOW, 0, enemy.Position, Vector.Zero, nil):ToEffect():GetSprite().PlaybackSpeed = 0.1
					Isaac.Spawn(EntityType.ENTITY_EFFECT, 7887, 100, enemy.Position, Vector.Zero, nil):ToEffect()

					-- Remove segments if needed
					if enemy.Type == EntityType.ENTITY_GRUB then
						for i, segments in pairs(Isaac.GetRoomEntities()) do
							if segments.Type == enemy.Type and segments.Variant == enemy.Variant and segments:HasCommonParentWithEntity(enemy.Child) then
								segments:Remove()
							end
						end
					else
						enemy:Remove()
					end

					-- Give stats
					local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_KEYS_TO_THE_KINGDOM)
					local buffChoice = rng:RandomInt(#statObjs) + 1
					buffs[buffChoice] = buffs[buffChoice] + 1
				end
			end
		end

		player:AddCacheFlags(ALL_BUFFED_FLAGS)
		player:EvaluateItems()
	end

	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, Mod.UseKTTK, CollectibleType.COLLECTIBLE_KEYS_TO_THE_KINGDOM)

-- Stats --
function Mod:KTTKbuffs(player, flag)
	local data = Mod:GetData(player)
	if data.KTTKBuffs == nil then return end

	for i, buffCount in ipairs(data.KTTKBuffs) do
		local stat = statObjs[i]

		if stat.Flag == flag then
			player[stat.Name] = player[stat.Name] + buffCount * stat.Buff
			break
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.KTTKbuffs)

function Mod:KTTKTempbuffs(player, flag)
	local data = Mod:GetData(player)
	if data.KTTKTempBuffs == nil then return end

	for i, buffCount in ipairs(data.KTTKTempBuffs) do
		local stat = statObjs[i]

		if stat.Flag == flag then
			player[stat.Name] = player[stat.Name] + buffCount * stat.TempBuff
			break
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.KTTKTempbuffs)

local ignoreRemoveTBuffs = false
function Mod:IgnoreRemoveTBuffsOnGameStart()
	ignoreRemoveTBuffs = true
end

Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Mod.IgnoreRemoveTBuffsOnGameStart)

function Mod:removeKTTKTbuffs()
	if ignoreRemoveTBuffs then
		ignoreRemoveTBuffs = false
		return
	end

	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = Mod:GetData(player)

		data.KTTKTempBuffs = nil

		player:AddCacheFlags(ALL_BUFFED_FLAGS)
		player:EvaluateItems()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Mod.removeKTTKTbuffs)

-- Spawn souls --
function Mod:kttkKills(entity)
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)

		if player:HasCollectible(CollectibleType.COLLECTIBLE_KEYS_TO_THE_KINGDOM) then
			if entity:IsBoss() then -- Bosses always give a soul with 3 charges
				Isaac.Spawn(EntityType.ENTITY_EFFECT, 7887, 1, entity.Position, Vector.Zero, player):ToEffect()
			elseif entity:IsActiveEnemy(true) and KTTKignores(entity) == true and not entity:IsInvincible() then
				local kttkRNG = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_KEYS_TO_THE_KINGDOM)

				if (kttkRNG:RandomInt(100) + 1) <= (entity.MaxHitPoints * 2.5) then -- Regular enemies have a chance to give a soul based on their Max HP
					Isaac.Spawn(EntityType.ENTITY_EFFECT, 7887, 0, entity.Position, Vector.Zero, player):ToEffect()
				end
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Mod.kttkKills)

-- Effects --
function Mod:EnemySouls(effect)
	local sprite = effect:GetSprite()

	-- Soul charge
	if effect.SubType == 0 or effect.SubType == 1 then
		local suffix = ""
		local charges = 1
		if effect.SubType == 1 then
			suffix = "Boss"
			charges = 3
		end

		if not sprite:IsPlaying("Move" .. suffix) then
			sprite:Play("Move" .. suffix, true)
		end
		sprite.Offset = Vector(0, -14)


		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			local data = Mod:GetData(player)

			effect.Velocity = (effect.Velocity + (((player.Position - effect.Position):Normalized() * 20) - effect.Velocity) * 0.4)
			sprite.Rotation = effect.Velocity:GetAngleDegrees() + 90

			-- Collect soul
			if effect.Position:DistanceSquared(player.Position) < 400 then
				data.Soul = true
				effect:Remove()
			end


			-- Get charge from soul
			if data.Soul == true then
				local slot = nil
				if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == CollectibleType.COLLECTIBLE_KEYS_TO_THE_KINGDOM then
					slot = ActiveSlot.SLOT_PRIMARY
				elseif player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) == CollectibleType.COLLECTIBLE_KEYS_TO_THE_KINGDOM then
					slot = ActiveSlot.SLOT_SECONDARY
				elseif player:GetActiveItem(ActiveSlot.SLOT_POCKET) == CollectibleType.COLLECTIBLE_KEYS_TO_THE_KINGDOM then
					slot = ActiveSlot.SLOT_POCKET
				end

				if slot ~= nil then
					if player:GetActiveCharge(slot) < maxCharges then
						local newCharges = math.min(player:GetActiveCharge(slot) + charges, maxCharges)
						player:SetActiveCharge(newCharges, slot)
						game:GetHUD():FlashChargeBar(player, slot)
						SFXManager():Play(SoundEffect.SOUND_BEEP)

						-- Play charged sound if soul charges it to max
						if player:GetActiveCharge(slot) >= maxCharges then
							SFXManager():Play(SoundEffect.SOUND_BATTERYCHARGE)
						end
					else
						game:GetHUD():FlashChargeBar(player, slot)
						SFXManager():Play(SoundEffect.SOUND_BATTERYCHARGE)
					end

					player:SetColor(Color(1, 1, 1, 1, 0.25, 0.25, 0.25), 5, 1, true, false)
					SFXManager():Play(SoundEffect.SOUND_SOUL_PICKUP)
				end

				data.Soul = false
			end
		end


		-- Rising soul
	elseif effect.SubType == 100 or effect.SubType == 101 then
		local suffix = ""
		local soundID = SoundEffect.SOUND_HOLY
		if effect.SubType == 101 then
			suffix = "Boss"
			soundID = SoundEffect.SOUND_DOGMA_ANGEL_TRANSFORM_END
		end

		if not sprite:IsPlaying("Spared" .. suffix) then
			sprite:Play("Spared" .. suffix, true)
		end
		if sprite:IsEventTriggered("Sound") then
			SFXManager():Play(soundID, 1.2)
		end


		-- Spotlight
	elseif effect.SubType == 200 then
		if not effect.Parent and not sprite:IsPlaying("LightDisappear") then
			sprite:Play("LightDisappear", true)
		end
	end


	-- Works on both spotlights and rising souls
	if sprite:IsEventTriggered("Remove") then
		effect:Remove()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Mod.EnemySouls, 7887)

-- Sparing --
function Mod:spareTimer(entity)
	if entity:IsBoss() then
		local data = Mod:GetData(entity)

		-- Timer
		if data.spareTimer then
			data.spareSpotlight.DepthOffset = entity.DepthOffset - 1

			if data.spareTimer <= 0 then
				data.spared = true
				data.spareTimer = nil
			else
				-- Shrink spotlight, whiten boss
				data.spareTimer = data.spareTimer - 1
				data.whiteColoring = 0.45 - (data.spareTimer / 2000)

				data.spareSpotlight:GetSprite().Scale = Vector(0.75 + data.spareTimer * 0.001, 1.25)
				entity:SetColor(Color(1, 1, 1, 1, data.whiteColoring, data.whiteColoring, data.whiteColoring), 5, 1, true,
					false)

				-- Extra coloring right before sparing
				if data.spareTimer <= 3 then
					entity:SetColor(Color(1, 1, 1, 1, 10, 10, 10), 5, 1, true, false)
				elseif data.spareTimer <= 5 then
					entity:SetColor(Color(1, 1, 1, 1, 0.75, 0.75, 0.75), 5, 1, true, false)
				end

				-- Tint body segments
				if entity.Type == EntityType.ENTITY_LARRYJR or entity.Type == EntityType.ENTITY_CHUB or entity.Type == EntityType.ENTITY_PIN or entity.Type == EntityType.ENTITY_TURDLET then
					for i, segments in pairs(Isaac.GetRoomEntities()) do
						if segments.Type == entity.Type and segments.Variant == entity.Variant and segments:HasCommonParentWithEntity(entity.Child) then
							segments:SetColor(entity:GetSprite().Color, 5, 1, true, false)
						end
					end
				end
			end


			-- Spared
		elseif data.spared == true then
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.GROUND_GLOW, 0, entity.Position, Vector.Zero, nil):ToEffect():GetSprite().PlaybackSpeed = 0.1
			Isaac.Spawn(EntityType.ENTITY_EFFECT, 7887, 101, entity.Position, Vector.Zero, nil):ToEffect()
			data.spareSpotlight:GetSprite():Play("LightDisappear", true)
			SFXManager():Play(SoundEffect.SOUND_DOGMA_GODHEAD, 0.75, 0, false, 1.1, 0)

			-- CUNT
			if entity.Type == EntityType.ENTITY_LARRYJR or entity.Type == EntityType.ENTITY_CHUB or entity.Type == EntityType.ENTITY_PIN or entity.Type == EntityType.ENTITY_TURDLET
				or (entity.Type == EntityType.ENTITY_GEMINI and entity.Variant == 0) then
				local checkVar = entity.Variant
				if entity.Type == EntityType.ENTITY_GEMINI then
					checkVar = 20
				end

				for _, removee in pairs(Isaac.GetRoomEntities()) do
					if removee.Type == entity.Type and removee.Variant == checkVar and removee:HasCommonParentWithEntity(entity.Child) then
						removee:Remove()
					end
				end
			end

			-- Properly kill the boss without playing the death animation (just removing it causes certain things to not work)
			entity:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
			entity:Die()
			entity:GetSprite():SetFrame("Death", 99)
			entity.Visible = false

			-- Give stats
			for i = 0, game:GetNumPlayers() - 1 do
				local player = Isaac.GetPlayer(i)

				if player:HasCollectible(CollectibleType.COLLECTIBLE_KEYS_TO_THE_KINGDOM) then
					local pdata = Mod:GetData(player)
					local buffs = pdata.KTTKBuffs

					local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_KEYS_TO_THE_KINGDOM)
					local choice1 = rng:RandomInt(#statObjs) + 1
					local choice2
					local choice3
					repeat
						choice2 = rng:RandomInt(#statObjs) + 1
					until choice2 ~= choice1

					buffs[choice1] = buffs[choice1] + 1
					buffs[choice2] = buffs[choice2] + 1
					if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and player:GetName() == "Peter" then
						repeat
							choice3 = rng:RandomInt(#statObjs) + 1
						until choice3 ~= choice2

						buffs[choice3] = buffs[choice3] + 1
					end
					player:AddCacheFlags(ALL_BUFFED_FLAGS)
					player:EvaluateItems()
				end
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, Mod.spareTimer)

-- Reset timer --
function Mod:spareResetBoss(target, damageAmount, damageFlags, damageSource, damageCountdownFrames)
	if target and target:IsBoss() then
		local data = Mod:GetData(target)

		if data.spareTimer then
			if damageSource.Entity and damageSource.Entity.SpawnerEntity then
				if damageSource.Entity.SpawnerEntity.Type ~= target.Type then
					data.spareTimer = spareTime - SpareTimeOffset
					SFXManager():Play(SoundEffect.SOUND_BISHOP_HIT, 1.25)
				end
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Mod.spareResetBoss)

function Mod:spareResetPlayer(target, damageAmount, damageFlags, damageSource, damageCountdownFrames)
	if damageSource.Entity and damageSource.Entity:IsBoss() then
		local spareCancel = false
		local data = nil
		if Mod:GetData(damageSource.Entity).spareTimer then
			data = Mod:GetData(damageSource.Entity)
			spareCancel = true
		elseif damageSource.Entity.SpawnerEntity and Mod:GetData(damageSource.Entity.SpawnerEntity).spareTimer then
			data = Mod:GetData(damageSource.Entity.SpawnerEntity)
			spareCancel = true
		end

		if spareCancel == true then
			data.spareTimer = nil
			data.spareSpotlight:GetSprite():Play("LightDisappear", true)
			data.spareSpotlight = nil
			SFXManager():Play(SoundEffect.SOUND_THUMBS_DOWN, 1.35, 0, false, 0.9, 0)
			SFXManager():Play(SoundEffect.SOUND_BISHOP_HIT, 1.5)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Mod.spareResetPlayer, EntityType.ENTITY_PLAYER)
