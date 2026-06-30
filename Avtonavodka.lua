--[[
    УНІВЕРСАЛЬНА АВТОНАВОДКА (емуляція миші)
    Працює навіть якщо гра блокує CFrame камери.
    Натисніть [Tab] або кнопку GUI для вмикання/вимикання.
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Camera = workspace.CurrentCamera
if not Camera then repeat wait() until workspace.CurrentCamera; Camera = workspace.CurrentCamera end

local AimbotEnabled = false
local Smoothness = 0.15  -- Плавність (0.1 - швидко, 0.3 - плавно)

-- Отримуємо об'єкт миші
local Mouse = LocalPlayer:GetMouse()

-- Пошук найближчого гравця до центру екрану
local function getClosestTarget()
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local BestTarget = nil
    local BestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end

        -- Шукаємо голову, якщо немає - беремо центр тіла
        local TargetPart = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
        if not TargetPart then continue end

        local Humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not Humanoid or Humanoid.Health <= 0 then continue end

        -- Отримуємо координати на екрані
        local ScreenPos, OnScreen = Camera:WorldToScreenPoint(TargetPart.Position)
        if not OnScreen then continue end

        -- Відстань від центру
        local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude
        if Dist < BestDistance then
            BestDistance = Dist
            BestTarget = {ScreenPos, player}
        end
    end

    return BestTarget
end

-- Головний цикл (виконується кожен кадр)
local function onRender()
    if not AimbotEnabled then return end

    local Target = getClosestTarget()
    if not Target then return end

    local ScreenPos = Target[1]
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Обчислюємо, на скільки пікселів потрібно зрушити мишу
    local DeltaX = (ScreenPos.X - Center.X) * Smoothness
    local DeltaY = (ScreenPos.Y - Center.Y) * Smoothness

    -- Емулюємо рух миші (основна магія!)
    Mouse.Move(DeltaX, DeltaY)
end

RunService.RenderStepped:Connect(onRender)

-- ===== ГРАФІЧНИЙ ІНТЕРФЕЙС =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.IgnoreGuiInset = true

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 200, 0, 50)
Button.Position = UDim2.new(0, 20, 0, 20)
Button.Text = "🔴 Aimbot OFF"
Button.TextColor3 = Color3.new(1, 1, 1)
Button.TextScaled = true
Button.BackgroundColor3 = Color3.new(0.7, 0.1, 0.1)
Button.BorderSizePixel = 2
Button.Parent = ScreenGui

local function updateButtonStyle()
    if AimbotEnabled then
        Button.Text = "🟢 Aimbot ON"
        Button.BackgroundColor3 = Color3.new(0.1, 0.7, 0.1)
    else
        Button.Text = "🔴 Aimbot OFF"
        Button.BackgroundColor3 = Color3.new(0.7, 0.1, 0.1)
    end
end

-- Натискання кнопки мишею
Button.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    updateButtonStyle()
end)

-- Гаряча клавіша [Tab]
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Tab then
        AimbotEnabled = not AimbotEnabled
        updateButtonStyle()
    end
end)

updateButtonStyle()
print("✅ Автонаводка завантажена! Натисніть [Tab] для перемикання.")
