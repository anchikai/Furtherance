local Mod = Furtherance

local SOUL_OF_MIRIAM = {}

Furtherance.Rune.SOUL_OF_MIRIAM = SOUL_OF_MIRIAM

SOUL_OF_MIRIAM.ID = Isaac.GetCardIdByName("Soul of Miriam")
SOUL_OF_MIRIAM.NULL_ID = Isaac.GetNullItemIdByName("soul of miriam")

function SOUL_OF_MIRIAM:SpawnExpandingCreep()
	local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 0,
		Mod.Room():GetCenterPos(), Vector.Zero, nil):ToEffect()
	---@cast creep EntityEffect
	creep:SetTimeout(-1)
	creep:Update()
	Mod:GetData(creep).SoulOfMiriamCreep = true
end

---@param card Card
---@param player EntityPlayer
---@param flags UseFlag
function SOUL_OF_MIRIAM:OnUse(card, player, flags)
	Mod.Room():GetEffects():AddNullEffect(SOUL_OF_MIRIAM.NULL_ID)
	SOUL_OF_MIRIAM:SpawnExpandingCreep()
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, SOUL_OF_MIRIAM.OnUse, SOUL_OF_MIRIAM.ID)

function SOUL_OF_MIRIAM:OnSOMRoom()
	local effects = Mod.Room():GetEffects()
	if effects:HasNullEffect(SOUL_OF_MIRIAM.NULL_ID) and Mod.Game:GetFrameCount() % 5 == 0 then
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RAIN_DROP, 0, Isaac.GetRandomPosition(), Vector.Zero, nil)
		if not Mod.Room():HasWater() then
			Isaac.CreateTimer(function()
				local room = Mod.Room()
				room:SetWaterAmount(room:GetWaterAmount() + 0.05)
			end, 1, 20, false)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, SOUL_OF_MIRIAM.OnSOMRoom)

function SOUL_OF_MIRIAM:CreepOnNewRoom()
	local effects = Mod.Room():GetEffects()
	if effects:HasNullEffect(SOUL_OF_MIRIAM.NULL_ID) then
		SOUL_OF_MIRIAM:SpawnExpandingCreep()
		if not Mod.Room():HasWater() then
			Mod.Room():SetWaterAmount(1)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, SOUL_OF_MIRIAM.CreepOnNewRoom)

function SOUL_OF_MIRIAM:SOMCreepUpdate(effect)
	local effects = Mod.Room():GetEffects()
	local data = Mod:TryGetData(effect)
	if data and data.SoulOfMiriamCreep then
		if effects:HasNullEffect(SOUL_OF_MIRIAM.NULL_ID) then
			effect.SpriteScale = effect.SpriteScale + Vector(0.01, 0.01)
		else
			effect:SetTimeout(60)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, SOUL_OF_MIRIAM.SOMCreepUpdate, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL)