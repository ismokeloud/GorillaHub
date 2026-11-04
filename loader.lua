--========================================================
--                   GORILLA HUB LOADER
--        Game Selector + Original FallenSurvival UI
--========================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local GITHUB_USER = "ismokeloud"
local GITHUB_REPO = "GorillaHub"
local GITHUB_BRANCH = "main"
local BASE_URL = string.format("https://raw.githubusercontent.com/%s/%s/%s/", GITHUB_USER, GITHUB_REPO, GITHUB_BRANCH)

local Previous = PlayerGui:FindFirstChild("GorillaHub")
if Previous then Previous:Destroy() end
local ExistingBlur = Lighting:FindFirstChild("GorillaHubBlur")
if ExistingBlur then ExistingBlur:Destroy() end

--========================================================
-- GAME SELECTOR UI
--========================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "GorillaHub"
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
    { Name = "FALLEN SURVIVAL", File = "FallenSurvival", Accent = Color3.fromRGB(73, 170, 255) },
    { Name = "LONE SURVIVAL", File = "LoneSurvival", Accent = Color3.fromRGB(100, 195, 255) },
    { Name = "DECAY", File = "Decay", Accent = Color3.fromRGB(150, 180, 205) }
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
        local url = BASE_URL .. "games/" .. gameData.File .. ".lua?t=" .. tostring(os.time())
        local scriptText = game:HttpGet(url)
        local func = loadstring(scriptText)
        func()
    end)
end

--========================================================
-- ORIGINAL UI + KEY SYSTEM (From your working file)
--========================================================

-- (This is your original working code)
local _signalCode = 'local Signal = {}\nSignal.__index = Signal\nSignal.ClassName = "Signal"\n\nlocal Connection = {}\nConnection.__index = Connection\nConnection.ClassName = "Connection"\n\nfunction Connection.new(signal, fn)\n    return setmetatable({ _signal = signal, _fn = fn, Connected = true }, Connection)\nend\nfunction Connection:IsConnected()\n    return self.Connected == true and self._signal ~= nil\nend\nfunction Connection:Disconnect()\n    self.Connected = false\n    self._signal = nil\n    self._fn = nil\nend\nConnection.Destroy = Connection.Disconnect\n\nfunction Signal.new()\n    return setmetatable({ _handlers = {} }, Signal)\nend\nfunction Signal.isSignal(value)\n    return type(value) == "table" and getmetatable(value) == Signal\nend\nfunction Signal:Connect(fn)\n    local conn = Connection.new(self, fn)\n    table.insert(self._handlers, conn)\n    return conn\nend\nfunction Signal:Fire(...)\n    for i = #self._handlers, 1, -1 do\n        local c = self._handlers[i]\n        if c.Connected then\n            local ok, err = pcall(c._fn, ...)\n            if not ok then warn(err) end\n        else\n            table.remove(self._handlers, i)\n        end\n    end\nend\nfunction Signal:Wait()\n    local co = coroutine.running()\n    local conn\n    conn = self:Connect(function(...)\n        if conn then conn:Disconnect() end\n        task.spawn(co, ...)\n    end)\n    return coroutine.yield()\nend\nfunction Signal:Once(fn)\n    local conn\n    conn = self:Connect(function(...)\n        if conn then conn:Disconnect() end\n        fn(...)\n    end)\n    return conn\nend\nfunction Signal:DisconnectAll()\n    for i = #self._handlers, 1, -1 do\n        local c = self._handlers[i]\n        if c.Connected then c:Disconnect() end\n        table.remove(self._handlers, i)\n    end\nend\nSignal.Destroy = Signal:DisconnectAll\n\nsetmetatable(Signal, {\n    __index = function(_, key)\n        error(string.format("Attempt to get Signal::%s (not a valid member)", tostring(key)), 2)\n    end,\n    __newindex = function(_, key, _)\n        error(string.format("Attempt to set Signal::%s (not a valid member)", tostring(key)), 2)\n    end,\n})\n\nreturn Signal'

local _octoSrc = game:HttpGet("https://raw.githubusercontent.com/GhostDuckyy/UI-Libraries/main/octohook/source.lua")
local _marker = "signal = loadstring(game:HttpGet('https://raw.githubusercontent.com/Quenty/NevermoreEngine/main/src/signal/src/Shared/Signal.lua'))();"
local _mi = _octoSrc:find(_marker, 1, true)
if _mi then
    _octoSrc = _octoSrc:sub(1, _mi - 1)
        .. "signal = (function()\n" .. _signalCode .. "\nend)();"
        .. _octoSrc:sub(_mi + #_marker)
end
local Octo = loadstring(_octoSrc)()

-- Synapse fallback
do
    local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local function b64decode(data)
        data = tostring(data or ""):gsub("[^" .. b64chars .. "=]", "")
        local bits = data:gsub(".", function(c)
            if c == "=" then return "" end
            local n = b64chars:find(c, 1, true) - 1
            local out = ""
            for i = 5, 0, -1 do
                out = out .. ((n % (2 ^ (i + 1)) >= 2 ^ i) and "1" or "0")
            end
            return out
        end)
        return (bits:gsub("%d%d%d?%d?%d?%d?%d?%d?", function(byte)
            if #byte ~= 8 then return "" end
            return string.char(tonumber(byte, 2))
        end))
    end
    local function protectGui(gui)
        if type(protectgui) == "function" then pcall(protectgui, gui) end
    end
    if not syn then
        getgenv().syn = {
            crypt = { base64 = { decode = b64decode } },
            protect_gui = protectGui,
        }
    elseif type(syn) == "table" then
        pcall(function()
            syn.crypt = syn.crypt or {}
            syn.crypt.base64 = syn.crypt.base64 or {}
            syn.crypt.base64.decode = syn.crypt.base64.decode or b64decode
            syn.protect_gui = syn.protect_gui or protectGui
        end)
    end
end

Octo.cheatname = "GorillaHub"
Octo.gamename = "FallenSurvival"
Octo.toggleKey = Enum.KeyCode.RightControl
Octo:init()
Octo.toggleKey = Enum.KeyCode.None

local THEMES = {
    ["Red"] = {
        ["Accent"]=Color3.fromRGB(255,80,80), ["Background"]=Color3.fromRGB(20,10,10),
        ["Border"]=Color3.fromRGB(0,0,0), ["Border 1"]=Color3.fromRGB(90,40,40),
        ["Border 2"]=Color3.fromRGB(18,8,8), ["Border 3"]=Color3.fromRGB(10,4,4),
        ["Primary Text"]=Color3.fromRGB(255,230,230), ["Group Background"]=Color3.fromRGB(18,8,8),
        ["Selected Tab Background"]=Color3.fromRGB(45,18,18), ["Unselected Tab Background"]=Color3.fromRGB(20,10,10),
        ["Selected Tab Text"]=Color3.fromRGB(255,255,255), ["Unselected Tab Text"]=Color3.fromRGB(220,160,160),
        ["Section Background"]=Color3.fromRGB(26,12,12), ["Option Text 1"]=Color3.fromRGB(255,230,230),
        ["Option Text 2"]=Color3.fromRGB(240,200,200), ["Option Text 3"]=Color3.fromRGB(220,160,160),
        ["Option Border 1"]=Color3.fromRGB(90,40,40), ["Option Border 2"]=Color3.fromRGB(0,0,0),
        ["Option Background"]=Color3.fromRGB(36,16,16),
        ["Risky Text"]=Color3.fromRGB(175,21,21), ["Risky Text Enabled"]=Color3.fromRGB(255,41,41),
    },
}
Octo:SetTheme(THEMES["Red"])

local Library = {}
Library.Flags = {}
Library.Theme = Octo.theme
Library.ThemeColorpickers = {}
Library.Folders = { Configs = Octo.cheatname .. "/" .. Octo.gamename .. "/configs" }
Library.MenuKeybind = Enum.KeyCode.RightControl
Library.Font = Font.fromEnum(Enum.Font.Gotham)

getgenv().GorillaLibrary = Library
getgenv().GorillaOcto = Octo
getgenv().GorillaMenuUnlocked = false
getgenv().GorillaPendingNotifications = getgenv().GorillaPendingNotifications or {}

-- Window Wrapper
function Library:Window(data)
    data = data or {}
    local viewport = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(1280, 720)
    local width, height = 600, 700
    local raw = Octo:NewWindow({
        title = tostring(data.Name or "GorillaHub"),
        size = UDim2.new(0, width, 0, height),
        position = UDim2.new(0, math.floor(viewport.X/2 - width/2), 0, math.floor(viewport.Y/2 - height/2)),
    })
    local window = { raw = raw }
    function window:Page(o)
        o = o or {}
        local tab = raw:AddTab(tostring(o.Name or "Tab"))
        local page = { raw = tab }
        function page:Section(o)
            o = o or {}
            local sec = tab:AddSection(tostring(o.Name or ""), tonumber(o.Side) or 1)
            local section = { raw = sec }
            function section:Toggle(o) local t = sec:AddToggle(o); return { raw = t, Colorpicker = function() end } end
            function section:Slider(o) local s = sec:AddSlider(o); return { raw = s } end
            function section:Dropdown(o) local d = sec:AddList(o); return { raw = d } end
            function section:Button(o) local b = sec:AddButton(o); return { SubButton = function() end } end
            function section:Textbox(o) local tb = sec:AddBox(o); return { raw = tb } end
            function section:Colorpicker(o) local c = sec:AddColor(o); return { raw = c } end
            function section:Bind(o) local b = sec:AddBind(o); return { raw = b } end
            function section:Label(text) return { Colorpicker = function() end, Keybind = function() end } end
            function section:Text(text) sec:AddText({ text = text }) end
            function section:Listbox(o) local l = sec:AddList(o); return { raw = l } end
            return section
        end
        return page
    end
    Octo:SetOpen(false)
    raw.objects.background.Visible = false
    task.spawn(function()
        for _ = 1, 6 do
            if getgenv().GorillaMenuUnlocked then break end
            raw.objects.background.Visible = false
            task.wait(0.03)
        end
    end)
    return window
end

-- Key System
local _keyCode = "SCORPION-WTF-JJZ9V-BMSCZ-8H6JY-127U8"
local _discordUrl = "https://discord.gg/reQwaRfXyX"
do
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "GorillaKeySystem"
    keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    keyGui.IgnoreGuiInset = true
    keyGui.ResetOnSpawn = false
    keyGui.DisplayOrder = 2147483647
    local parentRef = (gethui and gethui()) or PlayerGui
    keyGui.Parent = parentRef

    local bg = Color3.fromRGB(13, 14, 17)
    local panel = Color3.fromRGB(22, 23, 28)
    local box = Color3.fromRGB(29, 30, 36)
    local green = Color3.fromRGB(58, 232, 132)

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
    submit.BackgroundColor3 = green
    submit.Text = "continue"
    submit.TextColor3 = Color3.new(0,0,0)
    submit.Parent = win
    Instance.new("UICorner", submit).CornerRadius = UDim.new(0, 10)

    submit.MouseButton1Click:Connect(function()
        if tb.Text == _keyCode then
            keyGui:Destroy()
            getgenv().GorillaMenuUnlocked = true
            if Octo.windows and Octo.windows[1] then
                Octo.windows[1].objects.background.Visible = true
            end
        else
            tb.Text = "invalid key"
            task.wait(1)
            tb.Text = ""
        end
    end)
end

--========================================================
-- END LOADER
--========================================================
