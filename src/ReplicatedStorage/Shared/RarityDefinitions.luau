-- ModuleScript: as 9 raridades. Para criar uma nova, basta adicionar uma linha.
local Rarities = {
	Common       = { Order = 1, Name = "Common",         Color = Color3.fromRGB(190, 190, 190) },
	Uncommon     = { Order = 2, Name = "Uncommon",       Color = Color3.fromRGB(90, 200, 90) },
	Rare         = { Order = 3, Name = "Rare",          Color = Color3.fromRGB(60, 140, 255) },
	Epic         = { Order = 4, Name = "Epic",         Color = Color3.fromRGB(170, 80, 255) },
	Legendary    = { Order = 5, Name = "Legendary",      Color = Color3.fromRGB(255, 170, 30) },
	Mythic       = { Order = 6, Name = "Mythic",        Color = Color3.fromRGB(255, 70, 90) },
	Divine       = { Order = 7, Name = "Divine",        Color = Color3.fromRGB(255, 235, 140) },
	Secret       = { Order = 8, Name = "Secret",       Color = Color3.fromRGB(30, 30, 40) },
	Transcendent = { Order = 9, Name = "Transcendent", Color = Color3.fromRGB(120, 255, 240) },
}

local Module = {}

function Module.Get(rarityId)
	return Rarities[rarityId] or Rarities.Common
end

return Module
