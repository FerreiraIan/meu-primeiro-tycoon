-- Script (servidor): liga todos os serviços do jogo.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Services = script.Parent:WaitForChild("Services")

local PlayerDataService = require(Services.PlayerDataService)
local ProgressionService = require(Services.ProgressionService)
local InventoryService = require(Services.InventoryService)

ProgressionService.Start()
InventoryService.Start()

PlayerDataService.Start(function(player)
	InventoryService.OnPlayerLoaded(player)
	ProgressionService.Push(player)
end)

-- PROTÓTIPO: recompensas de teste (desligue em Config.TestMode)
if Config.TestMode then
	task.spawn(function()
		while true do
			task.wait(Config.TestIntervalSeconds)
			for _, player in Players:GetPlayers() do
				ProgressionService.AddXP(player, Config.TestXP)
				ProgressionService.AddCoins(player, Config.TestCoins)
			end
		end
	end)
end

print("[BooksOfChaos] Servidor iniciado! Versão " .. Config.Version)
