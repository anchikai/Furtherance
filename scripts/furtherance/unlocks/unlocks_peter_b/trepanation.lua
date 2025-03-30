local Mod = Furtherance

local TREPANATION = {}

Furtherance.Item.TREPANATION = TREPANATION

TREPANATION.ID = Isaac.GetItemIdByName("Trepanation")

TREPANATION.THRESHOLD = 15

---@param dir Vector
---@param amount integer
---@param owner EntityPlayer | EntityFamiliar
---@param weapon Weapon
function TREPANATION:OnWeaponFire(dir, amount, owner, weapon)
	local player = Mod:TryGetPlayer(owner)
	if not player or amount == 0 or not player:HasCollectible(TREPANATION.ID) then return end
	local previousNum = weapon:GetNumFired() - amount
	if player:GetFireDirection() == Direction.NO_DIRECTION then
		dir = Mod:DirectionToVector(player:GetHeadDirection())
	end

	if (previousNum % TREPANATION.THRESHOLD) + amount >= TREPANATION.THRESHOLD then
		local velocity = Mod:AddTearVelocity(dir, player.ShotSpeed * 10, player)
		local tear = player:FireTear(player.Position, velocity, false, false, true, player, 2)
		tear:ChangeVariant(TearVariant.BALLOON)
		tear:AddTearFlags(TearFlags.TEAR_BURSTSPLIT)
		tear.FallingSpeed = tear.FallingSpeed - 20
		tear.FallingAcceleration = tear.FallingAcceleration + 1
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED, TREPANATION.OnWeaponFire)
