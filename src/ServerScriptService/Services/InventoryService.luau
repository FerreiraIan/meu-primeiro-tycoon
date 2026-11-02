-- ModuleScript (servidor): livros que o jogador possui e qual está equipado.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local BookDefinitions = require(Shared:WaitForChild("BookDefinitions"))

local PlayerDataService = require(script.Parent.PlayerDataService)
local ProgressionService = require(script.Parent.ProgressionService)

local InventoryService = {}

local lastEquip = {}

function InventoryService.GrantBook(player, bookId)
	local data = PlayerDataService.Get(player)
	if not data or type(bookId) ~= "string" or not BookDefinitions.Exists(bookId) then
		return false
	end
	if data.OwnedBooks[bookId] then
		return false -- nunca duplica
	end
	data.OwnedBooks[bookId] = true
	return true
end

function InventoryService.EquipBook(player, bookId)
	local data = PlayerDataService.Get(player)
	if not data or type(bookId) ~= "string" then
		return false
	end
	if not data.OwnedBooks[bookId] then
		return false -- só equipa o que possui
	end
	data.EquippedBook = bookId
	ProgressionService.Push(player)
	return true
end

-- Chamado quando os dados do jogador carregam: dá o livro inicial se for a primeira vez.
function InventoryService.OnPlayerLoaded(player)
	local data = PlayerDataService.Get(player)
	if not data then
		return
	end
	if next(data.OwnedBooks) == nil then
		InventoryService.GrantBook(player, Config.StarterBookId)
	end
	if data.EquippedBook == "" or not data.OwnedBooks[data.EquippedBook] then
		InventoryService.EquipBook(player, Config.StarterBookId)
	end
end

function InventoryService.Start()
	Remotes.Get("RequestEquip").OnServerEvent:Connect(function(player, bookId)
		local now = os.clock()
		if lastEquip[player] and now - lastEquip[player] < 0.5 then
			return
		end
		lastEquip[player] = now
		InventoryService.EquipBook(player, bookId)
	end)

	game:GetService("Players").PlayerRemoving:Connect(function(player)
		lastEquip[player] = nil
	end)
end

return InventoryService
