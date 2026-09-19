local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Lite Hack + Ultimate Mods",
   LoadingTitle = "Memuat Cheat...",
   LoadingSubtitle = "Deep Memory Gun Mods Aktif!",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "PointBloxConfig",
      FileName = "Setting"
   }
})

-- NOTIFIKASI AWAL
Rayfield:Notify({
   Title = "Memuat Cheat...",
   Content = "Deep Memory Gun Mods Aktif!",
   Duration = 5,
   Image = 4483362458,
})

-- TAB 1: MAIN FEATURES
local MainTab = Window:CreateTab("Main Features", 4483362458)

MainTab:CreateToggle({
   Name = "Peringatan Admin (Popup Warning)",
   CurrentValue = false,
   Flag = "AdminWarn",
   Callback = function(Value)
      -- Logika Peringatan Admin
   end,
})

MainTab:CreateToggle({
   Name = "Aktifkan Auto Aim (Kunci Layar)",
   CurrentValue = false,
   Flag = "AutoAim",
   Callback = function(Value)
      -- Logika Auto Aim
   end,
})

MainTab:CreateDropdown({
   Name = "Mode Aimbot",
   Options = {"POV Kamera (FOV)", "Distance", "Nearest"},
   CurrentOption = {"POV Kamera (FOV)"},
   MultipleOptions = false,
   Flag = "AimbotMode",
   Callback = function(Option)
      -- Logika Mode Aimbot
   end,
})

MainTab:CreateDropdown({
   Name = "Target Bagian Tubuh",
   Options = {"Head", "Torso", "HumanoidRootPart"},
   CurrentOption = {"Head"},
   MultipleOptions = false,
   Flag = "AimTarget",
   Callback = function(Option)
      -- Logika Target
   end,
})

-- Kelengketan Aim dibuat lebih halus (Nilai default diset ke 5% agar tidak terlalu brutal)
MainTab:CreateSlider({
   Name = "Kelengketan Aim POV (Smoothness)",
   Range = {1, 100},
   Increment = 1,
   Suffix = "%",
   CurrentValue = 5, -- Default 5% agar pergerakan Aim halus/legit
   Flag = "AimSmoothness",
   Callback = function(Value)
      -- Atur kelengketan Aim
   end,
})

MainTab:CreateToggle({
   Name = "Tampilkan Lingkaran FOV",
   CurrentValue = false,
   Flag = "ShowFOV",
   Callback = function(Value)
      -- Logika Tampil FOV
   end,
})

-- Lebar Lingkaran FOV diperkecil (Default diset ke 60px agar tidak terlalu lebar)
MainTab:CreateSlider({
   Name = "Lebar Lingkaran FOV",
   Range = {30, 300},
   Increment = 5,
   Suffix = "Px",
   CurrentValue = 60, -- Default 60px agar area FOV pas/tidak terlalu lebar
   Flag = "FOVSize",
   Callback = function(Value)
      -- Atur ukuran lingkaran FOV
   end,
})

-- Enemy ESP dengan opsi Box (Kotak) & Tracer (Garis Merah/Hitam)
MainTab:CreateToggle({
   Name = "Enemy ESP (Box & Line)",
   CurrentValue = false,
   Flag = "EnemyESP",
   Callback = function(Value)
      -- Logika ESP: Menampilkan Garis Merah/Hitam & Kotak di sekitar musuh
   end,
})

MainTab:CreateDropdown({
   Name = "Warna Garis ESP",
   Options = {"Merah", "Hitam"},
   CurrentOption = {"Merah"},
   MultipleOptions = false,
   Flag = "ESPColor",
   Callback = function(Option)
      -- Atur warna garis tracer ESP
   end,
})

-- TAB 2: GUN MODS
local GunTab = Window:CreateTab("Gun Mods", 4483362458)

GunTab:CreateToggle({
   Name = "Gun Mods (Infinite Ammo & RPM)",
   CurrentValue = false,
   Flag = "GunModsToggle",
   Callback = function(Value)
      -- Logika Gun Mods
   end,
})

GunTab:CreateSlider({
   Name = "RPM Fire Rate",
   Range = {100, 1200},
   Increment = 50,
   Suffix = "RPM",
   CurrentValue = 800,
   Flag = "RPMSpeed",
   Callback = function(Value)
      -- Atur RPM
   end,
})

-- TAB 3: CONFIGURATION
local ConfigTab = Window:CreateTab("Configuration", 4483362458)

ConfigTab:CreateSection("Simpan settinganmu agar tidak perlu ngatur ulang saat pindah room.")

ConfigTab:CreateButton({
   Name = "Save Konfigurasi",
   Callback = function()
      Rayfield:SaveConfiguration()
   end,
})

ConfigTab:CreateButton({
   Name = "Load Konfigurasi",
   Callback = function()
      -- Logika Load Config
   end,
})

ConfigTab:CreateButton({
   Name = "Reset Semua ke Default",
   Callback = function()
      -- Logika Reset Default
   end,
})
