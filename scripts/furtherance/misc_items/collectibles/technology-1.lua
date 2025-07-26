local Mod = Furtherance

local TECHNOLOGY_MINUS_1 = {}

Furtherance.Item.TECHNOLOGY_MINUS_1 = TECHNOLOGY_MINUS_1

TECHNOLOGY_MINUS_1.ID = Isaac.GetItemIdByName("Technology -1")

TECHNOLOGY_MINUS_1.SPLIT_CHANCE = math.pi * 0.01

---@param ent EntityTear | EntityKnife | EntityBomb
function TECHNOLOGY_MINUS_1:ShootLasers(ent)
	local player = Mod:TryGetPlayer(ent, true)
	if player and player:HasCollectible(TECHNOLOGY_MINUS_1.ID) then
		local rng = player:GetCollectibleRNG(TECHNOLOGY_MINUS_1.ID)
		if (ent:ToKnife() and ent:IsFlying() or ent:ToBomb() and ent.IsFetus or ent:ToTear())
			and rng:RandomFloat() <= TECHNOLOGY_MINUS_1.SPLIT_CHANCE
		then
			local num = player:GetCollectibleNum(TECHNOLOGY_MINUS_1.ID) - 1
			local maxLasers = 3 + num
			local blocked = player:HasCollectible(CollectibleType.COLLECTIBLE_LACHRYPHAGY)
			if not blocked then
				player:BlockCollectible(CollectibleType.COLLECTIBLE_LACHRYPHAGY)
			end
			for _ = 1, maxLasers do
				local laser = player:FireTechLaser(ent.Position, LaserOffset.LASER_TRACTOR_BEAM_OFFSET, RandomVector(), false, true, player, 1)
				laser.PositionOffset = ent.PositionOffset
				laser:GetSprite().Color = player.LaserColor
				Mod:GetData(laser).TechMinus1Laser = true
			end
			if not blocked then
				player:UnblockCollectible(CollectibleType.COLLECTIBLE_LACHRYPHAGY)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, TECHNOLOGY_MINUS_1.ShootLasers)
Mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, TECHNOLOGY_MINUS_1.ShootLasers)
Mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, TECHNOLOGY_MINUS_1.ShootLasers)

---@param laser EntityLaser
function TECHNOLOGY_MINUS_1:LasersShootLasers(laser)
	local player = Mod:TryGetPlayer(laser, true)
	if player
		and player:HasCollectible(TECHNOLOGY_MINUS_1.ID)
		and laser.SubType == LaserSubType.LASER_SUBTYPE_LINEAR
		and laser:IsSampleLaser()
		and laser.Timeout >= 0
	then
		local data = Mod:TryGetData(laser)
		if not data or not data.TechMinus1Laser then
			local rng = player:GetCollectibleRNG(TECHNOLOGY_MINUS_1.ID)
			local pos = Mod:GetLaserEndPoint(laser)
			if not pos then return end
			local rngMult = 1
			if laser.FrameCount == -1
				or player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK)
				or player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK)
				or player.MaxFireDelay <= 1
			then
				rngMult = 3
			end
			if pos and rng:RandomFloat() <= (TECHNOLOGY_MINUS_1.SPLIT_CHANCE * rngMult) then
				local num = player:GetCollectibleNum(TECHNOLOGY_MINUS_1.ID) - 1
				local maxLasers = 3 + num
				local oppositeDir = Vector.FromAngle(laser.AngleDegrees):Rotated(180)
				local blocked = player:HasCollectible(CollectibleType.COLLECTIBLE_LACHRYPHAGY)
				if not blocked then
					player:BlockCollectible(CollectibleType.COLLECTIBLE_LACHRYPHAGY)
				end
				for _ = 1, maxLasers do
					local dir = oppositeDir:Rotated(Mod:RandomNum(-45, 45))
					local techLaser = player:FireTechLaser(pos, LaserOffset.LASER_SHOOP_OFFSET, dir, false, true, player, 1)
					techLaser.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
					techLaser.TearFlags = laser.TearFlags
					techLaser:GetSprite().Color = laser:GetSprite().Color
					Mod:GetData(techLaser).TechMinus1Laser = true
					techLaser.Parent = nil
				end
				if not blocked then
					player:UnblockCollectible(CollectibleType.COLLECTIBLE_LACHRYPHAGY)
				end
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, TECHNOLOGY_MINUS_1.LasersShootLasers)