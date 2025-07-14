local Mod = Furtherance
local floor = Mod.math.floor

local WINE_BOTTLE = {}

Furtherance.Item.WINE_BOTTLE = WINE_BOTTLE

WINE_BOTTLE.ID = Isaac.GetItemIdByName("Wine Bottle")

WINE_BOTTLE.SFX = Isaac.GetSoundIdByName("Cork")
WINE_BOTTLE.THRESHOLD = 15

--[[ local corkAnimations = {
	[Direction.NO_DIRECTION] = "Down",
	[Direction.LEFT] = "Side",
	[Direction.UP] = "Up",
	[Direction.RIGHT] = "Side",
	[Direction.DOWN] = "Down",
} ]]

---@param dir Vector
---@param amount integer
---@param owner EntityPlayer | EntityFamiliar
---@param weapon Weapon
function WINE_BOTTLE:CorkTear(dir, amount, owner, weapon)
	local player = Mod:TryGetPlayer(owner)
	if not player or not player:HasCollectible(WINE_BOTTLE.ID) then return end
	local previousNum = weapon:GetNumFired() - amount
	local fireDir = player:GetFireDirection()
	if fireDir == Direction.NO_DIRECTION then
		dir = Mod:DirectionToVector(player:GetHeadDirection())
		fireDir = player:GetHeadDirection()
	end

	if (previousNum % WINE_BOTTLE.THRESHOLD) + amount >= WINE_BOTTLE.THRESHOLD then
		local velocity = Mod:AddTearVelocity(dir, player.ShotSpeed * 12.5, player)
		local cork = player:FireTear(player.Position, velocity, true, false, true, player, 2)
		local sprite = cork:GetSprite()
		sprite:Load("gfx/tear_cork.anm2", true)
		local tearAnim = Furtherance:TearScaleToSizeAnim(cork)
		local data = Mod:GetData(cork)

		--Tear size is normally 1-13 but cork only has 1-6, so half it and clamp it
		local sizeAnim = tostring(Mod:Clamp(floor(tonumber(tearAnim) / 2), 1, 6))
		if tonumber(sizeAnim) > 6 then
			sizeAnim = "6"
		end

		sprite:Play("TearSide" .. sizeAnim)

		Mod.SFXMan:Stop(SoundEffect.SOUND_TEARS_FIRE)
		Mod.SFXMan:Play(WINE_BOTTLE.SFX, 2)
		local tearHitParams = player:GetTearHitParams(weapon:GetWeaponType(), 1.25, 1, player)
		cork.Scale = tearHitParams.TearScale * 1.5
		data.CorkTear = true
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED, WINE_BOTTLE.CorkTear)

---@param tear EntityTear
function WINE_BOTTLE:CorkTearRotation(tear)
	local data = Mod:TryGetData(tear)
	if data and data.CorkTear then
		tear:GetSprite().Rotation = tear.Velocity:GetAngleDegrees()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, WINE_BOTTLE.CorkTearRotation)
