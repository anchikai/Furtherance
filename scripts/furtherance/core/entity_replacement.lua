---Partial credit to Epiphany, with some adjustments on my end
local Mod = Furtherance

Furtherance.table_entity_replacements = {}

function Furtherance:RegisterReplacement(replacement_info)
	Mod.table_entity_replacements[#Mod.table_entity_replacements + 1] = Mod:CopyTable(replacement_info)
end

---@param entity Entity \
local function CheckReplaceNew(_, entity)
	local roomSave = Mod:RoomSave()
	roomSave.replacedStuff = roomSave.replacedStuff or {}
	local pData = Mod:GetPersistentEntityData(entity)

	if pData and pData.TriedReplace then
		return
	end

	local type = entity.Type
	local variant = entity.Variant
	local subtype = entity.SubType
	local rng = RNG()
	rng:SetSeed(entity.InitSeed)

	if type == EntityType.ENTITY_PICKUP and variant == PickupVariant.PICKUP_COIN then
		if Mod:IsMainGreedModeRoom() then
			return
		end

		--this  may be able to be replaced by checking the spawner entity but that needs testing

		local bloodDonationMachines = Mod:FilterList(
			Isaac.FindInRadius(entity.Position, 1),
			function(val)
				return val.Type == EntityType.ENTITY_SLOT and val.Variant == 2 -- blood donation machine
			end
		)

		if #bloodDonationMachines > 0 then
			return
		end

		local bloodDonors = Mod:GetPlayers(function(player)
			return Mod:GetFramesSinceActiveLastUsed(player, CollectibleType.COLLECTIBLE_IV_BAG) == 1
		end)

		if #bloodDonors > 0 then
			return
		end
	end

	local replacement_pool = Mod:EntityReplacement(type, variant, subtype, Mod.table_entity_replacements, rng, true)

	pData.TriedReplace = true
	if replacement_pool then
		-- print("replacing")
		if entity:ToPickup() then
			entity:ToPickup():Morph(replacement_pool[1], replacement_pool[2], replacement_pool[3], true, true, true)
		end
	end
end

--Checks if an entity is part of an entity replacements table.
--If the check is successful, it returns a table of the new type, variant, and subtype.
---@function
---@scope Epiphany
---@param type integer
---@param variant integer
---@param subtype integer
---@param replacements table
---@param rng RNG
---@param invert boolean @true if its replacing entities that arent unlocked
function Mod:EntityReplacement(type, variant, subtype, replacements, rng, invert)
	for _, replacement_info in pairs(replacements) do
		if
			((not replacement_info.old_type) or Mod:ContainsValue(replacement_info.old_type, type))
			and ((not replacement_info.old_variant) or Mod:ContainsValue(replacement_info.old_variant, variant))
			and ((not replacement_info.old_subtype) or Mod:ContainsValue(replacement_info.old_subtype, subtype))
			-- and (print("valid replacement") or true)
			and Mod:GetAchievement(replacement_info.achname) > 0
			and rng:RandomInt(replacement_info.probability_denominator) < replacement_info.probability_numerator
		then
			return { replacement_info.new_type, replacement_info.new_variant, replacement_info.new_subtype }
		end


		if invert == true then
			-- print(Mod:GetAchievement(replacement_info.achname), type, variant, subtype, invert)

			if
				type == replacement_info.new_type
				and variant == replacement_info.new_variant
				and subtype == replacement_info.new_subtype
				-- and (print("valid replacement") or true)
				and Mod:GetAchievement(replacement_info.achname) == 0
			then
				return { replacement_info.old_type[1],
					(not replacement_info.old_variant) and 0 or replacement_info.old_variant[1],
					(not replacement_info.old_subtype) and 0 or replacement_info.old_subtype[1] }
			end
		end
	end
end

local function onUpdate()
	--local entities = GetReplacableEntities()
	local entities = Isaac.FindByType(EntityType.ENTITY_PICKUP)
	entities = Mod:FilterList(entities, function(pickup)
		return pickup:Exists() and pickup.FrameCount == 1
	end)

	for _, ent in ipairs(entities) do
		CheckReplaceNew(_, ent)
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

local function onNewRoom()
	--local entities = GetReplacableEntities()
	local entities = Isaac.FindByType(EntityType.ENTITY_PICKUP)
	for _, ent in pairs(entities) do
		CheckReplaceNew(_, ent)
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onNewRoom)


--slot replacements and replacing things that arent unlocked
local function preRoomEntitySpawn(_, type, variant, subtype, _, seed)
	local rng = RNG()
	rng:SetSeed(seed, Mod.RECOMMENDED_SHIFT_IDX)

	local replacement

	if type == EntityType.ENTITY_SLOT or type == EntityType.ENTITY_SHOPKEEPER then --slots are done in pre room entity spawn so no temperance/judgement shenanigans
		replacement = Mod:EntityReplacement(type, variant, subtype, Mod.table_entity_replacements, rng, false)
	end

	if type == EntityType.ENTITY_PICKUP or type == EntityType.ENTITY_SLOT or type == EntityType.ENTITY_SHOPKEEPER then
		replacement = Mod:EntityReplacement(type, variant, subtype, Mod.table_entity_replacements, rng, true)
	end

	return replacement
end
Mod:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, preRoomEntitySpawn)
