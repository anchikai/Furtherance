local Mod = Furtherance
local loader = Mod.PatchesLoader

local function libraryExpandedPatch()
	Mod:AddToDictionary(LibraryExpanded.Item.WEIRD_BOOK.BookToDeli, Mod:Set({
		Mod.Item.BOOK_OF_AMBIT.ID,
		Mod.Item.BOOK_OF_BOOKS.ID,
		Mod.Item.BOOK_OF_GUIDANCE.ID,
		Mod.Item.BOOK_OF_LEVITICUS.ID,
		Mod.Item.BOOK_OF_SWIFTNESS.ID,
		Mod.Item.COSMIC_OMNIBUS.ID,
		Mod.Item.PRAYER_JOURNAL.ID,
		Mod.Item.SECRET_DIARY.ID
	}))
	LibraryExpanded.LibraryEID.TBOATB[Mod.Item.BOOK_OF_BOOKS.ID] = "#{{TBOATB}} Activated books will have TBOATB synergies"
end

loader:RegisterPatch("LibraryExpanded", libraryExpandedPatch)