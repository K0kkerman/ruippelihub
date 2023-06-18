local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local Players = game:GetService("Players")



-- Aimbot
local dwCamera = workspace.CurrentCamera
local dwRunService = game:GetService("RunService")
local dwUIS = game:GetService("UserInputService")
local dwEntities = game:GetService("Players")
local dwLocalPlayer = dwEntities.LocalPlayer
local dwMouse = dwLocalPlayer:GetMouse()

-- Variables
local SpinEnabled = false
local ReverseSpinEnabled = false
local JitterModeEnabled = false
local SpinSpeed = 0
local Character = Players.LocalPlayer.Character

local DefaultWalkSpeed = 16
local DefaultJumpPower = 50
local DefaultFOV = 70

NoUI = false

local function getRandomColor()
    local min = 0
    local max = 255
    return Color3.fromRGB(
        math.random(min, max),
        math.random(min, max),
        math.random(min, max)
    )
end
-- Aimbot settings
local settings = {
    Aimbot = false,
    Aiming = false,
    Aimbot_AimPart = "Head",
    Aimbot_TeamCheck = false,
    Aimbot_FOV_Radius = 5,
}

dwUIS.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        settings.Aiming = true
    end
end)

dwUIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        settings.Aiming = false
    end
end)

dwRunService.RenderStepped:Connect(function()
    local dist = math.huge
    local closest_char = nil
    if settings.Aimbot and settings.Aiming then
        for i, v in next, dwEntities:GetChildren() do
            if v ~= dwLocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character:FindFirstChild("Humanoid").Health > 0 then
                if settings.Aimbot_TeamCheck == true and v.Team ~= dwLocalPlayer.Team or settings.Aimbot_TeamCheck == false then
                    local char = v.Character
                    local char_part_pos, is_onscreen = dwCamera:WorldToViewportPoint(char[settings.Aimbot_AimPart].Position)
                    if is_onscreen then
                        local mag = (Vector2.new(dwMouse.X, dwMouse.Y) - Vector2.new(char_part_pos.X, char_part_pos.Y)).Magnitude
                        if mag < dist and mag < settings.Aimbot_FOV_Radius then
                            dist = mag
                            closest_char = char
                        end
                    end
                end
            end
        end

        if closest_char ~= nil and closest_char:FindFirstChild("HumanoidRootPart") and closest_char:FindFirstChild("Humanoid") and closest_char:FindFirstChild("Humanoid").Health > 0 then
            dwCamera.CFrame = CFrame.new(dwCamera.CFrame.Position, closest_char[settings.Aimbot_AimPart].Position)
        end
    end
end)

--esp func

_G.ESP = false
_G.ESPColor = Color3.fromRGB(255, 255, 255)

pcall(
    function()
        local highlight = Instance.new("Highlight")

        game:GetService("RunService").RenderStepped:Connect(
            function()
                for _, v in pairs(game.Players:GetPlayers()) do
                    if not v.Character:FindFirstChild("Highlight") then
                        highlight.FillTransparency = 1
                        highlight:Clone().Parent = v.Character
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    end

                    game.Players.PlayerAdded:Connect(
                        function(plr)
                            plr.CharacterAdded:Connect(
                                function(char)
                                    if not char:FindFirstChild("Highlight") then
                                        highlight.FillTransparency = 1
                                        highlight:Clone().Parent = char
                                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                                    end
                                end
                            )
                        end
                    )
                end

                for _, v in pairs(game.Players:GetPlayers()) do
                    local hl = v.Character:FindFirstChild("Highlight")
                    hl.Enabled = _G.ESP
                    hl.OutlineColor = _G.ESPColor
                end
            end
        )
    end
)

-- Function to update the character's rotation
local function UpdateCharacterRotation()
    if SpinEnabled and Character then
        local rotation = math.rad(SpinSpeed)
        if ReverseSpinEnabled then
            rotation = rotation * -1
        end
        if JitterModeEnabled then
            rotation = rotation * (math.random() < 0.5 and -1 or 1)
        end
        local newCFrame = Character:GetPrimaryPartCFrame() * CFrame.Angles(0, rotation, 0)
        Character:SetPrimaryPartCFrame(newCFrame)
    end
end

local function UpdateWalkSpeedSlider()
    walkSpeedSlider:SetValue(Character.Humanoid.WalkSpeed)
end

local function UpdateJumpPowerSlider()
    jumpPowerSlider:SetValue(Character.Humanoid.JumpPower)
end

local function UpdateFOVSlider()
    fovSlider:SetValue(workspace.CurrentCamera.FieldOfView)
end

local Window = Library:CreateWindow({
    Title = 'Ruippeli',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2,
    Size = UDim2.fromOffset(550, 285),
})



local Tabs = {
    Combat = Window:AddTab('combat'),
    Main = Window:AddTab('misc'),
    Menu = Window:AddTab('menu'),
}

local LeftMisc = Tabs.Main:AddLeftGroupbox('antiaim')
local RightMisc = Tabs.Main:AddRightGroupbox('humnoid')

local LeftMenu = Tabs.Menu:AddLeftGroupbox('main')
local RightMenu = Tabs.Menu:AddRightGroupbox('customize')

local LeftCombat = Tabs.Combat:AddLeftGroupbox('aimbot')
local RightCombat = Tabs.Combat:AddRightGroupbox('visual')

local Humanoid = Character:WaitForChild('Humanoid')

LeftCombat:AddToggle('toggle', {
    Text = 'toggle',
    Default = false,
    Callback = function(value)
        settings.Aimbot = value
    end
})

LeftCombat:AddToggle('teamcheck', {
    Text = 'teamcheck',
    Default = false,
    Callback = function(value)
        settings.Aimbot_TeamCheck = value
    end
})

LeftCombat:AddSlider('fov', {
    Text = 'fov',
    Default = 5,
    Min = 5,
    Max = 500,
    Rounding = 1,
    Callback = function(value)
        settings.Aimbot_FOV_Radius = value
    end
})  

RightCombat:AddToggle('outline', {
    Text = 'outline',
    Default = false,
    Callback = function(value)
        _G.ESP = value
    end
})

RightCombat:AddLabel('color'):AddColorPicker('color', {
    Default = Color3.new(1, 1, 1),
    Title = 'Some color', 
    Transparency = 0,

    Callback = function(value)
        _G.ESPColor = value
    end
})


LeftMenu:AddButton('unload', function()
    Library:Unload()
    settings.Aimbot = false
    _G.ESP = false
end)




LeftMisc:AddToggle('toggle', {
    Text = 'toggle',
    Default = false,
    Callback = function(value)
        SpinEnabled = value
        if value then
            -- Start spinning
            game:GetService("RunService").Heartbeat:Connect(UpdateCharacterRotation)
        end
    end
})

LeftMisc:AddSlider('Spin Speed', {
    Text = 'speed',
    Default = 0,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Callback = function(value)
        SpinSpeed = value
    end
})

LeftMisc:AddToggle('Reverse Spin', {
    Text = 'reverse',
    Default = false,
    Callback = function(value)
        ReverseSpinEnabled = value
    end
})

LeftMisc:AddToggle('Jitter Mode', {
    Text = 'jitter',
    Default = false,
    Callback = function(value)
        JitterModeEnabled = value
    end
})

RightMisc:AddSlider('Walkspeed', {
    Text = 'walkspeed',
    Default = Humanoid.WalkSpeed,
    Min = 16,
    Max = 300,
    Rounding = 1,
    Callback = function(value)
        Humanoid.WalkSpeed = value
    end
})

RightMisc:AddSlider('Jump Strength', {
    Text = 'jump force',
    Default = Humanoid.JumpPower,
    Min = 50,
    Max = 300,
    Rounding = 1,
    Callback = function(value)
        Humanoid.JumpPower = value
    end
})

RightMisc:AddButton('reset', function()
    if Character and Character:FindFirstChild("Humanoid") then
        local humanoid = Character.Humanoid
        humanoid.WalkSpeed = DefaultWalkSpeed
        humanoid.JumpPower = DefaultJumpPower
        UpdateWalkSpeedSlider()
        UpdateJumpPowerSlider()
    end
end)

RightMisc:AddSlider('FOV', {
    Text = 'fov',
    Default = DefaultFOV,
    Min = 70,
    Max = 120,
    Rounding = 0,
    Callback = function(value)
        workspace.CurrentCamera.FieldOfView = value
        if ForceFOVEnabled then
            UpdateFOV()
        end
    end
})

RightMisc:AddButton('reset fOV', function()
    workspace.CurrentCamera.FieldOfView = DefaultFOV
    UpdateFOVSlider()
end)

RightMenu:AddLabel('font color'):AddColorPicker('font color', {
    Default =  Color3.fromRGB(255, 255, 255),
    Title = 'font color', 
    Transparency = 0,

    Callback = function(value)
        Library.FontColor = value
        Library:UpdateColorsUsingRegistry()
    end
})

RightMenu:AddLabel('main color'):AddColorPicker('main color', {
    Default = Color3.fromRGB(28, 28, 28),
    Title = 'main color', 
    Transparency = 0,

    Callback = function(value)
        Library.MainColor = value
        Library:UpdateColorsUsingRegistry()
    end
})

RightMenu:AddLabel('background color'):AddColorPicker('background color', {
    Default = Color3.fromRGB(20, 20, 20),
    Title = 'background color', 
    Transparency = 0,

    Callback = function(value)
        Library.BackgroundColor = value
        Library:UpdateColorsUsingRegistry()
    end
})

RightMenu:AddLabel('accent color'):AddColorPicker('accent color', {
    Default = Color3.fromRGB(255, 0, 15),
    Title = 'accent color', 
    Transparency = 0,

    Callback = function(value)
        Library.AccentColor = value
        Library:UpdateColorsUsingRegistry()
    end
})

RightMenu:AddLabel('outline color'):AddColorPicker('outline color', {
    Default = Color3.fromRGB(50, 50, 50),
    Title = 'outline color', 
    Transparency = 0,

    Callback = function(value)
        Library.OutlineColor = value
        Library:UpdateColorsUsingRegistry()
    end
})

RightMenu:AddLabel('risk color'):AddColorPicker('risk color', {
    Default = Color3.fromRGB(255, 50, 50),
    Title = 'risk color', 
    Transparency = 0,

    Callback = function(value)
        Library.RiskColor = value
        Library:UpdateColorsUsingRegistry()
    end
})

Library.FontColor = Color3.fromRGB(255, 255, 255)
Library.MainColor = Color3.fromRGB(28, 28, 28)
Library.BackgroundColor = Color3.fromRGB(20, 20, 20)
Library.AccentColor = Color3.fromRGB(255, 0, 15)
Library.OutlineColor = Color3.fromRGB(50, 50, 50)
Library.RiskColor = Color3.fromRGB(255, 50, 50)
Library:UpdateColorsUsingRegistry()

RightMenu:AddButton('random colors', function()
    Library.FontColor = getRandomColor()
    Library.MainColor = getRandomColor()
    Library.BackgroundColor = getRandomColor()
    Library.AccentColor = getRandomColor()
    Library.OutlineColor = getRandomColor()
    Library.RiskColor = getRandomColor()
    Library:UpdateColorsUsingRegistry()
end)

RightMenu:AddButton('reset', function()
    Library.FontColor = Color3.fromRGB(255, 255, 255)
    Library.MainColor = Color3.fromRGB(28, 28, 28)
    Library.BackgroundColor = Color3.fromRGB(20, 20, 20)
    Library.AccentColor = Color3.fromRGB(255, 0, 15)
    Library.OutlineColor = Color3.fromRGB(50, 50, 50)
    Library.RiskColor = Color3.fromRGB(255, 50, 50)
    Library:UpdateColorsUsingRegistry()
end)


LeftMenu:AddLabel('menu bind'):AddKeyPicker('MenuKeybind', { Default = 'Insert', NoUI = true, Text = 'Menu keybind' })


Library.KeybindFrame.Visible = false


Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
