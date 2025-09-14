local Mod = Furtherance

local CHI_RHO = {}

Furtherance.Item.CHI_RHO = CHI_RHO

CHI_RHO.ID = Isaac.GetItemIdByName("Chi Rho")

CHI_RHO.MinLuck = 0
CHI_RHO.MaxLuck = 15
CHI_RHO.MinChance = 0.02
CHI_RHO.MaxChance = 0.15

---A percentage float chance to be used with an RNG object.
---@param player EntityPlayer
function CHI_RHO:GetChance(player)
	local luck = player.Luck
	luck = Mod:Clamp(luck, self.MinLuck, self.MaxLuck)

	local deltaX = self.MaxLuck - self.MinLuck
	local rngRequirement = ((self.MaxChance - self.MinChance) / deltaX) * luck +
		(self.MaxLuck * self.MinChance - self.MinLuck * self.MaxChance) / deltaX

	return rngRequirement
end

---@param dir Vector
---@param amount integer
---@param owner EntityPlayer | EntityFamiliar
---@param weapon Weapon
function CHI_RHO:OnWeaponFire(dir, amount, owner, weapon)
	local player = Mod:TryGetPlayer(owner, {WeaponOwner = true})
	if not player then return end
	if player:GetFireDirection() == Direction.NO_DIRECTION then
		dir = Mod:DirectionToVector(player:GetHeadDirection())
	end

	if player:HasCollectible(CHI_RHO.ID) then
		local rng = player:GetCollectibleRNG(CHI_RHO.ID)
		local timeout = 7 + (3 * (player:GetCollectibleNum(CHI_RHO.ID) - 1))
		for _ = 1, amount do
			if rng:RandomFloat() <= CHI_RHO:GetChance(player) then
				EntityLaser.ShootAngle(LaserVariant.LIGHT_BEAM, owner.Position, dir:GetAngleDegrees(), timeout, player:GetLaserOffset(LaserOffset.LASER_BRIMSTONE_OFFSET, dir), owner)
				break
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED, CHI_RHO.OnWeaponFire)