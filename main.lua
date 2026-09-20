-- LocalScript: YunkzHubsV1_PointBlox.lua
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- =========================================================
-- STATE FITUR & VARIABEL UTAMA
-- =========================================================
local FeatureStates = {
	AutoKill = false,
	ESP = false,
	TriggerBot = false,
	Wallbang = false,
	KebakUnlimited = false,
	AimAssist = false,
	InfiniteAmmo = false,
	Noclip = false,
	NoSpread = false,
	InstantReload = false,
	RapidFire = false,
	GodMode = false,
	KillRange = 50,
	AimFOV = 150,
	AimSmooth = 0.08,
	WalkSpeed = 16,
	DamageMultiplier = 1
}

local ESPHighlights = {}

-- =========================================================
-- LOGIKA FITUR AKTIF (FUNCTIONAL LOGIC)
-- =========================================================

-- WalkSpeed Loop saat Respawn
LocalPlayer.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid", 5)
	if hum then hum.WalkSpeed = FeatureStates.WalkSpeed end
end)

-- Noclip Loop
RunService.Stepped:Connect(function()
	if FeatureStates.Noclip and LocalPlayer.Character then
		for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

-- ESP (Highlight Enemy)
local function updateESP()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			if FeatureStates.ESP then
				if not ESPHighlights[player] then
					local hl = Instance.new("Highlight")
					hl.Name = "ESPHighlight"
					hl.FillColor = Color3.fromRGB(255, 50, 50)
					hl.OutlineColor = Color3.fromRGB(255, 255, 255)
					hl.FillTransparency = 0.5
					hl.Adornee = player.Character
					hl.Parent = player.Character
					ESPHighlights[player] = hl
				end
			else
				if ESPHighlights[player] then
					ESPHighlights[player]:Destroy()
					ESPHighlights[player] = nil
				end
			end
		end
	end
end

-- RenderStepped Loop (WalkSpeed Update & Aim Assist/AutoKill Logic)
RunService.RenderStepped:Connect(function()
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid.WalkSpeed = FeatureStates.WalkSpeed
	end

	if FeatureStates.AimAssist or FeatureStates.AutoKill then
		local closestTarget = nil
		local shortestDistance = FeatureStates.KillRange

		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				local targetPart = player.Character.HumanoidRootPart
				local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) 
					and (LocalPlayer.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude or 9999

				if distance <= shortestDistance then
					closestTarget = targetPart
					shortestDistance = distance
				end
			end
		end

		if closestTarget and FeatureStates.AimAssist then
			Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closestTarget.Position), FeatureStates.AimSmooth)
		end
	end
end)

Players.PlayerAdded:Connect(function() updateESP() end)
Players.PlayerRemoving:Connect(function(player)
	if ESPHighlights[player] then
		ESPHighlights[player]:Destroy()
		ESPHighlights[player] = nil
	end
end)

-- =========================================================
-- DESAIN USER INTERFACE (GUI) - YUNKZHUBSV1
-- =========================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "YunkzHubsV1"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 520, 0, 310)
mainFrame.Position = UDim2.new(0.5, -260, 0.5, -155)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

-- Top Bar Header
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 32)
topBar.BackgroundColor3 = Color3.fromRGB(10, 11, 16)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -100, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "YunkzHubsV1 | PointBlox | POIN BLOX"
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
titleLabel.TextSize = 13
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

-- Tombol Close (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -28, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(235, 60, 60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 12
closeBtn.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Sidebar Navigasi
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 110, 1, -32)
sidebar.Position = UDim2.new(0, 0, 0, 32)
sidebar.BackgroundColor3 = Color3.fromRGB(12, 13, 18)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Padding = UDim.new(0, 6)
sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sidebarLayout.Parent = sidebar

local sidebarPadding = Instance.new("UIPadding")
sidebarPadding.PaddingTop = UDim.new(0, 8)
sidebarPadding.Parent = sidebar

-- Content Area Konten
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -115, 1, -37)
contentArea.Position = UDim2.new(0, 112, 0, 34)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainFrame

local tabs = {}
local tabButtons = {}

local function createTab(tabName)
	local tabFrame = Instance.new("ScrollingFrame")
	tabFrame.Name = tabName .. "Tab"
	tabFrame.Size = UDim2.new(1, 0, 1, 0)
	tabFrame.BackgroundTransparency = 1
	tabFrame.ScrollBarThickness = 4
	tabFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 140, 255)
	tabFrame.Visible = false
	tabFrame.Parent = contentArea

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 8)
	listLayout.Parent = tabFrame

	tabs[tabName] = tabFrame

	local btn = Instance.new("TextButton")
	btn.Name = tabName .. "Btn"
	btn.Size = UDim2.new(0, 96, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
	btn.Text = tabName
	btn.TextColor3 = Color3.fromRGB(180, 180, 180)
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 13
	btn.Parent = sidebar

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn

	tabButtons[tabName] = btn

	btn.MouseButton1Click:Connect(function()
		for name, frame in pairs(tabs) do
			frame.Visible = (name == tabName)
		end
		for name, button in pairs(tabButtons) do
			if name == tabName then
				button.BackgroundColor3 = Color3.fromRGB(0, 102, 204)
				button.TextColor3 = Color3.fromRGB(255, 255, 255)
			else
				button.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
				button.TextColor3 = Color3.fromRGB(180, 180, 180)
			end
		end
	end)

	return tabFrame
end

local homeTab = createTab("Home")
local farmTab = createTab("Farm")
local roomTab = createTab("Room")
local teamTab = createTab("Team")
local miscTab = createTab("Misc")
local musicTab = createTab("Music")
local settingsTab = createTab("Settings")

-- =========================================================
-- TAB HOME
-- =========================================================
local profileFrame = Instance.new("Frame")
profileFrame.Size = UDim2.new(1, -10, 0, 70)
profileFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
profileFrame.Parent = homeTab

local profCorner = Instance.new("UICorner")
profCorner.CornerRadius = UDim.new(0, 6)
profCorner.Parent = profileFrame

local avatarImg = Instance.new("ImageLabel")
avatarImg.Size = UDim2.new(0, 54, 0, 54)
avatarImg.Position = UDim2.new(0, 8, 0, 8)
avatarImg.BackgroundColor3 = Color3.fromRGB(30, 33, 45)
avatarImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
avatarImg.Parent = profileFrame

local avatarCorner = Instance.new("UICorner")
avatarCorner.CornerRadius = UDim.new(0, 8)
avatarCorner.Parent = avatarImg

local usernameLbl = Instance.new("TextLabel")
usernameLbl.Size = UDim2.new(1, -75, 0, 20)
usernameLbl.Position = UDim2.new(0, 70, 0, 12)
usernameLbl.BackgroundTransparency = 1
usernameLbl.Text = LocalPlayer.DisplayName
usernameLbl.TextColor3 = Color3.fromRGB(0, 170, 255)
usernameLbl.TextSize = 14
usernameLbl.Font = Enum.Font.SourceSansBold
usernameLbl.TextXAlignment = Enum.TextXAlignment.Left
usernameLbl.Parent = profileFrame

local useridLbl = Instance.new("TextLabel")
useridLbl.Size = UDim2.new(1, -75, 0, 16)
useridLbl.Position = UDim2.new(0, 70, 0, 32)
useridLbl.BackgroundTransparency = 1
useridLbl.Text = "@" .. LocalPlayer.Name .. "\nID: " .. LocalPlayer.UserId
useridLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
useridLbl.TextSize = 11
useridLbl.Font = Enum.Font.SourceSans
useridLbl.TextXAlignment = Enum.TextXAlignment.Left
useridLbl.Parent = profileFrame

local featureTitle = Instance.new("TextLabel")
featureTitle.Size = UDim2.new(1, -10, 0, 20)
featureTitle.BackgroundTransparency = 1
featureTitle.Text = "Available Features:"
featureTitle.TextColor3 = Color3.fromRGB(0, 140, 255)
featureTitle.TextSize = 12
featureTitle.Font = Enum.Font.SourceSansBold
featureTitle.TextXAlignment = Enum.TextXAlignment.Left
featureTitle.Parent = homeTab

local featuresText = Instance.new("TextLabel")
featuresText.Size = UDim2.new(1, -10, 0, 150)
featuresText.BackgroundTransparency = 1
featuresText.Text = "- Auto Create Room: Create room auto\n- ESP: See enemies through wall\n- AimAssist: Smooth aimbot with FOV circle\n- TriggerBot: Auto shoot on target\n- Wallbang: Shoot through wall\n- Kebak Unlimited: Force ragdoll forever\n- No Spread: Perfect accuracy\n- Instant Reload: Zero reload time\n- Rapid Fire: 20 shots/second\n- Damage Multiplier: x10 damage\n- God Mode: Unlimited Health"
featuresText.TextColor3 = Color3.fromRGB(160, 160, 160)
featuresText.TextSize = 11
featuresText.Font = Enum.Font.SourceSans
featuresText.TextXAlignment = Enum.TextXAlignment.Left
featuresText.TextYAlignment = Enum.TextYAlignment.Top
featuresText.Parent = homeTab

-- =========================================================
-- HELPER KONTROL UI (TOGGLE & SLIDER)
-- =========================================================

local function createToggle(parent, titleText, featureKey, onChange)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -10, 0, 32)
	row.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
	row.Parent = parent

	local rowCorner = Instance.new("UICorner")
	rowCorner.CornerRadius = UDim.new(0, 5)
	rowCorner.Parent = row

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.7, 0, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = titleText
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.TextSize = 12
	label.Font = Enum.Font.SourceSans
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local toggleBg = Instance.new("TextButton")
	toggleBg.Size = UDim2.new(0, 36, 0, 18)
	toggleBg.Position = UDim2.new(1, -44, 0.5, -9)
	toggleBg.BackgroundColor3 = Color3.fromRGB(40, 44, 58)
	toggleBg.Text = ""
	toggleBg.Parent = row

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(1, 0)
	toggleCorner.Parent = toggleBg

	local circle = Instance.new("Frame")
	circle.Size = UDim2.new(0, 14, 0, 14)
	circle.Position = UDim2.new(0, 2, 0.5, -7)
	circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	circle.Parent = toggleBg

	local circleCorner = Instance.new("UICorner")
	circleCorner.CornerRadius = UDim.new(1, 0)
	circleCorner.Parent = circle

	local toggled = false
	toggleBg.MouseButton1Click:Connect(function()
		toggled = not toggled
		FeatureStates[featureKey] = toggled
		
		if toggled then
			toggleBg.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
			circle:TweenPosition(UDim2.new(1, -16, 0.5, -7), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
		else
			toggleBg.BackgroundColor3 = Color3.fromRGB(40, 44, 58)
			circle:TweenPosition(UDim2.new(0, 2, 0.5, -7), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
		end
		
		if onChange then onChange(toggled) end
	end)
end

local function createSlider(parent, titleText, featureKey, min, max, default)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -10, 0, 45)
	row.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
	row.Parent = parent

	local rowCorner = Instance.new("UICorner")
	rowCorner.CornerRadius = UDim.new(0, 5)
	rowCorner.Parent = row

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 0, 18)
	label.Position = UDim2.new(0, 10, 0, 4)
	label.BackgroundTransparency = 1
	label.Text = titleText .. ": " .. tostring(default)
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.TextSize = 12
	label.Font = Enum.Font.SourceSans
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -20, 0, 4)
	track.Position = UDim2.new(0, 10, 0, 28)
	track.BackgroundColor3 = Color3.fromRGB(40, 44, 58)
	track.Parent = row

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
	fill.BorderSizePixel = 0
	fill.Parent = track

	local thumb = Instance.new("Frame")
	thumb.Size = UDim2.new(0, 10, 0, 10)
	thumb.Position = UDim2.new(1, -5, 0.5, -5)
	thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	thumb.Parent = fill

	local thumbCorner = Instance.new("UICorner")
	thumbCorner.CornerRadius = UDim.new(1, 0)
	thumbCorner.Parent = thumb

	local dragging = false
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local mousePos = input.Position.X
			local trackPos = track.AbsolutePosition.X
			local trackWidth = track.AbsoluteSize.X
			local pct = math.clamp((mousePos - trackPos) / trackWidth, 0, 1)
			
			fill.Size = UDim2.new(pct, 0, 1, 0)
			local val = math.floor(min + (max - min) * pct)
			label.Text = titleText .. ": " .. tostring(val)
			FeatureStates[featureKey] = val
		end
	end)
end

-- =========================================================
-- ISIAN MASING-MASING TAB
-- =========================================================

-- Farm Tab (Gambar 2)
createToggle(farmTab, "Auto Kill", "AutoKill")
createToggle(farmTab, "ESP", "ESP", function(active) updateESP() end)
createToggle(farmTab, "Trigger Bot", "TriggerBot")
createToggle(farmTab, "Wallbang", "Wallbang")
createToggle(farmTab, "Kebak Unlimited", "KebakUnlimited")
createSlider(farmTab, "Kill Range", "KillRange", 0, 100, 50)

-- Room Tab (Gambar 3)
createToggle(roomTab, "Auto Create Room", "AutoCreateRoom")

local roomInputBox = Instance.new("TextBox")
roomInputBox.Size = UDim2.new(1, -10, 0, 28)
roomInputBox.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
roomInputBox.Text = LocalPlayer.Name
roomInputBox.TextColor3 = Color3.fromRGB(200, 200, 200)
roomInputBox.Font = Enum.Font.SourceSans
roomInputBox.TextSize = 12
roomInputBox.Parent = roomTab

local createRoomBtn = Instance.new("TextButton")
createRoomBtn.Size = UDim2.new(1, -10, 0, 32)
createRoomBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 60)
createRoomBtn.Text = "CREATE ROOM NOW"
createRoomBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
createRoomBtn.Font = Enum.Font.SourceSansBold
createRoomBtn.TextSize = 12
createRoomBtn.Parent = roomTab

local roomBtnCorner = Instance.new("UICorner")
roomBtnCorner.CornerRadius = UDim.new(0, 6)
roomBtnCorner.Parent = createRoomBtn

-- Misc Tab (Gambar 4 & 5)
createToggle(miscTab, "Aim Assist", "AimAssist")
createToggle(miscTab, "Infinite Ammo", "InfiniteAmmo")
createToggle(miscTab, "Noclip", "Noclip")
createToggle(miscTab, "No Spread", "NoSpread")
createToggle(miscTab, "Instant Reload", "InstantReload")
createToggle(miscTab, "Rapid Fire", "RapidFire")
createToggle(miscTab, "God Mode", "GodMode")
createSlider(miscTab, "Aim FOV", "AimFOV", 0, 360, 150)
createSlider(miscTab, "Aim Smooth", "AimSmooth", 0, 1, 0.08)
createSlider(miscTab, "Walk Speed", "WalkSpeed", 16, 200, 16)
createSlider(miscTab, "Damage Multiplier", "DamageMultiplier", 1, 10, 1)

-- Tab Default
homeTab.Visible = true
tabButtons["Home"].BackgroundColor3 = Color3.fromRGB(0, 102, 204)
tabButtons["Home"].TextColor3 = Color3.fromRGB(255, 255, 255)
