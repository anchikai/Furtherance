local Mod = Furtherance

local FLUX = {}

Furtherance.Item.FLUX = FLUX

FLUX.ID = Isaac.GetItemIdByName("Flux")

FLUX.TEAR_COLOR = Color(0.1, 0.5, 0.75, 0.75, 0, 0, 0.25)
FLUX.RANGE_UP = 9.75

---@param dir Vector
---@param amount integer
---@param owner EntityPlayer | EntityFamiliar
---@param weapon Weapon
function FLUX:OnWeaponFire(dir, amount, owner, weapon)
	local player = Mod:TryGetPlayer(owner)
	---@cast player EntityPlayer
	if player:HasCollectible(FLUX.ID) then
		if player:GetFireDirection() == Direction.NO_DIRECTION then
			dir = Mod:DirectionToVector(player:GetHeadDirection())
		end
		local velocity = Mod:AddTearVelocity(dir, player.ShotSpeed, player)
		local tear = player:FireTear(player.Position, velocity, true, false, true, player, 1)
		tear:SetColor(FLUX.TEAR_COLOR, -1, 1, false, true)
		Mod:GetData(tear).BackwardsFluxTear = true
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED, FLUX.OnWeaponFire)

---@param tear EntityTear
function FLUX:ManageTearVelocity(tear)
	local player = Mod:TryGetPlayer(tear)
	if not player then return end

	local data = Mod:GetData(tear)
	if not data.BackwardsFluxTear and player:HasCollectible(FLUX.ID) then
		tear.Velocity = player.Velocity * (2 + player.ShotSpeed * 1.25)
	elseif data.BackwardsFluxTear then
		tear.Velocity = -player.Velocity * (2 + player.ShotSpeed * 1.25)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, FLUX.ManageTearVelocity)

---@param player EntityPlayer
---@param flag CacheFlag
function FLUX:FluxStats(player, flag)
	if player:HasCollectible(FLUX.ID) then
		if flag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_SPECTRAL
		elseif flag == CacheFlag.CACHE_RANGE then
			player.TearRange = player.TearRange + (FLUX.RANGE_UP * 40)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, FLUX.FluxStats)
