-- ModuleScript (servidor): carrega e salva os dados dos jogadores com segurança.
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local PlayerDataService = {}

local TEMPLATE = {
	Version = Config.DataVersion,
	Coins = 0,
	XP = 0,
	Level = 1,
	OwnedBooks = {},
	EquippedBook = "",
	Settings = {},
}

local store = DataStoreService:GetDataStore(Config.DataStoreName)
local profiles = {}
local onLoaded = nil

local function deepCopy(value)
	if type(value) ~= "table" then
		return value
	end
	local copy = {}
	for k, v in value do
		copy[k] = deepCopy(v)
	end
	return copy
end

-- Completa campos que faltam (útil quando adicionarmos novos dados no futuro)
local function reconcile(data, template)
	for k, v in template do
		if data[k] == nil then
			data[k] = deepCopy(v)
		elseif type(v) == "table" and type(data[k]) == "table" then
			reconcile(data[k], v)
		end
	end
end

-- Migração de versões antigas dos dados (ainda não há nada para migrar)
local function migrate(data)
	if type(data.Version) ~= "number" then
		data.Version = 1
	end
	-- Exemplo futuro: if data.Version < 2 then ... data.Version = 2 end
end

local function withRetry(fn, attempts)
	local lastError
	for attempt = 1, attempts do
		local ok, result = pcall(fn)
		if ok then
			return true, result
		end
		lastError = result
		warn(("[PlayerData] Tentativa %d/%d falhou: %s"):format(attempt, attempts, tostring(result)))
		if attempt < attempts then
			task.wait(attempt * 2)
		end
	end
	return false, lastError
end

local function keyFor(player)
	return "Player_" .. player.UserId
end

local function loadPlayer(player)
	local attempts = RunService:IsStudio() and 1 or 5
	local ok, result = withRetry(function()
		return store:GetAsync(keyFor(player))
	end, attempts)

	if not player.Parent then
		return
	end

	local profile = { Data = nil, CanSave = true, Saving = false }

	if ok then
		local data = result
		if type(data) ~= "table" then
			data = deepCopy(TEMPLATE)
		end
		migrate(data)
		reconcile(data, TEMPLATE)
		profile.Data = data
	elseif RunService:IsStudio() then
		warn("[PlayerData] Sem acesso ao DataStore no Studio. Jogando SEM salvar.")
		profile.Data = deepCopy(TEMPLATE)
		profile.CanSave = false
	else
		-- Nunca deixamos o jogador jogar sem carregar: salvar por cima apagaria o progresso.
		player:Kick("We could not load your data. Please rejoin in a moment. Your progress is safe.")
		return
	end

	profiles[player] = profile
	if onLoaded then
		task.spawn(onLoaded, player, profile.Data)
	end
end

local function savePlayer(player)
	local profile = profiles[player]
	if not profile or not profile.CanSave then
		return true
	end
	while profile.Saving do
		task.wait(0.1)
	end
	profile.Saving = true
	local ok = withRetry(function()
		store:UpdateAsync(keyFor(player), function()
			return profile.Data
		end)
	end, 5)
	profile.Saving = false
	return ok
end

-- Devolve a tabela de dados do jogador, ou nil se ainda não carregou.
function PlayerDataService.Get(player)
	local profile = profiles[player]
	return profile and profile.Data or nil
end

-- callback(player, data) é chamado quando os dados do jogador terminam de carregar.
function PlayerDataService.Start(callback)
	onLoaded = callback

	Players.PlayerAdded:Connect(loadPlayer)
	for _, player in Players:GetPlayers() do
		task.spawn(loadPlayer, player)
	end

	Players.PlayerRemoving:Connect(function(player)
		savePlayer(player)
		profiles[player] = nil
	end)

	task.spawn(function()
		while true do
			task.wait(Config.AutoSaveSeconds)
			for _, player in Players:GetPlayers() do
				task.spawn(savePlayer, player)
			end
		end
	end)

	game:BindToClose(function()
		local pending = 0
		for _, player in Players:GetPlayers() do
			pending += 1
			task.spawn(function()
				savePlayer(player)
				pending -= 1
			end)
		end
		local startedAt = os.clock()
		while pending > 0 and os.clock() - startedAt < 25 do
			task.wait(0.2)
		end
	end)
end

return PlayerDataService
