local Mod = Furtherance
local CorkPop = Isaac.GetSoundIdByName("Cork")
local tearCount = 0

local corkAnimations = {
	[Direction.NO_DIRECTION] = "Down",
	[Direction.LEFT] = "Side",
	[Direction.UP] = "Up",
	[Direction.RIGHT] = "Side",
	[Direction.DOWN] = "Down",
}

function Mod:CorkTear(tear)
	local player = tear.Parent:ToPlayer()
	if player and player:HasCollectible(CollectibleType.COLLECTIBLE_WINE_BOTTLE) and player:GetPlayerType() ~= PlayerType.PLAYER_THEFORGOTTEN and player:GetPlayerType() ~= PlayerType.PLAYER_THEFORGOTTEN_B then
		if tearCount > 16 then
			tearCount = 0
		elseif tearCount < 17 then
			tearCount = tearCount + 1
		end
		if (16 - player:GetCollectibleNum(CollectibleType.COLLECTIBLE_WINE_BOTTLE, true) < 2 and tearCount == 2) or (tearCount == 16 - player:GetCollectibleNum(CollectibleType.COLLECTIBLE_WINE_BOTTLE, true) and player:GetCollectibleNum(CollectibleType.COLLECTIBLE_WINE_BOTTLE, true) < 15) then
			tearCount = -1
			tear:Remove()
			local Cork = player:FireTear(player.Position, tear.Velocity * (player.ShotSpeed * 1.25), true, false, true,
				player, 2)
			local sprite = Cork:GetSprite()
			sprite:Load("gfx/tear_cork.anm2", true)
			local tearScale = Furtherance:TearScaleToSizeAnim(Cork)
			--Tear size is normally 1-13 but cork only has 1-6, so half it and clamp it
			local sizeAnim = tostring(Mod:Clamp(math.floor(tonumber(tearScale) / 2), 1, 6))
			if tonumber(sizeAnim) > 6 then
				sizeAnim = "6"
			end
			local fireDir = player:GetFireDirection()
			sprite:Play("Tear" .. corkAnimations[fireDir] .. sizeAnim)
			if fireDir == Direction.LEFT then
				Cork.FlipX = true
			end
			SFXManager():Stop(SoundEffect.SOUND_TEARS_FIRE)
			SFXManager():Play(CorkPop, 2)
			Cork.Scale = tear.Scale * 1.5
			Cork:GetData().FR_CorkTear = true
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, Mod.CorkTear)

---@param tear EntityTear
function Mod:CorkTearRotation(tear)
	if tear:GetData().FR_CorkTear then
		tear:GetSprite().Rotation = tear.Velocity:GetAngleDegrees()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, Mod.CorkTearRotation)

local InputHeld = 0
function Mod:ForgorCork(player)
	local b_left = Input.GetActionValue(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex)
	local b_right = Input.GetActionValue(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex)
	local b_up = Input.GetActionValue(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex)
	local b_down = Input.GetActionValue(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex)
	local isAttacking = (b_down + b_right + b_left + b_up) > 0
	if not isAttacking and InputHeld ~= 0 then
		InputHeld = 0
	end
	if isAttacking then
		InputHeld = InputHeld + 1
	end
	if player and player:HasCollectible(CollectibleType.COLLECTIBLE_WINE_BOTTLE) and (player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B) then
		if tearCount > 16 then
			tearCount = 0
		elseif tearCount < 17 and InputHeld == 1 then
			tearCount = tearCount + 1
		end
		if (16 - player:GetCollectibleNum(CollectibleType.COLLECTIBLE_WINE_BOTTLE, true) < 2 and tearCount == 2) or (tearCount == 16 - player:GetCollectibleNum(CollectibleType.COLLECTIBLE_WINE_BOTTLE, true) and player:GetCollectibleNum(CollectibleType.COLLECTIBLE_WINE_BOTTLE, true) < 15) then
			tearCount = -1
			local Cork = player:FireTear(player.Position, player:GetAimDirection() * 10 * (player.ShotSpeed * 1.25), true,
				false, true, player, 2)
			local sprite = Cork:GetSprite()
			SFXManager():Play(CorkPop, 2)
			Cork.Scale = 1.5
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Mod.ForgorCork)

function Mod:ResetCork(continued)
	if continued == false then
		tearCount = 0
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Mod.ResetCork)
