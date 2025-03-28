local Mod = Furtherance
local game = Game()

local InfHP = false
local HighDamage = 0
local InfCharge = false
local HighLuck = 0
local QuickKill = false
function Mod:UseTilde(_, _, player)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_TILDE_KEY)
	local randomDebug = rng:RandomInt(5)
	local hud = game:GetHUD()
	if randomDebug == 0 then
		hud:ShowFortuneText("Infinite HP")
		InfHP = true
	elseif randomDebug == 1 then
		hud:ShowFortuneText("High Damage")
		HighDamage = 40
	elseif randomDebug == 2 then
		hud:ShowFortuneText("Infinite Item Charges")
		InfCharge = true
	elseif randomDebug == 3 then
		hud:ShowFortuneText("High Luck")
		HighLuck = 50
	else
		hud:ShowFortuneText("Quick Kill")
		QuickKill = true
		for i, entity in ipairs(Isaac.GetRoomEntities()) do
			if entity:IsActiveEnemy(false) and entity:IsVulnerableEnemy() then
				entity:Die()
			end
		end
	end
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	player:AddCacheFlags(CacheFlag.CACHE_LUCK)
	player:EvaluateItems()
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, Mod.UseTilde, CollectibleType.COLLECTIBLE_TILDE_KEY)

function Mod:InfiniteHealth(entity, amount, flag)
	local player = entity:ToPlayer()
	if InfHP and flag & DamageFlag.DAMAGE_FAKE ~= DamageFlag.DAMAGE_FAKE then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR, false, false, true, false, -1)
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Mod.InfiniteHealth, EntityType.ENTITY_PLAYER)

function Mod:InfiniteCharge(_, _, player)
	if InfCharge then
		ItemUsed = true
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, Mod.InfiniteCharge)

function Mod:DebugStats(player, flag)
	if flag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + HighDamage
	end
	if flag == CacheFlag.CACHE_LUCK then
		player.Luck = player.Luck + HighLuck
	end
	if ItemUsed or (InfCharge and (player:NeedsCharge(ActiveSlot.SLOT_PRIMARY) or player:NeedsCharge(ActiveSlot.SLOT_SECONDARY) or player:NeedsCharge(ActiveSlot.SLOT_POCKET))) then
		ItemUsed = false
		player:FullCharge(ActiveSlot.SLOT_PRIMARY, true)
		player:FullCharge(ActiveSlot.SLOT_SECONDARY, true)
		player:FullCharge(ActiveSlot.SLOT_POCKET, true)
		SFXManager():Stop(SoundEffect.SOUND_BATTERYCHARGE)
		SFXManager():Stop(SoundEffect.SOUND_ITEMRECHARGE)
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.DebugStats)

function Mod:ResetDebug()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		InfHP = false
		HighDamage = 0
		InfCharge = false
		HighLuck = 0
		QuickKill = false
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		player:EvaluateItems()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Mod.ResetDebug)
