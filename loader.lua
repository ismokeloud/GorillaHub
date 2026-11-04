--========================================================
--                   GORILLA HUB LOADER
--========================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local GITHUB_USER = "ismokeloud"
local GITHUB_REPO = "GorillaHub"
local GITHUB_BRANCH = "main"
local BASE_URL = string.format("https://raw.githubusercontent.com/%s/%s/%s/", GITHUB_USER, GITHUB_REPO, GITHUB_BRANCH)

--========================================================
-- KEY SYSTEM
--========================================================

local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "GorillaKeySystem"
KeyGui.IgnoreGuiInset = true
KeyGui.ResetOnSpawn = false
KeyGui.DisplayOrder = 2147483647
KeyGui.Parent = gethui and gethui() or PlayerGui

local KeyFrame = Instance.new("Frame", KeyGui)
KeyFrame.Size = UDim2.fromOffset(400, 250)
KeyFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
KeyFrame.BackgroundColor3 = Color3.fromRGB(13, 14, 17)
KeyFrame.BorderSizePixel = 0
Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 16)

local KeyTitle = Instance.new("TextLabel", KeyFrame)
KeyTitle.Size = UDim2.new(1, 0, 0, 50)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "GorillaHub Key"
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.TextSize = 24

local KeyBox = Instance.new("TextBox", KeyFrame)
KeyBox.Size = UDim2.new(1, -40, 0, 46)
KeyBox.Position = UDim2.fromOffset(20, 60)
KeyBox.BackgroundColor3 = Color3.fromRGB(29, 30, 36)
KeyBox.TextColor3 = Color3.new(1,1,1)
KeyBox.PlaceholderText = "Paste key..."
KeyBox.BorderSizePixel = 0
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 8)

local KeySubmit = Instance.new("TextButton", KeyFrame)
KeySubmit.Size = UDim2.new(1, -40, 0, 40)
KeySubmit.Position = UDim2.fromOffset(20, 120)
KeySubmit.BackgroundColor3 = Color3.fromRGB(58, 232, 132)
KeySubmit.Text = "Continue"
KeySubmit.TextColor3 = Color3.new(0,0,0)
KeySubmit.BorderSizePixel = 0
Instance.new("UICorner", KeySubmit).CornerRadius = UDim.new(0, 8)

local KeyStatus = Instance.new("TextLabel", KeyFrame)
KeyStatus.Size = UDim2.new(1, 0, 0, 20)
KeyStatus.Position = UDim2.fromOffset(0, 170)
KeyStatus.BackgroundTransparency = 1
KeyStatus.Text = ""
KeyStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
KeyStatus.Font = Enum.Font.GothamMedium
KeyStatus.TextSize = 14

-- Drag functionality
local dragging, dragStart, startPos
KeyFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = KeyFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        KeyFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

--========================================================
-- GAME SELECTOR
--========================================================

local SelectorGui = Instance.new("ScreenGui")
SelectorGui.Name = "GorillaSelector"
SelectorGui.IgnoreGuiInset = true
SelectorGui.ResetOnSpawn = false
SelectorGui.DisplayOrder = 100
SelectorGui.Parent = PlayerGui
SelectorGui.Enabled = false

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
        sDrag = true
        sStart = input.Position
        sPos = Panel.Position
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
    { Name = "FALLEN SURVIVAL", File = "FallenSurvival" },
    { Name = "LONE SURVIVAL", File = "LoneSurvival" },
    { Name = "DECAY", File = "Decay" }
}

--========================================================
-- LOADING & CONTEXT INJECTION
--========================================================

local function LoadGame(gameData)
    SelectorGui:Destroy()
    
    -- Create a brand new environment for the script
    local env = setmetatable({}, {__index = getgenv()})
    
    -- Export libraries into the environment
    env.GorillaLibrary = getgenv().GorillaLibrary
    env.GorillaOcto = getgenv().GorillaOcto
    env.GorillaMenuUnlocked = true
    
    local url = BASE_URL .. "games/" .. gameData.File .. ".lua?t=" .. tostring(os.time())
    local scriptText = game:HttpGet(url)
    local func, err = loadstring(scriptText)
    
    if not func then
        warn("Syntax error in " .. gameData.File .. ": " .. tostring(err))
        return
    end
    
    -- Run the script with the custom environment
    setfenv(func, env)
    local success, runtimeErr = pcall(func)
    
    if not success then
        warn("Runtime error in " .. gameData.File .. ": " .. tostring(runtimeErr))
    end
end

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
        LoadGame(gameData)
    end)
end

--========================================================
-- INITIALIZATION
--========================================================

-- You must define a dummy Octo library so the FallenSurvival module doesn't crash before it loads its real one
getgenv().GorillaOcto = {
    init = function() end,
    SetTheme = function() end,
    toggleKey = Enum.KeyCode.RightControl,
    theme = {},
    cheatname = "GorillaHub",
    gamename = "FallenSurvival",
    NewWindow = function() return { objects = { background = { Visible = false } }, AddTab = function() end } end
}

KeySubmit.MouseButton1Click:Connect(function()
    if KeyBox.Text == "SCORPION-WTF-JJZ9V-BMSCZ-8H6JY-127U8" then
        KeyGui:Destroy()
        SelectorGui.Enabled = true
    else
        KeyStatus.Text = "Invalid key"
        KeyBox.Text = ""
    end
end)
