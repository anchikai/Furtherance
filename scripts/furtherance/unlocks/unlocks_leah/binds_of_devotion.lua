local Mod = Furtherance

local BINDS_OF_DEVOTION = {}

Furtherance.Item.BINDS_OF_DEVOTION = BINDS_OF_DEVOTION

BINDS_OF_DEVOTION.ID = Isaac.GetItemIdByName("Binds of Devotion")
BINDS_OF_DEVOTION.PLAYER_FAKE_JACOB = Isaac.GetPlayerTypeByName("FR FakeJacob", false)

function BINDS_OF_DEVOTION:AddJacob(player)
	--RGON's method seems to have an odd bug with having their position be the same as it was in the previous room when moving rooms
	--local jacob = PlayerManager.SpawnCoPlayer2(BINDS_OF_DEVOTION.PLAYER_FAKE_JACOB)
	Isaac.ExecuteCommand("addplayer " .. BINDS_OF_DEVOTION.PLAYER_FAKE_JACOB)
	local jacob = Isaac.GetPlayer(Mod.Game:GetNumPlayers() - 1)
	jacob.Parent = player

	Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, jacob.Position, jacob.Velocity, jacob)
	jacob.Position = player.Position
	jacob:PlayExtraAnimation("Appear")
	jacob:AddCostume(Mod.ItemConfig:GetCollectible(BINDS_OF_DEVOTION.ID))
	Mod.HUD:AssignPlayerHUDs()

	return jacob
end

function BINDS_OF_DEVOTION:FakeJacobStats(player, flag)
	if player:GetPlayerType() == BINDS_OF_DEVOTION.PLAYER_FAKE_JACOB then -- If the player is Fake Jacob it will apply his stats
		if flag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay - 1
		end
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage - 0.75
		end
		if flag == CacheFlag.CACHE_RANGE then
			player.TearRange = player.TearRange - 60
		end
		if flag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed + 0.15
		end
		if flag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck + 1
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, BINDS_OF_DEVOTION.FakeJacobStats)

function BINDS_OF_DEVOTION:AddNewJacob(type, charge, firstTime, slot, varData, player)
	if player:HasCollectible(BINDS_OF_DEVOTION.ID) and not player.Parent then
		BINDS_OF_DEVOTION:AddJacob(player)
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, BINDS_OF_DEVOTION.AddNewJacob, BINDS_OF_DEVOTION.ID)

function BINDS_OF_DEVOTION:RemoveJacob(player, itemID)
	Mod.Foreach.Player(function(_player, playerIndex)
		if _player:GetPlayerType() == BINDS_OF_DEVOTION.PLAYER_FAKE_JACOB
			and Mod:IsSameEntity(_player.Parent, player)
			and _player:Exists()
			and not _player:IsDead()
		then
			PlayerManager.RemoveCoPlayer(_player)
			return true
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, BINDS_OF_DEVOTION.RemoveJacob)

function BINDS_OF_DEVOTION:FakobDied(entity)
	local player = entity:ToPlayer()
	if player and player:IsDead() then
		if player:GetPlayerType() == BINDS_OF_DEVOTION.PLAYER_FAKE_JACOB then
			--Find the player that owns the now dead Jacob
			Mod.Foreach.Player(function (_player, index)
				if not _player.Parent and Mod:IsSameEntity(player.Parent, _player) then
					_player:RemoveCollectible(BINDS_OF_DEVOTION.ID)
				end
			end)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, BINDS_OF_DEVOTION.FakobDied, EntityType.ENTITY_PLAYER)
