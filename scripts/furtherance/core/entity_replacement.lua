local Mod = Furtherance

---@type EntityReplacement[]
Furtherance.EntityReplacements = {}

---@class EntityReplacement
---@field OldType {[EntityType]: boolean}
---@field OldVariant {[integer]: boolean}
---@field OldSubtype {[integer]: boolean}?
---@field NewType EntityType
---@field NewVariant integer
---@field NewSubtype integer?
---@field ReplacementChance integer
---@field Achievement Achievement?
---@field IsChest boolean?

local noChestNullSubtypes = Mod:Set({
	NullPickupSubType.NO_COLLECTIBLE_CHEST,
	NullPickupSubType.NO_COLLECTIBLE_CHEST_COIN,
	NullPickupSubType.NO_COLLECTIBLE_TRINKET_CHEST,
})

---@param replacement_info EntityReplacement
function Furtherance:RegisterReplacement(replacement_info)
	Mod.Insert(Mod.EntityReplacements, Mod:CopyTable(replacement_info))
end

---@param entType EntityType
---@param variant integer
---@param subtype integer
---@param seed integer
local function entityReplacement(entType, variant, subtype, seed)
	for _, replacement_info in pairs(Mod.EntityReplacements) do
		--Must match type
		if replacement_info.OldType[entType]
			--Variant can match, or if replacing a pickup with a pickup, PickupVariant.PICKUP_NULL can be nearly any variant
			and (replacement_info.OldVariant[variant] or entType == EntityType.ENTITY_PICKUP and replacement_info.NewType == EntityType.ENTITY_PICKUP and variant == PickupVariant.PICKUP_NULL)
			--If no SubType specified, can only replace spawns that are "0" instead of set spawns
			and (not replacement_info.OldSubtype and subtype == NullPickupSubType.ANY or replacement_info.OldSubtype and replacement_info.OldSubtype[subtype])
			--No achievement, or achieveable
			and (not replacement_info.Achievement or Mod.PersistGameData:Unlocked(replacement_info.Achievement))
		then
			--Some NullPickupSubTypes don't allow specific variants. Blacklist chests or coins.
			if entType == EntityType.ENTITY_PICKUP and variant == PickupVariant.PICKUP_NULL then
				if (replacement_info.IsChest and noChestNullSubtypes[subtype])
					or replacement_info.NewVariant == PickupVariant.PICKUP_COIN
					and subtype == NullPickupSubType.NO_COLLECTIBLE_CHEST_COIN
				then
					return
				end
			end
			local newSubType = replacement_info.NewSubtype or 0
			local roll = RNG(seed):RandomFloat()
			local xmlData = XMLData.GetEntityByTypeVarSub(replacement_info.NewType, replacement_info.NewVariant, newSubType)
			local entName = "No name found"
			if xmlData then
				entName = xmlData.name
			end

			Mod:DebugLog("Attempting replacement for", entType .. "." .. variant .. "." .. subtype, "with",
				replacement_info.NewType .. "." .. replacement_info.NewVariant .. "." .. newSubType, "(" .. entName .. ")")
			Mod:DebugLog("Roll:", roll, "Chance:", replacement_info.ReplacementChance)

			if roll <= replacement_info.ReplacementChance then
				Mod:DebugLog("Replacement successful!")
				return { replacement_info.NewType, replacement_info.NewVariant, newSubType, seed }
			else
				Mod:DebugLog("Roll failed for replacement")
			end
		end
	end
end

local function preEntitySpawn(_, entType, variant, subtype, pos, vel, spawner, seed)
	if entType ~= EntityType.ENTITY_PICKUP then return end
	return entityReplacement(entType, variant, subtype, seed)
end

Mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, preEntitySpawn)

local function preRoomEntitySpawn(_, entType, variant, subtype, gridIndex, seed)
	if entType ~= EntityType.ENTITY_SLOT then return end
	return entityReplacement(entType, variant, subtype, seed)
end

Mod:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, preRoomEntitySpawn)