-- УНІВЕРСАЛЬНИЙ GOD MODE (намагається працювати скрізь)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

repeat wait() until lp.Character
local char = lp.Character
local hum = char:FindFirstChild("Humanoid")

if not hum then print("❌ Humanoid не знайдено"); return end

-- Вимкнути смерть
hum.BreakJointsOnDeath = false

-- Головний цикл
RunService.RenderStepped:Connect(function()
    if hum.Health < 99 then
        hum.Health = 100
    end
end)

-- Блокуємо смерть
hum.Died:Connect(function()
    hum.Health = 100
    hum.BreakJointsOnDeath = false
    pcall(function()
        -- Спроба воскресити через різні способи
        local rs = game:GetService("ReplicatedStorage")
        if rs:FindFirstChild("Revive") then rs.Revive:FireServer() end
        if rs:FindFirstChild("Respawn") then rs.Respawn:FireServer() end
        if rs:FindFirstChild("Character") then rs.Character:FireServer() end
        char:BreakJoints()
    end)
end)

print("✅ GOD MODE ЗАПУЩЕНО!")
