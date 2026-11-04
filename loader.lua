--========================================================
--                   GORILLA HUB LOADER
--        Game Selector + Module Loader + Key System
--========================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- REPLACE these two with your own GitHub details
local GITHUB_USER = "YourName"
local GITHUB_REPO = "GorillaHub"
local GITHUB_BRANCH = "main"
local BASE_URL = string.format(
    "https://raw.githubusercontent.com/%s/%s/%s/",
    GITHUB_USER, GITHUB_REPO, GITHUB_BRANCH
)

--========================================================
-- CLEANUP OLD INSTANCES
--========================================================

local Previous = PlayerGui:FindFirstChild("GorillaHub")
if Previous then Previous:Destroy() end

local ExistingBlur = Lighting:FindFirstChild("GorillaHubBlur")
if ExistingBlur then ExistingBlur:Destroy() end

--========================================================
-- THEME / HELPERS (same as your first file)
--========================================================

local Theme = {
    Background = Color3.fromRGB(9, 12, 18),
    Header = Color3.fromRGB(12, 17, 25),
    Sidebar = Color3.fromRGB(11, 15, 22),
    Panel = Color3.fromRGB(16, 22, 32),
    PanelHover = Color3.fromRGB(24, 36, 51),
    PanelLight = Color3.fromRGB(21, 30, 43),
    Blue = Color3.fromRGB(35, 145, 255),
    Cyan = Color3.fromRGB(85, 205, 255),
    Bright = Color3.fromRGB(145, 225, 255),
    White = Color3.fromRGB(232, 240, 250),
    SoftWhite = Color3.fromRGB(180, 196, 215),
    Muted = Color3.fromRGB(105, 124, 148),
    Border = Color3.fromRGB(43, 66, 91),
    Green = Color3.fromRGB(83, 220, 160)
}

local Fonts = {
    Display = Enum.Font.GothamBlack,
    Heading = Enum.Font.GothamBold,
    Normal = Enum.Font.GothamMedium,
    Light = Enum.Font.Gotham,
    Tech = Enum.Font.Code,
}

local function New(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local function Animate(object, duration, properties, style)
    local animation = TweenService:Create(
        object,
        TweenInfo.new(duration, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        properties
    )
    animation:Play()
    return animation
end

local function Round(parent, radius)
    return New("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function Outline(parent, color, transparency, thickness)
    return New("UIStroke", {
        Color = color or Theme.Border,
        Transparency = transparency or 0,
        Thickness = thickness or 1
    }, parent)
end

local function MakeFrame(parent, position, size, color, radius, zIndex)
    local object = New("Frame", {
        Position = position,
        Size = size,
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        ZIndex = zIndex or 1
    }, parent)
    if radius then Round(object, radius) end
    return object
end

local function MakeLabel(parent, text, position, size, font, textSize, color, zIndex)
    return New("TextLabel", {
        BackgroundTransparency = 1,
        Position = position,
        Size = size,
        Text = text,
        Font = font or Fonts.Normal,
        TextSize = textSize or 12,
        TextColor3 = color or Theme.White,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = zIndex or 2
    }, parent)
end

--========================================================
-- SCREEN GUI + BLUR
--========================================================

local Gui = New("ScreenGui", {
    Name = "GorillaHub",
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 100
}, PlayerGui)

local Blur = New("BlurEffect", {
    Name = "GorillaHubBlur",
    Size = 0,
    Enabled = true
}, Lighting)

--========================================================
-- GAME DEFINITIONS
--========================================================

local Games = {
    {
        Name = "FALLEN SURVIVAL",
        ShortName = "FALLEN",
        Description = "SURVIVAL  /  PVPVE",
        UniverseId = 3747388906,
        File = "FallenSurvival",
        Accent = Color3.fromRGB(73, 170, 255),
        Tag = "01"
    },
    {
        Name = "LONE SURVIVAL",
        ShortName = "LONE",
        Description = "SURVIVAL  /  OPEN WORLD",
        UniverseId = 4712109542,
        File = "LoneSurvival",
        Accent = Color3.fromRGB(100, 195, 255),
        Tag = "02"
    },
    {
        Name = "DECAY",
        ShortName = "DECAY",
        Description = "SURVIVAL  /  OPEN WORLD",
        UniverseId = 5000084391,
        File = "Decay",
        Accent = Color3.fromRGB(150, 180, 205),
        Tag = "03"
    }
}

--========================================================
-- GAME SELECTION SCREEN
--========================================================

local Splash = New("Frame", {
    Name = "GameSelector",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(5, 8, 13),
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    ZIndex = 5
}, Gui)

local SplashGradient = New("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 25, 39)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8, 12, 19)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(13, 20, 32))
    }),
    Rotation = 35
}, Splash)

local SplashScale = New("UIScale", { Scale = 0.92 }, Splash)

local SplashContent = New("CanvasGroup", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    GroupTransparency = 1,
    ZIndex = 6
}, Splash)

local SelectorPanel = MakeFrame(
    SplashContent,
    UDim2.fromScale(0.5, 0.5),
    UDim2.fromOffset(710, 465),
    Theme.Background,
    14,
    7
)
SelectorPanel.AnchorPoint = Vector2.new(0.5, 0.5)
SelectorPanel.ClipsDescendants = true

local SelectorStroke = Outline(SelectorPanel, Theme.Blue, 0.35, 1.3)

local SelectorGlow = MakeFrame(
    SplashContent,
    UDim2.fromScale(0.5, 0.5),
    UDim2.fromOffset(730, 485),
    Theme.Blue,
    16,
    6
)
SelectorGlow.AnchorPoint = Vector2.new(0.5, 0.5)
SelectorGlow.BackgroundTransparency = 0.97

New("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 30, 44)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(9, 13, 20))
    }),
    Rotation = 25
}, SelectorPanel)

local SelectorAccent = MakeFrame(
    SelectorPanel,
    UDim2.fromOffset(0, 0),
    UDim2.new(0, 0, 0, 2),
    Theme.Cyan,
    nil,
    8
)

--========================================================
-- LOGO
--========================================================

local function CreateLogo(parent, position, size)
    local logo = MakeFrame(
        parent, position, UDim2.fromOffset(size, size),
        Color3.fromRGB(18, 47, 73), 11, 10
    )
    Outline(logo, Theme.Blue, 0.15, 1.3)
    local ring = MakeFrame(
        logo, UDim2.fromOffset(4, 4),
        UDim2.new(1, -8, 1, -8), Theme.Panel, 9, 11
    )
    ring.BackgroundTransparency = 1
    Outline(ring, Theme.Cyan, 0.65, 1)
    local letter = MakeLabel(
        logo, "G", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1),
        Fonts.Display, math.floor(size * 0.65), Theme.Cyan, 12
    )
    letter.TextXAlignment = Enum.TextXAlignment.Center
    letter.TextStrokeColor3 = Theme.Blue
    letter.TextStrokeTransparency = 0.65
    return logo, ring
end

CreateLogo(SelectorPanel, UDim2.fromOffset(27, 23), 43)

MakeLabel(SelectorPanel, "GORILLA HUB", UDim2.fromOffset(82, 23),
    UDim2.fromOffset(240, 27), Fonts.Display, 21, Theme.White, 10)

MakeLabel(SelectorPanel, "MULTI-EXPERIENCE INTERFACE", UDim2.fromOffset(84, 49),
    UDim2.fromOffset(240, 15), Fonts.Tech, 9, Theme.Cyan, 10)

local BuildLabel = MakeLabel(SelectorPanel, "BUILD  /  001",
    UDim2.new(1, -135, 0, 34), UDim2.fromOffset(105, 18),
    Fonts.Tech, 9, Theme.Muted, 10)
BuildLabel.TextXAlignment = Enum.TextXAlignment.Right

MakeFrame(SelectorPanel, UDim2.fromOffset(0, 79),
    UDim2.new(1, 0, 0, 1), Theme.Border, nil, 8
).BackgroundTransparency = 0.45

MakeLabel(SelectorPanel, "CHOOSE YOUR EXPERIENCE",
    UDim2.fromOffset(29, 99), UDim2.new(1, -58, 0, 27),
    Fonts.Display, 19, Theme.White, 9)

MakeLabel(SelectorPanel, "Select a game to continue into Gorilla Hub.",
    UDim2.fromOffset(30, 127), UDim2.new(1, -58, 0, 18),
    Fonts.Light, 10, Theme.Muted, 9)

local CardHolder = New("Frame", {
    Position = UDim2.fromOffset(29, 166),
    Size = UDim2.fromOffset(652, 235),
    BackgroundTransparency = 1,
    ZIndex = 9
}, SelectorPanel)

New("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 15),
    SortOrder = Enum.SortOrder.LayoutOrder
}, CardHolder)

--========================================================
-- MODULE LOADER
--========================================================

local ActiveModuleCleanup = nil
local ModuleLoaded = false

local function LoadGameModule(gameData)
    -- If a module was already loaded, clean it up first
    if ActiveModuleCleanup then
        pcall(ActiveModuleCleanup)
        ActiveModuleCleanup = nil
    end
    ModuleLoaded = false

    local url = BASE_URL .. "games/" .. gameData.File .. ".lua?t=" .. tostring(os.time())
    local ok, scriptText = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok or not scriptText or scriptText == "" then
        warn("[GorillaHub] Failed to fetch module: " .. gameData.File .. " (" .. tostring(scriptText) .. ")")
        return false
    end

    local func, err = loadstring(scriptText)
    if not func then
        warn("[GorillaHub] Syntax error in " .. gameData.File .. ": " .. tostring(err))
        return false
    end

    local success, result = pcall(func)
    if not success then
        warn("[GorillaHub] Runtime error in " .. gameData.File .. ": " .. tostring(result))
        return false
    end

    -- If the module returns a function, store it as cleanup
    if type(result) == "function" then
        ActiveModuleCleanup = result
    end

    ModuleLoaded = true
    return true
end

--========================================================
-- GAME CARDS
--========================================================

local Selecting = false
local GameCards = {}

local function SelectGame(gameData)
    if Selecting then return end
    Selecting = true

    MakeLabel(SelectorPanel,
        "OPENING " .. gameData.ShortName .. "...",
        UDim2.fromOffset(29, 411), UDim2.new(1, -58, 0, 17),
        Fonts.Tech, 9, Theme.Cyan, 15)

    for name, data in pairs(GameCards) do
        if name == gameData.ShortName then
            Animate(data.Stroke, 0.2, { Color = Theme.Cyan, Transparency = 0 })
            Animate(data.Image, 0.2, { ImageColor3 = Color3.fromRGB(255, 255, 255) })
            data.SelectText.Text = "OPENING HUB..."
        else
            Animate(data.Button, 0.2, { BackgroundTransparency = 0.55 })
            Animate(data.Image, 0.2, { ImageTransparency = 0.5 })
        end
    end

    -- Load the feature module before opening the hub
    task.spawn(function()
        local loaded = LoadGameModule(gameData)
        if not loaded then
            -- Simple error message if module fails; still open the UI
            MakeLabel(SelectorPanel,
                "MODULE FAILED TO LOAD - CHECK CONSOLE",
                UDim2.fromOffset(29, 430), UDim2.new(1, -58, 0, 15),
                Fonts.Tech, 8, Color3.fromRGB(255, 90, 90), 15)
        end
    end)

    task.wait(0.45)

    Animate(SplashContent, 0.3, { GroupTransparency = 1 })
    Animate(SplashScale, 0.35, { Scale = 0.94 })
    Animate(Blur, 0.35, { Size = 14 })

    task.wait(0.32)
    Splash.Visible = false
end

local function CreateGameCard(gameData, index)
    local card = New("TextButton", {
        Name = gameData.ShortName .. "Card",
        Size = UDim2.fromOffset(207, 220),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ClipsDescendants = true,
        LayoutOrder = index,
        ZIndex = 10
    }, CardHolder)
    Round(card, 10)

    local cardStroke = Outline(card, Theme.Border, 0.55, 1)

    local imageClip = MakeFrame(card, UDim2.fromOffset(0, 0),
        UDim2.new(1, 0, 0, 113), Theme.PanelLight, 0, 11)
    imageClip.ClipsDescendants = true

    local thumbnail = New("ImageLabel", {
        Name = "GameThumbnail",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Image = string.format(
            "rbxthumb://type=GameThumbnail&id=%d&w=768&h=432",
            gameData.UniverseId
        ),
        ScaleType = Enum.ScaleType.Crop,
        ImageTransparency = 0.05,
        ImageColor3 = Color3.fromRGB(210, 225, 240),
        ZIndex = 12
    }, imageClip)

    task.delay(6, function()
        if thumbnail.Parent and not thumbnail.IsLoaded then
            thumbnail.Image = string.format(
                "rbxthumb://type=GameIcon&id=%d&w=512&h=512",
                gameData.UniverseId
            )
        end
    end)

    local imageShade = New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 13
    }, imageClip)
    New("UIGradient", {
        Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.88),
            NumberSequenceKeypoint.new(0.55, 0.75),
            NumberSequenceKeypoint.new(1, 0.15)
        })
    }, imageShade)

    local numberPill = MakeFrame(card, UDim2.fromOffset(11, 10),
        UDim2.fromOffset(31, 19), Color3.fromRGB(7, 15, 24), 5, 14)
    numberPill.BackgroundTransparency = 0.15
    local numberText = MakeLabel(numberPill, gameData.Tag,
        UDim2.fromScale(0, 0), UDim2.fromScale(1, 1),
        Fonts.Tech, 9, Theme.Cyan, 15)
    numberText.TextXAlignment = Enum.TextXAlignment.Center

    MakeLabel(card, gameData.Name, UDim2.fromOffset(12, 122),
        UDim2.new(1, -24, 0, 23), Fonts.Display, 12, Theme.White, 14)
    MakeLabel(card, gameData.Description, UDim2.fromOffset(12, 147),
        UDim2.new(1, -24, 0, 15), Fonts.Tech, 8, Theme.Muted, 14)

    local selectBar = MakeFrame(card, UDim2.fromOffset(11, 180),
        UDim2.new(1, -22, 0, 27), Color3.fromRGB(19, 43, 63), 6, 14)
    local selectStroke = Outline(selectBar, Theme.Blue, 0.75, 1)

    local selectText = MakeLabel(selectBar, "SELECT EXPERIENCE",
        UDim2.fromOffset(9, 0), UDim2.new(1, -25, 1, 0),
        Fonts.Heading, 8, Theme.Cyan, 15)

    local arrow = MakeLabel(selectBar, ">",
        UDim2.new(1, -22, 0, 0), UDim2.fromOffset(16, 27),
        Fonts.Display, 18, Theme.Cyan, 15)
    arrow.TextXAlignment = Enum.TextXAlignment.Center

    card.MouseEnter:Connect(function()
        Animate(card, 0.18, { BackgroundColor3 = Theme.PanelHover })
        Animate(cardStroke, 0.18, {
            Color = gameData.Accent, Transparency = 0.08, Thickness = 1.5
        })
        Animate(thumbnail, 0.25, {
            Size = UDim2.new(1, 12, 1, 12),
            ImageColor3 = Color3.fromRGB(255, 255, 255)
        })
        Animate(selectBar, 0.18, { BackgroundColor3 = Color3.fromRGB(25, 67, 99) })
        Animate(selectStroke, 0.18, { Transparency = 0.15 })
    end)

    card.MouseLeave:Connect(function()
        Animate(card, 0.18, { BackgroundColor3 = Theme.Panel })
        Animate(cardStroke, 0.18, {
            Color = Theme.Border, Transparency = 0.55, Thickness = 1
        })
        Animate(thumbnail, 0.22, {
            Size = UDim2.fromScale(1, 1),
            ImageColor3 = Color3.fromRGB(210, 225, 240)
        })
        Animate(selectBar, 0.18, { BackgroundColor3 = Color3.fromRGB(19, 43, 63) })
        Animate(selectStroke, 0.18, { Transparency = 0.75 })
    end)

    card.MouseButton1Down:Connect(function()
        Animate(card, 0.08, { Size = UDim2.fromOffset(202, 215) })
    end)
    card.MouseButton1Up:Connect(function()
        Animate(card, 0.12, { Size = UDim2.fromOffset(207, 220) })
    end)
    card.MouseButton1Click:Connect(function()
        SelectGame(gameData)
    end)

    GameCards[gameData.ShortName] = {
        Button = card,
        Stroke = cardStroke,
        Image = thumbnail,
        SelectText = selectText
    }
end

for i, gameData in ipairs(Games) do
    CreateGameCard(gameData, i)
end

-- footer
MakeFrame(SelectorPanel, UDim2.fromOffset(0, 402),
    UDim2.new(1, 0, 0, 1), Theme.Border, nil, 8
).BackgroundTransparency = 0.5

MakeLabel(SelectorPanel, "GORILLA HUB", UDim2.fromOffset(29, 419),
    UDim2.fromOffset(150, 15), Fonts.Tech, 8, Theme.Blue, 10)

MakeLabel(SelectorPanel, "SELECT A GAME TO CONTINUE",
    UDim2.new(1, -245, 0, 419), UDim2.fromOffset(215, 15),
    Fonts.Tech, 8, Theme.Muted, 10).TextXAlignment = Enum.TextXAlignment.Right

--========================================================
-- INITIAL SPLASH ANIMATION
--========================================================

SplashScale.Scale = 0.92
SplashContent.GroupTransparency = 1
SelectorPanel.Position = UDim2.fromScale(0.5, 0.53)

Animate(Blur, 0.45, { Size = 8 })
Animate(SplashScale, 0.65, { Scale = 1 }, Enum.EasingStyle.Back)
Animate(SplashContent, 0.6, { GroupTransparency = 0 })
Animate(SelectorPanel, 0.6, { Position = UDim2.fromScale(0.5, 0.5) }, Enum.EasingStyle.Back)
Animate(SelectorGlow, 0.65, { BackgroundTransparency = 0.96 })
Animate(SelectorAccent, 0.8, { Size = UDim2.new(1, 0, 0, 2) })

--========================================================
-- CLEANUP
--========================================================

Gui.Destroying:Connect(function()
    if Blur and Blur.Parent then Blur:Destroy() end
    if ActiveModuleCleanup then pcall(ActiveModuleCleanup) end
end)

--========================================================
-- END LOADER
--========================================================
