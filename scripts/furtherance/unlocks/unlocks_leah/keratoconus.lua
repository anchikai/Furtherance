local Mod = Furtherance

local KERATOCONUS = {}

Furtherance.Item.KERATOCONUS = KERATOCONUS

KERATOCONUS.ID = Isaac.GetItemIdByName("Keratoconus")

KERATOCONUS.SHOTSPEED_DOWN = 0.15
KERATOCONUS.RANGE_UP = 2 * Mod.RANGE_BASE_MULT

KERATOCONUS.MIN_SIZE_DISTANCE = 100
KERATOCONUS.MAX_SIZE_DISTANCE = 300

---@param player EntityPlayer
---@param flag CacheFlag
function KERATOCONUS:KeratoconusBuffs(player, flag)
	if not player:HasCollectible(KERATOCONUS.ID) then return end
	local numItems = player:GetCollectibleNum(KERATOCONUS.ID)
	if flag == CacheFlag.CACHE_SHOTSPEED then
		player.ShotSpeed = player.ShotSpeed - KERATOCONUS.SHOTSPEED_DOWN - ((numItems - 1) * KERATOCONUS.SHOTSPEED_DOWN * 0.5)
	elseif flag == CacheFlag.CACHE_RANGE then
		player.TearRange = player.TearRange + KERATOCONUS.RANGE_UP * numItems
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, KERATOCONUS.KeratoconusBuffs, CacheFlag.CACHE_SHOTSPEED)
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, KERATOCONUS.KeratoconusBuffs, CacheFlag.CACHE_RANGE)

---@param npc EntityNPC
function KERATOCONUS:GetClosestKeratoconusPlayer(npc)
	local closestPlayer
	local closestDist
	Mod.Foreach.Player(function(player)
		local dist = player.Position:DistanceSquared(npc.Position)
		if player:HasCollectible(KERATOCONUS.ID)
			and (not closestDist or dist < closestDist)
		then
			closestDist = dist
			closestPlayer = player
		end
	end)
	return closestPlayer
end

function KERATOCONUS:OnCollectibleRemove()
	if not PlayerManager.AnyoneHasCollectible(KERATOCONUS.ID) then
		Mod.Foreach.Entity(function (ent, index)
			local npc = ent:ToNPC()
			if npc and npc:IsActiveEnemy(false) and not npc:IsBoss() then
				local data = Mod:GetData(npc)
				if data.KeratoconusOriginalVars then
					npc:SetSize(data.KeratoconusOriginalVars[1], data.KeratoconusOriginalVars[2], 16)
					npc.Scale = data.KeratoconusOriginalVars[3]
					npc:SetSpeedMultiplier(data.KeratoconusOriginalVars[4])
				end
			end
		end)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, KERATOCONUS.OnCollectibleRemove, KERATOCONUS.ID)

---@param npc EntityNPC
function KERATOCONUS:SizeChanging(npc)
	if not npc:IsBoss()
		and not PlayerManager.AnyoneHasCollectible(KERATOCONUS.ID)
		and not npc:HasEntityFlags(EntityFlag.FLAG_SHRINK)
		and npc:IsActiveEnemy(false)
	then
		local player = KERATOCONUS:GetClosestKeratoconusPlayer(npc)
		local curDist = npc.Position:Distance(player.Position)
		local distMult = Mod:Clamp(
		(curDist - KERATOCONUS.MIN_SIZE_DISTANCE) / (KERATOCONUS.MAX_SIZE_DISTANCE - KERATOCONUS.MIN_SIZE_DISTANCE), 0, 1)
		local size = 1 + distMult
		local speed = 1 + -(distMult * 0.5)
		local data = Mod:GetData(npc)
		if not data.KeratoconusOriginalVars then
			data.KeratoconusOriginalVars = { npc.Size, npc.SizeMulti, npc.Scale, npc:GetSpeedMultiplier() }
		end
		npc:SetSize(data.KeratoconusOriginalVars[1] * size, Vector.One, 16)
		npc.Scale = size
		if npc:GetSpeedMultiplier() >= 1 and speed == 1 then return end
		npc:SetSpeedMultiplier(speed)
	end
end

Mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, KERATOCONUS.SizeChanging)
