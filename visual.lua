--// VISUAL FILTER
--// F4 = Mostrar/Ocultar menú
--// F5 = Activar/Desactivar efecto

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- CONFIGURACION
--==================================================

local Settings = {
    Brightness = 0,
    Contrast = 0,
    Saturation = 0,
    Temperature = 0,
    Enabled = true
}

--==================================================
-- CREAR / ACTUALIZAR EFECTO
--==================================================

local effect

local function updateTemperature()
    if not effect then return end

    local value = Settings.Temperature

    if value < 0 then
        local amount = math.abs(value)

        effect.TintColor = Color3.new(
            1 - (amount * 0.15),
            1 - (amount * 0.05),
            1
        )
    else
        effect.TintColor = Color3.new(
            1,
            1 - (value * 0.12),
            1 - (value * 0.22)
        )
    end
end

local function applyEffect()

    if not effect or not effect.Parent then
        effect = Instance.new("ColorCorrectionEffect")
        effect.Name = "CustomVisualFilter"
        effect.Parent = Lighting
    end

    effect.Brightness = Settings.Brightness
    effect.Contrast = Settings.Contrast
    effect.Saturation = Settings.Saturation

    updateTemperature()

    effect.Enabled = Settings.Enabled
end

local function removeOldEffects()

    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("ColorCorrectionEffect")
            and obj.Name == "CustomVisualFilter"
            and obj ~= effect then

            pcall(function()
                obj:Destroy()
            end)
        end
    end
end

-- Crear inicialmente
applyEffect()

--==================================================
-- GUI
--==================================================

pcall(function()
    playerGui:FindFirstChild("VisualFilterMenu"):Destroy()
end)

local gui = Instance.new("ScreenGui")
gui.Name = "VisualFilterMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(330, 390)
main.Position = UDim2.new(0, 30, 0.5, -195)
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
title.Size = UDim2.new(1, -20, 0, 45)
title.Position = UDim2.fromOffset(10, 5)
title.BackgroundTransparency = 1
title.Text = "VISUAL FILTER"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -20, 0, 20)
subtitle.Position = UDim2.fromOffset(10, 40)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Color & screen adjustments"
subtitle.TextColor3 = Color3.fromRGB(145, 145, 155)
subtitle.TextSize = 12
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = main

--==================================================
-- SLIDERS
--==================================================

local sliderY = 78

local function createSlider(name, minValue, maxValue, defaultValue, callback)

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -30, 0, 55)
    container.Position = UDim2.fromOffset(15, sliderY)
    container.BackgroundTransparency = 1
    container.Parent = main

    sliderY += 60

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(225, 225, 230)
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(170, 170, 180)
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 6)
    bar.Position = UDim2.fromOffset(0, 31)
    bar.BackgroundColor3 = Color3.fromRGB(55, 55, 62)
    bar.BorderSizePixel = 0
    bar.Parent = container

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(110, 170, 255)
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(14, 14)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
    knob.BorderSizePixel = 0
    knob.Parent = bar

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local dragging = false

    local function setValue(value)

        value = math.clamp(value, minValue, maxValue)

        local percent =
            (value - minValue) /
            (maxValue - minValue)

        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, 0, 0.5, 0)

        valueLabel.Text = string.format("%.2f", value)

        callback(value)
    end

    local function updateFromMouse(x)

        local percent = math.clamp(
            (x - bar.AbsolutePosition.X) /
            bar.AbsoluteSize.X,
            0,
            1
        )

        local value =
            minValue +
            ((maxValue - minValue) * percent)

        setValue(value)
    end

    bar.InputBegan:Connect(function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            dragging = true
            updateFromMouse(input.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(input)

        if dragging and
            input.UserInputType ==
            Enum.UserInputType.MouseMovement then

            updateFromMouse(input.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            dragging = false
        end
    end)

    setValue(defaultValue)
end

--==================================================
-- SLIDERS
--==================================================

createSlider(
    "Brightness",
    -1,
    1,
    Settings.Brightness,
    function(value)

        Settings.Brightness = value
        applyEffect()
    end
)

createSlider(
    "Contrast",
    -1,
    1,
    Settings.Contrast,
    function(value)

        Settings.Contrast = value
        applyEffect()
    end
)

createSlider(
    "Saturation",
    -1,
    1,
    Settings.Saturation,
    function(value)

        Settings.Saturation = value
        applyEffect()
    end
)

createSlider(
    "Temperature",
    -1,
    1,
    Settings.Temperature,
    function(value)

        Settings.Temperature = value
        applyEffect()
    end
)

--==================================================
-- RESET
--==================================================

local reset = Instance.new("TextButton")
reset.Size = UDim2.fromOffset(140, 35)
reset.Position = UDim2.fromOffset(15, 340)
reset.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
reset.BorderSizePixel = 0
reset.Text = "RESET"
reset.TextColor3 = Color3.fromRGB(230, 230, 235)
reset.TextSize = 12
reset.Font = Enum.Font.GothamBold
reset.Parent = main

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 7)
resetCorner.Parent = reset

reset.MouseButton1Click:Connect(function()

    Settings.Brightness = 0
    Settings.Contrast = 0
    Settings.Saturation = 0
    Settings.Temperature = 0

    applyEffect()

end)

--==================================================
-- STATUS
--==================================================

local status = Instance.new("TextLabel")
status.Size = UDim2.fromOffset(140, 35)
status.Position = UDim2.fromOffset(170, 340)
status.BackgroundTransparency = 1
status.Text = "● EFFECT ON"
status.TextColor3 = Color3.fromRGB(100, 220, 130)
status.TextSize = 12
status.Font = Enum.Font.GothamBold
status.TextXAlignment = Enum.TextXAlignment.Center
status.Parent = main

--==================================================
-- TECLAS
--==================================================

UIS.InputBegan:Connect(function(input, processed)

    if processed then
        return
    end

    -- F4 = Menu
    if input.KeyCode == Enum.KeyCode.F4 then

        main.Visible = not main.Visible
    end

    -- F5 = Efecto
    if input.KeyCode == Enum.KeyCode.F5 then

        Settings.Enabled = not Settings.Enabled

        applyEffect()

        if Settings.Enabled then

            status.Text = "● EFFECT ON"
            status.TextColor3 =
                Color3.fromRGB(100, 220, 130)

        else

            status.Text = "● EFFECT OFF"
            status.TextColor3 =
                Color3.fromRGB(220, 100, 100)
        end
    end
end)

--==================================================
-- RESPAWN / PROTECCION
--==================================================

player.CharacterAdded:Connect(function()

    -- Esperar a que termine de cargar el personaje
    task.wait(1)

    applyEffect()
    removeOldEffects()

    task.wait(1)

    applyEffect()
end)

-- Si el juego elimina/reemplaza el efecto,
-- lo volvemos a aplicar.
Lighting.ChildRemoved:Connect(function(child)

    if child == effect then

        task.defer(function()

            task.wait()

            applyEffect()
        end)
    end
end)

-- Comprobación periódica
task.spawn(function()

    while task.wait(2) do

        if Settings.Enabled then
            applyEffect()
        end

    end
end)

print("Visual Filter cargado | F4 = Menu | F5 = Effect")
