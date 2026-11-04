--========================================================
--                   GORILLA HUB LOADER
--        Everything in one file (No HttpGet for modules)
--========================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--========================================================
-- GAME SELECTOR UI
--========================================================

local SelectorGui = Instance.new("ScreenGui")
SelectorGui.Name = "GorillaSelector"
SelectorGui.IgnoreGuiInset = true
SelectorGui.ResetOnSpawn = false
SelectorGui.DisplayOrder = 100
SelectorGui.Parent = PlayerGui

local Splash = Instance.new("Frame", SelectorGui)
Splash.Size = UDim2.fromScale(1, 1)
Splash.BackgroundColor3 = Color3.fromRGB(5, 8, 13)
Splash.BackgroundTransparency = 0.1
Splash.BorderSizePixel = 0

local Panel = Instance.new("Frame", Splash)
Panel.Size = UDim2.fromOffset(710, 465)
Panel.Position = UDim2.fromScale(0.5, 0.5)
Panel.AnchorPoint = Vector2.new(0.5, 0.5)
Panel.BackgroundColor3 = Color3.fromRGB(9, 12, 18)
Panel.BorderSizePixel = 0
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel", Panel)
Title.Text = "CHOOSE YOUR EXPERIENCE"
Title.Position = UDim2.fromOffset(29, 99)
Title.Size = UDim2.new(1, -58, 0, 27)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 19
Title.TextColor3 = Color3.fromRGB(232, 240, 250)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local CardHolder = Instance.new("Frame", Panel)
CardHolder.Position = UDim2.fromOffset(29, 166)
CardHolder.Size = UDim2.fromOffset(652, 235)
CardHolder.BackgroundTransparency = 1
local ListLayout = Instance.new("UIListLayout", CardHolder)
ListLayout.FillDirection = Enum.FillDirection.Horizontal
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ListLayout.Padding = UDim.new(0, 15)

-- Selector Drag
local sDrag, sStart, sPos
Panel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sDrag = true; sStart = input.Position; sPos = Panel.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if sDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - sStart
        Panel.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then sDrag = false end
end)

local Games = {
    { Name = "FALLEN SURVIVAL" },
    { Name = "LONE SURVIVAL" },
    { Name = "DECAY" }
}

for i, gameData in ipairs(Games) do
    local card = Instance.new("TextButton", CardHolder)
    card.Size = UDim2.fromOffset(207, 220)
    card.BackgroundColor3 = Color3.fromRGB(16, 22, 32)
    card.Text = ""
    card.AutoButtonColor = false
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
    
    local lbl = Instance.new("TextLabel", card)
    lbl.Text = gameData.Name
    lbl.Position = UDim2.fromOffset(12, 122)
    lbl.Size = UDim2.new(1, -24, 0, 23)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    card.MouseButton1Click:Connect(function()
        SelectorGui:Destroy()
        if gameData.Name == "FALLEN SURVIVAL" then
            RunFallenSurvival()
        end
    end)
end

--========================================================
-- UTOPIA UI LIBRARY (Built into loader)
--========================================================

local Library = {}
Library.Flags = {}
Library.Theme = {
    ["Accent"]=Color3.fromRGB(255,80,80), ["Background"]=Color3.fromRGB(20,10,10),
    ["Border"]=Color3.fromRGB(0,0,0), ["Border 1"]=Color3.fromRGB(90,40,40),
    ["Border 2"]=Color3.fromRGB(18,8,8), ["Border 3"]=Color3.fromRGB(10,4,4),
    ["Primary Text"]=Color3.fromRGB(255,230,230), ["Group Background"]=Color3.fromRGB(18,8,8),
    ["Selected Tab Background"]=Color3.fromRGB(45,18,18), ["Unselected Tab Background"]=Color3.fromRGB(20,10,10),
    ["Selected Tab Text"]=Color3.fromRGB(255,255,255), ["Unselected Tab Text"]=Color3.fromRGB(220,160,160),
    ["Section Background"]=Color3.fromRGB(26,12,12), ["Option Text 1"]=Color3.fromRGB(255,230,230),
    ["Option Text 2"]=Color3.fromRGB(240,200,200), ["Option Text 3"]=Color3.fromRGB(220,160,160),
    ["Option Border 1"]=Color3.fromRGB(90,40,40), ["Option Border 2"]=Color3.fromRGB(0,0,0),
    ["Option Background"]=Color3.fromRGB(36,16,16), ["Risky Text"]=Color3.fromRGB(175,21,21),
    ["Risky Text Enabled"]=Color3.fromRGB(255,41,41),
}
Library.Folders = { Configs = "GorillaHub/configs" }
Library.Font = Font.fromEnum(Enum.Font.Gotham)
getgenv().GorillaLibrary = Library
getgenv().GorillaMenuUnlocked = true

function Library:Window(data)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "\0"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999999
    ScreenGui.Parent = gethui and gethui() or PlayerGui

    local Main = Instance.new("Frame")
    Main.Size = UDim2.fromOffset(600, 700)
    Main.Position = UDim2.new(0.5, -300, 0.5, -350)
    Main.BackgroundColor3 = self.Theme["Background"]
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner", Main)
    UICorner.CornerRadius = UDim.new(0, 8)
    local UIStroke = Instance.new("UIStroke", Main)
    UIStroke.Color = self.Theme["Border 1"]

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = data.Name or "GorillaHub"
    Title.TextColor3 = self.Theme["Primary Text"]
    Title.FontFace = self.Font
    Title.Parent = Main
    
    -- Drag
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    
    local TabHolder = Instance.new("Frame")
    TabHolder.Size = UDim2.new(1, 0, 0, 25)
    TabHolder.Position = UDim2.new(0, 0, 0, 30)
    TabHolder.BackgroundTransparency = 1
    TabHolder.Parent = Main
    
    local PageHolder = Instance.new("Frame")
    PageHolder.Size = UDim2.new(1, 0, 1, -55)
    PageHolder.Position = UDim2.new(0, 0, 0, 55)
    PageHolder.BackgroundTransparency = 1
    PageHolder.Parent = Main

    local window = { raw = { Main = Main, TabHolder = TabHolder, PageHolder = PageHolder, ScreenGui = ScreenGui } }
    
    function window:Page(o)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 100, 1, 0)
        btn.BackgroundColor3 = self.raw.Main.BackgroundColor3
        btn.Text = o.Name
        btn.TextColor3 = self.Theme["Primary Text"]
        btn.Parent = self.raw.TabHolder

        local pageFrame = Instance.new("Frame")
        pageFrame.Size = UDim2.fromScale(1, 1)
        pageFrame.BackgroundTransparency = 1
        pageFrame.Visible = false
        pageFrame.Parent = self.raw.PageHolder

        btn.MouseButton1Click:Connect(function()
            for _, v in pairs(self.raw.PageHolder:GetChildren()) do
                if v:IsA("Frame") then v.Visible = false end
            end
            pageFrame.Visible = true
        end)

        local page = { raw = pageFrame }
        function page:Section(o)
            local sec = Instance.new("Frame")
            sec.Size = UDim2.new(1, -10, 0, 100)
            sec.BackgroundColor3 = self.Theme["Option Background"]
            sec.Parent = self.raw
            Instance.new("UICorner", sec).CornerRadius = UDim.new(0, 4)
            return {
                Toggle = function(_, opts)
                    local t = Instance.new("TextButton")
                    t.Size = UDim2.new(1, 0, 0, 25)
                    t.Text = opts.Name
                    t.Parent = sec
                    return { raw = { SetState = function() end, AddColor = function() return { SetColor = function() end } end } }
                end,
                Slider = function(_, opts) return { raw = { SetValue = function() end } } end,
                Dropdown = function(_, opts) return { raw = { Select = function() end } } end,
                Button = function(_, opts) return { SubButton = function() end } end,
                Textbox = function(_, opts) return { raw = {} } end,
                Label = function(_, text) return { Colorpicker = function() end, Keybind = function() end } end,
                Text = function(_, text) end
            }
        end
        return page
    end
    return window
end

--========================================================
-- FALLEN SURVIVAL FEATURES SETUP
--========================================================
function RunFallenSurvival()
    local Window = Library:Window({ Name = "GorillaHub - Fallen" })
    
    local CombatTab = Window:Page({ Name = "Combat" })
    local AimSec = CombatTab:Section({ Name = "Silent Aim" })
    AimSec:Toggle({ Name = "Enabled" })
    AimSec:Toggle({ Name = "Visible Check" })
    
    local MovementTab = Window:Page({ Name = "Movement" })
    local MoveSec = MovementTab:Section({ Name = "Speed" })
    MoveSec:Toggle({ Name = "Enabled" })
    
    -- Here you would add your actual feature logic loops (RunService, etc)
    -- Example:
    -- RunService.Heartbeat:Connect(function()
    --    if Library.Flags["SpeedEnabled"] then ... end
    -- end)
end
