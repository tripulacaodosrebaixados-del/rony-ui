--[[
███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗    ██╗   ██╗██╗
████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝    ██║   ██║██║
██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗    ██║   ██║██║
██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║    ██║   ██║██║
██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║    ╚██████╔╝██║
╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝     ╚═════╝ ╚═╝

    NexusUI — Floating Interface Library for Roblox
    Version: 2.0.0 | Mobile + PC Support
    Author: NexusUI Framework
    
    FEATURES:
    ► Floating draggable window
    ► Tabs with animated switching
    ► Toggle buttons (on/off with animation)
    ► Buttons with ripple effect
    ► Sliders with value display
    ► Dropdowns / Selectors
    ► Text inputs
    ► Labels & Separators
    ► Scrolling sections
    ► Notifications / Toasts
    ► Mobile-first design
    ► Glassmorphism visual theme
    ► Smooth animations everywhere
    
    USAGE EXAMPLE at the bottom of this file.
--]]

-- ============================================================
-- SERVICES
-- ============================================================
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local CoreGui            = game:GetService("CoreGui")

local LocalPlayer        = Players.LocalPlayer
local Mouse              = LocalPlayer:GetMouse()

-- ============================================================
-- NEXUS UI LIBRARY
-- ============================================================
local NexusUI = {}
NexusUI.__index = NexusUI

-- ── Theme ────────────────────────────────────────────────────
NexusUI.Theme = {
    -- Backgrounds
    BG_PRIMARY      = Color3.fromRGB(10,  11,  20),
    BG_SECONDARY    = Color3.fromRGB(16,  17,  30),
    BG_TERTIARY     = Color3.fromRGB(22,  23,  40),
    BG_CARD         = Color3.fromRGB(25,  27,  48),
    BG_HOVER        = Color3.fromRGB(32,  34,  60),

    -- Accents
    ACCENT_PRIMARY  = Color3.fromRGB(99,  102, 241),  -- Indigo
    ACCENT_GLOW     = Color3.fromRGB(139, 92,  246),  -- Violet
    ACCENT_SUCCESS  = Color3.fromRGB(34,  197, 94),
    ACCENT_WARNING  = Color3.fromRGB(251, 191, 36),
    ACCENT_DANGER   = Color3.fromRGB(239, 68,  68),
    ACCENT_INFO     = Color3.fromRGB(56,  189, 248),

    -- Text
    TEXT_PRIMARY    = Color3.fromRGB(241, 245, 249),
    TEXT_SECONDARY  = Color3.fromRGB(148, 163, 184),
    TEXT_MUTED      = Color3.fromRGB(71,  85,  105),
    TEXT_ACCENT     = Color3.fromRGB(165, 180, 252),

    -- Borders
    BORDER_PRIMARY  = Color3.fromRGB(55,  48,  163),
    BORDER_SUBTLE   = Color3.fromRGB(30,  32,  55),

    -- Toggle
    TOGGLE_ON_BG    = Color3.fromRGB(99,  102, 241),
    TOGGLE_OFF_BG   = Color3.fromRGB(30,  32,  55),
    TOGGLE_KNOB     = Color3.fromRGB(255, 255, 255),

    -- Fonts
    FONT_TITLE      = Enum.Font.GothamBold,
    FONT_BODY       = Enum.Font.Gotham,
    FONT_MONO       = Enum.Font.Code,

    -- Sizes
    CORNER_MAIN     = UDim.new(0, 14),
    CORNER_ELEMENT  = UDim.new(0, 8),
    CORNER_SMALL    = UDim.new(0, 4),
}

-- ── Utility ──────────────────────────────────────────────────
local function Tween(obj, props, duration, style, dir)
    duration = duration or 0.25
    style    = style    or Enum.EasingStyle.Quart
    dir      = dir      or Enum.EasingDirection.Out
    local info = TweenInfo.new(duration, style, dir)
    local t    = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function Create(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then obj[k] = v end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = obj
    end
    if props and props.Parent then obj.Parent = props.Parent end
    return obj
end

local function AddCorner(parent, radius)
    return Create("UICorner", {CornerRadius = radius or NexusUI.Theme.CORNER_ELEMENT, Parent = parent})
end

local function AddStroke(parent, color, thickness, transparency)
    return Create("UIStroke", {
        Color        = color        or NexusUI.Theme.BORDER_SUBTLE,
        Thickness    = thickness    or 1,
        Transparency = transparency or 0,
        Parent       = parent
    })
end

local function AddGradient(parent, colorSeq, rotation)
    return Create("UIGradient", {
        Color    = colorSeq or ColorSequence.new({
            ColorSequenceKeypoint.new(0,   NexusUI.Theme.ACCENT_PRIMARY),
            ColorSequenceKeypoint.new(1,   NexusUI.Theme.ACCENT_GLOW),
        }),
        Rotation = rotation or 135,
        Parent   = parent
    })
end

local function RippleEffect(button, x, y)
    local ripple = Create("Frame", {
        Size            = UDim2.new(0, 0,  0, 0),
        Position        = UDim2.new(0, x - button.AbsolutePosition.X,
                                    0, y - button.AbsolutePosition.Y),
        AnchorPoint     = Vector2.new(0.5, 0.5),
        BackgroundColor3= Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.7,
        ZIndex          = button.ZIndex + 5,
        Parent          = button
    })
    AddCorner(ripple, UDim.new(1, 0))
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
    Tween(ripple, {Size = UDim2.new(0, size, 0, size), BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Quad)
    task.delay(0.5, function() ripple:Destroy() end)
end

-- ── Dragging (Mobile + PC) ───────────────────────────────────
local function MakeDraggable(handle, frame)
    local dragging, dragStart, startPos = false, nil, nil

    local function onStart(pos)
        dragging  = true
        dragStart = pos
        startPos  = frame.Position
    end
    local function onMove(pos)
        if not dragging then return end
        local delta = pos - dragStart
        local newX  = math.clamp(startPos.X.Offset + delta.X, 0,
                        workspace.CurrentCamera.ViewportSize.X - frame.AbsoluteSize.X)
        local newY  = math.clamp(startPos.Y.Offset + delta.Y, 0,
                        workspace.CurrentCamera.ViewportSize.Y - frame.AbsoluteSize.Y)
        frame.Position = UDim2.new(0, newX, 0, newY)
    end
    local function onEnd() dragging = false end

    -- PC
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            onStart(Vector2.new(i.Position.X, i.Position.Y))
        end
    end)
    -- Mobile
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then
            onStart(Vector2.new(i.Position.X, i.Position.Y))
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or
           i.UserInputType == Enum.UserInputType.Touch then
            onMove(Vector2.new(i.Position.X, i.Position.Y))
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
           i.UserInputType == Enum.UserInputType.Touch then
            onEnd()
        end
    end)
end

-- ============================================================
-- WINDOW CONSTRUCTOR
-- ============================================================
function NexusUI.new(config)
    config = config or {}
    local T     = NexusUI.Theme
    local self  = setmetatable({}, NexusUI)

    self.Title       = config.Title    or "NexusUI"
    self.SubTitle    = config.SubTitle or "v2.0"
    self.Width       = config.Width    or 360
    self.Height      = config.Height   or 480
    self.Tabs        = {}
    self._activeTab  = nil
    self._notifCount = 0

    -- ── Root ScreenGui ───────────────────────────────────────
    self.ScreenGui = Create("ScreenGui", {
        Name            = "NexusUI_" .. self.Title,
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        DisplayOrder    = 999,
        IgnoreGuiInset  = true,
        Parent          = (pcall(function() return CoreGui end) and CoreGui) or LocalPlayer.PlayerGui,
    })

    -- ── Backdrop blur hint ───────────────────────────────────
    self.Backdrop = Create("Frame", {
        Size                    = UDim2.new(1, 0, 1, 0),
        BackgroundColor3        = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency  = 0.6,
        ZIndex                  = 0,
        Visible                 = false,
        Parent                  = self.ScreenGui,
    })

    -- ── Main Window ──────────────────────────────────────────
    local vp      = workspace.CurrentCamera.ViewportSize
    local startX  = math.floor((vp.X - self.Width)  / 2)
    local startY  = math.floor((vp.Y - self.Height) / 2)

    self.Window = Create("Frame", {
        Size                    = UDim2.new(0, self.Width, 0, self.Height),
        Position                = UDim2.new(0, startX, 0, startY),
        BackgroundColor3        = T.BG_PRIMARY,
        BackgroundTransparency  = 0.04,
        BorderSizePixel         = 0,
        ZIndex                  = 10,
        ClipsDescendants        = true,
        Parent                  = self.ScreenGui,
    })
    AddCorner(self.Window, T.CORNER_MAIN)
    AddStroke(self.Window, T.BORDER_PRIMARY, 1.5, 0.2)

    -- Glow shadow
    local shadow = Create("ImageLabel", {
        Size                    = UDim2.new(1, 60, 1, 60),
        Position                = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint             = Vector2.new(0.5, 0.5),
        BackgroundTransparency  = 1,
        Image                   = "rbxassetid://5554236805",
        ImageColor3             = T.ACCENT_PRIMARY,
        ImageTransparency       = 0.65,
        ScaleType               = Enum.ScaleType.Slice,
        SliceCenter             = Rect.new(23, 23, 277, 277),
        ZIndex                  = 9,
        Parent                  = self.ScreenGui,
    })
    -- keep shadow aligned
    local function syncShadow()
        shadow.Position = UDim2.new(
            0, self.Window.Position.X.Offset + self.Width / 2,
            0, self.Window.Position.Y.Offset + self.Height / 2)
    end
    syncShadow()
    RunService.RenderStepped:Connect(syncShadow)

    -- ── Top bar gradient line ────────────────────────────────
    local accentLine = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = T.ACCENT_PRIMARY,
        BorderSizePixel  = 0,
        ZIndex           = 12,
        Parent           = self.Window,
    })
    AddGradient(accentLine)

    -- ── Header ───────────────────────────────────────────────
    self.Header = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 56),
        Position         = UDim2.new(0, 0, 0, 2),
        BackgroundColor3 = T.BG_SECONDARY,
        BorderSizePixel  = 0,
        ZIndex           = 11,
        Parent           = self.Window,
    })

    -- Icon orb
    local iconFrame = Create("Frame", {
        Size             = UDim2.new(0, 34, 0, 34),
        Position         = UDim2.new(0, 12, 0.5, 0),
        AnchorPoint      = Vector2.new(0, 0.5),
        BackgroundColor3 = T.ACCENT_PRIMARY,
        ZIndex           = 12,
        Parent           = self.Header,
    })
    AddCorner(iconFrame, UDim.new(0, 8))
    AddGradient(iconFrame)
    Create("TextLabel", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "✦",
        TextColor3       = Color3.fromRGB(255, 255, 255),
        TextSize         = 16,
        Font             = T.FONT_TITLE,
        ZIndex           = 13,
        Parent           = iconFrame,
    })

    -- Title text
    local titleLabel = Create("TextLabel", {
        Size             = UDim2.new(0, 160, 0, 22),
        Position         = UDim2.new(0, 56, 0, 9),
        BackgroundTransparency = 1,
        Text             = self.Title,
        TextColor3       = T.TEXT_PRIMARY,
        TextSize         = 15,
        Font             = T.FONT_TITLE,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 12,
        Parent           = self.Header,
    })
    Create("TextLabel", {
        Size             = UDim2.new(0, 160, 0, 16),
        Position         = UDim2.new(0, 56, 0, 30),
        BackgroundTransparency = 1,
        Text             = self.SubTitle,
        TextColor3       = T.TEXT_MUTED,
        TextSize         = 11,
        Font             = T.FONT_BODY,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 12,
        Parent           = self.Header,
    })

    -- Close button
    local closeBtn = Create("TextButton", {
        Size             = UDim2.new(0, 30, 0, 30),
        Position         = UDim2.new(1, -42, 0.5, 0),
        AnchorPoint      = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(239, 68, 68),
        BackgroundTransparency = 0.3,
        Text             = "✕",
        TextColor3       = Color3.fromRGB(255,255,255),
        TextSize         = 13,
        Font             = T.FONT_TITLE,
        ZIndex           = 13,
        Parent           = self.Header,
    })
    AddCorner(closeBtn, UDim.new(1, 0))
    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, {BackgroundTransparency = 0}, 0.15)
    end)
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, {BackgroundTransparency = 0.3}, 0.15)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    -- Mobile touch
    closeBtn.TouchTap:Connect(function() self:Toggle() end)

    -- Minimize button
    local minBtn = Create("TextButton", {
        Size             = UDim2.new(0, 30, 0, 30),
        Position         = UDim2.new(1, -78, 0.5, 0),
        AnchorPoint      = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(251, 191, 36),
        BackgroundTransparency = 0.3,
        Text             = "–",
        TextColor3       = Color3.fromRGB(255,255,255),
        TextSize         = 15,
        Font             = T.FONT_TITLE,
        ZIndex           = 13,
        Parent           = self.Header,
    })
    AddCorner(minBtn, UDim.new(1, 0))

    self._minimized = false
    self._fullHeight = self.Height

    minBtn.MouseButton1Click:Connect(function() self:Minimize() end)
    minBtn.TouchTap:Connect(function() self:Minimize() end)

    MakeDraggable(self.Header, self.Window)

    -- ── Tab Bar ──────────────────────────────────────────────
    self.TabBar = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 40),
        Position         = UDim2.new(0, 0, 0, 58),
        BackgroundColor3 = T.BG_TERTIARY,
        BorderSizePixel  = 0,
        ZIndex           = 11,
        ClipsDescendants = true,
        Parent           = self.Window,
    })
    self.TabBarList = Create("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex           = 12,
        Parent           = self.TabBar,
    })
    self.TabBarLayout = Create("UIListLayout", {
        FillDirection    = Enum.FillDirection.Horizontal,
        VerticalAlignment= Enum.VerticalAlignment.Center,
        Padding          = UDim.new(0, 2),
        SortOrder        = Enum.SortOrder.LayoutOrder,
        Parent           = self.TabBarList,
    })
    Create("UIPadding", {
        PaddingLeft  = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        Parent       = self.TabBarList,
    })

    -- Scrollable tab bar for many tabs
    local tabScroll = Create("ScrollingFrame", {
        Size                    = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency  = 1,
        ScrollBarThickness      = 0,
        CanvasSize              = UDim2.new(0, 0, 1, 0),
        ScrollingDirection      = Enum.ScrollingDirection.X,
        AutomaticCanvasSize     = Enum.AutomaticSize.X,
        ZIndex                  = 12,
        Parent                  = self.TabBar,
    })
    self.TabScrollFrame = tabScroll
    self.TabBarList.Parent = tabScroll

    -- Active tab indicator pill
    self.TabIndicator = Create("Frame", {
        Size             = UDim2.new(0, 0, 0, 3),
        Position         = UDim2.new(0, 0, 1, -3),
        BackgroundColor3 = T.ACCENT_PRIMARY,
        BorderSizePixel  = 0,
        ZIndex           = 14,
        Parent           = self.TabBar,
    })
    AddCorner(self.TabIndicator, UDim.new(1, 0))
    AddGradient(self.TabIndicator)

    -- ── Content area ─────────────────────────────────────────
    self.ContentArea = Create("Frame", {
        Size             = UDim2.new(1, 0, 1, -100),
        Position         = UDim2.new(0, 0, 0, 100),
        BackgroundTransparency = 1,
        ZIndex           = 11,
        ClipsDescendants = true,
        Parent           = self.Window,
    })

    -- ── Notification container ───────────────────────────────
    self.NotifContainer = Create("Frame", {
        Size             = UDim2.new(0, 300, 1, 0),
        Position         = UDim2.new(1, 10, 0, 0),
        BackgroundTransparency = 1,
        ZIndex           = 100,
        Parent           = self.Window,
    })
    Create("UIListLayout", {
        FillDirection    = Enum.FillDirection.Vertical,
        VerticalAlignment= Enum.VerticalAlignment.Top,
        Padding          = UDim.new(0, 8),
        SortOrder        = Enum.SortOrder.LayoutOrder,
        Parent           = self.NotifContainer,
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        Parent     = self.NotifContainer,
    })

    -- Entry animation
    self.Window.Size = UDim2.new(0, self.Width, 0, 0)
    self.Window.BackgroundTransparency = 1
    Tween(self.Window, {
        Size = UDim2.new(0, self.Width, 0, self.Height),
        BackgroundTransparency = 0.04
    }, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    self._visible = true
    return self
end

-- ── Toggle visibility ────────────────────────────────────────
function NexusUI:Toggle()
    local T = NexusUI.Theme
    if self._visible then
        Tween(self.Window, {Size = UDim2.new(0, self.Width, 0, 0), BackgroundTransparency = 1},
              0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.3, function() self.Window.Visible = false end)
    else
        self.Window.Visible = true
        Tween(self.Window, {
            Size = UDim2.new(0, self.Width, 0, self._minimized and 58 or self._fullHeight),
            BackgroundTransparency = 0.04
        }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end
    self._visible = not self._visible
end

function NexusUI:Minimize()
    if self._minimized then
        Tween(self.Window, {Size = UDim2.new(0, self.Width, 0, self._fullHeight)}, 0.35, Enum.EasingStyle.Back)
        Tween(self.ContentArea,  {BackgroundTransparency = 1}, 0.2)
        self._minimized = false
    else
        Tween(self.Window, {Size = UDim2.new(0, self.Width, 0, 58)}, 0.3, Enum.EasingStyle.Quart)
        self._minimized = true
    end
end

-- ============================================================
-- TAB CONSTRUCTOR
-- ============================================================
function NexusUI:AddTab(config)
    config = config or {}
    local T    = NexusUI.Theme
    local tab  = {}
    tab.Name   = config.Name  or ("Tab " .. (#self.Tabs + 1))
    tab.Icon   = config.Icon  or "⬡"

    -- Tab button
    tab.Button = Create("TextButton", {
        Size             = UDim2.new(0, 0, 1, -6),
        AutomaticSize    = Enum.AutomaticSize.X,
        BackgroundColor3 = T.BG_TERTIARY,
        BackgroundTransparency = 1,
        Text             = tab.Icon .. "  " .. tab.Name,
        TextColor3       = T.TEXT_MUTED,
        TextSize         = 12,
        Font             = T.FONT_BODY,
        LayoutOrder      = #self.Tabs + 1,
        ZIndex           = 13,
        Parent           = self.TabBarList,
    })
    AddCorner(tab.Button, UDim.new(0, 6))
    Create("UIPadding", {
        PaddingLeft  = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent       = tab.Button,
    })

    -- Scroll content frame
    tab.ScrollFrame = Create("ScrollingFrame", {
        Size                    = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency  = 1,
        ScrollBarThickness      = 3,
        ScrollBarImageColor3    = T.ACCENT_PRIMARY,
        CanvasSize              = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize     = Enum.AutomaticSize.Y,
        ScrollingDirection      = Enum.ScrollingDirection.Y,
        ZIndex                  = 11,
        Visible                 = false,
        Parent                  = self.ContentArea,
    })
    tab.Layout = Create("UIListLayout", {
        FillDirection    = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding          = UDim.new(0, 6),
        SortOrder        = Enum.SortOrder.LayoutOrder,
        Parent           = tab.ScrollFrame,
    })
    Create("UIPadding", {
        PaddingTop    = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 16),
        PaddingLeft   = UDim.new(0, 10),
        PaddingRight  = UDim.new(0, 10),
        Parent        = tab.ScrollFrame,
    })

    tab._index = #self.Tabs + 1
    table.insert(self.Tabs, tab)

    -- Activate on click / tap
    local function activate()
        self:_selectTab(tab)
    end
    tab.Button.MouseButton1Click:Connect(activate)
    tab.Button.TouchTap:Connect(activate)

    -- Auto-select first tab
    if #self.Tabs == 1 then
        self:_selectTab(tab)
    end

    return tab
end

function NexusUI:_selectTab(tab)
    local T = NexusUI.Theme
    -- Deactivate all
    for _, t in ipairs(self.Tabs) do
        t.ScrollFrame.Visible = false
        Tween(t.Button, {TextColor3 = T.TEXT_MUTED, BackgroundTransparency = 1}, 0.2)
    end
    -- Activate selected
    tab.ScrollFrame.Visible = true
    Tween(tab.Button, {TextColor3 = T.TEXT_ACCENT, BackgroundTransparency = 0.85}, 0.2)

    -- Move indicator
    task.defer(function()
        local bx = tab.Button.AbsolutePosition.X - self.TabBar.AbsolutePosition.X
        local bw = tab.Button.AbsoluteSize.X
        Tween(self.TabIndicator, {
            Position = UDim2.new(0, bx, 1, -3),
            Size     = UDim2.new(0, bw, 0, 3),
        }, 0.3, Enum.EasingStyle.Quart)
    end)

    self._activeTab = tab
end

-- ============================================================
-- ELEMENT HELPERS  (all return handle for chaining/removal)
-- ============================================================

-- ── Section label ────────────────────────────────────────────
function NexusUI:AddSection(tab, text)
    local T  = NexusUI.Theme
    local row = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        ZIndex           = 12,
        LayoutOrder      = #tab.ScrollFrame:GetChildren(),
        Parent           = tab.ScrollFrame,
    })
    Create("TextLabel", {
        Size             = UDim2.new(1, -4, 1, 0),
        Position         = UDim2.new(0, 2, 0, 0),
        BackgroundTransparency = 1,
        Text             = string.upper(text),
        TextColor3       = T.ACCENT_PRIMARY,
        TextSize         = 10,
        Font             = T.FONT_TITLE,
        TextXAlignment   = Enum.TextXAlignment.Left,
        LetterSpacing    = 2,
        ZIndex           = 13,
        Parent           = row,
    })
    Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.BORDER_SUBTLE,
        BorderSizePixel  = 0,
        ZIndex           = 13,
        Parent           = row,
    })
    return row
end

-- ── Separator ────────────────────────────────────────────────
function NexusUI:AddSeparator(tab)
    local T = NexusUI.Theme
    local sep = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = T.BORDER_SUBTLE,
        BorderSizePixel  = 0,
        LayoutOrder      = #tab.ScrollFrame:GetChildren(),
        Parent           = tab.ScrollFrame,
    })
    AddGradient(sep, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(0.3, T.BORDER_SUBTLE),
        ColorSequenceKeypoint.new(0.7, T.BORDER_SUBTLE),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
    }), 0)
    return sep
end

-- ── Label / Info ─────────────────────────────────────────────
function NexusUI:AddLabel(tab, text, color)
    local T  = NexusUI.Theme
    local card = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = T.BG_CARD,
        BackgroundTransparency = 0.3,
        BorderSizePixel  = 0,
        LayoutOrder      = #tab.ScrollFrame:GetChildren(),
        Parent           = tab.ScrollFrame,
    })
    AddCorner(card)
    local lbl = Create("TextLabel", {
        Size             = UDim2.new(1, -16, 1, 0),
        Position         = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text             = text,
        TextColor3       = color or T.TEXT_SECONDARY,
        TextSize         = 12,
        Font             = T.FONT_BODY,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
        ZIndex           = 13,
        Parent           = card,
    })
    -- auto-size
    card.AutomaticSize = Enum.AutomaticSize.Y
    return {Frame = card, Label = lbl, SetText = function(_, t) lbl.Text = t end}
end

-- ── Button ───────────────────────────────────────────────────
function NexusUI:AddButton(tab, config)
    config = config or {}
    local T   = NexusUI.Theme
    local btnColor = config.Color or T.ACCENT_PRIMARY
    local card = Create("TextButton", {
        Size             = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = btnColor,
        BackgroundTransparency = 0.15,
        Text             = "",
        BorderSizePixel  = 0,
        AutoButtonColor  = false,
        LayoutOrder      = #tab.ScrollFrame:GetChildren(),
        ClipsDescendants = true,
        ZIndex           = 12,
        Parent           = tab.ScrollFrame,
    })
    AddCorner(card)
    AddStroke(card, btnColor, 1, 0.6)

    -- Icon + text layout
    local inner = Create("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex           = 13,
        Parent           = card,
    })
    if config.Icon then
        Create("TextLabel", {
            Size             = UDim2.new(0, 28, 1, 0),
            Position         = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text             = config.Icon,
            TextColor3       = Color3.fromRGB(255,255,255),
            TextSize         = 16,
            Font             = T.FONT_BODY,
            ZIndex           = 14,
            Parent           = inner,
        })
    end
    Create("TextLabel", {
        Size             = UDim2.new(1, config.Icon and -44 or -20, 1, 0),
        Position         = UDim2.new(0, config.Icon and 40 or 10, 0, 0),
        BackgroundTransparency = 1,
        Text             = config.Name or "Button",
        TextColor3       = Color3.fromRGB(255,255,255),
        TextSize         = 13,
        Font             = T.FONT_TITLE,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 14,
        Parent           = inner,
    })

    -- Hover / Press effects
    card.MouseEnter:Connect(function()
        Tween(card, {BackgroundTransparency = 0, Size = UDim2.new(1, 0, 0, 42)}, 0.15)
    end)
    card.MouseLeave:Connect(function()
        Tween(card, {BackgroundTransparency = 0.15, Size = UDim2.new(1, 0, 0, 40)}, 0.2)
    end)
    card.MouseButton1Down:Connect(function()
        Tween(card, {Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 0.05}, 0.08)
    end)
    card.MouseButton1Up:Connect(function()
        Tween(card, {Size = UDim2.new(1, 0, 0, 40)}, 0.15)
    end)

    card.MouseButton1Click:Connect(function(x, y)
        RippleEffect(card, Mouse.X, Mouse.Y)
        if config.Callback then config.Callback() end
    end)
    card.TouchTap:Connect(function(touches)
        local p = touches[1]
        RippleEffect(card, p.Position.X, p.Position.Y)
        if config.Callback then config.Callback() end
    end)

    return {Frame = card}
end

-- ── Toggle ───────────────────────────────────────────────────
function NexusUI:AddToggle(tab, config)
    config = config or {}
    local T       = NexusUI.Theme
    local state   = config.Default or false
    local card    = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = T.BG_CARD,
        BackgroundTransparency = 0.2,
        BorderSizePixel  = 0,
        LayoutOrder      = #tab.ScrollFrame:GetChildren(),
        ZIndex           = 12,
        Parent           = tab.ScrollFrame,
    })
    AddCorner(card)
    AddStroke(card, T.BORDER_SUBTLE, 1, 0.4)

    -- Icon
    if config.Icon then
        Create("TextLabel", {
            Size             = UDim2.new(0, 28, 1, 0),
            Position         = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text             = config.Icon,
            TextColor3       = T.TEXT_SECONDARY,
            TextSize         = 15,
            Font             = T.FONT_BODY,
            ZIndex           = 13,
            Parent           = card,
        })
    end
    local nameLabel = Create("TextLabel", {
        Size             = UDim2.new(1, -80, 0, 18),
        Position         = UDim2.new(0, config.Icon and 42 or 12, 0, 8),
        BackgroundTransparency = 1,
        Text             = config.Name or "Toggle",
        TextColor3       = T.TEXT_PRIMARY,
        TextSize         = 13,
        Font             = T.FONT_TITLE,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 13,
        Parent           = card,
    })
    if config.Description then
        Create("TextLabel", {
            Size             = UDim2.new(1, -80, 0, 14),
            Position         = UDim2.new(0, config.Icon and 42 or 12, 0, 26),
            BackgroundTransparency = 1,
            Text             = config.Description,
            TextColor3       = T.TEXT_MUTED,
            TextSize         = 10,
            Font             = T.FONT_BODY,
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = 13,
            Parent           = card,
        })
        card.Size = UDim2.new(1, 0, 0, 54)
    end

    -- Track
    local track = Create("Frame", {
        Size             = UDim2.new(0, 44, 0, 24),
        Position         = UDim2.new(1, -56, 0.5, 0),
        AnchorPoint      = Vector2.new(0, 0.5),
        BackgroundColor3 = state and T.TOGGLE_ON_BG or T.TOGGLE_OFF_BG,
        ZIndex           = 13,
        Parent           = card,
    })
    AddCorner(track, UDim.new(1, 0))

    -- Knob
    local knob = Create("Frame", {
        Size             = UDim2.new(0, 18, 0, 18),
        Position         = state and UDim2.new(0, 23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        AnchorPoint      = Vector2.new(0, 0.5),
        BackgroundColor3 = T.TOGGLE_KNOB,
        ZIndex           = 14,
        Parent           = track,
    })
    AddCorner(knob, UDim.new(1, 0))

    local function setToggle(val, silent)
        state = val
        Tween(track, {BackgroundColor3 = state and T.TOGGLE_ON_BG or T.TOGGLE_OFF_BG}, 0.25)
        Tween(knob,  {Position = state and UDim2.new(0, 23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, 0.25, Enum.EasingStyle.Back)
        if not silent and config.Callback then config.Callback(state) end
    end

    local btn = Create("TextButton", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "",
        ZIndex           = 15,
        Parent           = card,
    })
    btn.MouseButton1Click:Connect(function() setToggle(not state) end)
    btn.TouchTap:Connect(function() setToggle(not state) end)

    return {
        Frame    = card,
        GetState = function() return state end,
        SetState = function(_, v) setToggle(v, true) end,
    }
end

-- ── Slider ───────────────────────────────────────────────────
function NexusUI:AddSlider(tab, config)
    config = config or {}
    local T     = NexusUI.Theme
    local min   = config.Min     or 0
    local max   = config.Max     or 100
    local step  = config.Step    or 1
    local value = config.Default or min
    local suffix= config.Suffix  or ""

    local card = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = T.BG_CARD,
        BackgroundTransparency = 0.2,
        BorderSizePixel  = 0,
        LayoutOrder      = #tab.ScrollFrame:GetChildren(),
        ZIndex           = 12,
        Parent           = tab.ScrollFrame,
    })
    AddCorner(card)
    AddStroke(card, T.BORDER_SUBTLE, 1, 0.4)

    Create("TextLabel", {
        Size             = UDim2.new(1, -80, 0, 18),
        Position         = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1,
        Text             = config.Name or "Slider",
        TextColor3       = T.TEXT_PRIMARY,
        TextSize         = 13,
        Font             = T.FONT_TITLE,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 13,
        Parent           = card,
    })
    local valLabel = Create("TextLabel", {
        Size             = UDim2.new(0, 70, 0, 18),
        Position         = UDim2.new(1, -80, 0, 8),
        BackgroundTransparency = 1,
        Text             = tostring(value) .. suffix,
        TextColor3       = T.ACCENT_PRIMARY,
        TextSize         = 13,
        Font             = T.FONT_TITLE,
        TextXAlignment   = Enum.TextXAlignment.Right,
        ZIndex           = 13,
        Parent           = card,
    })

    -- Track bg
    local trackBg = Create("Frame", {
        Size             = UDim2.new(1, -24, 0, 5),
        Position         = UDim2.new(0, 12, 0, 38),
        BackgroundColor3 = T.BG_HOVER,
        ZIndex           = 13,
        Parent           = card,
    })
    AddCorner(trackBg, UDim.new(1, 0))

    -- Fill
    local fill_pct = (value - min) / (max - min)
    local fillBar = Create("Frame", {
        Size             = UDim2.new(fill_pct, 0, 1, 0),
        BackgroundColor3 = T.ACCENT_PRIMARY,
        ZIndex           = 14,
        Parent           = trackBg,
    })
    AddCorner(fillBar, UDim.new(1, 0))
    AddGradient(fillBar)

    -- Handle
    local handle = Create("Frame", {
        Size             = UDim2.new(0, 18, 0, 18),
        Position         = UDim2.new(fill_pct, -9, 0.5, 0),
        AnchorPoint      = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        ZIndex           = 15,
        Parent           = trackBg,
    })
    AddCorner(handle, UDim.new(1, 0))
    Create("UIStroke", {Color = T.ACCENT_PRIMARY, Thickness = 2, Parent = handle})

    local function updateSlider(absX)
        local rel = math.clamp((absX - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
        local raw = min + (max - min) * rel
        local snapped = math.floor(raw / step + 0.5) * step
        value = math.clamp(snapped, min, max)
        local pct = (value - min) / (max - min)
        Tween(fillBar, {Size = UDim2.new(pct, 0, 1, 0)}, 0.07)
        Tween(handle,  {Position = UDim2.new(pct, -9, 0.5, 0)}, 0.07)
        valLabel.Text = tostring(math.floor(value * 100 + 0.5) / 100) .. suffix
        if config.Callback then config.Callback(value) end
    end

    local dragging = false
    local hitArea = Create("TextButton", {
        Size             = UDim2.new(1, 0, 1, 20),
        Position         = UDim2.new(0, 0, 0, -10),
        BackgroundTransparency = 1,
        Text             = "",
        ZIndex           = 16,
        Parent           = trackBg,
    })
    hitArea.MouseButton1Down:Connect(function() dragging = true updateSlider(Mouse.X) end)
    hitArea.TouchLongPress:Connect(function() dragging = true end)
    hitArea.TouchPan:Connect(function(_, pos)
        if #pos > 0 then updateSlider(pos[1].Position.X) end
    end)
    hitArea.MouseButton1Click:Connect(function() updateSlider(Mouse.X) end)
    UserInputService.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(Mouse.X)
        elseif i.UserInputType == Enum.UserInputType.Touch then
            updateSlider(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
           i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return {
        Frame    = card,
        GetValue = function() return value end,
        SetValue = function(_, v)
            value = math.clamp(v, min, max)
            local pct = (value - min) / (max - min)
            Tween(fillBar, {Size = UDim2.new(pct, 0, 1, 0)}, 0.2)
            Tween(handle,  {Position = UDim2.new(pct, -9, 0.5, 0)}, 0.2)
            valLabel.Text = tostring(value) .. suffix
        end,
    }
end

-- ── Dropdown ─────────────────────────────────────────────────
function NexusUI:AddDropdown(tab, config)
    config = config or {}
    local T       = NexusUI.Theme
    local options = config.Options or {}
    local selected = config.Default or (options[1] or "Select...")
    local open     = false

    local wrapper = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 46),
        BackgroundTransparency = 1,
        ZIndex           = 12,
        LayoutOrder      = #tab.ScrollFrame:GetChildren(),
        ClipsDescendants = false,
        Parent           = tab.ScrollFrame,
    })

    local card = Create("TextButton", {
        Size             = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = T.BG_CARD,
        BackgroundTransparency = 0.2,
        Text             = "",
        AutoButtonColor  = false,
        BorderSizePixel  = 0,
        ZIndex           = 20,
        ClipsDescendants = true,
        Parent           = wrapper,
    })
    AddCorner(card)
    AddStroke(card, T.BORDER_SUBTLE, 1, 0.4)

    Create("TextLabel", {
        Size             = UDim2.new(1, -50, 0, 18),
        Position         = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1,
        Text             = config.Name or "Dropdown",
        TextColor3       = T.TEXT_SECONDARY,
        TextSize         = 11,
        Font             = T.FONT_BODY,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 21,
        Parent           = card,
    })
    local selLabel = Create("TextLabel", {
        Size             = UDim2.new(1, -50, 0, 16),
        Position         = UDim2.new(0, 12, 0, 24),
        BackgroundTransparency = 1,
        Text             = selected,
        TextColor3       = T.TEXT_PRIMARY,
        TextSize         = 13,
        Font             = T.FONT_TITLE,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 21,
        Parent           = card,
    })
    local arrow = Create("TextLabel", {
        Size             = UDim2.new(0, 30, 1, 0),
        Position         = UDim2.new(1, -38, 0, 0),
        BackgroundTransparency = 1,
        Text             = "▾",
        TextColor3       = T.TEXT_MUTED,
        TextSize         = 16,
        Font             = T.FONT_BODY,
        ZIndex           = 21,
        Parent           = card,
    })

    -- Dropdown list
    local listFrame = Create("ScrollingFrame", {
        Size                    = UDim2.new(1, 0, 0, 0),
        Position                = UDim2.new(0, 0, 1, 4),
        BackgroundColor3        = T.BG_TERTIARY,
        BorderSizePixel         = 0,
        ScrollBarThickness      = 2,
        ScrollBarImageColor3    = T.ACCENT_PRIMARY,
        CanvasSize              = UDim2.new(0,0,0,0),
        AutomaticCanvasSize     = Enum.AutomaticSize.Y,
        ZIndex                  = 30,
        ClipsDescendants        = true,
        Visible                 = false,
        Parent                  = wrapper,
    })
    AddCorner(listFrame)
    AddStroke(listFrame, T.BORDER_PRIMARY, 1, 0.4)
    local listLayout = Create("UIListLayout", {
        FillDirection    = Enum.FillDirection.Vertical,
        Padding          = UDim.new(0, 0),
        SortOrder        = Enum.SortOrder.LayoutOrder,
        Parent           = listFrame,
    })

    -- Populate options
    for i, opt in ipairs(options) do
        local row = Create("TextButton", {
            Size             = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = opt == selected and T.BG_HOVER or T.BG_TERTIARY,
            BackgroundTransparency = 0,
            Text             = opt,
            TextColor3       = opt == selected and T.ACCENT_PRIMARY or T.TEXT_PRIMARY,
            TextSize         = 12,
            Font             = T.FONT_BODY,
            TextXAlignment   = Enum.TextXAlignment.Left,
            BorderSizePixel  = 0,
            LayoutOrder      = i,
            ZIndex           = 31,
            Parent           = listFrame,
        })
        Create("UIPadding", {PaddingLeft = UDim.new(0, 14), Parent = row})
        row.MouseEnter:Connect(function()
            Tween(row, {BackgroundColor3 = T.BG_HOVER, BackgroundTransparency = 0}, 0.1)
        end)
        row.MouseLeave:Connect(function()
            Tween(row, {
                BackgroundColor3 = (row.Text == selected) and T.BG_HOVER or T.BG_TERTIARY,
                BackgroundTransparency = 0
            }, 0.1)
        end)
        local function selectOpt()
            selected = opt
            selLabel.Text = selected
            for _, c in ipairs(listFrame:GetChildren()) do
                if c:IsA("TextButton") then
                    Tween(c, {
                        BackgroundColor3 = (c.Text == selected) and T.BG_HOVER or T.BG_TERTIARY,
                        TextColor3 = (c.Text == selected) and T.ACCENT_PRIMARY or T.TEXT_PRIMARY
                    }, 0.15)
                end
            end
            Tween(listFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2, Enum.EasingStyle.Quart)
            task.delay(0.2, function() listFrame.Visible = false end)
            Tween(arrow, {Rotation = 0}, 0.2)
            open = false
            if config.Callback then config.Callback(selected) end
        end
        row.MouseButton1Click:Connect(selectOpt)
        row.TouchTap:Connect(selectOpt)
    end

    local maxH = math.min(#options * 36, 180)

    local function toggleDropdown()
        open = not open
        if open then
            listFrame.Visible = true
            Tween(listFrame, {Size = UDim2.new(1, 0, 0, maxH)}, 0.25, Enum.EasingStyle.Back)
            Tween(arrow, {Rotation = 180}, 0.25)
        else
            Tween(listFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2, Enum.EasingStyle.Quart)
            task.delay(0.2, function() listFrame.Visible = false end)
            Tween(arrow, {Rotation = 0}, 0.2)
        end
    end

    card.MouseButton1Click:Connect(toggleDropdown)
    card.TouchTap:Connect(toggleDropdown)

    return {
        Frame       = wrapper,
        GetSelected = function() return selected end,
        SetOptions  = function(_, opts)
            options = opts
            for _, c in ipairs(listFrame:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            for i, opt in ipairs(options) do
                -- (re-create rows — abbreviated)
            end
        end,
    }
end

-- ── Text Input ───────────────────────────────────────────────
function NexusUI:AddInput(tab, config)
    config = config or {}
    local T = NexusUI.Theme

    local card = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = T.BG_CARD,
        BackgroundTransparency = 0.2,
        BorderSizePixel  = 0,
        LayoutOrder      = #tab.ScrollFrame:GetChildren(),
        ZIndex           = 12,
        Parent           = tab.ScrollFrame,
    })
    AddCorner(card)
    AddStroke(card, T.BORDER_SUBTLE, 1, 0.4)

    Create("TextLabel", {
        Size             = UDim2.new(1, -16, 0, 16),
        Position         = UDim2.new(0, 12, 0, 7),
        BackgroundTransparency = 1,
        Text             = config.Name or "Input",
        TextColor3       = T.TEXT_SECONDARY,
        TextSize         = 10,
        Font             = T.FONT_BODY,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 13,
        Parent           = card,
    })

    local inputBg = Create("Frame", {
        Size             = UDim2.new(1, -24, 0, 26),
        Position         = UDim2.new(0, 12, 0, 27),
        BackgroundColor3 = T.BG_HOVER,
        ZIndex           = 13,
        Parent           = card,
    })
    AddCorner(inputBg, UDim.new(0, 5))
    AddStroke(inputBg, T.BORDER_SUBTLE, 1, 0.6)

    local box = Create("TextBox", {
        Size             = UDim2.new(1, -16, 1, 0),
        Position         = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text             = config.Default or "",
        PlaceholderText  = config.Placeholder or "Digite aqui...",
        PlaceholderColor3= T.TEXT_MUTED,
        TextColor3       = T.TEXT_PRIMARY,
        TextSize         = 12,
        Font             = T.FONT_BODY,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ClearTextOnFocus = config.ClearOnFocus ~= nil and config.ClearOnFocus or false,
        ZIndex           = 14,
        Parent           = inputBg,
    })

    box.Focused:Connect(function()
        Tween(inputBg, {BackgroundColor3 = T.BG_PRIMARY}, 0.15)
        Tween(inputBg, {}, 0.15)
        AddStroke(inputBg, T.ACCENT_PRIMARY, 1.5, 0)
    end)
    box.FocusLost:Connect(function(enter)
        Tween(inputBg, {BackgroundColor3 = T.BG_HOVER}, 0.15)
        if enter and config.Callback then config.Callback(box.Text) end
    end)
    box:GetPropertyChangedSignal("Text"):Connect(function()
        if config.OnChange then config.OnChange(box.Text) end
    end)

    return {
        Frame    = card,
        GetText  = function() return box.Text end,
        SetText  = function(_, t) box.Text = t end,
        Clear    = function() box.Text = "" end,
    }
end

-- ── Color Picker (Simple) ────────────────────────────────────
function NexusUI:AddColorPicker(tab, config)
    config = config or {}
    local T      = NexusUI.Theme
    local colors = {
        Color3.fromRGB(239,68,68),  Color3.fromRGB(251,146,60),
        Color3.fromRGB(250,204,21), Color3.fromRGB(74,222,128),
        Color3.fromRGB(34,211,238), Color3.fromRGB(99,102,241),
        Color3.fromRGB(167,139,250),Color3.fromRGB(244,114,182),
        Color3.fromRGB(255,255,255),Color3.fromRGB(148,163,184),
        Color3.fromRGB(51,65,85),   Color3.fromRGB(15,23,42),
    }
    local selected = config.Default or colors[1]

    local card = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 80),
        BackgroundColor3 = T.BG_CARD,
        BackgroundTransparency = 0.2,
        BorderSizePixel  = 0,
        LayoutOrder      = #tab.ScrollFrame:GetChildren(),
        ZIndex           = 12,
        Parent           = tab.ScrollFrame,
    })
    AddCorner(card)
    AddStroke(card, T.BORDER_SUBTLE, 1, 0.4)

    Create("TextLabel", {
        Size             = UDim2.new(1, -60, 0, 18),
        Position         = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1,
        Text             = config.Name or "Cor",
        TextColor3       = T.TEXT_PRIMARY,
        TextSize         = 13,
        Font             = T.FONT_TITLE,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 13,
        Parent           = card,
    })

    local preview = Create("Frame", {
        Size             = UDim2.new(0, 36, 0, 20),
        Position         = UDim2.new(1, -48, 0, 8),
        BackgroundColor3 = selected,
        ZIndex           = 13,
        Parent           = card,
    })
    AddCorner(preview, UDim.new(0, 5))
    AddStroke(preview, T.BORDER_SUBTLE, 1, 0)

    local palette = Create("Frame", {
        Size             = UDim2.new(1, -24, 0, 30),
        Position         = UDim2.new(0, 12, 0, 38),
        BackgroundTransparency = 1,
        ZIndex           = 13,
        Parent           = card,
    })
    Create("UIListLayout", {
        FillDirection    = Enum.FillDirection.Horizontal,
        Padding          = UDim.new(0, 4),
        SortOrder        = Enum.SortOrder.LayoutOrder,
        Parent           = palette,
    })

    for i, col in ipairs(colors) do
        local swatch = Create("TextButton", {
            Size             = UDim2.new(0, 24, 0, 24),
            BackgroundColor3 = col,
            Text             = "",
            BorderSizePixel  = 0,
            LayoutOrder      = i,
            ZIndex           = 14,
            Parent           = palette,
        })
        AddCorner(swatch, UDim.new(0, 5))
        local function pick()
            selected = col
            Tween(preview, {BackgroundColor3 = col}, 0.2)
            if config.Callback then config.Callback(col) end
        end
        swatch.MouseButton1Click:Connect(pick)
        swatch.TouchTap:Connect(pick)
    end

    return {Frame = card, GetColor = function() return selected end}
end

-- ============================================================
-- NOTIFICATION / TOAST
-- ============================================================
function NexusUI:Notify(config)
    config = config or {}
    local T        = NexusUI.Theme
    local typeColors = {
        success = T.ACCENT_SUCCESS,
        warning = T.ACCENT_WARNING,
        danger  = T.ACCENT_DANGER,
        info    = T.ACCENT_INFO,
        default = T.ACCENT_PRIMARY,
    }
    local accentCol = typeColors[config.Type or "default"] or T.ACCENT_PRIMARY
    local duration  = config.Duration or 3.5

    self._notifCount += 1
    local notif = Create("Frame", {
        Size             = UDim2.new(0, 280, 0, 0),
        BackgroundColor3 = T.BG_SECONDARY,
        BackgroundTransparency = 0.05,
        BorderSizePixel  = 0,
        AutomaticSize    = Enum.AutomaticSize.Y,
        LayoutOrder      = self._notifCount,
        ClipsDescendants = true,
        ZIndex           = 100,
        Parent           = self.NotifContainer,
    })
    AddCorner(notif)
    AddStroke(notif, accentCol, 1.5, 0.3)

    -- Accent left bar
    Create("Frame", {
        Size             = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = accentCol,
        ZIndex           = 101,
        Parent           = notif,
    })

    local inner = Create("Frame", {
        Size             = UDim2.new(1, -8, 0, 0),
        Position         = UDim2.new(0, 8, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex           = 101,
        Parent           = notif,
    })
    Create("UIPadding", {
        PaddingTop    = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingRight  = UDim.new(0, 10),
        Parent        = inner,
    })
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding       = UDim.new(0, 3),
        Parent        = inner,
    })

    if config.Title then
        Create("TextLabel", {
            Size             = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text             = config.Title,
            TextColor3       = Color3.fromRGB(255,255,255),
            TextSize         = 13,
            Font             = T.FONT_TITLE,
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = 102,
            Parent           = inner,
        })
    end
    if config.Message then
        Create("TextLabel", {
            Size             = UDim2.new(1, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text             = config.Message,
            TextColor3       = T.TEXT_SECONDARY,
            TextSize         = 11,
            Font             = T.FONT_BODY,
            TextXAlignment   = Enum.TextXAlignment.Left,
            TextWrapped      = true,
            ZIndex           = 102,
            Parent           = inner,
        })
    end

    -- Progress bar
    local prog = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        Position         = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = accentCol,
        ZIndex           = 102,
        Parent           = notif,
    })
    AddCorner(prog, UDim.new(1, 0))

    -- Animate in
    notif.BackgroundTransparency = 1
    Tween(notif, {BackgroundTransparency = 0.05}, 0.3)

    -- Countdown + dismiss
    Tween(prog, {Size = UDim2.new(0, 0, 0, 2)}, duration, Enum.EasingStyle.Linear)
    task.delay(duration, function()
        Tween(notif, {BackgroundTransparency = 1, Size = UDim2.new(0, 280, 0, 0)}, 0.3)
        task.delay(0.3, function() notif:Destroy() end)
    end)
end

-- ============================================================
-- KEYBIND TOGGLE (for hiding/showing window)
-- ============================================================
function NexusUI:SetKeybind(key)
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == key then
            self:Toggle()
        end
    end)
end

-- ============================================================
-- RETURN LIBRARY
-- ============================================================
return NexusUI

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  EXEMPLO DE USO COMPLETO  (Cole num LocalScript novo)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local NexusUI = loadstring(game:HttpGet("URL_DO_SCRIPT"))()
-- OU se estiver no mesmo arquivo, simplesmente:
-- local NexusUI = require(script)   (se for ModuleScript)

-- Criar janela principal
local Window = NexusUI.new({
    Title    = "Meu Script",
    SubTitle = "by Dev",
    Width    = 360,
    Height   = 480,
})

-- Tecla para esconder/mostrar (RightShift)
Window:SetKeybind(Enum.KeyCode.RightShift)

-- ── ABA 1: COMBAT ────────────────────────────────────────────
local tabCombat = Window:AddTab({ Name = "Combat",  Icon = "⚔" })

Window:AddSection(tabCombat, "Ataques")

Window:AddButton(tabCombat, {
    Name     = "Kill Aura",
    Icon     = "🎯",
    Color    = Color3.fromRGB(239, 68, 68),
    Callback = function()
        print("Kill Aura ativado!")
    end
})

Window:AddToggle(tabCombat, {
    Name        = "Auto Attack",
    Icon        = "⚡",
    Description = "Ataca automaticamente inimigos próximos",
    Default     = false,
    Callback    = function(state)
        print("Auto Attack:", state)
    end
})

Window:AddSlider(tabCombat, {
    Name     = "Attack Range",
    Min      = 5,
    Max      = 100,
    Step     = 1,
    Default  = 20,
    Suffix   = " studs",
    Callback = function(value)
        print("Range:", value)
    end
})

-- ── ABA 2: PLAYER ────────────────────────────────────────────
local tabPlayer = Window:AddTab({ Name = "Player", Icon = "🧍" })

Window:AddSection(tabPlayer, "Velocidade & Física")

Window:AddSlider(tabPlayer, {
    Name     = "WalkSpeed",
    Min      = 16,
    Max      = 500,
    Step     = 1,
    Default  = 16,
    Callback = function(v)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
})

Window:AddSlider(tabPlayer, {
    Name     = "JumpPower",
    Min      = 50,
    Max      = 500,
    Step     = 5,
    Default  = 50,
    Callback = function(v)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = v
    end
})

Window:AddSeparator(tabPlayer)
Window:AddSection(tabPlayer, "Visuais")

Window:AddToggle(tabPlayer, {
    Name     = "Noclip",
    Icon     = "👻",
    Callback = function(state)
        -- implementar noclip
    end
})

-- ── ABA 3: MISC ──────────────────────────────────────────────
local tabMisc = Window:AddTab({ Name = "Misc", Icon = "⚙" })

Window:AddSection(tabMisc, "Utilitários")

Window:AddDropdown(tabMisc, {
    Name     = "Teleport para",
    Options  = {"Spawn", "Base", "Loja", "Boss", "Saída"},
    Default  = "Spawn",
    Callback = function(sel)
        print("Teleportando para:", sel)
    end
})

Window:AddInput(tabMisc, {
    Name        = "Custom Chat",
    Placeholder = "Digite a mensagem...",
    Callback    = function(text)
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, "All")
    end
})

Window:AddSection(tabMisc, "Aparência")

Window:AddColorPicker(tabMisc, {
    Name     = "Cor do Personagem",
    Callback = function(color)
        local char = game.Players.LocalPlayer.Character
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Color = color
            end
        end
    end
})

Window:AddLabel(tabMisc, "ℹ NexusUI v2.0 — Use com responsabilidade!", Color3.fromRGB(99, 102, 241))

-- ── Notificação inicial ───────────────────────────────────────
task.delay(1, function()
    Window:Notify({
        Title    = "✦ NexusUI Carregado!",
        Message  = "Script pronto. Pressione RightShift para esconder.",
        Type     = "success",
        Duration = 4,
    })
end)
--]]
