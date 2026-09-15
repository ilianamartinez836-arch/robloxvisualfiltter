
--// POST FX OPTIMIZER
--// F8 = Activar / Desactivar
--// F9 = Mostrar / Ocultar menu
--
--// No modifica tu CustomVisualFilter
--// Compatible con tu Visual Filter y FPS Booster

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- CONFIGURACION
--==================================================

local Enabled = true
local MenuVisible = true

-- Efectos que queremos desactivar
local DisabledEffects = {
    BloomEffect = true,
    BlurEffect = true,
    DepthOfFieldEffect = true,
    SunRaysEffect = true,
    ColorGradingEffect = true
}

-- Tu filtro visual queda protegido
local ProtectedEffects = {
    CustomVisualFilter = true
}

--==================================================
-- COMPROBAR SI ES UN POST FX
--==================================================

local function isTargetEffect(obj)

    if ProtectedEffects[obj.Name] then
        return false
    end

    return DisabledEffects[obj.ClassName] == true
end

--==================================================
-- DESACTIVAR POST FX
--==================================================

local function disableEffect(obj)

    if not Enabled then
        return
    end

    if isTargetEffect(obj) then

        pcall(function()
            obj.Enabled = false
        end)

    end
end

--==================================================
-- ESCANEAR LIGHTING
--==================================================

local function scanLighting()

    if not Enabled then
        return
    end

    for _, obj in ipairs(Lighting:GetDescendants()) do
        disableEffect(obj)
    end

end

--==================================================
-- ESCANEAR CAMERA
--==================================================

local function scanCamera()

    if not Enabled then
        return
    end

    local camera = workspace.CurrentCamera

    if not camera then
        return
    end

    for _, obj in ipairs(camera:GetDescendants()) do
        disableEffect(obj)
    end

end

--==================================================
-- APLICAR
--==================================================

local function applyOptimizer()

    if not Enabled then
        return
    end

    scanLighting()
    scanCamera()

end

--==================================================
-- RESTAURAR POST FX
--==================================================

local function restoreEffects()

    for _, obj in ipairs(Lighting:GetDescendants()) do

        if isTargetEffect(obj) then

            pcall(function()
                obj.Enabled = true
            end)

        end
    end

    local camera = workspace.CurrentCamera

    if camera then

        for _, obj in ipairs(camera:GetDescendants()) do

            if isTargetEffect(obj) then

                pcall(function()
                    obj.Enabled = true
                end)

            end
        end
    end

end

--==================================================
-- DETECTAR EFECTOS NUEVOS EN LIGHTING
--==================================================

Lighting.DescendantAdded:Connect(function(obj)

    if not Enabled then
        return
    end

    task.defer(function()
        disableEffect(obj)
    end)

end)

--==================================================
-- DETECTAR EFECTOS NUEVOS EN CAMERA
--==================================================

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()

    if Enabled then

        task.wait(0.2)
        scanCamera()

    end

end)

--==================================================
-- GUI
--==================================================

pcall(function()
    playerGui:FindFirstChild("PostFXOptimizer"):Destroy()
end)

local gui = Instance.new("ScreenGui")
gui.Name = "PostFXOptimizer"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(290, 185)
main.Position = UDim2.new(0, 30, 0.5, -92)
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
title.Text = "POST FX OPTIMIZER"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -20, 0, 45)
info.Position = UDim2.fromOffset(10, 40)
info.BackgroundTransparency = 1
info.Text = "Bloom • Blur • DoF • Sun Rays • Color Grading"
info.TextColor3 = Color3.fromRGB(145, 145, 155)
info.TextSize = 11
info.Font = Enum.Font.Gotham
info.TextWrapped = true
info.TextXAlignment = Enum.TextXAlignment.Left
info.Parent = main

--==================================================
-- TOGGLE
--==================================================

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.fromOffset(250, 38)
toggle.Position = UDim2.fromOffset(20, 90)
toggle.BorderSizePixel = 0
toggle.TextSize = 13
toggle.Font = Enum.Font.GothamBold
toggle.Parent = main

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 7)
toggleCorner.Parent = toggle

local function updateButton()

    if Enabled then

        toggle.Text = "●  POST FX: OFF"
        toggle.TextColor3 = Color3.fromRGB(100, 220, 130)
        toggle.BackgroundColor3 = Color3.fromRGB(35, 55, 40)

    else

        toggle.Text = "●  POST FX: ON"
        toggle.TextColor3 = Color3.fromRGB(220, 100, 100)
        toggle.BackgroundColor3 = Color3.fromRGB(55, 35, 35)

    end

end

toggle.MouseButton1Click:Connect(function()

    if Enabled then

        Enabled = false
        restoreEffects()

    else

        Enabled = true
        applyOptimizer()

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

    -- F8 = Optimizer ON/OFF
    if input.KeyCode == Enum.KeyCode.F8 then

        if Enabled then

            Enabled = false
            restoreEffects()

        else

            Enabled = true
            applyOptimizer()

        end

        updateButton()

    end

    -- F9 = Menu
    if input.KeyCode == Enum.KeyCode.F9 then

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
        applyOptimizer()
    end

end)

--==================================================
-- COMPROBACION LIGERA
--==================================================

task.spawn(function()

    while task.wait(3) do

        if Enabled then
            applyOptimizer()
        end

    end

end)

--==================================================
-- INICIAR
--==================================================

applyOptimizer()
updateButton()

print("Post FX Optimizer cargado | F8 = ON/OFF | F9 = Menu")
