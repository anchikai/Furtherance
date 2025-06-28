local Mod = Furtherance

local REBOUND_WORM = {}

Furtherance.Trinket.REBOUND_WORM = REBOUND_WORM

REBOUND_WORM.ID = Isaac.GetTrinketIdByName("Rebound Worm")

---@param tearorBomb EntityTear | EntityBomb
---@param gridEnt GridEntity?
function REBOUND_WORM:PreTearAndBombCollision(tearorBomb, gridIndex, gridEnt)
	local player = tearorBomb.SpawnerEntity and tearorBomb.SpawnerEntity:ToPlayer()
	if gridEnt and player and player:HasTrinket(REBOUND_WORM.ID) then
		local data = Mod:GetData(tearorBomb)
		if data.SlickWormBounced then
			return
		end
		local dir = tearorBomb.Velocity:Rotated(180)
		--Basically take a few steps back before firing in case the tear gets too close into a grid
		local pos = tearorBomb.Position + dir:Resized(10)
		local enemy = Mod:GetClosestEnemyInView(pos, 650, tearorBomb.Velocity:Rotated(180), 90, true,
			true)
		if enemy then
			tearorBomb.Velocity = (enemy.Position - tearorBomb.Position):Resized(tearorBomb.Velocity:Length() * 1.5)
			data.SlickWormBounced = true
			return true
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_TEAR_GRID_COLLISION, REBOUND_WORM.PreTearAndBombCollision)
Mod:AddCallback(ModCallbacks.MC_PRE_BOMB_GRID_COLLISION, REBOUND_WORM.PreTearAndBombCollision)

---@param laser EntityLaser
function REBOUND_WORM:LaserUpdate(laser)
	local data = Mod:TryGetData(laser)
	if data and data.SlickWormLaserParent then
		if not data.SlickWormLaserParent.Ref then
			laser:Remove()
		end
		return
	end
	if (laser.SubType ~= LaserSubType.LASER_SUBTYPE_LINEAR
		or not laser:IsSampleLaser())
		or laser.Timeout <= 0
	then
		return
	end
	local player = laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer()
	if player and player:HasTrinket(REBOUND_WORM.ID) and (not Mod:HasBitFlags(player.TearFlags, TearFlags.TEAR_BOUNCE) or laser.BounceLaser) then
		local samples = laser:GetSamples()
		local endPoint = samples:Get(#samples - 1)
		data = Mod:GetData(laser)
		local slickLaserRef = data.SlickWormLaser
		local slickLaserEnt = slickLaserRef and slickLaserRef.Ref and slickLaserRef.Ref:ToLaser()
		if slickLaserEnt then
			slickLaserEnt.Position = endPoint
			slickLaserEnt.Timeout = laser.Timeout
			slickLaserEnt.MaxDistance = laser.MaxDistance
		end
		local vecAngle = Vector.FromAngle(laser.AngleDegrees)
		local referencePos = endPoint - vecAngle:Resized(20)
		if Mod.Room():GetGridIndex(referencePos) ~= -1 then
			local enemy = Mod:GetClosestEnemyInView(endPoint, nil, vecAngle:Rotated(180), 90,
				false, false)
			if enemy and not slickLaserEnt then
				local dir = (enemy.Position - endPoint)
				local slickLaser
				if laser.Variant == LaserVariant.THIN_RED then
					slickLaser = player:FireTechLaser(endPoint, LaserOffset.LASER_SHOOP_OFFSET, dir, false, false, player, laser:GetDamageMultiplier())
				else
					slickLaser = player:FireBrimstone(dir, player, laser:GetDamageMultiplier())
				end
				slickLaser.Timeout = laser.Timeout
				slickLaser.DisableFollowParent = true
				slickLaser.Position = endPoint
				slickLaser.Parent = laser
				slickLaser.MaxDistance = laser.MaxDistance
				Mod:GetData(slickLaser).SlickWormLaserParent = EntityPtr(laser)
				data.SlickWormLaser = EntityPtr(slickLaser)
			elseif enemy and slickLaserEnt then
				local angle = (enemy.Position - slickLaserEnt.Position):GetAngleDegrees()
				slickLaserEnt.AngleDegrees = Mod:LerpAngleDegrees(slickLaserEnt.AngleDegrees, angle, 0.1)
			end
		elseif slickLaserEnt then
			slickLaserEnt:Remove()
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, REBOUND_WORM.LaserUpdate)
