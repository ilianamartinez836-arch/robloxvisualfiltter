```lua
--// VISUAL COLOR FILTER
--// Brightness / Saturation / Contrast / Temperature
--// F4 = Mostrar/Ocultar menú
--// F5 = Activar/Desactivar efecto

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- LIMPIAR VERSIONES ANTERIORES
--==================================================

pcall(function()
    Lighting:FindFirstChild("CustomVisualFilter"):Destroy()
end)

pcall(function()
    playerGui:FindFirstChild("VisualFilterMenu"):Destroy()
end)

--==================================================
-- EFECTO
--==================================================

local effect = Instance.new("ColorCorrectionEffect")
effect.Name = "CustomVisualFilter"
effect.Brightness = 0
effect.Contrast = 0
effect.Saturation = 0
effect.TintColor = Color3.fromRGB(255, 255, 255)
effect.Enabled = true
effect.Parent = Lighting

--==================================================
-- GUI
--==================================================

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
-- SLIDER CREATOR
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

        local percent = (value - minValue) / (maxValue - minValue)

        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, 0, 0.5, 0)

        valueLabel.Text = string.format("%.2f", value)

        callback(value)
    end

    local function updateFromMouse(x)
        local percent = math.clamp(
            (x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,
            0,
            1
        )

        local value = minValue + ((maxValue - minValue) * percent)
        setValue(value)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateFromMouse(input.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromMouse(input.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    setValue(defaultValue)

    return setValue
end

--==================================================
-- CONFIGURACIONES
--==================================================

local brightness = 0
local contrast = 0
local saturation = 0

local temperature = 0

createSlider(
    "Brightness",
    -1,
    1,
    0,
    function(value)
        brightness = value
        effect.Brightness = value
    end
)

createSlider(
    "Contrast",
    -1,
    1,
    0,
    function(value)
        contrast = value
        effect.Contrast = value
    end
)

createSlider(
    "Saturation",
    -1,
    1,
    0,
    function(value)
        saturation = value
        effect.Saturation = value
    end
)

createSlider(
    "Temperature",
    -1,
    1,
    0,
    function(value)
        temperature = value

        -- Frío -> azul
        -- Cálido -> amarillo/naranja

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
)

--==================================================
-- BOTON RESET
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
    effect.Brightness = 0
    effect.Contrast = 0
    effect.Saturation = 0
    effect.TintColor = Color3.fromRGB(255, 255, 255)

    -- Recrear GUI para que los sliders vuelvan a 0
    gui:Destroy()

    task.wait()

    -- Ejecutar nuevamente el script no es necesario;
    -- los valores visuales ya fueron restaurados.
end)

--==================================================
-- ESTADO
--==================================================

local enabled = true

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

    -- F4 = ocultar/mostrar menú
    if input.KeyCode == Enum.KeyCode.F4 then
        main.Visible = not main.Visible
    end

    -- F5 = activar/desactivar efecto
    if input.KeyCode == Enum.KeyCode.F5 then
        enabled = not enabled
        effect.Enabled = enabled

        if enabled then
            status.Text = "● EFFECT ON"
            status.TextColor3 = Color3.fromRGB(100, 220, 130)
        else
            status.Text = "● EFFECT OFF"
            status.TextColor3 = Color3.fromRGB(220, 100, 100)
        end
    end
end)

print("Visual Filter cargado | F4 = Menu | F5 = Effect")
```
