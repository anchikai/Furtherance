local Mod = Furtherance

local fluxTearColor = Color(0.1, 0.5, 0.75, 0.75, 0, 0, 0.25)

function Mod:AddFluxTears(tear)
	local data = Mod:GetData(tear)
	if data.AppliedTearFlags == nil then
		data.AppliedTearFlags = {}
	end

	local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
	if player == nil or not player:HasCollectible(CollectibleType.COLLECTIBLE_FLUX) then return end

	if tear.FrameCount ~= 1 or not data.FiredByPlayer or data.AppliedTearFlags.Flux then return end

	data.AppliedTearFlags.Flux = 1

	local extraTear = player:FireTear(tear.Position, -tear.Velocity, true, false, true, player, 1)
	extraTear:SetColor(fluxTearColor, 0, 0, false, false)

	local extraData = Mod:GetData(extraTear)
	extraData.AppliedTearFlags.PharaohCat = data.AppliedTearFlags.PharaohCat
	extraData.AppliedTearFlags.Flux = 2
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, Mod.AddFluxTears)

function Mod:FluxTears(tear)
	local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
	if player == nil then return end

	local data = Mod:GetData(tear)
	if data.AppliedTearFlags.Flux == 1 then
		tear.Velocity = player.Velocity * (2 + player.ShotSpeed * 1.25)
	elseif data.AppliedTearFlags.Flux == 2 then
		tear.Velocity = player.Velocity * (2 + -player.ShotSpeed * 1.25)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, Mod.FluxTears)

function Mod:AddFiredByPlayerField(tear)
	local data = Mod:GetData(tear)
	data.FiredByPlayer = true
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, Mod.AddFiredByPlayerField)

function Mod:FluxFlags(player, flag)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_FLUX) then
		if flag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_SPECTRAL
		end
		if flag == CacheFlag.CACHE_RANGE then
			player.TearRange = player.TearRange + 390
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.FluxFlags)
