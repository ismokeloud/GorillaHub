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
local GITHUB_USER = "ismokeloud"
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
-- THEME / HELPERS
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
-- OCTOHOOK + LIBRARY COMPAT LAYER
--========================================================

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

-- Theme presets
local THEMES = {
    ["Black"] = {
        ["Accent"]=Color3.fromRGB(180,180,180), ["Background"]=Color3.fromRGB(8,8,8),
        ["Border"]=Color3.fromRGB(0,0,0), ["Border 1"]=Color3.fromRGB(40,40,40),
        ["Border 2"]=Color3.fromRGB(12,12,12), ["Border 3"]=Color3.fromRGB(4,4,4),
        ["Primary Text"]=Color3.fromRGB(240,240,240), ["Group Background"]=Color3.fromRGB(10,10,10),
        ["Selected Tab Background"]=Color3.fromRGB(24,24,24), ["Unselected Tab Background"]=Color3.fromRGB(8,8,8),
        ["Selected Tab Text"]=Color3.fromRGB(255,255,255), ["Unselected Tab Text"]=Color3.fromRGB(150,150,150),
        ["Section Background"]=Color3.fromRGB(14,14,14), ["Option Text 1"]=Color3.fromRGB(240,240,240),
        ["Option Text 2"]=Color3.fromRGB(200,200,200), ["Option Text 3"]=Color3.fromRGB(150,150,150),
        ["Option Border 1"]=Color3.fromRGB(40,40,40), ["Option Border 2"]=Color3.fromRGB(0,0,0),
        ["Option Background"]=Color3.fromRGB(20,20,20),
        ["Risky Text"]=Color3.fromRGB(175,21,21), ["Risky Text Enabled"]=Color3.fromRGB(255,41,41),
    },
    ["Purple"] = {
        ["Accent"]=Color3.fromRGB(170,90,255), ["Background"]=Color3.fromRGB(14,10,24),
        ["Border"]=Color3.fromRGB(0,0,0), ["Border 1"]=Color3.fromRGB(60,40,90),
        ["Border 2"]=Color3.fromRGB(12,8,20), ["Border 3"]=Color3.fromRGB(6,4,12),
        ["Primary Text"]=Color3.fromRGB(240,230,255), ["Group Background"]=Color3.fromRGB(12,8,20),
        ["Selected Tab Background"]=Color3.fromRGB(30,20,50), ["Unselected Tab Background"]=Color3.fromRGB(14,10,24),
        ["Selected Tab Text"]=Color3.fromRGB(255,255,255), ["Unselected Tab Text"]=Color3.fromRGB(180,160,220),
        ["Section Background"]=Color3.fromRGB(18,14,30), ["Option Text 1"]=Color3.fromRGB(240,230,255),
        ["Option Text 2"]=Color3.fromRGB(210,200,240), ["Option Text 3"]=Color3.fromRGB(170,160,200),
        ["Option Border 1"]=Color3.fromRGB(60,40,90), ["Option Border 2"]=Color3.fromRGB(0,0,0),
        ["Option Background"]=Color3.fromRGB(26,20,42),
        ["Risky Text"]=Color3.fromRGB(175,21,21), ["Risky Text Enabled"]=Color3.fromRGB(255,41,41),
    },
    ["Green"] = {
        ["Accent"]=Color3.fromRGB(50,220,110), ["Background"]=Color3.fromRGB(12,24,16),
        ["Border"]=Color3.fromRGB(0,0,0), ["Border 1"]=Color3.fromRGB(35,90,55),
        ["Border 2"]=Color3.fromRGB(10,20,13), ["Border 3"]=Color3.fromRGB(5,11,7),
        ["Primary Text"]=Color3.fromRGB(235,255,240), ["Group Background"]=Color3.fromRGB(10,20,13),
        ["Selected Tab Background"]=Color3.fromRGB(18,40,26), ["Unselected Tab Background"]=Color3.fromRGB(12,24,16),
        ["Selected Tab Text"]=Color3.fromRGB(235,255,240), ["Unselected Tab Text"]=Color3.fromRGB(150,215,170),
        ["Section Background"]=Color3.fromRGB(16,34,22), ["Option Text 1"]=Color3.fromRGB(235,255,240),
        ["Option Text 2"]=Color3.fromRGB(200,235,210), ["Option Text 3"]=Color3.fromRGB(150,215,170),
        ["Option Border 1"]=Color3.fromRGB(35,90,55), ["Option Border 2"]=Color3.fromRGB(0,0,0),
        ["Option Background"]=Color3.fromRGB(22,48,32),
        ["Risky Text"]=Color3.fromRGB(175,21,21), ["Risky Text Enabled"]=Color3.fromRGB(255,41,41),
    },
    ["Blue"] = {
        ["Accent"]=Color3.fromRGB(80,160,255), ["Background"]=Color3.fromRGB(10,14,24),
        ["Border"]=Color3.fromRGB(0,0,0), ["Border 1"]=Color3.fromRGB(40,60,90),
        ["Border 2"]=Color3.fromRGB(8,12,20), ["Border 3"]=Color3.fromRGB(4,6,12),
        ["Primary Text"]=Color3.fromRGB(230,240,255), ["Group Background"]=Color3.fromRGB(8,12,20),
        ["Selected Tab Background"]=Color3.fromRGB(18,28,50), ["Unselected Tab Background"]=Color3.fromRGB(10,14,24),
        ["Selected Tab Text"]=Color3.fromRGB(255,255,255), ["Unselected Tab Text"]=Color3.fromRGB(160,180,220),
        ["Section Background"]=Color3.fromRGB(14,18,30), ["Option Text 1"]=Color3.fromRGB(230,240,255),
        ["Option Text 2"]=Color3.fromRGB(200,215,240), ["Option Text 3"]=Color3.fromRGB(160,180,220),
        ["Option Border 1"]=Color3.fromRGB(40,60,90), ["Option Border 2"]=Color3.fromRGB(0,0,0),
        ["Option Background"]=Color3.fromRGB(20,26,42),
        ["Risky Text"]=Color3.fromRGB(175,21,21), ["Risky Text Enabled"]=Color3.fromRGB(255,41,41),
    },
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

-- ApplyTheme
local function ApplyTheme(name)
    local t = THEMES[name]
    if not t then
        Library:Notification("Unknown theme: " .. tostring(name), 2, Color3.fromRGB(255, 80, 80))
        return
    end
    for k, v in pairs(t) do Octo.theme[k] = v end
    Library.Theme = Octo.theme
    for k, v in pairs(t) do
        local picker = Library.ThemeColorpickers[k]
        if picker then pcall(function() picker:Set(v) end) end
    end
    Octo.UpdateThemeColors()
    Library:Notification("Theme applied: " .. tostring(name), 2, Color3.fromRGB(50, 220, 110))
end

local KINDS, SETTERS = {}, {}
local function ColorFlag(c3)
    c3 = c3 or Color3.new(1, 1, 1)
    return {
        Color = c3,
        HexValue = string.format("#%02X%02X%02X",
            math.floor(c3.R*255+0.5), math.floor(c3.G*255+0.5), math.floor(c3.B*255+0.5)),
        Alpha = 1,
    }
end
local function CopyValue(v)
    if type(v) == "table" then
        local t = {}
        for k, x in pairs(v) do t[k] = CopyValue(x) end
        return t
    end
    return v
end
local function Register(flag, kind, value, setter)
    if flag == nil or flag == "" then return end
    Library.Flags[flag] = value
    KINDS[flag] = kind
    SETTERS[flag] = setter
end

local function AddSlider(section, opts)
    opts = opts or {}
    local flag = opts.Flag
    local decimals = tonumber(opts.Decimals) or 0
    local increment = decimals > 0 and (10 ^ -decimals) or 1
    local default = tonumber(opts.Default) or 0
    local initial = decimals > 0 and (default + increment * 1e-6) or default
    local raw = section:AddSlider({
        text = tostring(opts.Name or ""), flag = flag,
        min = tonumber(opts.Min) or 0, max = tonumber(opts.Max) or 100,
        value = initial, suffix = tostring(opts.Suffix or ""), increment = increment,
        callback = function(v)
            if flag then Library.Flags[flag] = v end
            if opts.Callback then opts.Callback(v) end
        end,
    })
    raw.value = default
    Register(flag, "slider", default, function(v) raw:SetValue(tonumber(v) or 0, false) end)
    return { raw = raw, Set = function(_, v) raw:SetValue(tonumber(v) or 0, false) end }
end

local function AddDropdown(section, opts)
    opts = opts or {}
    local flag = opts.Flag
    local multi = opts.Multi == true
    local values = {}
    for i, v in ipairs(opts.Items or {}) do values[i] = tostring(v) end
    local raw = section:AddList({
        text = tostring(opts.Name or ""), flag = flag, values = values, multi = multi,
        callback = function(v)
            if not multi and v == "" then v = nil end
            if flag then Library.Flags[flag] = CopyValue(v) end
            if opts.Callback then opts.Callback(v) end
        end,
    })
    if opts.Default ~= nil then
        raw:Select(CopyValue(opts.Default), true)
        if opts.Callback then opts.Callback(CopyValue(raw.selected)) end
    end
    local selected = raw.selected
    if not multi and selected == "" then selected = nil end
    Register(flag, "dropdown", CopyValue(selected), function(v) raw:Select(v, false) end)
    return { raw = raw, Set = function(_, v) raw:Select(v, false) end }
end

local function AddColor(section, opts)
    opts = opts or {}
    local flag = opts.Flag
    local default = opts.Default or Color3.fromRGB(255, 255, 255)
    local raw = section:AddColor({
        text = tostring(opts.Text or opts.Name or ""), flag = flag, color = default,
        callback = function(c3)
            if flag then Library.Flags[flag] = ColorFlag(c3) end
            if opts.Callback then opts.Callback(c3) end
        end,
    })
    Register(flag, "color", ColorFlag(default), function(v)
        local c3 = type(v) == "table" and v.Color or v
        raw:SetColor(c3 or Color3.new(1, 1, 1), false)
    end)
    return {
        raw = raw,
        Set = function(_, c3)
            raw:SetColor(c3 or Color3.new(1, 1, 1), true)
            if flag then Library.Flags[flag] = ColorFlag(c3) end
        end,
    }
end

local function AddToggle(section, opts)
    opts = opts or {}
    local flag = opts.Flag
    local default = opts.Default == true
    local raw = section:AddToggle({
        text = tostring(opts.Name or ""), flag = flag,
        callback = function(v)
            if flag then Library.Flags[flag] = v end
            if opts.Callback then opts.Callback(v) end
        end,
    })
    if default then raw:SetState(true, true) end
    Register(flag, "toggle", default, function(v) raw:SetState(v == true, false) end)
    local wrapper = { raw = raw }
    function wrapper:Colorpicker(o)
        o = o or {}
        local colorFlag = o.Flag
        local colorDefault = o.Default or Color3.fromRGB(255, 255, 255)
        local color = raw:AddColor({
            text = tostring(o.Name or ""), flag = colorFlag, color = colorDefault,
            callback = function(c3)
                if colorFlag then Library.Flags[colorFlag] = ColorFlag(c3) end
                if o.Callback then o.Callback(c3) end
            end,
        })
        Register(colorFlag, "color", ColorFlag(colorDefault), function(v)
            local c3 = type(v) == "table" and v.Color or v
            color:SetColor(c3 or Color3.new(1, 1, 1), false)
        end)
        return {
            raw = color,
            Set = function(_, c3)
                color:SetColor(c3 or Color3.new(1, 1, 1), true)
                if colorFlag then Library.Flags[colorFlag] = ColorFlag(c3) end
            end,
        }
    end
    return wrapper
end

local function AddBind(section, opts)
    opts = opts or {}
    local flag = opts.Flag
    local mode = tostring(opts.Mode or "Toggle")
    local default = opts.Default or Enum.KeyCode.None
    local entry = { Mode = mode, Key = default, Toggled = false, Active = false }
    local raw
    Register(flag, "keybind", entry, function(v)
        if not raw or type(v) ~= "table" then return end
        local wantToggled = v.Toggled == true
        local e = Library.Flags[flag]
        if e then e.Mode = v.Mode or e.Mode end
        raw:SetBind(v.Key or Enum.KeyCode.None)
        if e then
            e.Mode = v.Mode or e.Mode
            e.Toggled = wantToggled
            e.Active = false
            raw.state = wantToggled
            pcall(function() raw.indicatorValue:SetEnabled(wantToggled and not raw.noindicator) end)
        end
    end)
    local creating = true
    raw = section:AddBind({
        text = tostring(opts.Text or opts.Name or ""), flag = flag,
        bind = default, mode = mode:lower(),
        callback = function(state)
            if flag then
                local e = Library.Flags[flag]
                if e then e.Toggled = state == true; e.Active = state == true end
            end
        end,
        keycallback = function(key)
            if flag then
                local e = Library.Flags[flag]
                if e then e.Key = (key == "none") and Enum.KeyCode.None or key end
            end
            if flag == "Menu Keybind" and key ~= "none" and typeof(key) == "EnumItem" and key ~= Enum.KeyCode.None then
                Library.MenuKeybind = key
                if getgenv().GorillaMenuUnlocked then Octo.toggleKey = key end
            end
            if not creating and opts.Callback then opts.Callback(key) end
        end,
    })
    creating = false
    if flag then
        local e = Library.Flags[flag]
        if e then e.Key = (raw.bind == "none") and Enum.KeyCode.None or raw.bind end
    end
    return { raw = raw, Set = function(_, key) if key ~= nil then raw:SetBind(key) end end }
end

local function MakeButton(raw)
    local wrapper = { raw = raw }
    function wrapper:SubButton(o)
        o = o or {}
        local sub = raw:AddButton({ text = tostring(o.Name or ""), flag = o.Flag, callback = o.Callback })
        return MakeButton(sub)
    end
    return wrapper
end
local function AddButton(section, opts)
    opts = opts or {}
    local raw = section:AddButton({ text = tostring(opts.Name or ""), flag = opts.Flag, callback = opts.Callback })
    return MakeButton(raw)
end
local function AddBox(section, opts)
    opts = opts or {}
    local flag = opts.Flag
    local default = tostring(opts.Default or "")
    local raw = section:AddBox({
        text = tostring(opts.Name or ""), flag = flag, input = default,
        callback = function(v)
            if flag then Library.Flags[flag] = v end
            if opts.Callback then opts.Callback(v) end
        end,
    })
    Register(flag, "text", default, function(v) raw:SetInput(tostring(v or ""), false) end)
    if opts.Default ~= nil and opts.Callback then opts.Callback(default) end
    return { raw = raw }
end
local function MakeLabel(section, text)
    local label = { text = tostring(text or "") }
    function label:Colorpicker(o)
        o = o or {}
        return AddColor(section, { Text = self.text, Flag = o.Flag, Default = o.Default, Callback = o.Callback })
    end
    function label:Keybind(o)
        o = o or {}
        return AddBind(section, { Text = self.text, Flag = o.Flag, Default = o.Default, Mode = o.Mode, Callback = o.Callback })
    end
    return label
end
local function MakeSection(raw)
    local section = { raw = raw }
    function section:Toggle(o) return AddToggle(raw, o) end
    function section:Slider(o) return AddSlider(raw, o) end
    function section:Dropdown(o) return AddDropdown(raw, o) end
    function section:Button(o) return AddButton(raw, o) end
    function section:Textbox(o) return AddBox(raw, o) end
    function section:Listbox(o) o = o or {}; o.Multi = false; return AddDropdown(raw, o) end
    function section:Colorpicker(o) return AddColor(raw, o) end
    function section:Bind(o) return AddBind(raw, o) end
    function section:Label(text) return MakeLabel(raw, text) end
    function section:Text(text) raw:AddText({ text = tostring(text or "") }) end
    return section
end
local function MakePage(raw)
    local page = { raw = raw }
    function page:Section(o)
        o = o or {}
        return MakeSection(raw:AddSection(tostring(o.Name or ""), tonumber(o.Side) or 1))
    end
    return page
end

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
        return MakePage(raw:AddTab(tostring(o.Name or "Tab")))
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

function Library:Watermark(text, info)
    Octo.watermark.text[1] = { tostring(text or "GorillaHub"), true }
    Octo.watermark.text[2] = { "", false }
    Octo.watermark.text[3] = { Octo.gamename, true }
    local watermark = {}
    function watermark:SetVisibility(v)
        Octo.flags.watermark_enabled = v == true
        pcall(function() Octo.watermark:Update() end)
    end
    function watermark:SetText(t)
        Octo.watermark.text[1] = { tostring(t or "GorillaHub"), true }
        pcall(function() Octo.watermark:Update() end)
    end
    return watermark
end
function Library:KeybindList()
    local list = {}
    function list:SetVisibility(v) pcall(function() Octo.keyIndicator:SetEnabled(v == true) end) end
    return list
end
function Library:Notification(text, duration, color)
    local message
    if type(text) == "table" then
        message = tostring(text.Title or text.Description or "Notification")
    else
        message = tostring(text or "")
    end
    local dur = tonumber(duration) or 3
    local c3 = (typeof(color) == "Color3") and color or Color3.fromRGB(50, 220, 110)
    if not getgenv().GorillaMenuUnlocked then
        table.insert(getgenv().GorillaPendingNotifications, { message, dur, c3 })
        return
    end
    pcall(function() Octo:SendNotification(message, dur, c3) end)
end
function Library:FlushNotifications()
    for _, n in ipairs(getgenv().GorillaPendingNotifications or {}) do
        pcall(function() Octo:SendNotification(n[1], n[2], n[3]) end)
    end
    getgenv().GorillaPendingNotifications = {}
end
function Library:ChangeTheme(key, value)
    if key == nil then return end
    if Octo and Octo.theme then Octo.theme[key] = value end
    if Octo and Octo.UpdateThemeColors then pcall(function() Octo.UpdateThemeColors() end) end
end

-- Configs
local function ConfigPath(name)
    name = tostring(name or "")
    if name == "" then return nil end
    if not name:lower():match("%.json$") then name = name .. ".json" end
    return Library.Folders.Configs .. "/" .. name
end
local function EncodeFlag(value, kind)
    if kind == "color" then
        local c3 = (type(value) == "table" and value.Color) or Color3.new(1, 1, 1)
        return { __type = "Color3", r = c3.R, g = c3.G, b = c3.B }
    elseif kind == "keybind" then
        local key = type(value) == "table" and value.Key or Enum.KeyCode.None
        return {
            __type = "Keybind",
            key = (typeof(key) == "EnumItem" and key.Name) or "None",
            mode = (type(value) == "table" and value.Mode) or "Toggle",
            toggled = type(value) == "table" and value.Toggled == true or false,
        }
    end
    return value
end
local function DecodeFlag(value, kind)
    if kind == "color" and type(value) == "table" then
        return ColorFlag(Color3.new(tonumber(value.r) or 1, tonumber(value.g) or 1, tonumber(value.b) or 1))
    elseif kind == "keybind" and type(value) == "table" then
        local keyName = value.key or "None"
        return {
            Mode = value.mode or "Toggle",
            Key = Enum.KeyCode[keyName] or Enum.UserInputType[keyName] or Enum.KeyCode.None,
            Toggled = value.toggled == true, Active = false,
        }
    end
    return value
end
function Library:GetConfig(name)
    if name ~= nil then
        local path = ConfigPath(name)
        if not path then return nil end
        local ok, contents = pcall(readfile, path)
        return ok and contents or nil
    end
    local data = {}
    for flag, value in pairs(self.Flags) do data[flag] = EncodeFlag(value, KINDS[flag]) end
    return HttpService:JSONEncode(data)
end
function Library:SaveConfig(name)
    local path = ConfigPath(name)
    if not path then return end
    local ok = pcall(function() writefile(path, self:GetConfig()) end)
    if ok then self:Notification("Config saved: " .. name, 3, Color3.fromRGB(50, 220, 110))
    else self:Notification("Failed to save config", 3, Color3.fromRGB(255, 0, 0)) end
end
function Library:LoadConfig(contents)
    if type(contents) ~= "string" then return end
    local ok, data = pcall(function() return HttpService:JSONDecode(contents) end)
    if not ok or type(data) ~= "table" then
        self:Notification("Invalid config", 3, Color3.fromRGB(255, 0, 0)); return
    end
    for flag, rawValue in pairs(data) do
        local kind, setter = KINDS[flag], SETTERS[flag]
        if kind and setter then pcall(setter, DecodeFlag(rawValue, kind)) end
    end
    self:Notification("Config loaded", 3, Color3.fromRGB(50, 220, 110))
end
function Library:DeleteConfig(name)
    local path = ConfigPath(name)
    if not path then return end
    pcall(delfile, path)
end
function Library:RefreshConfigsList(list)
    local raw = list and (list.raw or list) or nil
    if not raw then return end
    raw:ClearValues()
    local ok, files = pcall(listfiles, self.Folders.Configs)
    if not ok or type(files) ~= "table" then return end
    table.sort(files)
    for _, path in ipairs(files) do
        local name = tostring(path):match("([^\\/]+)$")
        if name and name:lower():match("%.json$") then raw:AddValue(name) end
    end
end

--========================================================
-- KEY SYSTEM
--========================================================

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

    local keyFont
    pcall(function() keyFont = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium) end)
    if not keyFont then keyFont = Enum.Font.GothamMedium end
    local function F(lbl)
        local ok = pcall(function() lbl.FontFace = keyFont end)
        if not ok or not lbl.FontFace then pcall(function() lbl.Font = keyFont end) end
        if not lbl.FontFace then lbl.Font = Enum.Font.GothamMedium end
    end

    local white = Color3.fromRGB(245, 246, 250)
    local lightGray = Color3.fromRGB(156, 158, 168)
    local dimGray = Color3.fromRGB(96, 98, 108)
    local green = Color3.fromRGB(58, 232, 132)
    local greenBright = Color3.fromRGB(120, 255, 180)
    local blue = Color3.fromRGB(96, 190, 255)
    local red = Color3.fromRGB(255, 96, 108)
    local bg = Color3.fromRGB(13, 14, 17)
    local panel = Color3.fromRGB(22, 23, 28)
    local box = Color3.fromRGB(29, 30, 36)
    local strokeColor = Color3.fromRGB(46, 48, 58)

    local function corner(inst, r)
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r); c.Parent = inst; return c
    end
    local function stroke(inst, color, thickness, transparency)
        local s = Instance.new("UIStroke")
        s.Color = color or strokeColor
        s.Thickness = thickness or 1
        s.Transparency = transparency or 0
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent = inst
        return s
    end
    local function padding(inst, p)
        local u = Instance.new("UIPadding")
        u.PaddingLeft = UDim.new(0, p); u.PaddingRight = UDim.new(0, p)
        u.PaddingTop = UDim.new(0, p); u.PaddingBottom = UDim.new(0, p)
        u.Parent = inst
    end
    local function tween(inst, props, t, style)
        return TweenService:Create(inst, TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    end

    local blocker = Instance.new("Frame")
    blocker.Size = UDim2.fromScale(1, 1)
    blocker.BackgroundColor3 = Color3.new(0, 0, 0)
    blocker.BackgroundTransparency = 1
    blocker.BorderSizePixel = 0
    blocker.Active = true
    blocker.Parent = keyGui
    tween(blocker, { BackgroundTransparency = 0.35 }, 0.25):Play()

    pcall(function()
        local blur = Instance.new("BlurEffect")
        blur.Size = 0; blur.Parent = Lighting
        tween(blur, { Size = 18 }, 0.3):Play()
        keyGui.AncestryChanged:Connect(function(_, parent)
            if not parent then
                local tw = tween(blur, { Size = 0 }, 0.2)
                tw:Play(); tw.Completed:Wait(); blur:Destroy()
            end
        end)
    end)

    local win = Instance.new("Frame")
    win.Size = UDim2.fromOffset(400, 470)
    win.Position = UDim2.new(0.5, -200, 0.5, -235)
    win.BackgroundColor3 = bg
    win.BorderSizePixel = 0
    win.Active = true
    win.Parent = keyGui
    corner(win, 16)
    local winStroke = stroke(win, strokeColor, 1, 0.15)

    local shadow = Instance.new("ImageLabel")
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.fromScale(0.5, 0.5)
    shadow.Size = UDim2.new(1, 80, 1, 80)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.4
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = -1
    shadow.Parent = win

    win.BackgroundTransparency = 1
    win.Size = UDim2.fromOffset(360, 430)
    tween(win, { BackgroundTransparency = 0, Size = UDim2.fromOffset(400, 470) }, 0.3, Enum.EasingStyle.Back):Play()
    tween(winStroke, { Transparency = 0.15 }, 0.3):Play()

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(1, 0, 0, 3)
    accent.BackgroundColor3 = white
    accent.BorderSizePixel = 0
    accent.Parent = win
    corner(accent, 16)
    local accentGrad = Instance.new("UIGradient")
    accentGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, green),
        ColorSequenceKeypoint.new(0.5, blue),
        ColorSequenceKeypoint.new(1, green),
    })
    accentGrad.Parent = accent

    task.spawn(function()
        while win.Parent do
            for i = 0, 1, 0.02 do
                if not win.Parent then break end
                accentGrad.Offset = Vector2.new(math.sin(i * math.pi) * 0.3, 0)
                task.wait(0.03)
            end
        end
    end)

    local inner = Instance.new("Frame")
    inner.Size = UDim2.fromScale(1, 1)
    inner.BackgroundTransparency = 1
    inner.Parent = win
    padding(inner, 28)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(26, 26)
    closeBtn.Position = UDim2.new(1, -26, 0, 22)
    closeBtn.AnchorPoint = Vector2.new(1, 0)
    closeBtn.BackgroundColor3 = box
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "x"
    closeBtn.TextColor3 = lightGray
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = 5
    closeBtn.Parent = win
    corner(closeBtn, 8)
    local closeStroke = stroke(closeBtn, strokeColor, 1, 0.2)
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, { BackgroundColor3 = red, TextColor3 = white }, 0.12):Play()
        tween(closeStroke, { Color = red, Transparency = 0 }, 0.12):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, { BackgroundColor3 = box, TextColor3 = lightGray }, 0.12):Play()
        tween(closeStroke, { Color = strokeColor, Transparency = 0.2 }, 0.12):Play()
    end)
    closeBtn.MouseButton1Click:Connect(function()
        tween(win, { BackgroundTransparency = 1, Size = UDim2.fromOffset(360, 430) }, 0.2, Enum.EasingStyle.Quad):Play()
        tween(blocker, { BackgroundTransparency = 1 }, 0.2):Play()
        task.wait(0.22)
        keyGui:Destroy()
    end)

    local icon = Instance.new("Frame")
    icon.Size = UDim2.fromOffset(42, 42)
    icon.Position = UDim2.new(0.5, -21, 0, 0)
    icon.BackgroundColor3 = panel
    icon.BorderSizePixel = 0
    icon.Parent = inner
    corner(icon, 10)
    stroke(icon, green, 1, 0.7)
    local iconGlyph = Instance.new("TextLabel")
    iconGlyph.Size = UDim2.fromScale(1, 1)
    iconGlyph.BackgroundTransparency = 1
    iconGlyph.Text = "G"
    iconGlyph.Font = Enum.Font.GothamBlack
    iconGlyph.TextSize = 20
    iconGlyph.TextColor3 = green
    iconGlyph.Parent = icon

    local title = Instance.new("TextLabel")
    title.Position = UDim2.fromOffset(0, 52)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "GorillaHub"
    title.TextXAlignment = Enum.TextXAlignment.Center
    F(title)
    title.TextSize = 26
    title.TextColor3 = white
    title.Parent = inner

    local subtitle = Instance.new("TextLabel")
    subtitle.Position = UDim2.fromOffset(0, 86)
    subtitle.Size = UDim2.new(1, 0, 0, 16)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "enter your key to continue"
    subtitle.TextXAlignment = Enum.TextXAlignment.Center
    F(subtitle)
    subtitle.TextSize = 12
    subtitle.TextColor3 = lightGray
    subtitle.Parent = inner

    local sep = Instance.new("Frame")
    sep.Position = UDim2.fromOffset(0, 116)
    sep.Size = UDim2.new(1, 0, 0, 1)
    sep.BackgroundColor3 = white
    sep.BorderSizePixel = 0
    sep.Parent = inner
    local sepGrad = Instance.new("UIGradient")
    sepGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.5),
        NumberSequenceKeypoint.new(1, 1),
    })
    sepGrad.Parent = sep

    local tb = Instance.new("TextBox")
    tb.Position = UDim2.fromOffset(0, 132)
    tb.Size = UDim2.new(1, 0, 0, 46)
    tb.BackgroundColor3 = box
    tb.BorderSizePixel = 0
    tb.PlaceholderText = "paste key here..."
    tb.PlaceholderColor3 = dimGray
    tb.Text = ""
    tb.TextColor3 = white
    F(tb)
    tb.TextSize = 13
    tb.TextXAlignment = Enum.TextXAlignment.Left
    tb.ClearTextOnFocus = false
    tb.Parent = inner
    corner(tb, 10)
    local tbStroke = stroke(tb, strokeColor, 1, 0.1)
    padding(tb, 16)
    tb.Focused:Connect(function()
        tween(tbStroke, { Color = green, Transparency = 0 }, 0.12):Play()
        tween(tb, { BackgroundColor3 = Color3.fromRGB(34, 35, 42) }, 0.12):Play()
    end)
    tb.FocusLost:Connect(function()
        tween(tbStroke, { Color = strokeColor, Transparency = 0.1 }, 0.15):Play()
        tween(tb, { BackgroundColor3 = box }, 0.15):Play()
    end)

    local submit = Instance.new("TextButton")
    submit.Position = UDim2.fromOffset(0, 192)
    submit.Size = UDim2.new(1, 0, 0, 44)
    submit.BackgroundColor3 = white
    submit.BorderSizePixel = 0
    submit.Text = "continue"
    submit.TextColor3 = Color3.fromRGB(10, 30, 18)
    F(submit)
    submit.TextSize = 14
    submit.AutoButtonColor = false
    submit.Parent = inner
    corner(submit, 10)
    local submitGrad = Instance.new("UIGradient")
    submitGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, green),
        ColorSequenceKeypoint.new(1, greenBright),
    })
    submitGrad.Parent = submit
    local submitStroke = stroke(submit, greenBright, 1, 0.7)

    submit.MouseEnter:Connect(function()
        tween(submitStroke, { Transparency = 0 }, 0.12):Play()
    end)
    submit.MouseLeave:Connect(function()
        tween(submitStroke, { Transparency = 0.7 }, 0.15):Play()
    end)

    local discordBtn = Instance.new("TextButton")
    discordBtn.Position = UDim2.fromOffset(0, 250)
    discordBtn.Size = UDim2.new(1, 0, 0, 48)
    discordBtn.BackgroundColor3 = panel
    discordBtn.BorderSizePixel = 0
    discordBtn.Text = "join discord  -  reQwaRfXyX"
    discordBtn.TextColor3 = white
    F(discordBtn)
    discordBtn.TextSize = 13
    discordBtn.AutoButtonColor = false
    discordBtn.Parent = inner
    corner(discordBtn, 10)
    local discStroke = stroke(discordBtn, strokeColor, 1, 0.1)
    discordBtn.MouseEnter:Connect(function()
        tween(discordBtn, { BackgroundColor3 = Color3.fromRGB(30, 44, 40) }, 0.15):Play()
        tween(discStroke, { Color = green, Transparency = 0 }, 0.15):Play()
    end)
    discordBtn.MouseLeave:Connect(function()
        tween(discordBtn, { BackgroundColor3 = panel }, 0.15):Play()
        tween(discStroke, { Color = strokeColor, Transparency = 0.1 }, 0.15):Play()
    end)

    local discordHint = Instance.new("TextLabel")
    discordHint.Position = UDim2.fromOffset(0, 304)
    discordHint.Size = UDim2.new(1, 0, 0, 14)
    discordHint.BackgroundTransparency = 1
    discordHint.Text = "click to copy invite link"
    discordHint.TextXAlignment = Enum.TextXAlignment.Center
    F(discordHint)
    discordHint.TextSize = 11
    discordHint.TextColor3 = dimGray
    discordHint.Parent = inner

    local statusPill = Instance.new("Frame")
    statusPill.Position = UDim2.new(0.5, -90, 0, 334)
    statusPill.Size = UDim2.fromOffset(180, 26)
    statusPill.BackgroundColor3 = panel
    statusPill.BackgroundTransparency = 1
    statusPill.BorderSizePixel = 0
    statusPill.Parent = inner
    corner(statusPill, 13)

    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.fromOffset(6, 6)
    statusDot.Position = UDim2.new(0, 12, 0.5, -3)
    statusDot.BackgroundColor3 = red
    statusDot.BorderSizePixel = 0
    statusDot.BackgroundTransparency = 1
    statusDot.Parent = statusPill
    corner(statusDot, 3)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -24, 1, 0)
    status.Position = UDim2.fromOffset(24, 0)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.TextXAlignment = Enum.TextXAlignment.Center
    F(status)
    status.TextSize = 12
    status.TextColor3 = red
    status.Parent = statusPill

    local function setStatus(text, color)
        status.Text = text
        status.TextColor3 = color or red
        statusDot.BackgroundColor3 = color or red
        local target = text ~= "" and 0.25 or 1
        tween(statusPill, { BackgroundTransparency = target }, 0.15):Play()
        tween(statusDot, { BackgroundTransparency = text ~= "" and 0 or 1 }, 0.15):Play()
    end

    local footer = Instance.new("TextLabel")
    footer.Position = UDim2.new(0, 0, 1, -26)
    footer.Size = UDim2.new(1, 0, 0, 14)
    footer.BackgroundTransparency = 1
    footer.Text = "no key? join the discord to get one"
    footer.TextXAlignment = Enum.TextXAlignment.Center
    F(footer)
    footer.TextSize = 10
    footer.TextColor3 = dimGray
    footer.Parent = inner

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 70)
    titleBar.BackgroundTransparency = 1
    titleBar.Active = true
    titleBar.ZIndex = 3
    titleBar.Parent = win

    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = win.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    discordBtn.MouseButton1Click:Connect(function()
        local ok = pcall(function() setclipboard(_discordUrl) end)
        if ok then
            setStatus("invite link copied", greenBright)
            task.delay(1.8, function() if status and status.Parent then setStatus("", red) end end)
        else
            setStatus(_discordUrl, white)
        end
    end)

    local busy = false
    local function check()
        if busy then return end
        if tb.Text == _keyCode then
            busy = true
            setStatus("key accepted", greenBright)
            submit.Text = "unlocked"
            tween(submitStroke, { Transparency = 0 }, 0.2):Play()
            task.wait(0.55)
            tween(win, { BackgroundTransparency = 1, Size = UDim2.fromOffset(360, 430) }, 0.25, Enum.EasingStyle.Back):Play()
            tween(blocker, { BackgroundTransparency = 1 }, 0.25):Play()
            task.wait(0.28)
            keyGui:Destroy()
            getgenv().GorillaMenuUnlocked = true
            if Library.MenuKeybind and Library.MenuKeybind ~= Enum.KeyCode.None then
                Octo.toggleKey = Library.MenuKeybind
            end
            Library:FlushNotifications()
        else
            setStatus("invalid key", red)
            tb.Text = ""
            task.spawn(function()
                local orig = win.Position
                for i = 1, 4 do
                    win.Position = orig + UDim2.fromOffset((i % 2 == 0 and 7 or -7), 0)
                    task.wait(0.028)
                end
                win.Position = orig
            end)
        end
    end
    submit.MouseButton1Click:Connect(check)
    tb.FocusLost:Connect(function(enter) if enter then check() end end)
end

--========================================================
-- SCREEN GUI + BLUR (for the game selector)
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

New("UIGradient", {
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
    Theme.Background, 14, 7
)
SelectorPanel.AnchorPoint = Vector2.new(0.5, 0.5)
SelectorPanel.ClipsDescendants = true

Outline(SelectorPanel, Theme.Blue, 0.35, 1.3)

local SelectorGlow = MakeFrame(
    SplashContent,
    UDim2.fromScale(0.5, 0.5),
    UDim2.fromOffset(730, 485),
    Theme.Blue, 16, 6
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
    Theme.Cyan, nil, 8
)

local function CreateLogo(parent, position, size)
    local logo = MakeFrame(parent, position, UDim2.fromOffset(size, size), Color3.fromRGB(18, 47, 73), 11, 10)
    Outline(logo, Theme.Blue, 0.15, 1.3)
    local ring = MakeFrame(logo, UDim2.fromOffset(4, 4), UDim2.new(1, -8, 1, -8), Theme.Panel, 9, 11)
    ring.BackgroundTransparency = 1
    Outline(ring, Theme.Cyan, 0.65, 1)
    local letter = MakeLabel(logo, "G", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1),
        Fonts.Display, math.floor(size * 0.65), Theme.Cyan, 12)
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
    if ActiveModuleCleanup then
        pcall(ActiveModuleCleanup)
        ActiveModuleCleanup = nil
    end
    ModuleLoaded = false

    local url = BASE_URL .. "games/" .. gameData.File .. ".lua?t=" .. tostring(os.time())
    local ok, scriptText = pcall(function() return game:HttpGet(url) end)
    if not ok or not scriptText or scriptText == "" then
        warn("[GorillaHub] Failed to fetch module: " .. gameData.File)
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

    MakeLabel(SelectorPanel, "OPENING " .. gameData.ShortName .. "...",
        UDim2.fromOffset(29, 411), UDim2.new(1, -58, 0, 17),
        Fonts.Tech, 9, Theme.Cyan, 15)

    for name, data in pairs(GameCards) do
        if name == gameData.ShortName then
            Animate(data.Stroke, 0.2, { Color = Theme.Cyan, Transparency = 0 })
            Animate(data.Image, 0.2, { ImageColor3 = Color3.new(1, 1, 1) })
            data.SelectText.Text = "OPENING HUB..."
        else
            Animate(data.Button, 0.2, { BackgroundTransparency = 0.55 })
            Animate(data.Image, 0.2, { ImageTransparency = 0.5 })
        end
    end

    task.spawn(function()
        local loaded = LoadGameModule(gameData)
        if not loaded then
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
        Image = string.format("rbxthumb://type=GameThumbnail&id=%d&w=768&h=432", gameData.UniverseId),
        ScaleType = Enum.ScaleType.Crop,
        ImageTransparency = 0.05,
        ImageColor3 = Color3.fromRGB(210, 225, 240),
        ZIndex = 12
    }, imageClip)

    task.delay(6, function()
        if thumbnail.Parent and not thumbnail.IsLoaded then
            thumbnail.Image = string.format("rbxthumb://type=GameIcon&id=%d&w=512&h=512", gameData.UniverseId)
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
        Animate(cardStroke, 0.18, { Color = gameData.Accent, Transparency = 0.08, Thickness = 1.5 })
        Animate(thumbnail, 0.25, { Size = UDim2.new(1, 12, 1, 12), ImageColor3 = Color3.new(1, 1, 1) })
        Animate(selectBar, 0.18, { BackgroundColor3 = Color3.fromRGB(25, 67, 99) })
        Animate(selectStroke, 0.18, { Transparency = 0.15 })
    end)

    card.MouseLeave:Connect(function()
        Animate(card, 0.18, { BackgroundColor3 = Theme.Panel })
        Animate(cardStroke, 0.18, { Color = Theme.Border, Transparency = 0.55, Thickness = 1 })
        Animate(thumbnail, 0.22, { Size = UDim2.fromScale(1, 1), ImageColor3 = Color3.fromRGB(210, 225, 240) })
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
