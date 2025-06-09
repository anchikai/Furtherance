local Mod = Furtherance
local loader = Mod.PatchesLoader

local function stageAPIPatch()
	---@param gridEnt GridEntity
	local function patchRockGFX(gridEnt, _, _)
		if gridEnt:GetType() == GridEntityType.GRID_ROCKB
			and gridEnt:GetVariant() == Mod.Item.EPITAPH.TOMBSTONE_GRID_VARIANT
		then
			return "gfx/grid/tombstone.png"
		end
	end

	StageAPI.AddCallback("Furtherance", StageAPI.Enum.Callbacks.PRE_CHANGE_ROCK_GFX, CallbackPriority.DEFAULT, patchRockGFX)
end

loader:RegisterPatch("StageAPI", stageAPIPatch)