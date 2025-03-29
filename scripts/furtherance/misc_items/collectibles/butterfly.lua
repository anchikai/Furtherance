local Mod = Furtherance

local BUTTERFLY = {}

Furtherance.Item.BUTTERFLY = BUTTERFLY

BUTTERFLY.ID = Isaac.GetItemIdByName("Butterfly")

---@param ent Entity
function BUTTERFLY:ButterflyDamage(ent)
	local player = ent:ToPlayer()
	---@cast player EntityPlayer
	local data = Mod:GetData(player)

	if player:HasCollectible(BUTTERFLY.ID) then
		data.ButterflyTears = 60 * player:GetCollectibleNum(BUTTERFLY.ID)
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, BUTTERFLY.ButterflyDamage, EntityType.ENTITY_PLAYER)

function BUTTERFLY:FireButterflyTears(player)
	local data = Mod:GetData(player)
	if player and player:HasCollectible(BUTTERFLY.ID) then
		local rng = player:GetCollectibleRNG(BUTTERFLY.ID)
		if data.ButterflyTears == nil then
			data.ButterflyTears = 0
		elseif data.ButterflyTears > 0 then
			data.ButterflyTears = data.ButterflyTears - 1
			if data.ButterflyTears % 2 == 0 then
				player:FireTear(player.Position, RandomVector():Resized(10), true, true, true, player, 0.5)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, BUTTERFLY.FireButterflyTears)
