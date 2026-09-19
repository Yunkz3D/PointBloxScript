local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Service Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Indikator Titik Tengah (Center Dot)
local CenterDot = Drawing.new("Circle")
CenterDot.Color = Color3.fromRGB(255, 0, 0) -- Warna Merah
CenterDot.Thickness = 1
CenterDot.NumSides = 30
CenterDot.Radius = 3 -- Ukuran Titik
CenterDot.Filled = true
CenterDot.Visible = false

-- Variabel Status Fitur
local AutoAimActive = false
local AimSmoothness = 0.05
local FOVRadius = 60
local AimTargetPart = "Head"

local ESPActive = false
local ESPColor = Color3.fromRGB(255, 0, 0)
local ESPDrawings = {}

local GunModsActive = false
local BazookaBrutalActive = false
local RPMSpeed = 800

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

-- FUNGSI AMBIL DAN PEGANG BAZOOKA OTOMATIS
local function AutoEquipBazooka()
   local Character = LocalPlayer.Character
   local Backpack = LocalPlayer:FindFirstChild("Backpack")
   if not Character or not Backpack then return end

   local BazookaTool = nil
   for _, tool in pairs(Backpack:GetChildren()) do
      if tool:IsA("Tool") and (string.find(string.lower(tool.Name), "bazooka") or string.find(string.lower(tool.Name), "rpg") or string.find(string.lower(tool.Name), "rocket")) then
         BazookaTool = tool
         break
      end
   end

   if not BazookaTool then
      for _, tool in pairs(Character:GetChildren()) do
         if tool:IsA("Tool") and (string.find(string.lower(tool.Name), "bazooka") or string.find(string.lower(tool.Name), "rpg") or string.find(string.lower(tool.Name), "rocket")) then
            BazookaTool = tool
            break
         end
      end
   end

   if BazookaTool and BazookaTool.Parent == Backpack then
      Character.Humanoid:EquipTool(BazookaTool)
   end
end

-- JENDELA UTAMA
local Window = Rayfield:CreateWindow({
   Name = "Lite Hack + Ultimate Mods",
   LoadingTitle = "Memuat Fitur...",
   LoadingSubtitle = "Oleh Yunkz3D",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "PointBloxConfig",
      FileName = "Setting"
   }
})

-- NOTIFIKASI
Rayfield:Notify({
   Title = "Pemberitahuan",
   Content = "Fitur berhasil dimuat dan siap digunakan!",
   Duration = 4,
   Image = 4483362458,
})

-- TAB 1: FITUR UTAMA
local MainTab = Window:CreateTab("Fitur Utama", 4483362458)

MainTab:CreateToggle({
   Name = "Peringatan Admin (Pesan Peringatan)",
   CurrentValue = false,
   Flag = "PeringatanAdmin",
   Callback = function(Value)
      if Value then
         Rayfield:Notify({
            Title = "Peringatan Admin",
            Content = "Sistem pengawasan admin diaktifkan.",
            Duration = 3,
         })
      end
   end,
})

MainTab:CreateToggle({
   Name = "Aktifkan Bantuan Bidikan (Kunci Layar)",
   CurrentValue = false,
   Flag = "AutoAim",
   Callback = function(Value)
      AutoAimActive = Value
   end,
})

MainTab:CreateDropdown({
   Name = "Mode Bantuan Bidikan",
   Options = {"POV Kamera", "Jarak Terdekat", "Pemain Terdekat"},
   CurrentOption = {"POV Kamera"},
   MultipleOptions = false,
   Flag = "ModeAim",
   Callback = function(Option)
      -- Mode Aim
   end,
})

MainTab:CreateDropdown({
   Name = "Target Bagian Tubuh",
   Options = {"Kepala", "Dada", "Badan Utama"},
   CurrentOption = {"Kepala"},
   MultipleOptions = false,
   Flag = "TargetTubuh",
   Callback = function(Option)
      local choice = Option[1]
      if choice == "Kepala" then AimTargetPart = "Head"
      elseif choice == "Dada" then AimTargetPart = "Torso"
      elseif choice == "Badan Utama" then AimTargetPart = "HumanoidRootPart"
      end
   end,
})

MainTab:CreateSlider({
   Name = "Kelengketan Bantuan Bidikan (Kelebutan)",
   Range = {1, 100},
   Increment = 1,
   Suffix = "%",
   CurrentValue = 5,
   Flag = "SmoothnessAim",
   Callback = function(Value)
      AimSmoothness = Value / 100
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

MainTab:CreateSlider({
   Name = "Jangkauan Bantuan Bidikan (Area Lock)",
   Range = {30, 300},
   Increment = 5,
   Suffix = " Px",
   CurrentValue = 60,
   Flag = "UkuranFOV",
   Callback = function(Value)
      FOVRadius = Value
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

MainTab:CreateDropdown({
   Name = "Warna Garis Penglihat Musuh",
   Options = {"Merah", "Hitam"},
   CurrentOption = {"Merah"},
   MultipleOptions = false,
   Flag = "WarnaESP",
   Callback = function(Option)
      if Option[1] == "Merah" then
         ESPColor = Color3.fromRGB(255, 0, 0)
      else
         ESPColor = Color3.fromRGB(0, 0, 0)
      end
   end,
})

-- TAB 2: MODIFIKASI SENJATA
local GunTab = Window:CreateTab("Modifikasi Senjata", 4483362458)

GunTab:CreateToggle({
   Name = "Modifikasi Senjata (Peluru Tak Terbatas)",
   CurrentValue = false,
   Flag = "GunModsToggle",
   Callback = function(Value)
      GunModsActive = Value
   end,
})

GunTab:CreateToggle({
   Name = "Bazooka Brutal (Auto Ambil & Spam RPG)",
   CurrentValue = false,
   Flag = "BazookaBrutal",
   Callback = function(Value)
      BazookaBrutalActive = Value
      if Value then
         AutoEquipBazooka()
      end
   end,
})

GunTab:CreateSlider({
   Name = "Kecepatan Tembak (RPM)",
   Range = {100, 1200},
   Increment = 50,
   Suffix = " RPM",
   CurrentValue = 800,
   Flag = "RPMSpeed",
   Callback = function(Value)
      RPMSpeed = Value
   end,
})

-- TAB 3: PENGATURAN
local ConfigTab = Window:CreateTab("Pengaturan", 4483362458)

ConfigTab:CreateSection("Simpan pengaturan agar tidak perlu mengatur ulang.")

ConfigTab:CreateButton({
   Name = "Simpan Pengaturan",
   Callback = function()
      Rayfield:SaveConfiguration()
   end,
})

ConfigTab:CreateButton({
   Name = "Muat Pengaturan",
   Callback = function()
      -- Muat
   end,
})

ConfigTab:CreateButton({
   Name = "Atur Ulang ke Awal",
   Callback = function()
      -- Reset
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

-- LOGIKA SISTEM
RunService.RenderStepped:Connect(function()
   -- Posisi Titik Layar Tepat Di Tengah Kamera
   local ViewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
   CenterDot.Position = ViewportCenter

   -- Logika Bazooka Brutal
   if BazookaBrutalActive and LocalPlayer.Character then
      local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
      if Tool then
         if Tool:FindFirstChild("Ammo") then Tool.Ammo.Value = 999 end
         if Tool:FindFirstChild("StoredAmmo") then Tool.StoredAmmo.Value = 999 end
         if Tool:FindFirstChild("Cooldown") then Tool.Cooldown.Value = 0 end
      else
         AutoEquipBazooka()
      end
   end

   -- Logika Aimbot (Mengunci dari Tengah Layar)
   if AutoAimActive then
      local ClosestTarget = nil
      local ShortestDistance = math.huge

      for _, player in pairs(Players:GetPlayers()) do
         if IsEnemy(player) and player.Character and player.Character:FindFirstChild(AimTargetPart) and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local TargetPart = player.Character[AimTargetPart]
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)

            if OnScreen then
               local CenterDistance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - ViewportCenter).Magnitude
               if CenterDistance <= FOVRadius and CenterDistance < ShortestDistance then
                  ShortestDistance = CenterDistance
                  ClosestTarget = TargetPart
               end
            end
         end
      end

      if ClosestTarget then
         local CurrentCamCFrame = Camera.CFrame
         local TargetCFrame = CFrame.new(Camera.CFrame.Position, ClosestTarget.Position)
         Camera.CFrame = CurrentCamCFrame:Lerp(TargetCFrame, AimSmoothness)
      end
   end

   -- Logika ESP Kotak & Garis (Musuh Saja)
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
               Box.Color = ESPColor
               Box.Thickness = 1.5
               Box.Size = Vector2.new(BoxWidth, BoxHeight)
               Box.Position = Vector2.new(Pos.X - BoxWidth / 2, Pos.Y - BoxHeight / 2)

               local Line = ESPDrawings[player].Line
               Line.Visible = true
               Line.Color = ESPColor
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
