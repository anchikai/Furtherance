---@param tab table
---@param path string
local function loopInclude(tab, path)
	path = "scripts.furtherance.unlocks.unlocks_" .. path
	for _, fileName in pairs(tab) do
		Furtherance.Include(path .. "." .. fileName)
	end
end

--#region Leah

local leah = {

}

loopInclude(leah, "leah")

--#endregion

--#region Tainted Leah

local leah_b = {

}

loopInclude(leah_b, "leah_b")

--#endregion

--#region Miriam

local miriam = {

}

loopInclude(miriam, "miriam")

--#endregion

--#region Tainted Miriam

local miriam_b = {

}

loopInclude(miriam_b, "miriam_b")

--#endregion

--#region Peter

local peter = {

}

loopInclude(peter, "peter")

--#endregion

--#region Tainted Peter

local peter_b = {

}

loopInclude(peter_b, "peter_b")

--#endregion

--#region Default unlocks (if any?)

local default = {

}

loopInclude(default, "default")

--#region Challenges

local challenges = {

}

loopInclude(challenges, "challenges")

--#endregion

--#region Misc

local misc = {

}

loopInclude(misc, "misc")

--#endregion

Furtherance.Include("scripts.furtherance.unlocks.unlock_table")
Furtherance.Include("scripts.furtherance.unlocks.unlock_tracker_marks")
Furtherance.Include("scripts.furtherance.unlocks.unlock_tracker_misc")