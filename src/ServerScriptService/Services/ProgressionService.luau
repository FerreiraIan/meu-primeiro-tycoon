-- ModuleScript (servidor): moedas, XP e nível. Só o servidor altera esses valores.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local PlayerDataService = require(script.Parent.PlayerDataService)

local ProgressionService = {}

local lastRequest = {}

local function xpNeeded(level)
	return 100 * level
end

local function isValidAmount(amount)
	return type(amount) == "number" and amount == amount and amount > 0 and amount < 1e9
end

function ProgressionService.Push(player)
	local data = PlayerDataService.Get(player)
	if not data then
		return
	end
	Remotes.Get("DataUpdated"):FireClient(player, {
		Coins = data.Coins,
		XP = data.XP,
		Level = data.Level,
		XPNeeded = xpNeeded(data.Level),
		EquippedBook = data.EquippedBook,
	})
end

function ProgressionService.AddCoins(player, amount)
	local data = PlayerDataService.Get(player)
	if not data or not isValidAmount(amount) then
		return
	end
	data.Coins += math.floor(amount)
	ProgressionService.Push(player)
end

function ProgressionService.AddXP(player, amount)
	local data = PlayerDataService.Get(player)
	if not data or not isValidAmount(amount) then
		return
	end
	data.XP += math.floor(amount)
	while data.Level < Config.MaxLevel and data.XP >= xpNeeded(data.Level) do
		data.XP -= xpNeeded(data.Level)
		data.Level += 1
	end
	if data.Level >= Config.MaxLevel then
		data.XP = 0
	end
	ProgressionService.Push(player)
end

function ProgressionService.Start()
	-- O cliente pede os dados ao abrir (evita perder a primeira atualização)
	Remotes.Get("RequestData").OnServerEvent:Connect(function(player)
		local now = os.clock()
		if lastRequest[player] and now - lastRequest[player] < 1 then
			return
		end
		lastRequest[player] = now
		ProgressionService.Push(player)
	end)

	game:GetService("Players").PlayerRemoving:Connect(function(player)
		lastRequest[player] = nil
	end)
end

return ProgressionService
