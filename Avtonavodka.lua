-- ОРИГІНАЛЬНИЙ СКРИПТ OMNIMAN, АЛЕ З ФІКСОВАНОЮ ЦІЛЛЮ
local v0=game:GetService("Players");local v1=v0.LocalPlayer;local v2=game:GetService("UserInputService");local v3=game:GetService("RunService");local v4=workspace.CurrentCamera;local v5={AimEnabled=false,AimPart="Head",TeamCheck=true,WallCheck=false,Ignore096=true,AimbotFOV=450,ESP_Enabled=false,Speed=16,ShowWallUI=false};
-- 🔥 НОВА ЗМІННА: ЗАФІКСОВАНИЙ ГРАВЕЦЬ
local lockedTarget = nil
local isLocked = false

-- ФУНКЦІЯ ПОШУКУ ЦІЛІ (З ФІКСАЦІЄЮ)
local function v7()
    -- ЯКЩО Є ЗАФІКСОВАНИЙ ГРАВЕЦЬ І ВІН ЖИВИЙ - ЦІЛИМОСЬ У НЬОГО
    if lockedTarget and lockedTarget.Character and lockedTarget.Character:FindFirstChild("Humanoid") and lockedTarget.Character.Humanoid.Health > 0 then
        local v115 = lockedTarget.Character
        local aimPart = v115:FindFirstChild(v5.AimPart) or v115:FindFirstChild("HumanoidRootPart")
        if aimPart then
            return aimPart
        end
    end
    
    -- ЯКЩО ФІКСАЦІЇ НЕМАЄ - ШУКАЄМО НАЙБЛИЖЧОГО (ЯК У ОРИГІНАЛІ)
    local v61,v62=nil,math.huge;
    for v101,v102 in pairs(v0:GetPlayers()) do 
        if ((v102~=v1) and v102.Character) then 
            local v115=v102.Character;
            if (v5.Ignore096 and (v115.Name=="SCP-096")) then continue;end 
            if (v5.TeamCheck and v6((v1.Team and v1.Team.Name) or "" ,(v102.Team and v102.Team.Name) or "" )) then continue;end 
            local v116=v115:FindFirstChild(v5.AimPart) or v115:FindFirstChild("HumanoidRootPart") ;
            if v116 then 
                local v126,v127=v4:WorldToViewportPoint(v116.Position);
                if v127 then 
                    local v136=(v1.Character and v1.Character:FindFirstChild("HumanoidRootPart") and (v116.Position-v1.Character.HumanoidRootPart.Position).Magnitude) or 1000 ;
                    if (v136<v62) then 
                        if v5.WallCheck then 
                            local v137=Ray.new(v4.CFrame.Position,(v116.Position-v4.CFrame.Position).Unit * 500 );
                            if workspace:FindPartOnRayWithIgnoreList(v137,{v1.Character,v115}) then continue;end 
                        end 
                        v62=v136;v61=v116;
                    end 
                end 
            end 
        end 
    end 
    return v61;
end

-- ... (ВЕСЬ ІНШИЙ КОД GUI, ЯКИЙ БУВ У ОРИГІНАЛІ, ЗАЛИШАЄТЬСЯ БЕЗ ЗМІН) ...
-- ВСТАВ ТУТ ВЕСЬ ОРИГІНАЛЬНИЙ КОД ДО РЯДКА v3.RenderStepped

-- 🔄 ЗМІНЮЄМО ОСНОВНИЙ ЦИКЛ, ЩОБ ВИКОРИСТОВУВАТИ НОВУ ФУНКЦІЮ
v3.RenderStepped:Connect(function() 
    if v5.AimEnabled then 
        local v112 = v7()  -- ВИКОРИСТОВУЄМО НОВУ ФУНКЦІЮ З ФІКСАЦІЄЮ
        if v112 then 
            v4.CFrame = CFrame.new(v4.CFrame.Position, v112.Position);
        end 
    end 
    if (v1.Character and v1.Character:FindFirstChild("Humanoid")) then 
        v1.Character.Humanoid.WalkSpeed=v5.Speed;
    end 
end);

-- 🎯 КНОПКИ ДЛЯ КЕРУВАННЯ ФІКСАЦІЄЮ
local function CreateLockButtons()
    local gui = v1.PlayerGui:FindFirstChild("OmnimanTrue")
    if not gui then return end
    
    local frame = gui:FindFirstChildOfClass("Frame")
    if not frame then return end
    
    -- КНОПКА "ЗАФІКСУВАТИ" (LOCK)
    local lockBtn = Instance.new("TextButton", frame)
    lockBtn.Size = UDim2.new(0, 100, 0, 30)
    lockBtn.Position = UDim2.new(0, 10, 0, 220)
    lockBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    lockBtn.Text = "🔒 Lock"
    lockBtn.TextColor3 = Color3.new(1,1,1)
    lockBtn.Font = Enum.Font.GothamBold
    lockBtn.TextSize = 14
    Instance.new("UICorner", lockBtn)
    
    -- КНОПКА "ЗНЯТИ ФІКСАЦІЮ" (UNLOCK)
    local unlockBtn = Instance.new("TextButton", frame)
    unlockBtn.Size = UDim2.new(0, 100, 0, 30)
    unlockBtn.Position = UDim2.new(0, 120, 0, 220)
    unlockBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
    unlockBtn.Text = "🔓 Unlock"
    unlockBtn.TextColor3 = Color3.new(1,1,1)
    unlockBtn.Font = Enum.Font.GothamBold
    unlockBtn.TextSize = 14
    Instance.new("UICorner", unlockBtn)
    
    -- ЛОГІКА LOCK: ЗАФІКСОВУЄМО ПОТОЧНУ ЦІЛЬ
    lockBtn.MouseButton1Click:Connect(function()
        local currentTarget = v7() -- Шукаємо поточну ціль
        if currentTarget then
            -- Шукаємо гравця, якому належить ця частина тіла
            for _, player in pairs(v0:GetPlayers()) do
                if player ~= v1 and player.Character then
                    local part = player.Character:FindFirstChild(v5.AimPart) or player.Character:FindFirstChild("HumanoidRootPart")
                    if part == currentTarget then
                        lockedTarget = player
                        isLocked = true
                        lockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                        lockBtn.Text = "✅ Locked"
                        print("🎯 Зафіксовано гравця:", player.Name)
                        break
                    end
                end
            end
        else
            print("⚠️ Немає цілі для фіксації!")
        end
    end)
    
    -- ЛОГІКА UNLOCK: ЗНІМАЄМО ФІКСАЦІЮ
    unlockBtn.MouseButton1Click:Connect(function()
        lockedTarget = nil
        isLocked = false
        lockBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        lockBtn.Text = "🔒 Lock"
        print("🔓 Фіксацію знято")
    end)
end

-- ВИКЛИКАЄМО ФУНКЦІЮ СТВОРЕННЯ КНОПОК (З НЕВЕЛИКОЮ ЗАТРИМКОЮ)
task.wait(0.5)
CreateLockButtons()

print("✅ Оновлений скрипт з фіксацією цілі завантажено!")
print("🎯 Натисни 'Lock', щоб зафіксувати поточного ворога")
print("🔓 Натисни 'Unlock', щоб зняти фіксацію")
