--========================================================
--                   GORILLA HUB LOADER
--        Game Selector + Fallen Survival + Key System
--========================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--========================================================
-- UTOPIA LIBRARY (Standard Roblox GUI)
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
Library.Folders = { Configs = "GorillaHub/FallenSurvival/configs" }
Library.Font = Font.fromEnum(Enum.Font.Gotham)

getgenv().GorillaLibrary = Library
getgenv().GorillaMenuUnlocked = false

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
    Main.Visible = getgenv().GorillaMenuUnlocked
    
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
    
    -- Drag functionality
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
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
-- GAME SELECTOR UI
--========================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "GorillaHubSelector"
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 100
Gui.Parent = PlayerGui

local Splash = Instance.new("Frame", Gui)
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

-- Game Selector Dragging
local dragging, dragStart, startPos
Panel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Panel.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

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
        Splash.Visible = false
        if gameData.Name == "FALLEN SURVIVAL" then
            -- Directly call the setup instead of HTTP Get
            SetupFallenSurvival()
        end
    end)
end

--========================================================
-- FALLEN SURVIVAL FEATURES SETUP
--========================================================
function SetupFallenSurvival()
    local Window = Library:Window({ Name = "GorillaHub - Fallen" })
    local CombatTab = Window:Page({ Name = "Combat" })
    local CombatSec = CombatTab:Section({ Name = "Silent Aim" })
    CombatSec:Toggle({ Name = "Enabled" })
    
    local ExploitTab = Window:Page({ Name = "Exploits" })
    local ExploitSec = ExploitTab:Section({ Name = "Exploits" })
    ExploitSec:Toggle({ Name = "No Fall Damage" })
    ExploitSec:Toggle({ Name = "Instant Eoka" })
end

--========================================================
-- KEY SYSTEM
--========================================================

local _keyCode = "SCORPION-WTF-JJZ9V-BMSCZ-8H6JY-127U8"
do
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "GorillaKeySystem"
    keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    keyGui.IgnoreGuiInset = true
    keyGui.ResetOnSpawn = false
    keyGui.DisplayOrder = 2147483647
    keyGui.Parent = gethui and gethui() or PlayerGui

    local bg = Color3.fromRGB(13, 14, 17)
    local box = Color3.fromRGB(29, 30, 36)

    local win = Instance.new("Frame")
    win.Size = UDim2.fromOffset(400, 470)
    win.Position = UDim2.new(0.5, -200, 0.5, -235)
    win.BackgroundColor3 = bg
    win.BorderSizePixel = 0
    win.Parent = keyGui
    Instance.new("UICorner", win).CornerRadius = UDim.new(0, 16)

    local title = Instance.new("TextLabel")
    title.Position = UDim2.fromOffset(0, 52)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "GorillaHub"
    title.FontFace = Library.Font
    title.TextSize = 26
    title.TextColor3 = Color3.new(1,1,1)
    title.Parent = win

    local tb = Instance.new("TextBox")
    tb.Position = UDim2.fromOffset(20, 132)
    tb.Size = UDim2.new(1, -40, 0, 46)
    tb.BackgroundColor3 = box
    tb.PlaceholderText = "paste key here..."
    tb.Text = ""
    tb.TextColor3 = Color3.new(1,1,1)
    tb.Parent = win
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 10)

    local submit = Instance.new("TextButton")
    submit.Position = UDim2.fromOffset(20, 192)
    submit.Size = UDim2.new(1, -40, 0, 44)
    submit.BackgroundColor3 = Color3.fromRGB(58, 232, 132)
    submit.Text = "continue"
    submit.TextColor3 = Color3.new(0,0,0)
    submit.Parent = win
    Instance.new("UICorner", submit).CornerRadius = UDim.new(0, 10)

    -- Key system dragging
    local kDrag, kStart, kPos
    win.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            kDrag = true
            kStart = input.Position
            kPos = win.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if kDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - kStart
            win.Position = UDim2.new(kPos.X.Scale, kPos.X.Offset + delta.X, kPos.Y.Scale, kPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            kDrag = false
        end
    end)

    submit.MouseButton1Click:Connect(function()
        if tb.Text == _keyCode then
            keyGui:Destroy()
            getgenv().GorillaMenuUnlocked = true
            for _, gui in pairs(PlayerGui:GetChildren()) do
                if gui.Name == "\0" then
                    for _, main in pairs(gui:GetChildren()) do
                        if main:IsA("Frame") then main.Visible = true end
                    end
                end
            end
        else
            tb.Text = "invalid key"
            task.wait(1)
            tb.Text = ""
        end
    end)
end
