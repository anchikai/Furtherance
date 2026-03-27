local Mod = Furtherance

---@type EntityReplacement[]
Furtherance.EntityReplacements = {}

---@type PickupReplacement[]
Furtherance.PickupReplacements = {}

local allowedRoomSpawnTypes = {}

---@class PickupReplacement
---@field OldVariant {[PickupVariant | integer]: boolean}
---@field OldSubtype {[integer]: boolean}?
---@field NewVariant PickupVariant | integer
---@field NewSubtype integer | nil | fun(rng: RNG, subtype: integer): integer
---@field ReplacementChance number| nil | fun(): number
---@field Achievement Achievement | nil | fun(): boolean
---Runs after the requirements for replacing the pickup are met, whether or not it will replace the pickup
---@field PostRollReplacement nil | fun(pickup: EntityPickup, rng: RNG, rollSuccess: boolean, variant: PickupVariant, subtype: integer)

---@class EntityReplacement
---@field OldType {[EntityType]: boolean}
---@field OldVariant {[integer]: boolean}
---@field OldSubtype {[integer]: boolean}?
---@field NewType EntityType
---@field NewVariant integer
---@field NewSubtype integer | nil | fun(rng: RNG, subtype: integer): integer
---@field ReplacementChance number| nil | fun(): number
---@field Achievement Achievement | nil | fun(): boolean
---@field PostRollReplacement nil | fun(rng: RNG, rollSuccess: boolean, entType: EntityType, variant: PickupVariant, subtype: integer)

---@class EntityReplacementInput: EntityReplacement
---@field OldType EntityType[]
---@field OldVariant integer[]
---@field OldSubtype integer[]?

---@class PickupReplacementInput: PickupReplacement
---@field OldVariant integer[]
---@field OldSubtype integer[]?

local vanillaChests = Mod:Set({
	PickupVariant.PICKUP_CHEST,
	PickupVariant.PICKUP_BOMBCHEST,
	PickupVariant.PICKUP_SPIKEDCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_MIMICCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_MEGACHEST,
	PickupVariant.PICKUP_HAUNTEDCHEST,
	PickupVariant.PICKUP_LOCKEDCHEST
})

---@param replacement_info EntityReplacementInput
function Furtherance:RegisterReplacementEntity(replacement_info)
	---@type EntityReplacement
	local replacement_info_copy = Mod:CopyTable(replacement_info)
	replacement_info_copy.OldType = Mod:Set(replacement_info.OldType)
	replacement_info_copy.OldVariant = Mod:Set(replacement_info.OldVariant)
	if replacement_info_copy.OldSubtype and replacement_info.OldSubtype then
		replacement_info_copy.OldSubtype = Mod:Set(replacement_info.OldSubtype)
	end
	Mod.EntityReplacements[#Mod.EntityReplacements + 1] = replacement_info_copy
	for _, entType in ipairs(replacement_info.OldType) do
		if entType ~= EntityType.ENTITY_PICKUP then
			allowedRoomSpawnTypes[entType] = true
		else
			Mod:DebugLog("Please use Furtherance:RegisterReplacementPickup for replacing pickups!")
		end
	end
end

---Pickup replacements are intended for pickups that are **intended to be randomized** for the purpose of pickup pools.
---
---This will not allow replacements of predetermined spawns (e.g. 5.20.0 for a random coin vs 5.20.1 for a penny).
---@param replacement_info PickupReplacementInput
function Furtherance:RegisterReplacementPickup(replacement_info)
	---@type PickupReplacement
	local replacement_info_copy = Mod:CopyTable(replacement_info)
	replacement_info_copy.OldVariant = Mod:Set(replacement_info.OldVariant)
	if replacement_info_copy.OldSubtype and replacement_info.OldSubtype then
		replacement_info_copy.OldSubtype = Mod:Set(replacement_info.OldSubtype)
	end
	Mod.PickupReplacements[#Mod.PickupReplacements + 1] = replacement_info_copy
end

---@param funcOrInit Achievement | fun(): boolean
local function isEntityAvailable(funcOrInit)
	local isAvailable = true
	if type(funcOrInit) == "function" then
		isAvailable = funcOrInit()
	elseif type(funcOrInit) == "number" then
		local persistGameData = Isaac.GetPersistentGameData()
		isAvailable = persistGameData:Unlocked(funcOrInit)
	end
	return isAvailable
end

---@param funcOrInit integer | fun(...): any
local function tryGetInt(funcOrInit, ...)
	local int = 0
	if type(funcOrInit) == "function" then
		int = funcOrInit(...)
	elseif type(funcOrInit) == "number" then
		int = funcOrInit
	end
	return int
end

---@param pickup EntityPickup
---@param variant PickupVariant
---@param subtype integer
---@param requestedVariant PickupVariant
---@param requestedSubtype integer
---@param rng RNG
local function pickupReplacement(_, pickup, variant, subtype, requestedVariant, requestedSubtype, rng)
	local randomPickup = requestedVariant == PickupVariant.PICKUP_NULL
	local randomPickupSub = not randomPickup and requestedSubtype == 0
	for _, replacement_info in pairs(Mod.PickupReplacements) do
		if isEntityAvailable(replacement_info.Achievement)
			--Completely random pickup, or a random subtype of a pickup. Don't want to be replacing predetermined spawns!
			and (randomPickup or randomPickupSub)
			and replacement_info.OldVariant[variant]
			and (not replacement_info.OldSubtype or replacement_info.OldSubtype[subtype])
		then
			local newSubtype = tryGetInt(replacement_info.NewSubtype, rng, subtype)
			local xmlData = XMLData.GetEntityByTypeVarSub(EntityType.ENTITY_PICKUP, replacement_info.NewVariant,
				newSubtype)
			local entName = "No name found"
			if xmlData then
				entName = xmlData.name
			end
			local replacementChance = tryGetInt(replacement_info.ReplacementChance)
			local roll = rng:RandomFloat()

			Mod:DebugLog("Attempting replacement for pickup", variant .. "." .. subtype, "with",
				replacement_info.NewVariant .. "." .. newSubtype, "(" .. entName .. ")")
			Mod:DebugLog("Roll:", roll, "Chance:", replacementChance)

			if roll <= replacementChance then
				Mod:DebugLog("Replacement successful!")
				if replacement_info.PostRollReplacement then
					replacement_info.PostRollReplacement(pickup, rng, true, replacement_info.NewVariant, newSubtype)
				end
				return { replacement_info.NewVariant, newSubtype }
			else
				if replacement_info.PostRollReplacement then
					replacement_info.PostRollReplacement(pickup, rng, false, variant, subtype)
				end
				Mod:DebugLog("Roll failed for replacement")
			end
			--Only override if it's tied to an achievement specifically
		elseif type(replacement_info.Achievement) == "string"
			---@diagnostic disable-next-line: param-type-mismatch
			and not Isaac.GetPersistentGameData():Unlocked(replacement_info.Achievement)
			and replacement_info.NewVariant == variant
			and (not replacement_info.NewSubtype or type(replacement_info.NewSubtype) == "number" and replacement_info.NewSubtype == subtype)
		then
			local oldVariant = replacement_info.OldVariant and Mod:GetKeys(replacement_info.OldVariant) or { 0 }
			local oldSubtype = replacement_info.OldSubtype and Mod:GetKeys(replacement_info.OldSubtype) or { 0 }
			table.sort(oldVariant)
			table.sort(oldSubtype)
			local selVar = oldVariant[1]
			local selSub = oldSubtype[1]
			if vanillaChests[selVar] then
				--Spawn as open chests otherwise
				selSub = ChestSubType.CHEST_CLOSED
			end
			Mod:DebugLog("Pickup " .. variant .. "." .. subtype, "not unlocked! Replacing with", selVar .. "." .. selSub)
			return { selVar, selSub }
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_SELECTION, pickupReplacement)

---@param entType EntityType
---@param variant integer
---@param subtype integer
---@param seed integer
local function entityReplacement(_, entType, variant, subtype, gridIndex, seed)
	if not allowedRoomSpawnTypes[entType] then
		return
	end
	for _, replacement_info in pairs(Mod.EntityReplacements) do
		if isEntityAvailable(replacement_info.Achievement)
			and replacement_info.OldType[entType]
			and replacement_info.OldVariant[variant]
			and (not replacement_info.OldSubtype or replacement_info.OldSubtype[subtype])
		then
			local rng = RNG(seed)
			local newSubtype = tryGetInt(replacement_info.NewSubtype, rng, subtype)
			local xmlData = XMLData.GetEntityByTypeVarSub(replacement_info.NewType, replacement_info.NewVariant,
				newSubtype)
			local entName = "No name found"
			if xmlData then
				entName = xmlData.name
			end
			local replacementChance = tryGetInt(replacement_info.ReplacementChance)
			local roll = rng:RandomFloat()

			Mod:DebugLog("Attempting replacement for", entType .. "." .. variant .. "." .. subtype, "with",
				replacement_info.NewType .. "." .. replacement_info.NewVariant .. "." .. newSubtype,
				"(" .. entName .. ")")
			Mod:DebugLog("Roll:", roll, "Chance:", replacementChance)

			if roll <= replacementChance then
				Mod:DebugLog("Replacement successful!")
				if replacement_info.PostRollReplacement then
					replacement_info.PostRollReplacement(rng, true, replacement_info.NewType, replacement_info
					.NewVariant, newSubtype)
				end
				return { replacement_info.NewType, replacement_info.NewVariant, newSubtype }
			else
				if replacement_info.PostRollReplacement then
					replacement_info.PostRollReplacement(rng, false, entType, variant, subtype)
				end
				Mod:DebugLog("Roll failed for replacement")
			end
			--Only override if it's tied to an achievement specifically
		elseif type(replacement_info.Achievement) == "string"
			---@diagnostic disable-next-line: param-type-mismatch
			and not Isaac.GetPersistentGameData():Unlocked(replacement_info.Achievement)
			and replacement_info.NewType == entType
			and replacement_info.NewVariant == variant
			and (not replacement_info.NewSubtype or type(replacement_info.NewSubtype) == "number" and replacement_info.NewSubtype == subtype)
		then
			local oldType = Mod:GetKeys(replacement_info.OldType)
			local oldVariant = replacement_info.OldVariant and Mod:GetKeys(replacement_info.OldVariant) or { 0 }
			local oldSubtype = replacement_info.OldSubtype and Mod:GetKeys(replacement_info.OldSubtype) or { 0 }
			table.sort(oldType)
			table.sort(oldVariant)
			table.sort(oldSubtype)
			local selType = oldType[1]
			local selVar = oldVariant[1]
			local selSub = oldSubtype[1]
			Mod:DebugLog(entType .. "." .. variant .. "." .. subtype, "not unlocked! Replacing with",
				selType .. "." .. selVar .. "." .. selSub)
			return { selType, selVar, selSub }
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, entityReplacement)
