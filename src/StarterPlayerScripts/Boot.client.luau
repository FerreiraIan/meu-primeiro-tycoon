-- LocalScript (cliente): HUD feito por código, pensado primeiro para celular.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))
local Rarity = require(Shared:WaitForChild("RarityDefinitions"))
local Books = require(Shared:WaitForChild("BookDefinitions"))

local gui = Instance.new("ScreenGui")
gui.Name = "GameUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local scale = Instance.new("UIScale")
scale.Parent = gui

local function updateScale()
	local camera = workspace.CurrentCamera
	if camera then
		scale.Scale = math.clamp(camera.ViewportSize.Y / 720, 0.75, 1.5)
	end
end
updateScale()
if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

-- Painel principal (canto superior esquerdo, longe dos controles do celular)
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Position = UDim2.new(0, 12, 0, 12)
panel.Size = UDim2.new(0, 250, 0, 100)
panel.BackgroundColor3 = Color3.fromRGB(20, 18, 34)
panel.BackgroundTransparency = 0.15
panel.BorderSizePixel = 0
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(120, 90, 200)
stroke.Thickness = 2
stroke.Parent = panel

local function makeLabel(name, position, size, textSize, color)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Position = position
	label.Size = size
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = textSize
	label.TextColor3 = color
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = ""
	label.Parent = panel
	return label
end

local levelLabel = makeLabel("Level", UDim2.new(0, 12, 0, 6), UDim2.new(0.5, -12, 0, 24), 18, Color3.fromRGB(255, 255, 255))
local coinsLabel = makeLabel("Coins", UDim2.new(0.5, 0, 0, 6), UDim2.new(0.5, -12, 0, 24), 18, Color3.fromRGB(255, 205, 60))
coinsLabel.TextXAlignment = Enum.TextXAlignment.Right
local bookLabel = makeLabel("Book", UDim2.new(0, 12, 0, 70), UDim2.new(1, -24, 0, 24), 16, Color3.fromRGB(190, 190, 190))

local barBack = Instance.new("Frame")
barBack.Name = "XPBack"
barBack.Position = UDim2.new(0, 12, 0, 36)
barBack.Size = UDim2.new(1, -24, 0, 18)
barBack.BackgroundColor3 = Color3.fromRGB(45, 40, 70)
barBack.BorderSizePixel = 0
barBack.Parent = panel
Instance.new("UICorner", barBack).CornerRadius = UDim.new(0, 9)

local barFill = Instance.new("Frame")
barFill.Name = "XPFill"
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(110, 200, 255)
barFill.BorderSizePixel = 0
barFill.Parent = barBack
Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 9)

local xpLabel = Instance.new("TextLabel")
xpLabel.Size = UDim2.new(1, 0, 1, 0)
xpLabel.BackgroundTransparency = 1
xpLabel.Font = Enum.Font.GothamBold
xpLabel.TextSize = 12
xpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
xpLabel.Text = ""
xpLabel.ZIndex = 2
xpLabel.Parent = barBack

levelLabel.Text = "Carregando..."

Remotes.Get("DataUpdated").OnClientEvent:Connect(function(snapshot)
	levelLabel.Text = "Nv " .. snapshot.Level
	coinsLabel.Text = "Moedas: " .. snapshot.Coins
	xpLabel.Text = snapshot.XP .. " / " .. snapshot.XPNeeded .. " XP"

	local fraction = math.clamp(snapshot.XP / snapshot.XPNeeded, 0, 1)
	TweenService:Create(barFill, TweenInfo.new(0.3), { Size = UDim2.new(fraction, 0, 1, 0) }):Play()

	local book = Books.Get(snapshot.EquippedBook)
	if book then
		bookLabel.Text = book.Name
		bookLabel.TextColor3 = Rarity.Get(book.Rarity).Color
	else
		bookLabel.Text = "Sem livro"
	end
end)

Remotes.Get("RequestData"):FireServer()
