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
		if data.SlickWormBounced then return end
		local enemy = Mod:GetClosestEnemyInView(tearorBomb.Position, 500, tearorBomb.Velocity:Rotated(180), 90, true,
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
	if laser.SubType ~= LaserSubType.LASER_SUBTYPE_LINEAR then
		return
	end
	local player = laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer()
	if player and player:HasTrinket(REBOUND_WORM.ID) then
		local endPoint = laser:GetEndPoint()
		if Mod.Room():GetGridEntityFromPos(endPoint) then
			local data = Mod:GetData(laser)
			if data.IsSlickWormLaser then
				if laser.Parent and not laser.Parent:Exists() then
					laser:Remove()
				end
				return
			end
			local enemy = Mod:GetClosestEnemyInView(endPoint, nil, Vector.FromAngle(laser.AngleDegrees):Rotated(180), 90,
				false, false)
			if enemy then
				if not data.SlickWormLaser then
					local angle = (enemy.Position - endPoint):GetAngleDegrees()
					local slickLaser = EntityLaser.ShootAngle(laser.Variant, endPoint, angle, laser.Timeout,
					laser.PositionOffset, player)
					for name, value in ipairs(getmetatable(laser).__propget) do
						if not string.find(name, "Angle") then
							slickLaser[name] = value(laser)
						end
					end
					slickLaser.Parent = laser
					slickLaser.DisableFollowParent = true
					Mod:GetData(slickLaser).IsSlickWormLaser = true
					data.SlickWormLaser = slickLaser
				end
				if data.SlickWormLaser:Exists() then
					local angle = (enemy.Position - data.SlickWormLaser.Position):GetAngleDegrees()
					data.SlickWormLaser.AngleDegrees = angle
					data.SlickWormLaser.Position = endPoint
				end
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, REBOUND_WORM.LaserUpdate)
