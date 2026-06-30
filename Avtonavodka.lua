--[[
    АВТОНАВОДКА ДЛЯ ROBLOX (AIMBOT)
    Призначено для навчальних цілей у приватних іграх.
    ВИКОРИСТАННЯ В ПУБЛІЧНИХ ІГРАХ ЗАБОРОНЕНО ТА МОЖЕ ПРИЗВЕСТИ ДО БАНУ.
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Чекаємо, поки камера завантажиться
local Camera = workspace.CurrentCamera
if not Camera then
    repeat wait() until workspace.CurrentCamera
    Camera = workspace.CurrentCamera
end

-- Змінні стану
local AimbotEnabled = false
local Smoothness = 0.25 -- Плавність (0.1 - швидко, 0.5 - повільно, 1 - вимкнено)

-- Створення GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.IgnoreGuiInset = true

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 160, 0, 50)
Button.Position = UDim2.new(0, 20, 0, 20) -- Лівий верхній кут
Button.Text = "🔴 Aimbot OFF"
Button.TextColor3 = Color3.new(1, 1, 1)
Button.TextScaled = true
Button.BackgroundColor3 = Color3.new(0.7, 0.1, 0.1)
Button.BorderSizePixel = 2
Button.Parent = ScreenGui

-- Додаємо ефект наведення миші
local function updateButtonStyle()
    if AimbotEnabled then
        Button.Text = "🟢 Aimbot ON"
        Button.BackgroundColor3 = Color3.new(0.1, 0.7, 0.1)
    else
        Button.Text = "🔴 Aimbot OFF"
        Button.BackgroundColor3 = Color3.new(0.7, 0.1, 0.1)
    end
end

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
        
        -- Перевіряємо, чи живий гравець і чи є голова
        if not Head or not Humanoid or Humanoid.Health <= 0 then continue end
        
        -- Перевіряємо, чи видно гравця (променева перевірка)
        local RaycastParams = RaycastParams.new()
        RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        RaycastParams.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
        
        local Origin = Camera.CFrame.Position
        local Direction = (Head.Position - Origin).Unit * 1000
        local Hit = workspace:Raycast(Origin, Direction, RaycastParams)
        
        -- Якщо промінь влучив не в ціль, або влучив у щось інше (стіну) - пропускаємо
        if Hit and Hit.Instance and not Hit.Instance:IsDescendantOf(player.Character) then
            -- Можна закоментувати цю перевірку, щоб наводити крізь стіни (не радимо)
            -- continue
        end

        -- Перетворюємо позицію голови в екранні координати
        local ScreenPos, OnScreen = Camera:WorldToScreenPoint(Head.Position)
        if not OnScreen then continue end
        
        -- Обчислюємо відстань від центру
        local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude
        
        if Dist < BestDistance then
            BestDistance = Dist
            BestTarget = Head
        end
    end
    
    return BestTarget
end

-- Основний цикл автонаводки
local function onRender()
    if not AimbotEnabled then return end
    
    local Target = getClosestTarget()
    if not Target then return end
    
    -- Плавне наведення (Lerp)
    local CurrentCF = Camera.CFrame
    local TargetPos = Target.Position
    local NewCF = CFrame.new(CurrentCF.Position, TargetPos)
    
    -- Інтерполяція між поточним і цільовим CFrame
    Camera.CFrame = CurrentCF:Lerp(NewCF, Smoothness)
end

-- Підключення до RenderStepped
local RenderConnection = RunService.RenderStepped:Connect(onRender)

-- Обробка натискання кнопки
Button.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    updateButtonStyle()
    
    -- Візуальний зворотній зв'язок (вібрація кнопки)
    Button:TweenSize(UDim2.new(0, 150, 0, 45), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
    task.wait(0.1)
    Button:TweenSize(UDim2.new(0, 160, 0, 50), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
end)

-- Гаряча клавіша: [Tab] для ввімкнення/вимкнення
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Tab then
        AimbotEnabled = not AimbotEnabled
        updateButtonStyle()
    end
end)

-- Очищення при виході гравця (хороша практика)
LocalPlayer.AncestryChanged:Connect(function()
    if not LocalPlayer.Parent then
        RenderConnection:Disconnect()
        ScreenGui:Destroy()
    end
end)

-- Початкове оновлення стилю
updateButtonStyle()

print("Автонаводка завантажена! Натисніть [Tab] або кнопку GUI для перемикання.")
