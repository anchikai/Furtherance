local Mod = Furtherance

local ESSENCE_OF_PROSPERITY = {}

Furtherance.Rune.ESSENCE_OF_PROSPERITY = ESSENCE_OF_PROSPERITY

ESSENCE_OF_PROSPERITY.ID = Isaac.GetCardIdByName("Essence of Prosperity")

ESSENCE_OF_PROSPERITY.SLOW_COLOR = Color(0.5, 0.5, 0.8, 1, 0, 0.04, 0.1)
ESSENCE_OF_PROSPERITY.SLOW_DURATION = 150
ESSENCE_OF_PROSPERITY.SLOW_VALUE = 0.5

--TODO: Idk seems kinda...weak? Necronomicon deals a guaranteed 40. Continuous raindrops over every enemy sounds cool.

---@param player EntityPlayer
function ESSENCE_OF_PROSPERITY:OnUse(card, player, flag)
	Mod:ForEachEnemy(function(npc)
		if npc:IsVulnerableEnemy() then
			local rainDrop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RAIN_DROP, 0, npc.Position, Vector.Zero, player):ToEffect()
			rainDrop.Parent = npc
			---@cast rainDrop EntityEffect
			rainDrop:FollowParent(npc)
			local anim = Mod.GENERIC_RNG:RandomInt(4) + 1
			rainDrop:GetSprite():Play("Drop0" .. anim)
			Mod:GetData(rainDrop).ProsperityRainDrop = true
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, ESSENCE_OF_PROSPERITY.OnUse, ESSENCE_OF_PROSPERITY.ID)

---@param effect EntityEffect
function ESSENCE_OF_PROSPERITY:DamageEnemyOnRaindropEnd(effect)
	local data = Mod:TryGetData(effect)
	if data
		and data.ProsperityRainDrop
		and effect.Parent
		and effect.Parent:Exists()
	then
		local player = effect.SpawnerEntity and effect.SpawnerEntity:ToPlayer()
		if not player then return end
		local source = EntityRef(player)
		local sprite = effect:GetSprite()
		effect.Position = effect.Parent.Position
		if sprite:GetFrame() == 14 then
			effect.Parent:TakeDamage(player.Damage * 0.66, 0, source, 0)
			effect.Parent:AddSlowing(source, ESSENCE_OF_PROSPERITY.SLOW_DURATION, ESSENCE_OF_PROSPERITY.SLOW_VALUE, ESSENCE_OF_PROSPERITY.SLOW_COLOR)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, ESSENCE_OF_PROSPERITY.DamageEnemyOnRaindropEnd, EffectVariant.RAIN_DROP)
