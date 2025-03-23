---@param player EntityPlayer
function Furtherance:ShouldFamiliarAutoAim(player)
	local shouldAuto = false
	local playerType = player:GetPlayerType()
	if player:HasCollectible(CollectibleType.COLLECTIBLE_KING_BABY)
		or (playerType == PlayerType.PLAYER_LILITH_B and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT))
	then
		shouldAuto = true
	end
	return shouldAuto
end

---@param familiar EntityFamiliar
---@return Vector shootDir, boolean isAutoAim
function Furtherance:GetFamiliarAimVector(familiar)
	local player = familiar.Player
	local aimVector = Furtherance:DirectionToVector(player:GetFireDirection())
	local isAutoAim = false

	if player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED)
		or player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT)
	then
		local targetAimVector = Furtherance:TryGetMarkedTargetAimVector(player)

		if targetAimVector then
			aimVector = targetAimVector
			isAutoAim = true
		end
	elseif Furtherance:ShouldFamiliarAutoAim(player) then
		local closestEnemy = Furtherance.Character.BLUEBABY.CREEP.SENTIENT:FindClosestEnemy(familiar,
			function(ent) return ent.Position:DistanceSquared(familiar.Position) <= 800 ^ 2 end) --800, roughly, from King Baby and Gello testing
		if closestEnemy then
			isAutoAim = true
			aimVector = (closestEnemy.Position - familiar.Position):Normalized()
		end
	end

	return aimVector, isAutoAim
end
