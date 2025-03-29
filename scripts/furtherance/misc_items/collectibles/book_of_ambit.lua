local Mod = Furtherance

local BOOK_OF_AMBIT = {}

Furtherance.Item.BOOK_OF_AMBIT = BOOK_OF_AMBIT

BOOK_OF_AMBIT.ID = Isaac.GetItemIdByName("Book of Ambit")

BOOK_OF_AMBIT.GIANTBOOK = Isaac.GetGiantBookIdByName("Book of Ambit")

function BOOK_OF_AMBIT:OnUse(_, _, player)
	ItemOverlay.Show(BOOK_OF_AMBIT.GIANTBOOK, 3, player)
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, BOOK_OF_AMBIT.OnUse, BOOK_OF_AMBIT.ID)

---@param player EntityPlayer
---@param flag CacheFlag
function BOOK_OF_AMBIT:AmbitStats(player, flag)
	local tempEffects = player:GetEffects():GetCollectibleEffectNum(BOOK_OF_AMBIT.ID)
	if tempEffects > 0 then
		if flag == CacheFlag.CACHE_RANGE then
			player.TearRange = player.TearRange + tempEffects * 200
		end
		if flag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed + tempEffects * 1.5
		end
		if flag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_PIERCING
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, BOOK_OF_AMBIT.AmbitStats)

---@param tear EntityTear
function BOOK_OF_AMBIT:UpdateTearVariant(tear)
	local player = Mod:TryGetPlayer(tear)
	if player then
		if player:GetEffects():GetCollectibleEffectNum(BOOK_OF_AMBIT.ID) > 0 then
			local variant = TearVariant.CUPID_BLUE
			if Furtherance:IsBloodTear(tear) then
				variant = TearVariant.CUPID_BLOOD
			end
			tear:ChangeVariant(variant)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, BOOK_OF_AMBIT.UpdateTearVariant)
