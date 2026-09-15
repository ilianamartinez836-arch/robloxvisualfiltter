--// TSB FPS BOOSTER
--// F6 = Activar / Desactivar
--// F7 = Ocultar / Mostrar menú
--// Visual solamente

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================

local Enabled = true
local MenuVisible = true

--==================================================
-- NOMBRES DE OBJETOS QUE QUEREMOS OCULTAR
--==================================================

local rockNames = {
    rock = true,
    rocks = true,
    stone = true,
    stones = true,
    rubble = true,
    debris = true,
    boulder = true,
    boulders = true,
    pebble = true,
    pebbles = true
}

local function isRock(obj)
    local name = string.lower(obj.Name)

    return rockNames[name]
        or string.find(name, "rock")
        or string.find(name, "stone")
        or string.find(name, "rubble")
        or string.find(name, "boulder")
end

--==================================================
-- OCULTAR ROCKS
--==================================================

local function hideRock(obj)

    if not Enabled then
        return
    end

    if not isRock(obj) then
        return
    end

    -- Si es una pieza física, ocultarla solamente
    -- en nuestro cliente.
    if obj:IsA("BasePart") then

        pcall(function()
            obj.LocalTransparencyModifier = 1
            obj.CastShadow = false
        end)

    elseif obj:IsA("Model") then

        for _, descendant in ipairs(obj:GetDescendants()) do

            if descendant:IsA("BasePart") then

                pcall(function()
                    descendant.LocalTransparencyModifier = 1
                    descendant.CastShadow = false
                end)

            end
        end
    end
end

--==================================================
-- ESCANEAR ROCKS EXISTENTES
--==================================================

local function scanRocks()

    if not Enabled then
        return
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        hideRock(obj)
    end
end

--==================================================
-- SOMBRAS
--==================================================

local originalGlobalShadows = Lighting.GlobalShadows

local function applyShadows()

    if Enabled then

        Lighting.GlobalShadows = false

        for _, obj in ipairs(Lighting:GetDescendants()) do

            if obj:IsA("PointLight")
                or obj:IsA("SpotLight")
                or obj:IsA("SurfaceLight") then

                pcall(function()
                    obj.Shadows = false
                end)

            end
        end

    else

        Lighting.GlobalShadows = originalGlobalShadows
    end
end

--==================================================
-- ACTIVAR
--==================================================

local function enableBooster()

    Enabled = true

    applyShadows()
    scanRocks()
end

--==================================================
-- DESACTIVAR
--==================================================

local function disableBooster()

    Enabled = false

    Lighting.GlobalShadows = originalGlobalShadows

    -- Restaurar transparencia local de los objetos
    for _, obj in ipairs(workspace:GetDescendants()) do

        if isRock(obj) and obj:IsA("BasePart") then

            pcall(function()
                obj.LocalTransparencyModifier = 0
            end)

        elseif isRock(obj) and obj:IsA("Model") then

            for _, descendant in ipairs(obj:GetDescendants()) do

                if descendant:IsA("BasePart") then

                    pcall(function()
                        descendant.LocalTransparencyModifier = 0
                    end)

                end
            end
        end
    end
end

--==================================================
-- DETECTAR OBJETOS NUEVOS
--==================================================

workspace.DescendantAdded:Connect(function(obj)

    if not Enabled then
        return
    end

    task.defer(function()
        hideRock(obj)
    end)
end)

--==================================================
-- GUI
--==================================================

pcall(function()
    playerGui:FindFirstChild("TSBFPSBooster"):Destroy()
end)

local gui = Instance.new("ScreenGui")
gui.Name = "TSBFPSBooster"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(270, 150)
main.Position = UDim2.new(0, 30, 0.5, -75)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(65, 65, 75)
stroke.Thickness = 1
stroke.Parent = main

--==================================================
-- TITULO
--==================================================

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 35)
title.Position = UDim2.fromOffset(10, 8)
title.BackgroundTransparency = 1
title.Text = "FPS BOOSTER"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -20, 0, 25)
info.Position = UDim2.fromOffset(10, 40)
info.BackgroundTransparency = 1
info.Text = "Shadows + Rock Removal"
info.TextColor3 = Color3.fromRGB(145, 145, 155)
info.TextSize = 12
info.Font = Enum.Font.Gotham
info.TextXAlignment = Enum.TextXAlignment.Left
info.Parent = main

--==================================================
-- TOGGLE
--==================================================

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.fromOffset(235, 38)
toggle.Position = UDim2.fromOffset(17, 75)
toggle.BorderSizePixel = 0
toggle.TextSize = 13
toggle.Font = Enum.Font.GothamBold
toggle.Parent = main

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 7)
toggleCorner.Parent = toggle

local function updateButton()

    if Enabled then

        toggle.Text = "●  FPS BOOSTER: ON"
        toggle.TextColor3 = Color3.fromRGB(100, 220, 130)
        toggle.BackgroundColor3 = Color3.fromRGB(35, 55, 40)

    else

        toggle.Text = "●  FPS BOOSTER: OFF"
        toggle.TextColor3 = Color3.fromRGB(220, 100, 100)
        toggle.BackgroundColor3 = Color3.fromRGB(55, 35, 35)
    end
end

toggle.MouseButton1Click:Connect(function()

    if Enabled then
        disableBooster()
    else
        enableBooster()
    end

    updateButton()
end)

--==================================================
-- TECLAS
--==================================================

UIS.InputBegan:Connect(function(input, processed)

    if processed then
        return
    end

    -- F6 = Booster ON/OFF
    if input.KeyCode == Enum.KeyCode.F6 then

        if Enabled then
            disableBooster()
        else
            enableBooster()
        end

        updateButton()
    end

    -- F7 = Mostrar/Ocultar menú
    if input.KeyCode == Enum.KeyCode.F7 then

        MenuVisible = not MenuVisible
        main.Visible = MenuVisible
    end
end)

--==================================================
-- RESPAWN
--==================================================

player.CharacterAdded:Connect(function()

    task.wait(1)

    if Enabled then
        applyShadows()
        scanRocks()
    end
end)

--==================================================
-- INICIAR
--==================================================

enableBooster()
updateButton()

print("TSB FPS Booster cargado | F6 = ON/OFF | F7 = Menu")
