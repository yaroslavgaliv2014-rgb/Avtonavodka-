--[[
    РОБОЧА АВТОНАВОДКА ДЛЯ БУДЬ-ЯКОЇ КАМЕРИ (з фіксом Scriptable)
    Встановлює повний контроль над камерою, поки бот активний.
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Camera = workspace.CurrentCamera
if not Camera then repeat wait() until workspace.CurrentCamera; Camera = workspace.CurrentCamera end

-- Зберігаємо тип камери, який був до включення бота (щоб повернути як було)
local OriginalCameraType = Camera.CameraType

-- Змінні
local AimbotEnabled = false
local Smoothness = 0.25 -- Плавність (0.1 - різко, 0.5 - плавно)

-- Функція пошуку найближчого гравця до центру екрану
local function getClosestTarget()
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local BestTarget = nil
    local BestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        local Head = player.Character:FindFirstChild("Head")
        local Humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not Head or not Humanoid or Humanoid.Health <= 0 then continue end
        
        -- Перевірка видимості (опціонально, прибираємо коментар щоб ввімкнути анти-стіни)
        --[[
        local RaycastParams = RaycastParams.new()
        RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        RaycastParams.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
        local Origin = Camera.CFrame.Position
        local Direction = (Head.Position - Origin).Unit * 1000
        local Hit = workspace:Raycast(Origin, Direction, RaycastParams)
        if Hit and Hit.Instance and not Hit.Instance:IsDescendantOf(player.Character) then
            -- continue
        end
        ]]

        local ScreenPos, OnScreen = Camera:WorldToScreenPoint(Head.Position)
        if not OnScreen then continue end
        
        local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude
        if Dist < BestDistance then
            BestDistance = Dist
            BestTarget = Head
        end
    end
    
    return BestTarget
end

-- ГОЛОВНИЙ ЦИКЛ (тепер з примусовим Scriptable)
local function onRender()
    if not AimbotEnabled then
        -- Якщо бот вимкнено, повертаємо камеру в звичайний режим (якщо вона ще в Scriptable)
        if Camera.CameraType == Enum.CameraType.Scriptable then
            Camera.CameraType = OriginalCameraType
        end
        return
    end
    
    -- КЛЮЧОВИЙ ФІКС: Переводимо камеру в ручний режим (це блокує всі зовнішні скрипти)
    -- Робимо це КОЖЕН КАДР, бо гра може намагатись змінити тип назад.
    Camera.CameraType = Enum.CameraType.Scriptable
    
    local Target = getClosestTarget()
    if not Target then return end
    
    -- Наводимось плавно
    local CurrentCF = Camera.CFrame
    local TargetPos = Target.Position
    local NewCF = CFrame.new(CurrentCF.Position, TargetPos)
    
    Camera.CFrame = CurrentCF:Lerp(NewCF, Smoothness)
end

-- Підключення до рендеру
local RenderConnection = RunService.RenderStepped:Connect(onRender)

-- ========== СТВОРЕННЯ ГАРНОГО GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.IgnoreGuiInset = true

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 160, 0, 50)
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

-- Натискання кнопки
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

-- Якщо гравець вийшов - прибираємо за собою
LocalPlayer.AncestryChanged:Connect(function()
    if not LocalPlayer.Parent then
        RenderConnection:Disconnect()
        ScreenGui:Destroy()
    end
end)

updateButtonStyle()
print("✅ Автонаводка завантажена! Натисніть [Tab] або кнопку. (Режим Scriptable активується автоматично)")
