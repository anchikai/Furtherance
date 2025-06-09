local Mod = Furtherance
local loader = Mod.PatchesLoader

local function futurePatch()
	TheFuture.ModdedCharacterDialogue["Leah"] = {
		"rough day?",
		"i get that",
		"it's not much but...",
		"i hope this helps"
	}
	TheFuture.ModdedTaintedCharacterDialogue["Leah"] = {
		"why did the gym couple break up?",
		"they just couldn't work out",
		"...",
		"sorry, i thought a joke could cheer you up",
		"i'll just stop talking now"
	}
	TheFuture.ModdedCharacterDialogue["Peter"] = {
		"is it time for shift change already?",
		"i've been sitting here for awhile waiting",
		"wait, you're not the new gate guardian?",
		"sigh...can you go find them for me?"
	}
	TheFuture.ModdedTaintedCharacterDialogue["Peter"] = {
		"what are you doing down there?",
		"you need to be up here to get in",
		"seriously, i'm not coming down there",
		"...",
		"whatever, i'll wait",
	}
	TheFuture.ModdedCharacterDialogue["Miriam"] = {
		"woah slow down there!",
		"you're getting everything wet",
		"wipe your feet at least before going inside",
		"i don't want to have to mop the floor again"
	}
	TheFuture.ModdedTaintedCharacterDialogue["Miriam"] = {
		"is it true what they say?",
		"that the dark side has cookies",
		"i could go for some right now",
		"so where do i sign up?"
	}
end

loader:RegisterPatch("TheFuture", futurePatch)