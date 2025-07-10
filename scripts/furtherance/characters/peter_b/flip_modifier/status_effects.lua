local Mod = Furtherance
local SEL = StatusEffectLibrary
local FLIP = Mod.Character.PETER_B.FLIP

local STATUS_EFFECTS = {}

FLIP.STATUS_EFFECTS = STATUS_EFFECTS

--Highest to lowest, top to bottom
local VANILLA_STATUS_PRIORITY = {
	EntityFlag.FLAG_CHARM,
	EntityFlag.FLAG_BRIMSTONE_MARKED,
	EntityFlag.FLAG_MAGNETIZED,
	EntityFlag.FLAG_BAITED,
	EntityFlag.FLAG_CONFUSION,
	EntityFlag.FLAG_BURN,
	EntityFlag.FLAG_POISON,
	EntityFlag.FLAG_FEAR,
	EntityFlag.FLAG_BLEED_OUT,
	EntityFlag.FLAG_SLOW,
	EntityFlag.FLAG_WEAKNESS
}
local FLAG_TO_ICON = {
	[EntityFlag.FLAG_CHARM] = "Charm",
	[EntityFlag.FLAG_BRIMSTONE_MARKED] = "BrimstoneCurse",
	[EntityFlag.FLAG_MAGNETIZED] = "Magnetize",
	[EntityFlag.FLAG_BAITED] = "Bait",
	[EntityFlag.FLAG_CONFUSION] = "Confuse",
	[EntityFlag.FLAG_BURN] = "Burn",
	[EntityFlag.FLAG_POISON] = "Poison",
	[EntityFlag.FLAG_FEAR] = "Fear",
	[EntityFlag.FLAG_BLEED_OUT] = "BleedingOut",
	[EntityFlag.FLAG_SLOW] = "Slow",
	[EntityFlag.FLAG_WEAKNESS] = "Weakness",
}

STATUS_EFFECTS.STRENGTH_NAME = "FR_STRENGTH"
local statusSprite = Sprite("gfx/ui/fr_statuseffects.anm2", true)
statusSprite:Play("Strength")
local STATUS_COLOR = Color(1, 1, 1, 1, 0.3, 0, 0, 0.2, 0, 0, 0.75)
SEL.RegisterStatusEffect(STATUS_EFFECTS.STRENGTH_NAME, statusSprite, STATUS_COLOR, nil, true)

STATUS_EFFECTS.STRENGTH_FLAG = SEL.StatusFlag[STATUS_EFFECTS.STRENGTH_NAME]

---@param npc EntityNPC
function STATUS_EFFECTS:RenderReflectiveStatusEffects(npc, offset)
	if FLIP.PETER_EFFECTS_ACTIVE
		and not FLIP:ShouldIgnoreEntity(npc)
		and Mod.Room():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT
	then
		local data = Mod:GetData(npc)
		local anim = ""
		for _, statusFlag in ipairs(VANILLA_STATUS_PRIORITY) do
			if npc:HasEntityFlags(statusFlag) then
				anim = FLAG_TO_ICON[statusFlag]
				break
			end
		end
		if anim ~= "" and (not data.PeterFlippedRenderStatus or data.PeterFlippedRenderStatus:GetAnimation() ~= anim) then
			data.PeterFlippedRenderStatus = data.PeterFlippedRenderStatus or Sprite("gfx/statuseffects.anm2")
			data.PeterFlippedRenderStatus:Play(anim)
		end
		local statusOffset = Mod:GetStatusEffectOffset(npc)

		if not data.PeterFlippedRenderStatus or anim == "" or not statusOffset then return end
		local renderPos = Isaac.WorldToRenderPosition(npc.Position + npc.PositionOffset) + offset - statusOffset
		data.PeterFlippedRenderStatus:Render(renderPos)
		if Mod:ShouldUpdateSprite() then
			data.PeterFlippedRenderStatus:Update()
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, STATUS_EFFECTS.RenderReflectiveStatusEffects)

function STATUS_EFFECTS:AllowReflectiveStatusEffects(ent)
	if FLIP.PETER_EFFECTS_ACTIVE
		and not SEL.Utils.IsOpenSegment(ent)
	then
		return true
	end
end

SEL.Callbacks.AddCallback(SEL.Callbacks.ID.PRE_RENDER_STATUS_EFFECTS, STATUS_EFFECTS.AllowReflectiveStatusEffects)

---@param ent Entity
function STATUS_EFFECTS:PreApplyStrength(ent)
	if not (ent:IsActiveEnemy(false)
			and not ent:IsInvincible()
			and not FLIP:ShouldIgnoreEntity(ent)
			and ent:ToNPC()
			and ent:ToNPC().CanShutDoors
		)
	then
		return true
	end
end

SEL.Callbacks.AddCallback(SEL.Callbacks.ID.PRE_ADD_ENTITY_STATUS_EFFECT, STATUS_EFFECTS.PreApplyStrength,
	STATUS_EFFECTS.STRENGTH_FLAG)

---@param ent Entity
---@param amount number
function STATUS_EFFECTS:HalfDamage(ent, amount, flags, source, countdown)
	if not ent:IsActiveEnemy(false) then return end
	local hasStrength = SEL:GetStatusEffectData(ent, STATUS_EFFECTS.STRENGTH_FLAG)
	if hasStrength then
		return { Damage = amount * 0.75 }
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, STATUS_EFFECTS.HalfDamage)

---@param npc EntityNPC
function STATUS_EFFECTS:StrengthAndWeakness(npc)
	local data = Mod:GetData(npc)
	if data.PeterFlipped then
		if FLIP:IsRoomEffectActive() then
			if SEL:HasStatusEffect(npc, STATUS_EFFECTS.STRENGTH_FLAG) then
				SEL:RemoveStatusEffect(npc, STATUS_EFFECTS.STRENGTH_FLAG)
			end
			if not npc:HasEntityFlags(EntityFlag.FLAG_WEAKNESS) then
				npc:AddEntityFlags(EntityFlag.FLAG_WEAKNESS)
			end
		elseif not FLIP:IsRoomEffectActive() and not SEL:HasStatusEffect(npc, STATUS_EFFECTS.STRENGTH_FLAG) then
			print("wh")
			if not SEL:HasStatusEffect(npc, STATUS_EFFECTS.STRENGTH_FLAG) then
				SEL:AddStatusEffect(npc, STATUS_EFFECTS.STRENGTH_FLAG, -1, EntityRef(nil))
			end
			if npc:HasEntityFlags(EntityFlag.FLAG_WEAKNESS) then
				npc:ClearEntityFlags(EntityFlag.FLAG_WEAKNESS)
			end
		end
	end
	if FLIP:ShouldIgnoreEntity(npc) then
		if FLIP:IsRoomEffectActive() and not npc:HasEntityFlags(EntityFlag.FLAG_WEAKNESS) then
			npc:AddEntityFlags(EntityFlag.FLAG_WEAKNESS)
		elseif not FLIP:IsRoomEffectActive() and npc:HasEntityFlags(EntityFlag.FLAG_WEAKNESS) then
			npc:ClearEntityFlags(EntityFlag.FLAG_WEAKNESS)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, STATUS_EFFECTS.StrengthAndWeakness)

return STATUS_EFFECTS
