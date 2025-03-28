local Mod = Furtherance
local game = Game()

COSTUME_PETER_A_DRIP = Isaac.GetCostumeIdByPath("gfx/characters/Character_002_Peter_Drip.anm2")
COSTUME_PETER_B_DRIP = Isaac.GetCostumeIdByPath("gfx/characters/Character_002b_Peter_Drip.anm2")

function Mod:OnInit(player)
	local data = Mod:GetData(player)
	data.Init = true

	if player:GetPlayerType() == PlayerType.PLAYER_PETER then    -- If the player is Peter it will apply his drip
		player:AddNullCostume(COSTUME_PETER_A_DRIP)
	elseif player:GetPlayerType() == PlayerType.PLAYER_PETER_B then -- Apply different drip for his tainted variant
		player:AddNullCostume(COSTUME_PETER_B_DRIP)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Mod.OnInit)

function Mod:GivePeterItems(player)
	local data = Mod:GetData(player)
	if not data.Init then return end

	if player:GetPlayerType() == PlayerType.PLAYER_PETER then
		if player.FrameCount == 1 and not Mod.IsContinued then
			player:AddTrinket(TrinketType.TRINKET_ALABASTER_SCRAP, true)
			player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_KEYS_TO_THE_KINGDOM, ActiveSlot.SLOT_POCKET, false)
		elseif player.FrameCount > 1 then
			data.Init = nil
		end
	elseif player:GetPlayerType() == PlayerType.PLAYER_PETER_B then
		if player.FrameCount == 1 and not Mod.IsContinued then
			player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_MUDDLED_CROSS, ActiveSlot.SLOT_POCKET, false)
		elseif player.FrameCount > 1 then
			data.Init = nil
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Mod.GivePeterItems)

function Mod:PeterUpdate(player)
	if player:GetPlayerType() == PlayerType.PLAYER_PETER_B then
		if player:GetSoulHearts() > 0 then
			player:AddSoulHearts(-player:GetSoulHearts())
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Mod.PeterUpdate)

function Mod:PeterStats(player, flag)
	if player:GetPlayerType() == PlayerType.PLAYER_PETER then
		if flag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed - 0.25
		end
		if flag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay + 8.69999981
		end
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage - 0.5
		end
		if flag == CacheFlag.CACHE_RANGE then
			player.TearRange = player.TearRange + 20
		end
	elseif player:GetPlayerType() == PlayerType.PLAYER_PETER_B then
		if flag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck - 1
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.PeterStats)

function Mod:Hearts(entity, collider)
	if collider:ToPlayer() then
		local player = collider:ToPlayer()
		local data = Mod:GetData(player)
		if player:GetPlayerType() == PlayerType.PLAYER_PETER_B then -- Prevent Tainted Peter from obtaining Non-Red Health
			if entity.SubType == HeartSubType.HEART_SOUL or entity.SubType == HeartSubType.HEART_HALF_SOUL or entity.SubType == HeartSubType.HEART_BLACK then
				return false
			elseif entity.SubType == HeartSubType.HEART_BLENDED then
				if player:GetHearts() < player:GetMaxHearts() + (player:GetBoneHearts() * 2) then
					entity:GetSprite():Play("Collect", true)
					entity:Die()
					SFXManager():Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 0, false)
					SFXManager():Stop(SoundEffect.SOUND_HOLY, 1, 0, false)
					player:AddHearts(2)
				else
					return false
				end
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Mod.Hearts, PickupVariant.PICKUP_HEART)

function Mod:PeterQual(entity)
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == PlayerType.PLAYER_PETER_B then
			local itemConfig = Isaac.GetItemConfig()
			if Mod.Flipped == false then
				if itemConfig:GetCollectible(entity.SubType).Quality > 2 and entity.SubType ~= CollectibleType.COLLECTIBLE_BIRTHRIGHT then
					local price = entity.Price
					entity:Morph(entity.Type, entity.Variant, 0, false, true, false)
					entity.Price = price
					return
				end
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, Mod.PeterQual, PickupVariant.PICKUP_COLLECTIBLE)

function Mod:BloodyTears(tear)
	local player = tear.Parent:ToPlayer()
	if player:GetPlayerType() == PlayerType.PLAYER_PETER_B then
		if tear.Variant == TearVariant.BLUE then
			tear:ChangeVariant(TearVariant.BLOOD)
		elseif tear.Variant == TearVariant.CUPID_BLUE then
			tear:ChangeVariant(TearVariant.CUPID_BLOOD)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, Mod.BloodyTears)

function Mod:ClickerFix(_, _, player)
	player:TryRemoveNullCostume(COSTUME_PETER_A_DRIP)
	player:TryRemoveNullCostume(COSTUME_PETER_B_DRIP)
	if player:GetPlayerType() == PlayerType.PLAYER_PETER then
		player:AddNullCostume(COSTUME_PETER_A_DRIP)
	elseif player:GetPlayerType() == PlayerType.PLAYER_PETER_B then
		player:AddNullCostume(COSTUME_PETER_B_DRIP)
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, Mod.ClickerFix, CollectibleType.COLLECTIBLE_CLICKER)


function Mod:TaintedPeterHome()
	local level = game:GetLevel()
	local room = game:GetRoom()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == PlayerType.PLAYER_PETER and level:GetCurrentRoomIndex() == 94 and level:GetStage() == LevelStage.STAGE8 and Mod.Unlocks.Peter.Tainted ~= true then
			local RememberPocket = player:GetActiveCharge(ActiveSlot.SLOT_POCKET)
			for _, entity in ipairs(Isaac.GetRoomEntities()) do
				if (((entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE)
						or (entity.Type == EntityType.ENTITY_SHOPKEEPER)) and room:IsFirstVisit())
					or (entity.Type == EntityType.ENTITY_SLOT and entity.Variant == 14) then
					entity:Remove()
					player:ChangePlayerType(PlayerType.PLAYER_PETER_B)
					Isaac.Spawn(EntityType.ENTITY_SLOT, 14, 0, entity.Position, Vector.Zero, nil)
					player:ChangePlayerType(PlayerType.PLAYER_PETER)
					player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_KEYS_TO_THE_KINGDOM, ActiveSlot.SLOT_POCKET,
					false)
					player:SetActiveCharge(RememberPocket, ActiveSlot.SLOT_POCKET)
				end
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Mod.TaintedPeterHome)

function Mod:UnlockTaintedPeter(player)
	if player:GetPlayerType() ~= PlayerType.PLAYER_PETER or Mod.Unlocks.Peter.Tainted then return end

	for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_SLOT, 14)) do
		local sprite = entity:GetSprite()
		if sprite:IsFinished("PayPrize") then
			Mod.Unlocks.Peter.Tainted = true
			GiantBookAPI.ShowAchievement("achievement_taintedpeter.png")
			for _, poof in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.POOF01)) do
				poof:Remove()
			end
			break
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Mod.UnlockTaintedPeter)
