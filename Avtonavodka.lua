-- ОНОВЛЕНИЙ СКРИПТ: ДОДАНО GOD MODE
local v0=game:GetService("Players");local v1=v0.LocalPlayer;local v2=game:GetService("UserInputService");local v3=game:GetService("RunService");local v4=workspace.CurrentCamera;local v5={AimEnabled=false,AimPart="Head",TeamCheck=true,WallCheck=false,Ignore096=true,AimbotFOV=450,ESP_Enabled=false,Speed=16,ShowWallUI=false};

-- 🔥 ЗМІННІ ДЛЯ ФІКСАЦІЇ ТА РУХУ
local lockedTarget = nil
local isLocked = false
local isMoving = false
local godModeEnabled = false  -- НОВА ЗМІННА ДЛЯ GOD MODE

-- ВІДСЛІДКОВУЄМО НАТИСКАННЯ КЛАВІШ РУХУ (WASD)
v2.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.A or 
       input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.D then
        isMoving = true
    end
end)

v2.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.A or 
       input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.D then
        isMoving = false
    end
end)

local function v6(v58,v59)
    if ( not v58 or  not v59 or (v58=="") or (v59=="")) then return false;end
    if ((v58=="Global Occult Coalition") or (v59=="Global Occult Coalition")) then return v58==v59 ;end
    if (v58==v59) then return true;end
    local v60={["Class-D"]={["Chaos Insurgency"]=true},["Chaos Insurgency"]={["Class-D"]=true},["Foundation Personnel"]={["Mobile Task Forces"]=true,["Security Department"]=true},["Mobile Task Forces"]={["Foundation Personnel"]=true,["Security Department"]=true},["Security Department"]={["Foundation Personnel"]=true,["Mobile Task Forces"]=true},["Serpents Hand"]={SCP=true},SCP={["Serpents Hand"]=true}};
    return (v60[v58] and v60[v58][v59]) or false ;
end

-- ФУНКЦІЯ ПОШУКУ ЦІЛІ (З ФІКСАЦІЄЮ)
local function v7()
    if lockedTarget and lockedTarget.Character and lockedTarget.Character:FindFirstChild("Humanoid") and lockedTarget.Character.Humanoid.Health > 0 then
        local v115 = lockedTarget.Character
        local aimPart = v115:FindFirstChild(v5.AimPart) or v115:FindFirstChild("HumanoidRootPart")
        if aimPart then
            return aimPart
        end
    end
    
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

-- GUI
local v8=Instance.new("ScreenGui",v1.PlayerGui);v8.Name="OmnimanTrue";v8.IgnoreGuiInset=true;v8.ResetOnSpawn=false;

local function v12(v63)
    local v64,v65,v66;
    v63.InputBegan:Connect(function(v103)
        if ((v103.UserInputType==Enum.UserInputType.MouseButton1) or (v103.UserInputType==Enum.UserInputType.Touch)) then
            v64=true;v66=v103.Position;v65=v63.Position;
        end
    end);
    v2.InputChanged:Connect(function(v104)
        if (v64 and ((v104.UserInputType==Enum.UserInputType.MouseMovement) or (v104.UserInputType==Enum.UserInputType.Touch))) then
            local v119=v104.Position-v66 ;
            v63.Position=UDim2.new(v65.X.Scale,v65.X.Offset + v119.X ,v65.Y.Scale,v65.Y.Offset + v119.Y );
        end
    end);
    v63.InputEnded:Connect(function() v64=false;end);
end

local v13={};
local function v14(v67,v68)
    local v69=Instance.new("UIGradient",v67);
    if v68 then
        v69.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(25,0,50)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(10,0,20)),ColorSequenceKeypoint.new(1,Color3.fromRGB(25,0,50))});
    else
        v69.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(180,100,255)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(180,100,255))});
    end
    table.insert(v13,v69);
end

local function v15(v70,v71,v72,v73)
    local v74=Instance.new("TextButton",v70);
    v74.Size=v71;v74.Position=v72;v74.BackgroundColor3=Color3.new(1,1,1);v74.Text="";
    Instance.new("UICorner",v74);v14(v74,true);
    local v79=Instance.new("TextLabel",v74);
    v79.Size=UDim2.new(1,0,1,0);v79.BackgroundTransparency=1;v79.Text=v73;v79.TextColor3=Color3.new(1,1,1);v79.Font="GothamBold";v79.TextSize=14;v14(v79,false);
    return v74,v79;
end

local v16=Instance.new("Frame",v8);
v16.Active=true;v16.Size=UDim2.new(0,240,0,360);v16.Position=UDim2.new(0.5, -120,0.5, -180);
v16.BackgroundColor3=Color3.new(1,1,1);
Instance.new("UICorner",v16);v12(v16);
Instance.new("UIStroke",v16).Color=Color3.fromRGB(150,50,255);
v14(v16,true);

local v22=Instance.new("TextLabel",v16);
v22.Size=UDim2.new(1,0,0,40);v22.BackgroundTransparency=1;v22.Text="Omniman | Breach";v22.TextColor3=Color3.new(1,1,1);v22.Font="GothamBold";v22.TextSize=18;v14(v22,false);

local v29=Instance.new("ScrollingFrame",v16);
v29.Size=UDim2.new(1, -20,1, -60);v29.Position=UDim2.new(0,10,0,45);
v29.BackgroundTransparency=1;v29.ScrollBarThickness=0;
local listLayout = Instance.new("UIListLayout",v29)
listLayout.Padding = UDim.new(0,5)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- 📌 ФУНКЦІЯ СТВОРЕННЯ КНОПОК (ДЛЯ ВСІХ)
local function createButton(text, configKey, order)
    local btn, label = v15(v29, UDim2.new(1,0,0,35), UDim2.new(0,0,0,0), text .. ": OFF")
    btn.LayoutOrder = order
    btn.MouseButton1Click:Connect(function()
        v5[configKey] = not v5[configKey]
        label.Text = text .. ": " .. ((v5[configKey] and "ON") or "OFF")
    end)
    return btn, label
end

-- КНОПКИ В ПОРЯДКУ
-- SPEED (окремо)
local speedBox = Instance.new("TextBox", v29)
speedBox.Size = UDim2.new(1,0,0,35)
speedBox.BackgroundColor3 = Color3.fromRGB(0,0,0)
speedBox.BackgroundTransparency = 0.6
speedBox.Text = "Speed: 16"
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.Font = "GothamBold"
speedBox.TextSize = 14
speedBox.LayoutOrder = 1
v14(speedBox)
Instance.new("UICorner", speedBox)
speedBox.FocusLost:Connect(function() v5.Speed = tonumber(speedBox.Text:match("%d+")) or 16 end)

-- ІНШІ КНОПКИ
createButton("Aimbot Master", "AimEnabled", 2)
createButton("Visuals ESP", "ESP_Enabled", 3)

-- 🔥 НОВІ КНОПКИ LOCK / UNLOCK
local lockBtn, lockLabel = v15(v29, UDim2.new(1,0,0,35), UDim2.new(0,0,0,0), "🔒 Lock")
lockBtn.LayoutOrder = 4
lockLabel.Text = "🔒 Lock"

local unlockBtn, unlockLabel = v15(v29, UDim2.new(1,0,0,35), UDim2.new(0,0,0,0), "🔓 Unlock")
unlockBtn.LayoutOrder = 5
unlockLabel.Text = "🔓 Unlock"

-- 🛡️ НОВА КНОПКА GOD MODE
local godBtn, godLabel = v15(v29, UDim2.new(1,0,0,35), UDim2.new(0,0,0,0), "God Mode: OFF")
godBtn.LayoutOrder = 6

-- ЛОГІКА GOD MODE (ЗМІННА godModeEnabled ВЖЕ Є)
godBtn.MouseButton1Click:Connect(function()
    godModeEnabled = not godModeEnabled
    if godModeEnabled then
        godLabel.Text = "God Mode: ON"
        godBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        print("🛡️ God Mode ACTIVATED")
        -- Запускаємо захист
        EnableGodMode()
    else
        godLabel.Text = "God Mode: OFF"
        godBtn.BackgroundColor3 = Color3.new(1,1,1)
        print("🛡️ God Mode DEACTIVATED")
        DisableGodMode()
    end
end)

-- ЛОГІКА LOCK
lockBtn.MouseButton1Click:Connect(function()
    local currentTarget = v7()
    if currentTarget then
        for _, player in pairs(v0:GetPlayers()) do
            if player ~= v1 and player.Character then
                local part = player.Character:FindFirstChild(v5.AimPart) or player.Character:FindFirstChild("HumanoidRootPart")
                if part == currentTarget then
                    lockedTarget = player
                    isLocked = true
                    lockLabel.Text = "✅ Locked: " .. player.Name
                    lockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                    print("🎯 Зафіксовано гравця:", player.Name)
                    break
                end
            end
        end
    else
        print("⚠️ Немає цілі для фіксації!")
    end
end)

-- ЛОГІКА UNLOCK
unlockBtn.MouseButton1Click:Connect(function()
    lockedTarget = nil
    isLocked = false
    lockLabel.Text = "🔒 Lock"
    lockBtn.BackgroundColor3 = Color3.new(1,1,1)
    print("🔓 Фіксацію знято")
end)

-- КНОПКА ЗАКРИТТЯ
local v51=Instance.new("TextButton",v16);
v51.Size=UDim2.new(0,30,0,30);v51.Position=UDim2.new(1, -35,0,5);
v51.Text="X";v51.BackgroundColor3=Color3.new(0,0,0);v51.BackgroundTransparency=0.5;v51.TextColor3=Color3.new(1,1,1);
Instance.new("UICorner",v51);v14(v51,false);
local v47,v48=v15(v8,UDim2.new(0,110,0,40),UDim2.new(0.5, -55,0,50),"Omniman");
v47.Visible=false;v12(v47);Instance.new("UIStroke",v47).Color=Color3.fromRGB(150,50,255);
v51.MouseButton1Click:Connect(function() v16.Visible=false;v47.Visible=true;end);
v47.MouseButton1Click:Connect(function() v16.Visible=true;v47.Visible=false;end);

-- =====================================================
-- 🛡️ ФУНКЦІЇ GOD MODE
-- =====================================================
local godConnections = {}  -- Масив для зберігання підключень

function EnableGodMode()
    -- Отримуємо персонажа та Humanoid
    local char = v1.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    
    -- Метод 1: Блокування функції TakeDamage
    if not hum._oldTakeDamage then
        hum._oldTakeDamage = hum.TakeDamage
        hum.TakeDamage = function(self, amount)
            if godModeEnabled then
                return nil  -- Ігноруємо пошкодження
            end
            return self._oldTakeDamage(self, amount)
        end
    end
    
    -- Метод 2: Миттєве відновлення здоров'я (кожен кадр)
    local conn1 = v3.RenderStepped:Connect(function()
        if godModeEnabled and hum and hum.Health < 100 then
            hum.Health = 100
            -- Спроба скинути статус падіння
            if hum:FindFirstChild("HumanoidRootPart") then
                hum.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end)
    table.insert(godConnections, conn1)
    
    -- Метод 3: Захист від смерті
    local conn2 = hum.Died:Connect(function()
        if godModeEnabled then
            hum.Health = 100
            hum.BreakJointsOnDeath = false
            -- Спроба воскреснути через ReplicatedStorage
            pcall(function()
                local rs = game:GetService("ReplicatedStorage")
                if rs:FindFirstChild("Revive") then rs.Revive:FireServer() end
                if rs:FindFirstChild("Respawn") then rs.Respawn:FireServer() end
                if rs:FindFirstChild("Character") then rs.Character:FireServer() end
            end)
        end
    end)
    table.insert(godConnections, conn2)
    
    -- Метод 4: Скидання швидкості падіння (щоб уникнути шкоди від падіння)
    local conn3 = v3.Heartbeat:Connect(function()
        if godModeEnabled and char and char:FindFirstChild("HumanoidRootPart") then
            local vel = char.HumanoidRootPart.Velocity
            if vel.Y < -30 then  -- Якщо швидкість падіння занадто велика
                char.HumanoidRootPart.Velocity = Vector3.new(vel.X, -10, vel.Z)  -- Обмежуємо
            end
        end
    end)
    table.insert(godConnections, conn3)
end

function DisableGodMode()
    -- Відключаємо всі підключення
    for _, conn in ipairs(godConnections) do
        conn:Disconnect()
    end
    godConnections = {}
    
    -- Відновлюємо TakeDamage
    local char = v1.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum and hum._oldTakeDamage then
            hum.TakeDamage = hum._oldTakeDamage
            hum._oldTakeDamage = nil
        end
    end
end

-- ESP
v3.Heartbeat:Connect(function()
    local v100=tick();
    for v107,v108 in pairs(v13) do v108.Rotation=math.sin(v100 * 1.5 ) * 60 ;end
    if v5.ESP_Enabled then
        for v121,v122 in pairs(v0:GetPlayers()) do
            if ((v122~=v1) and v122.Character) then
                local v128=v122.Character:FindFirstChild("OmniHL") or Instance.new("Highlight",v122.Character) ;
                v128.Name="OmniHL";v128.Enabled=true;v128.FillColor=v122.TeamColor.Color;v128.OutlineColor=Color3.new(1,1,1);v128.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;
            end
        end
    else
        for v123,v124 in pairs(v0:GetPlayers()) do
            if (v124.Character and v124.Character:FindFirstChild("OmniHL")) then v124.Character.OmniHL:Destroy();end
        end
    end
end);

-- ОСНОВНИЙ ЦИКЛ З ФІКСОМ ХОДИ
v3.RenderStepped:Connect(function()
    if v5.AimEnabled then
        local targetPart = v7()
        if targetPart and not isMoving then
            v4.CFrame = CFrame.new(v4.CFrame.Position, targetPart.Position)
        end
    end
    if (v1.Character and v1.Character:FindFirstChild("Humanoid")) then
        v1.Character.Humanoid.WalkSpeed = v5.Speed
    end
end)

print("✅ Оновлений скрипт: додано God Mode! Використовуй кнопку в меню.")
