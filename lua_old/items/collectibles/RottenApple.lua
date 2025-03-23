local mod = Furtherance

--removes the player's current trinkets, gives the player the one you provided, uses the smelter, then gives the player back the original trinkets. (kittenchilly's code!)
function mod:AddSmeltedTrinket(player, trinket, firstTimePickingUp)
	--get the trinkets they're currently holding
	local trinket0 = player:GetTrinket(0)
	local trinket1 = player:GetTrinket(1)

	--remove them
	if trinket0 ~= 0 then
		player:TryRemoveTrinket(trinket0)
	end
	if trinket1 ~= 0 then
		player:TryRemoveTrinket(trinket1)
	end

	player:AddTrinket(trinket, firstTimePickingUp == nil and true or firstTimePickingUp)  --add the trinket
	player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, false, false, false) --smelt it

	--give their trinkets back
	if trinket0 ~= 0 then
		player:AddTrinket(trinket0, false)
	end
	if trinket1 ~= 0 then
		player:AddTrinket(trinket1, false)
	end
end

local allWorms = {
	TrinketType.TRINKET_PULSE_WORM,
	TrinketType.TRINKET_WIGGLE_WORM,
	TrinketType.TRINKET_RING_WORM,
	TrinketType.TRINKET_FLAT_WORM,
	TrinketType.TRINKET_HOOK_WORM,
	TrinketType.TRINKET_WHIP_WORM,
	TrinketType.TRINKET_TAPE_WORM,
	TrinketType.TRINKET_LAZY_WORM,
	-- TrinketType.TRINKET_RAINBOW_WORM,
	-- TrinketType.TRINKET_OUROBOROS_WORM,
	TrinketType.TRINKET_BRAIN_WORM,

	-- Modded Worms
	TrinketType.TRINKET_SLICK_WORM,
	TrinketType.TRINKET_HAMMERHEAD_WORM,
}

function mod:GiveWormOnPickUp(player)
	local data = mod:GetData(player)
	if player.QueuedItem.Item
		and not player.QueuedItem.Touched
		and player.QueuedItem.Item.ID == CollectibleType.COLLECTIBLE_ROTTEN_APPLE
		and not data.FR_RottenAppleGiveWorm
	then
		data.FR_RottenAppleGiveWorm = true
	elseif not player.QueuedItem.Item and data.FR_RottenAppleGiveWorm then
		local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_ROTTEN_APPLE)
		local chosenWorm = allWorms[rng:RandomInt(#allWorms) + 1]
		mod:AddSmeltedTrinket(player, chosenWorm, true)
		data.FR_RottenAppleGiveWorm = false
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.GiveWormOnPickUp)

function mod:RottenAppleBuffs(player, flag)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_ROTTEN_APPLE) then
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage +
			(2 * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ROTTEN_APPLE, false))
		end
	end
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.RottenAppleBuffs)
