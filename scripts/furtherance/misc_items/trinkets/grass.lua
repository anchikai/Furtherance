local Mod = Furtherance

local GRASS = {}

Furtherance.Trinket.GRASS = GRASS

GRASS.ID = Isaac.GetTrinketIdByName("Grass")

--30 minutes
GRASS.TIMER = 30 * 60 * 30
GRASS.SPEED_UP_PER_GRASS = 0.05

local grassVariants = {
	"01",
	"02",
	"03",
	"04",
	"05",
	"06",
	"07",
	"08",
	"09",
	"10",
	"35",
	"36",
	"37",
	"38",
	"39",
	"40",
}

function GRASS:OverrideDecoration()
	if PlayerManager.AnyoneHasTrinket(GRASS.ID) then
		local rng = RNG(Mod.Room():GetDecorationSeed())
		Mod:ForEachGrid(function (gridEnt, gridIndex)
			local sprite = gridEnt:GetSprite()
			sprite:Load("gfx/grid/props_grass.anm2")
			local anim = "Prop" .. grassVariants[rng:RandomInt(#grassVariants) + 1]
			sprite:Play(anim)
			sprite:ReplaceSpritesheet(0, "gfx/grid/props_grass.png", true)
		end, GridEntityType.GRID_DECORATION)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, GRASS.OverrideDecoration)

---@param gridEnt GridEntityDecoration
function GRASS:DetectGrassPlayer(gridEnt)
	if not PlayerManager.AnyoneHasTrinket(GRASS.ID) then return end
	Mod.Foreach.PlayerInRadius(gridEnt.Position, 20, function (player, index)
		if player:HasTrinket(GRASS.ID) then
			local data = Mod:GetData(player)
			if not data.GrassIndexCrossed or not data.GrassIndexCrossed[gridEnt:GetGridIndex()] then
				data.GrassIndexCrossed = data.GrassIndexCrossed or {}
				data.GrassIndexCrossed[gridEnt:GetGridIndex()] = true
				player:GetEffects():AddTrinketEffect(GRASS.ID)
			end
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_DECORATION_UPDATE, GRASS.DetectGrassPlayer)

---@param player EntityPlayer
function GRASS:OnTrinketRemove(player)
	player:GetEffects():RemoveTrinketEffect(GRASS.ID, -1)
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_REMOVED, GRASS.OnTrinketRemove, GRASS.ID)

function GRASS:OnNewRoom(player)
	local data = Mod:GetData(player)
	data.GrassIndexCrossed = nil
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, GRASS.OnNewRoom)

---@param player EntityPlayer
function GRASS:SpeedUp(player)
	local effects = player:GetEffects()
	if effects:HasTrinketEffect(GRASS.ID) then
		player.MoveSpeed = player.MoveSpeed + (GRASS.SPEED_UP_PER_GRASS * effects:GetTrinketEffectNum(GRASS.ID))
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, GRASS.SpeedUp, CacheFlag.CACHE_SPEED)
