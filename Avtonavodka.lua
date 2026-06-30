--[[
    ПОКРАЩЕНА АВТОНАВОДКА (точне наведення + резервна ціль)
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Camera = workspace.CurrentCamera
if not Camera then repeat wait() until workspace.CurrentCamera; Camera = workspace.CurrentCamera end

local OriginalCameraType = Camera.CameraType

local AimbotEnabled = false
local Smoothness = 0.08  -- <-- ЗМІНЕНО: майже миттєве наведення (було 0.25)

-- Функція пошуку найближчого гравця (тепер цілиться в голову або центр тіла)
local function getClosestTarget()
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local BestTarget = nil
    local BestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        -- Спершу шукаємо голову
        local TargetPart = player.Character:FindFirstChild("Head")
        -- Якщо голови немає (наприклад, персонаж без голови) – беремо HumanoidRootPart
        if not TargetPart then
            TargetPart = player.Character:FindFirstChild("HumanoidRootPart")
        end
        if not TargetPart then continue end

        local Humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not Humanoid or Humanoid.Health <= 0 then continue end

        -- ПЕРЕВІРКА СТІН - зараз вимкнена (щоб наводити крізь усе)
        -- Якщо хочеш ввімкнути анти-стіни - розкоментуй наступний блок
        --[[
        local RaycastParams = RaycastParams.new()
        RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        RaycastParams.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
        local Origin = Camera.CFrame.Position
        local Direction = (TargetPart.Position - Origin).Unit * 1000
        local Hit = workspace:Raycast(Origin, Direction, RaycastParams)
        if Hit and Hit.Instance and not Hit.Instance:IsDescendantOf(player.Character) then
            continue
        end
        ]]

        local ScreenPos, OnScreen = Camera:WorldToScreenPoint(TargetPart.Position)
        if not OnScreen then continue end
        
        local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude
        if Dist < BestDistance then
            BestDistance = Dist
            BestTarget = TargetPart
        end
    end
    
    return BestTarget
end

-- Основний цикл
local function onRender()
    if not AimbotEnabled then
        if Camera.CameraType == Enum.CameraType.Scriptable then
            Camera.CameraType = OriginalCameraType
        end
        return
    end
    
    Camera.CameraType = Enum.CameraType.Scriptable  -- Фіксуємо камеру кожен кадр
    
    local Target = getClosestTarget()
    if not Target then
        -- Якщо цілі немає, оновлюємо текст кнопки
        Button.Text = "🔴 Немає цілі"
        return
    end
    
    -- Оновлюємо текст кнопки з ім'ям гравця (для наочності)
    local playerName = "Невідомий"
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and Target:IsDescendantOf(plr.Character) then
            playerName = plr.Name
            break
        end
    end
    Button.Text = "🎯 " .. playerName
    
    -- Плавне наведення
    local CurrentCF = Camera.CFrame
    local TargetPos = Target.Position
    local NewCF = CFrame.new(CurrentCF.Position, TargetPos)
    
    Camera.CFrame = CurrentCF:Lerp(NewCF, Smoothness)
end

local RenderConnection = RunService.RenderStepped:Connect(onRender)

-- ========== GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.IgnoreGuiInset = true

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 200, 0, 50)  -- трохи ширше, щоб вміщало ім'я
Button.Position = UDim2.new(0, 20, 0, 20)
Button.Text = "🔴 Aimbot OFF"
Button.TextColor3 = Color3.new(1, 1, 1)
Button.TextScaled = true
Button.BackgroundColor3 = Color3.new(0.7, 0.1, 0.1)
Button.BorderSizePixel = 2
Button.Parent = ScreenGui

local function updateButtonStyle()
    if AimbotEnabled then
        Button.BackgroundColor3 = Color3.new(0.1, 0.7, 0.1)
    else
        Button.Text = "🔴 Aimbot OFF"
        Button.BackgroundColor3 = Color3.new(0.7, 0.1, 0.1)
    end
end

Button.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    if not AimbotEnabled then
        Button.Text = "🔴 Aimbot OFF"
    end
    updateButtonStyle()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Tab then
        AimbotEnabled = not AimbotEnabled
        if not AimbotEnabled then
            Button.Text = "🔴 Aimbot OFF"
        end
        updateButtonStyle()
    end
end)

LocalPlayer.AncestryChanged:Connect(function()
    if not LocalPlayer.Parent then
        RenderConnection:Disconnect()
        ScreenGui:Destroy()
    end
end)

updateButtonStyle()
print("✅ Автонаводка завантажена! Натисніть [Tab] або кнопку. Наводиться чітко в голову/тіло.")
