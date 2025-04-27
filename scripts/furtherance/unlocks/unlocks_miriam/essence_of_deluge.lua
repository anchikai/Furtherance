local Mod = Furtherance

local ESSENCE_OF_DELUGE = {}

Furtherance.Rune.ESSENCE_OF_DELUGE = ESSENCE_OF_DELUGE

ESSENCE_OF_DELUGE.ID = Isaac.GetCardIdByName("Essence of Deluge")

ESSENCE_OF_DELUGE.SLOW_COLOR = Color(0.5, 0.5, 0.8, 1, 0, 0.04, 0.1)
ESSENCE_OF_DELUGE.SLOW_DURATION = 150
ESSENCE_OF_DELUGE.SLOW_VALUE = 0.5

--TODO: To be reworked

---@param player EntityPlayer
function ESSENCE_OF_DELUGE:OnUse(card, player, flag)
	Isaac.CreateTimer(function ()
		Mod:ForEachEnemy(function(npc)
			local rainDrop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RAIN_DROP, 0,
				npc.Position, Vector.Zero, player):ToEffect()
			rainDrop.Parent = npc
			---@cast rainDrop EntityEffect
			rainDrop:FollowParent(npc)
			local anim = RNG():RandomInt(4)
			rainDrop:GetSprite():Play("Drop0" .. anim)
			Mod:GetData(rainDrop).DelugeRainDrop = true
		end, true)
	end, 15, 10, false)
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, ESSENCE_OF_DELUGE.OnUse, ESSENCE_OF_DELUGE.ID)

---@param effect EntityEffect
function ESSENCE_OF_DELUGE:DamageEnemyOnRaindropEnd(effect)
	local data = Mod:TryGetData(effect)
	if data
		and data.DelugeRainDrop
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
			effect.Parent:AddSlowing(source, ESSENCE_OF_DELUGE.SLOW_DURATION,
				ESSENCE_OF_DELUGE.SLOW_VALUE, ESSENCE_OF_DELUGE.SLOW_COLOR)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, ESSENCE_OF_DELUGE.DamageEnemyOnRaindropEnd,
	EffectVariant.RAIN_DROP)
