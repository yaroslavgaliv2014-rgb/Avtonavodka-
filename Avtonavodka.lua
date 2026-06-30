-- GOD MODE GUI з анімацією та рухом
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer

-- Очікуємо персонажа
repeat wait() until lp.Character
local character = lp.Character
local humanoid = character:FindFirstChild("Humanoid")

if not humanoid then
    print("❌ Humanoid не знайдено!")
    return
end

-- Вимкнути смерть
humanoid.BreakJointsOnDeath = false

-- Створення GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GodModeGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = lp.PlayerGui

-- Основний фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 80)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -40)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.15
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Стиль (заокруглення + обводка)
local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(100, 200, 255)
stroke.Thickness = 2
stroke.Transparency = 0.6

-- Градієнтний фон
local gradient = Instance.new("UIGradient", mainFrame)
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 50)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 10, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 50))
})

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 30)
title.Position = UDim2.new(0, 15, 0, 5)
title.BackgroundTransparency = 1
title.Text = "💎 GOD MODE"
title.TextColor3 = Color3.fromRGB(180, 230, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- Кнопка закриття (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
closeBtn.BackgroundTransparency = 0.5
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = mainFrame

local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 6)

-- Кнопка відкриття (маленька іконка, коли GUI закрито)
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 50, 0, 50)
openBtn.Position = UDim2.new(0, 20, 0, 50)
openBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
openBtn.BackgroundTransparency = 0.3
openBtn.Text = "🛡️"
openBtn.TextSize = 24
openBtn.Visible = false
openBtn.Parent = screenGui

local openCorner = Instance.new("UICorner", openBtn)
openCorner.CornerRadius = UDim.new(1, 0)

-- Статус (онлайн / офлайн)
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -30, 0, 25)
status.Position = UDim2.new(0, 15, 0, 40)
status.BackgroundTransparency = 1
status.Text = "✅ Безсмертя АКТИВНЕ"
status.TextColor3 = Color3.fromRGB(100, 255, 150)
status.Font = Enum.Font.GothamMedium
status.TextSize = 14
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = mainFrame

-- Анімація появи (збільшення + прозорість)
mainFrame.BackgroundTransparency = 1
mainFrame.Size = UDim2.new(0, 200, 0, 60)
local fadeIn = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0.15,
    Size = UDim2.new(0, 260, 0, 80)
})
fadeIn:Play()

-- 🔥 GOD MODE ЛОГІКА
local godModeActive = true

RunService.RenderStepped:Connect(function()
    if godModeActive and humanoid and humanoid.Health < 99 then
        humanoid.Health = 100
    end
end)

humanoid.Died:Connect(function()
    if godModeActive then
        humanoid.Health = 100
        humanoid.BreakJointsOnDeath = false
        pcall(function()
            game:GetService("ReplicatedStorage"):FindFirstChild("Revive"):FireServer()
        end)
    end
end)

-- 🔄 ПЕРЕМИКАННЯ GOD MODE ПО КЛІКУ НА СТАТУС
status.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        godModeActive = not godModeActive
        if godModeActive then
            status.Text = "✅ Безсмертя АКТИВНЕ"
            status.TextColor3 = Color3.fromRGB(100, 255, 150)
            mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
            stroke.Color = Color3.fromRGB(100, 200, 255)
        else
            status.Text = "❌ Безсмертя ВИМКНЕНО"
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            mainFrame.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
            stroke.Color = Color3.fromRGB(255, 100, 100)
        end
    end
end)

-- ✕ ЗАКРИТТЯ
closeBtn.MouseButton1Click:Connect(function()
    local fadeOut = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 200, 0, 60)
    })
    fadeOut:Play()
    fadeOut.Completed:Connect(function()
        mainFrame.Visible = false
        openBtn.Visible = true
        local openAnim = TweenService:Create(openBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.3,
            Size = UDim2.new(0, 50, 0, 50)
        })
        openAnim:Play()
    end)
end)

-- 🛡️ ВІДКРИТТЯ
openBtn.MouseButton1Click:Connect(function()
    openBtn.Visible = false
    mainFrame.Visible = true
    mainFrame.BackgroundTransparency = 1
    mainFrame.Size = UDim2.new(0, 200, 0, 60)
    local openAnim = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.15,
        Size = UDim2.new(0, 260, 0, 80)
    })
    openAnim:Play()
end)

-- 🖱️ ПЕРЕТЯГУВАННЯ
local dragging = false
local dragStart = nil
local startPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

print("✅ God Mode GUI завантажено! Клікни на статус, щоб вмикати/вимикати.")
