--[[
    RONY HUB
    Farm • Torre • Mundos • Rebirth • Speed • Anti-AFK
--]]

-- ═══════════════════════════════════════
--  BIBLIOTECAS
-- ═══════════════════════════════════════
local Fluent = loadstring(game:HttpGet(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
))()
local SaveManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"
))()
local InterfaceManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"
))()

-- ═══════════════════════════════════════
--  SERVIÇOS
-- ═══════════════════════════════════════
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")

local LP   = Players.LocalPlayer
local char = LP.Character or LP.CharacterAdded:Wait()
local hrp  = char:WaitForChild("HumanoidRootPart")

-- ═══════════════════════════════════════
--  ESTADO
-- ═══════════════════════════════════════
local farmingWin    = false
local farmingTorre  = false
local rebirthAtivo  = false
local speedAtivo    = false
local antiAfkAtivo  = false
local speedValor    = 24
local rebirthDelay  = 0.1
local collected     = 0
local rebirths      = 0
local statusTxt     = "Parado"
local SpeedConn     = nil
local AntiAfkConn   = nil
local lastAfkMove   = tick()

-- refs para os toggles (usados no PararTudo e SaveManager)
local ToggleFarmRef    = nil
local ToggleTorreRef   = nil
local ToggleRebirthRef = nil
local ToggleSpeedRef   = nil
local ToggleAfkRef     = nil

-- ═══════════════════════════════════════
--  HELPERS
-- ═══════════════════════════════════════
local function GetHRP()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function GetHum()
    local c = LP.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function SafeTP(cf)
    local root = GetHRP()
    if not root then return false end
    local ok = pcall(function() root.CFrame = cf end)
    return ok
end

local function SafeFire(root, part)
    pcall(function()
        firetouchinterest(root, part, 0)
        firetouchinterest(root, part, 1)
    end)
end

-- ═══════════════════════════════════════
--  CFRAMES — MUNDOS
-- ═══════════════════════════════════════
local MUNDOS = {
    { name = "Mundo 1 - Terra",                   cf = CFrame.new(1.02734947,  0.919134617,  14.7633591,   0,-1,0, 1,0,0, 0,0, 1) },
    { name = "Mundo 2 - Montanhas",               cf = CFrame.new(3.52734804,  11264.3213,  -116.507256,   0,-1,0, 1,0,0, 0,0, 1) },
    { name = "Mundo 3 - Ilha do Vulcao",          cf = CFrame.new(3.52734804,  22355.9961,  -267.691284,   0,-1,0, 1,0,0, 0,0, 1) },
    { name = "Mundo 4 - Nuvem de Trovao",         cf = CFrame.new(3.52734804,  33619.9961,  -418.691284,   0,-1,0, 1,0,0, 0,0, 1) },
    { name = "Mundo 5 - WaterLand",               cf = CFrame.new(1.02734756,  0.921996236, 1241.50708,    0, 1,0, 1,0,0, 0,0,-1) },
    { name = "Mundo 6 - Praia",                   cf = CFrame.new(3.52734804,  11264.3213,  1101.90869,    0,-1,0, 1,0,0, 0,0, 1) },
    { name = "Mundo 7 - Estaleiro Abissal",       cf = CFrame.new(3.52734804,  22355.9961,  950.540466,    0,-1,0, 1,0,0, 0,0, 1) },
    { name = "Mundo 8 - Queda de Gelo",           cf = CFrame.new(3.52734804,  33619.9961,  799.10376,     0,-1,0, 1,0,0, 0,0, 1) },
    { name = "Mundo 9 - Deserto",                 cf = CFrame.new(1.02734756,  0.92199707,  4184.80273,    0, 1,0, 1,0,0, 0,0,-1) },
    { name = "Mundo 10 - Veu de Cristal",         cf = CFrame.new(3.52734804,  11264.3213,  4045.20459,    0,-1,0, 1,0,0, 0,0, 1) },
    { name = "Mundo 11 - Planicies de Petalas",   cf = CFrame.new(3.52734804,  22355.9961,  3893.83643,    0,-1,0, 1,0,0, 0,0, 1) },
    { name = "Mundo 12 - Pastagens de Cogumelos", cf = CFrame.new(3.52734804,  33619.9961,  3742.39966,    0,-1,0, 1,0,0, 0,0, 1) },
}

-- ═══════════════════════════════════════
--  CFRAMES — OUTROS
-- ═══════════════════════════════════════
local TORRE_CF = CFrame.new(
    3.2179985, 40752.0117, 3717.75293,
    -1, 0, 0,
     0, 1, 0,
     0, 0, -1
)

local SAPATOS_CF = CFrame.new(
    -45.96101, 12.8364601, 16.6812382,
     2.2649765e-05, -0.876991034, -0.480506718,
    -1,             -2.2649765e-05, -5.7965517e-06,
    -5.7965517e-06,  0.480506718,  -0.876991034
)

-- ═══════════════════════════════════════
--  FARM — TORRE
-- ═══════════════════════════════════════
function loopTorre()
    while farmingTorre do
        local root = GetHRP()
        if root then
            pcall(function() root.CFrame = TORRE_CF end)
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "WinButton" and v:IsA("BasePart") then
                    SafeFire(root, v)
                end
            end
        end
        task.wait(0.3)
    end
end

-- ═══════════════════════════════════════
--  FARM — WINBUTTONS ALEATORIO
-- ═══════════════════════════════════════
function loopWin()
    collected = 0
    while farmingWin do
        local root = GetHRP()
        if not root then task.wait(1); continue end

        local btns = {}
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "WinButton" and v:IsA("BasePart") then
                table.insert(btns, v)
            end
        end

        if #btns == 0 then
            statusTxt = "Procurando WinButtons..."
            task.wait(1)
        else
            for _, btn in ipairs(btns) do
                if not farmingWin then break end
                local r = GetHRP()
                if r then
                    pcall(function() r.CFrame = btn.CFrame + Vector3.new(0, 3, 0) end)
                    task.wait(0.05)
                    SafeFire(r, btn)
                    collected = collected + 1
                    statusTxt = "Coletados: " .. collected .. " | Botoes: " .. #btns
                end
                task.wait(0.25)
            end
        end
        task.wait(0.1)
    end
    statusTxt = "Parado | Total: " .. collected
end

-- ═══════════════════════════════════════
--  AUTO REBIRTH
-- ═══════════════════════════════════════
function loopRebirth()
    while rebirthAtivo do
        pcall(function()
            local args = { "Rebirths", "Request" }
            game:GetService("ReplicatedStorage")
                :WaitForChild("Events")
                :WaitForChild("InvokeServerAction")
                :InvokeServer(unpack(args))
        end)
        rebirths = rebirths + 1
        task.wait(rebirthDelay)
    end
end

-- ═══════════════════════════════════════
--  SPEED BOOST
-- ═══════════════════════════════════════
function enableSpeed()
    if SpeedConn then SpeedConn:Disconnect() end
    SpeedConn = RunService.Heartbeat:Connect(function()
        if not speedAtivo then return end
        local h = GetHum()
        if h then h.WalkSpeed = speedValor end
    end)
end
enableSpeed()

-- ═══════════════════════════════════════
--  ANTI-AFK
-- ═══════════════════════════════════════
function enableAntiAfk()
    if AntiAfkConn then AntiAfkConn:Disconnect() end
    AntiAfkConn = RunService.Heartbeat:Connect(function()
        if not antiAfkAtivo then return end
        if tick() - lastAfkMove >= 55 then
            local root = GetHRP()
            if root then
                pcall(function()
                    root.CFrame = root.CFrame * CFrame.new(0.01, 0, 0)
                    task.delay(0.1, function()
                        pcall(function()
                            root.CFrame = root.CFrame * CFrame.new(-0.01, 0, 0)
                        end)
                    end)
                end)
            end
            lastAfkMove = tick()
        end
    end)
end
enableAntiAfk()

-- ═══════════════════════════════════════
--  PARAR TUDO
-- ═══════════════════════════════════════
local function PararTudo()
    farmingWin   = false
    farmingTorre = false
    rebirthAtivo = false
    speedAtivo   = false

    local h = GetHum()
    if h then h.WalkSpeed = 16 end

    if ToggleFarmRef    then pcall(function() ToggleFarmRef:SetValue(false)    end) end
    if ToggleTorreRef   then pcall(function() ToggleTorreRef:SetValue(false)   end) end
    if ToggleRebirthRef then pcall(function() ToggleRebirthRef:SetValue(false) end) end
    if ToggleSpeedRef   then pcall(function() ToggleSpeedRef:SetValue(false)   end) end

    statusTxt = "Parado | Total: " .. collected
    Fluent:Notify({ Title = "Rony Hub", Content = "Tudo parado!", Duration = 3 })
end

-- ═══════════════════════════════════════
--  RESPAWN — reativa o que estava ligado
-- ═══════════════════════════════════════
LP.CharacterAdded:Connect(function(c)
    char = c
    hrp  = c:WaitForChild("HumanoidRootPart")
    task.wait(2)
    enableSpeed()
    enableAntiAfk()
    if farmingTorre then task.spawn(loopTorre)   end
    if farmingWin   then task.spawn(loopWin)     end
    if rebirthAtivo then task.spawn(loopRebirth) end
end)

-- ═══════════════════════════════════════
--  HUD
-- ═══════════════════════════════════════
local function MkTxt(y, cor)
    local d        = Drawing.new("Text")
    d.Visible      = false
    d.Color        = cor
    d.Size         = 14
    d.Center       = false
    d.Outline      = true
    d.OutlineColor = Color3.new(0, 0, 0)
    d.Font         = 2
    d.Position     = Vector2.new(10, y)
    return d
end

local HudFarm    = MkTxt(40, Color3.fromRGB(0,   220, 160))
local HudTorre   = MkTxt(58, Color3.fromRGB(255, 200, 80 ))
local HudRebirth = MkTxt(76, Color3.fromRGB(140, 180, 255))
local HudAfk     = MkTxt(94, Color3.fromRGB(200, 200, 200))

RunService.PreSimulation:Connect(function()
    HudFarm.Text    = "[Farm] " .. statusTxt
    HudFarm.Visible = farmingWin

    HudTorre.Text    = "[Torre] Farm ativo"
    HudTorre.Visible = farmingTorre

    HudRebirth.Text    = "[Rebirth] Feitos: " .. rebirths
    HudRebirth.Visible = rebirthAtivo

    HudAfk.Text    = "[Anti-AFK] Ativo"
    HudAfk.Visible = antiAfkAtivo
end)

local StatusPara = nil
task.spawn(function()
    while true do
        task.wait(1)
        if StatusPara then
            pcall(function() StatusPara:SetValue(statusTxt) end)
        end
    end
end)

-- ═══════════════════════════════════════
--  JANELA FLUENT
-- ═══════════════════════════════════════
local Win = Fluent:CreateWindow({
    Title    = "Rony Hub",
    SubTitle = "Farm • Mundos • Rebirth • Speed",
    TabWidth = 160,
    Size     = UDim2.new(0, 600, 0, 500),
    Acrylic  = false,
    Theme    = "Dark",
})

local TabFarm     = Win:AddTab({ Title = "Farm",     Icon = "zap"        })
local TabTorre    = Win:AddTab({ Title = "Torre",    Icon = "shield"     })
local TabMundos   = Win:AddTab({ Title = "Mundos",   Icon = "map-pin"    })
local TabRebirth  = Win:AddTab({ Title = "Rebirth",  Icon = "refresh-cw" })
local TabExtras   = Win:AddTab({ Title = "Extras",   Icon = "zap"        })

local TabSettings = Win:AddTab({ Title = "Config",   Icon = "settings"   })

-- ════════════════════════════
--  ABA: FARM
-- ════════════════════════════
ToggleFarmRef = TabFarm:AddToggle("ToggleFarm", {
    Title    = "Auto Farm de Dinheiro",
    Default  = false,
    Callback = function(v)
        farmingWin = v
        if v then
            task.spawn(loopWin)
            Fluent:Notify({ Title = "Farm", Content = "Iniciado!", Duration = 2 })
        else
            Fluent:Notify({ Title = "Farm", Content = "Parado.", Duration = 2 })
        end
    end,
})

StatusPara = TabFarm:AddParagraph({ Title = "Status", Content = "Parado" })

TabFarm:AddButton({
    Title    = "Parar Farm",
    Callback = function()
        farmingWin = false
        if ToggleFarmRef then pcall(function() ToggleFarmRef:SetValue(false) end) end
        Fluent:Notify({ Title = "Farm", Content = "Parado.", Duration = 2 })
    end,
})

-- ════════════════════════════
--  ABA: TORRE
-- ════════════════════════════
ToggleTorreRef = TabTorre:AddToggle("ToggleTorre", {
    Title       = "Auto Farm — Melhor Torre",
    Description = "Teleporta e dispara firetouchinterest nos WinButtons",
    Default     = false,
    Callback    = function(v)
        farmingTorre = v
        if v then
            task.spawn(loopTorre)
            Fluent:Notify({ Title = "Torre", Content = "Iniciado!", Duration = 2 })
        else
            Fluent:Notify({ Title = "Torre", Content = "Parado.", Duration = 2 })
        end
    end,
})

TabTorre:AddButton({
    Title    = "Teleportar para Torre Agora",
    Callback = function()
        local ok = SafeTP(TORRE_CF)
        Fluent:Notify({ Title = "Torre", Content = ok and "Teleportado!" or "Erro.", Duration = 2 })
    end,
})

TabTorre:AddButton({
    Title    = "Parar Torre",
    Callback = function()
        farmingTorre = false
        if ToggleTorreRef then pcall(function() ToggleTorreRef:SetValue(false) end) end
        Fluent:Notify({ Title = "Torre", Content = "Parado.", Duration = 2 })
    end,
})

-- ════════════════════════════
--  ABA: MUNDOS
-- ════════════════════════════
local MundoNames    = {}
local SelectedMundo = 1
for _, m in ipairs(MUNDOS) do
    table.insert(MundoNames, m.name)
end

TabMundos:AddDropdown("DropMundo", {
    Title    = "Selecionar Mundo",
    Values   = MundoNames,
    Default  = 1,
    Callback = function(value)
        for i, m in ipairs(MUNDOS) do
            if m.name == value then SelectedMundo = i; break end
        end
    end,
})

TabMundos:AddButton({
    Title    = "Ir para Mundo Selecionado",
    Callback = function()
        local m = MUNDOS[SelectedMundo]
        if m then
            local ok = SafeTP(m.cf)
            Fluent:Notify({
                Title   = "Mundo",
                Content = ok and ("Indo para: " .. m.name) or "Erro ao teleportar.",
                Duration = 2,
            })
        end
    end,
})

for _, mundo in ipairs(MUNDOS) do
    local ref = mundo
    TabMundos:AddButton({
        Title    = ref.name,
        Callback = function()
            local ok = SafeTP(ref.cf)
            Fluent:Notify({
                Title   = "Mundo",
                Content = ok and ref.name or "Erro ao teleportar.",
                Duration = 2,
            })
        end,
    })
end

-- ════════════════════════════
--  ABA: REBIRTH
-- ════════════════════════════
ToggleRebirthRef = TabRebirth:AddToggle("ToggleRebirth", {
    Title    = "Auto Rebirth",
    Default  = false,
    Callback = function(v)
        rebirthAtivo = v
        if v then
            task.spawn(loopRebirth)
            Fluent:Notify({ Title = "Rebirth", Content = "Iniciado!", Duration = 2 })
        else
            Fluent:Notify({ Title = "Rebirth", Content = "Parado.", Duration = 2 })
        end
    end,
})

TabRebirth:AddSlider("SliderRebirth", {
    Title    = "Delay entre Rebirths (seg)",
    Min      = 0.1,
    Max      = 10,
    Default  = 0.1,
    Rounding = 1,
    Callback = function(v) rebirthDelay = v end,
})

TabRebirth:AddButton({
    Title    = "Rebirth Agora",
    Callback = function()
        pcall(function()
            local args = { "Rebirths", "Request" }
            game:GetService("ReplicatedStorage")
                :WaitForChild("Events")
                :WaitForChild("InvokeServerAction")
                :InvokeServer(unpack(args))
        end)
        rebirths = rebirths + 1
        Fluent:Notify({ Title = "Rebirth", Content = "Feito! Total: " .. rebirths, Duration = 2 })
    end,
})

TabRebirth:AddButton({
    Title    = "Parar Rebirth",
    Callback = function()
        rebirthAtivo = false
        if ToggleRebirthRef then pcall(function() ToggleRebirthRef:SetValue(false) end) end
        Fluent:Notify({ Title = "Rebirth", Content = "Parado.", Duration = 2 })
    end,
})

-- ════════════════════════════
--  ABA: EXTRAS
-- ════════════════════════════
ToggleSpeedRef = TabExtras:AddToggle("ToggleSpeed", {
    Title    = "Speed Boost",
    Default  = false,
    Callback = function(v)
        speedAtivo = v
        if not v then
            local h = GetHum()
            if h then h.WalkSpeed = 16 end
        end
    end,
})

TabExtras:AddSlider("SliderSpeed", {
    Title    = "Velocidade",
    Min      = 16,
    Max      = 200,
    Default  = 24,
    Rounding = 0,
    Callback = function(v) speedValor = v end,
})

ToggleAfkRef = TabExtras:AddToggle("ToggleAfk", {
    Title    = "Anti-AFK",
    Default  = false,
    Callback = function(v)
        antiAfkAtivo = v
        lastAfkMove  = tick()
        Fluent:Notify({ Title = "Anti-AFK", Content = v and "Ativado!" or "Desativado.", Duration = 2 })
    end,
})

TabExtras:AddButton({
    Title    = "Teleportar — Vendedor de Sapatos",
    Callback = function()
        local ok = SafeTP(SAPATOS_CF)
        Fluent:Notify({ Title = "Sapatos", Content = ok and "Teleportado!" or "Erro.", Duration = 2 })
    end,
})

TabExtras:AddButton({
    Title    = "PARAR TUDO",
    Callback = function() PararTudo() end,
})



-- ════════════════════════════
--  ABA: CONFIG (SaveManager)
--  Salva automaticamente os toggles e sliders
-- ════════════════════════════
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(TabSettings)
SaveManager:BuildConfigSection(TabSettings)
SaveManager:SetFolder("RonyHub")
SaveManager:SetConfig("Default")
SaveManager:LoadAutoloadConfig()

-- ═══════════════════════════════════════
--  START
-- ═══════════════════════════════════════
Win:SelectTab(1)

task.delay(1, function()
    Fluent:Notify({
        Title    = "Rony Hub Carregado",
        Content  = "Farm | Torre | Mundos | Rebirth | Speed | Anti-AFK",
        Duration = 4,
    })
end)

print("[Rony Hub] Carregado!")
