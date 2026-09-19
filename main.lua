local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Service Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Indikator Titik Tengah (Center Crosshair RGB)
local CenterDot = Drawing.new("Circle")
CenterDot.Color = Color3.fromRGB(255, 0, 0)
CenterDot.Thickness = 1
CenterDot.NumSides = 30
CenterDot.Radius = 3
CenterDot.Filled = true
CenterDot.Visible = false

-- Variabel Status Fitur
local AutoAimActive = false
local AimSmoothness = 0.25 -- Fleksibel & Tidak Kaku
local AimTargetOption = "Kepala"
local MaxDistance = 80 -- Jarak Maksimal Lock (Hanya Musuh Dekat)

local ESPActive = false
local ESPColor = Color3.fromRGB(255, 0, 0)
local ESPDrawings = {}

local AutoGrenadeActive = false
local NoRecoilActive = false

-- FUNGSI HITUNG WARNA RGB (RAINBOW EFFECT)
local function GetRGBColor()
   local Hue = (tick() % 3) / 3
   return Color3.fromHSV(Hue, 1, 1)
end

-- FUNGSI CEK MUSUH (TEAM CHECK)
local function IsEnemy(player)
   if player == LocalPlayer then return false end
   if LocalPlayer.Team and player.Team then
      return LocalPlayer.Team ~= player.Team
   end
   if player:FindFirstChild("TeamColor") and LocalPlayer:FindFirstChild("TeamColor") then
      return player.TeamColor ~= LocalPlayer.TeamColor
   end
   return true
end

-- FUNGSI AMBIL GRANAT DARI BACKPACK
local function AutoEquipGrenade()
   local Character = LocalPlayer.Character
   local Backpack = LocalPlayer:FindFirstChild("Backpack")
   if not Character or not Backpack then return end

   local GrenadeTool = nil
   for _, tool in pairs(Backpack:GetChildren()) do
      if tool:IsA("Tool") and (string.find(string.lower(tool.Name), "grenade") or string.find(string.lower(tool.Name), "granat") or string.find(string.lower(tool.Name), "bomb") or string.find(string.lower(tool.Name), "m67")) then
         GrenadeTool = tool
         break
      end
   end

   if GrenadeTool then
      Character.Humanoid:EquipTool(GrenadeTool)
   end
end

-- JENDELA UTAMA
local Window = Rayfield:CreateWindow({
   Name = "PointBlox Hub (Close Range Lock)",
   LoadingTitle = "Memuat Fitur...",
   LoadingSubtitle = "Oleh Yunkz3D",
   Theme = "Default",
   CustomTheme = {
      TextColor = Color3.fromRGB(255, 255, 255),
      Background = Color3.fromRGB(15, 15, 15),
      Topbar = Color3.fromRGB(25, 25, 25),
      Shadow = Color3.fromRGB(0, 0, 0),
      NotificationBackground = Color3.fromRGB(20, 20, 20),
      NotificationActionsBackground = Color3.fromRGB(230, 230, 230),
      TabBackground = Color3.fromRGB(25, 25, 25),
      TabStroke = Color3.fromRGB(255, 0, 0),
      TabBackgroundSelected = Color3.fromRGB(40, 40, 40),
      ElementBackground = Color3.fromRGB(25, 25, 25),
      ElementBackgroundHover = Color3.fromRGB(35, 35, 35),
      ElementStroke = Color3.fromRGB(255, 0, 0),
      SecondaryElementBackground = Color3.fromRGB(20, 20, 20),
      SecondaryElementStroke = Color3.fromRGB(40, 40, 40),
      SliderBackground = Color3.fromRGB(30, 30, 30),
      SliderProgress = Color3.fromRGB(255, 0, 0),
      SliderStroke = Color3.fromRGB(255, 0, 0),
      ToggleBackground = Color3.fromRGB(30, 30, 30),
      ToggleEnabled = Color3.fromRGB(255, 0, 0),
      ToggleDisabled = Color3.fromRGB(80, 80, 80),
      DropdownBackground = Color3.fromRGB(25, 25, 25),
      DropdownStroke = Color3.fromRGB(255, 0, 0),
      InputBackground = Color3.fromRGB(25, 25, 25),
      InputStroke = Color3.fromRGB(255, 0, 0),
      PlaceholderColor = Color3.fromRGB(178, 178, 178)
   },
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "PointBloxConfig",
      FileName = "Setting"
   }
})

-- NOTIFIKASI
Rayfield:Notify({
   Title = "Pemberitahuan",
   Content = "Sistem Lock Musuh Terdekat Berhasil Dimuat!",
   Duration = 4,
   Image = 4483362458,
})

-- TAB 1: FITUR UTAMA
local MainTab = Window:CreateTab("Fitur Utama", 4483362458)

MainTab:CreateToggle({
   Name = "Aktifkan Bantuan Bidikan (Musuh Terdekat)",
   CurrentValue = false,
   Flag = "AutoAim",
   Callback = function(Value)
      AutoAimActive = Value
   end,
})

MainTab:CreateSlider({
   Name = "Jarak Maksimal Lock Musuh",
   Range = {20, 200},
   Increment = 5,
   Suffix = " Studs",
   CurrentValue = 80,
   Flag = "MaxDistanceSlider",
   Callback = function(Value)
      MaxDistance = Value
   end,
})

MainTab:CreateDropdown({
   Name = "Tingkat Kelengketan Kamera",
   Options = {"Biasa (Halus)", "Sedang (Sangat Fleksibel)", "Besar (Responsif)"},
   CurrentOption = {"Sedang (Sangat Fleksibel)"},
   MultipleOptions = false,
   Flag = "PresetKelengketan",
   Callback = function(Option)
      local val = Option[1]
      if val == "Biasa (Halus)" then
         AimSmoothness = 0.08
      elseif val == "Sedang (Sangat Fleksibel)" then
         AimSmoothness = 0.25
      elseif val == "Besar (Responsif)" then
         AimSmoothness = 0.40
      end
   end,
})

MainTab:CreateDropdown({
   Name = "Target Bagian Tubuh",
   Options = {"Kepala", "Dada", "Badan Utama", "Acak (Kepala / Dada)"},
   CurrentOption = {"Kepala"},
   MultipleOptions = false,
   Flag = "TargetTubuh",
   Callback = function(Option)
      AimTargetOption = Option[1]
   end,
})

MainTab:CreateToggle({
   Name = "Tampilkan Titik Tengah (Center Crosshair)",
   CurrentValue = false,
   Flag = "ShowCenterDot",
   Callback = function(Value)
      CenterDot.Visible = Value
   end,
})

MainTab:CreateToggle({
   Name = "Penglihat Musuh (Kotak & Garis)",
   CurrentValue = false,
   Flag = "EnemyESP",
   Callback = function(Value)
      ESPActive = Value
      if not Value then
         for _, draw in pairs(ESPDrawings) do
            if draw.Box then draw.Box:Remove() end
            if draw.Line then draw.Line:Remove() end
         end
         ESPDrawings = {}
      end
   end,
})

-- TAB 2: MODIFIKASI SENJATA
local GunTab = Window:CreateTab("Modifikasi Senjata", 4483362458)

GunTab:CreateToggle({
   Name = "Tanpa Rekoil (Stabil 1 Titik)",
   CurrentValue = false,
   Flag = "NoRecoilToggle",
   Callback = function(Value)
      NoRecoilActive = Value
   end,
})

GunTab:CreateToggle({
   Name = "Auto Ambil & Refill Granat",
   CurrentValue = false,
   Flag = "AutoGrenade",
   Callback = function(Value)
      AutoGrenadeActive = Value
      if Value then
         AutoEquipGrenade()
      end
   end,
})

-- TAB 3: PENGATURAN
local ConfigTab = Window:CreateTab("Pengaturan", 4483362458)

ConfigTab:CreateSection("Simpan pengaturan agar tidak perlu mengatur ulang.")

ConfigTab:CreateButton({
   Name = "Simpan Pengaturan",
   Callback = function()
      Rayfield:SaveConfiguration()
      Rayfield:Notify({Title = "Pengaturan", Content = "Pengaturan tersimpan!", Duration = 3})
   end,
})

ConfigTab:CreateButton({
   Name = "Muat Pengaturan",
   Callback = function()
      Rayfield:LoadConfiguration()
      Rayfield:Notify({Title = "Pengaturan", Content = "Pengaturan berhasil dimuat!", Duration = 3})
   end,
})

-- FUNGSI HAPUS ESP PLAYER KELUAR/MATI
local function ClearPlayerESP(player)
   if ESPDrawings[player] then
      if ESPDrawings[player].Box then ESPDrawings[player].Box:Remove() end
      if ESPDrawings[player].Line then ESPDrawings[player].Line:Remove() end
      ESPDrawings[player] = nil
   end
end

Players.PlayerRemoving:Connect(ClearPlayerESP)

-- LOGIKA SISTEM UTAMA
RunService.RenderStepped:Connect(function()
   local CurrentRGB = GetRGBColor()
   local ViewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
   
   -- Titik Tengah RGB
   CenterDot.Position = ViewportCenter
   CenterDot.Color = CurrentRGB

   -- Logika No Recoil
   if NoRecoilActive and LocalPlayer.Character then
      local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
      if Tool then
         for _, v in pairs(Tool:GetDescendants()) do
            if v:IsA("Value") or v:IsA("NumberValue") or v:IsA("IntValue") then
               local name = string.lower(v.Name)
               if string.find(name, "recoil") or string.find(name, "spread") or string.find(name, "accuracy") or string.find(name, "kick") then
                  v.Value = 0
               end
            end
         end
      end
   end

   -- Logika Refill Granat
   if AutoGrenadeActive and LocalPlayer.Character then
      local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
      if not Tool or not (string.find(string.lower(Tool.Name), "grenade") or string.find(string.lower(Tool.Name), "granat") or string.find(string.lower(Tool.Name), "bomb") or string.find(string.lower(Tool.Name), "m67")) then
         AutoEquipGrenade()
      end
   end

   -- Logika Aimbot khusus Musuh Terdekat (Jarak Dekat Only)
   if AutoAimActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
      local MyPosition = LocalPlayer.Character.HumanoidRootPart.Position
      local ClosestTarget = nil
      local ShortestWorldDistance = MaxDistance

      local SelectedPart = "Head"
      if AimTargetOption == "Kepala" then
         SelectedPart = "Head"
      elseif AimTargetOption == "Dada" then
         SelectedPart = "Torso"
      elseif AimTargetOption == "Badan Utama" then
         SelectedPart = "HumanoidRootPart"
      elseif AimTargetOption == "Acak (Kepala / Dada)" then
         SelectedPart = (math.random(1, 2) == 1) and "Head" or "Torso"
      end

      -- Cari musuh berdasarkan JARAK FISIK (Studs) terdekat dari karakter kita
      for _, player in pairs(Players:GetPlayers()) do
         if IsEnemy(player) and player.Character and player.Character:FindFirstChild(SelectedPart) and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local TargetPart = player.Character[SelectedPart]
            local WorldDistance = (TargetPart.Position - MyPosition).Magnitude

            -- Hanya kunci jika jarak musuh berada di bawah batas MaxDistance
            if WorldDistance <= ShortestWorldDistance then
               local _, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
               if OnScreen then
                  ShortestWorldDistance = WorldDistance
                  ClosestTarget = TargetPart
               end
            end
         end
      end

      -- Kunci Kamera dengan Transisi Mulus (Layar Tetap Bebas Digerakkan)
      if ClosestTarget then
         local TargetCFrame = CFrame.new(Camera.CFrame.Position, ClosestTarget.Position)
         Camera.CFrame = Camera.CFrame:Lerp(TargetCFrame, AimSmoothness)
      end
   end

   -- Logika ESP Kotak & Garis RGB
   if ESPActive then
      for _, player in pairs(Players:GetPlayers()) do
         if IsEnemy(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local Char = player.Character
            local Root = Char.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)

            if OnScreen then
               if not ESPDrawings[player] then
                  ESPDrawings[player] = {
                     Box = Drawing.new("Square"),
                     Line = Drawing.new("Line")
                  }
               end

               local CFramePos, Size = Char:GetBoundingBox()
               local TopPos = Camera:WorldToViewportPoint((CFramePos * CFrame.new(0, Size.Y / 2, 0)).Position)
               local BottomPos = Camera:WorldToViewportPoint((CFramePos * CFrame.new(0, -Size.Y / 2, 0)).Position)
               local BoxHeight = math.abs(TopPos.Y - BottomPos.Y)
               local BoxWidth = BoxHeight / 1.5

               local Box = ESPDrawings[player].Box
               Box.Visible = true
               Box.Color = CurrentRGB
               Box.Thickness = 1.5
               Box.Size = Vector2.new(BoxWidth, BoxHeight)
               Box.Position = Vector2.new(Pos.X - BoxWidth / 2, Pos.Y - BoxHeight / 2)

               local Line = ESPDrawings[player].Line
               Line.Visible = true
               Line.Color = CurrentRGB
               Line.Thickness = 1.5
               Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
               Line.To = Vector2.new(Pos.X, Pos.Y)
            else
               ClearPlayerESP(player)
            end
         else
            ClearPlayerESP(player)
         end
      end
   end
end)
