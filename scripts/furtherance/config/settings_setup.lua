--luacheck: no max line length
local Mod = Furtherance
local SettingsHelper = Furtherance.SettingsHelper

local frameOptions = {}
for i = 5, 20 do
	Mod.Insert(frameOptions, i)
end
local opacityOptions = {}
for i = 0, 10 do
	Mod.Insert(opacityOptions, i * 0.1)
end

SettingsHelper.AddChoiceSetting("General", Mod.Setting.HeartRenovatorDoubleTap,
	"Adjust the double tap window for Heart Renovator", frameOptions, 5)

local CHOICE_GRID = 1
local CHOICE_DEFAULT = 0.5

SettingsHelper.AddChoiceSetting("Tainted Peter", Mod.Setting.TPeterSubmergedOpacityGrid,
	"Opacity of the outline for submerged entities when under a grid", opacityOptions, CHOICE_GRID * 10 + 1)

SettingsHelper.AddChoiceSetting("Tainted Peter", Mod.Setting.TPeterSubmergedOpacityDefault,
	"Opacity of the outline for submerged entities when not under a grid, if enabled", opacityOptions, CHOICE_DEFAULT * 10 + 1)
