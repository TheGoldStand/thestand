--[[
    MM2 FULL MENU: AutoFarm, Fly, Fling, Speed, Jump, Role ESP
    Для Delta Executor
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ===== GUI создание =====
local gui = Instance.new("ScreenGui")
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 360)
mainFrame.Position = UDim2.new(0.5, -130, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = false

-- скругление углов
local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 10)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
header.BorderSizePixel = 0
local headerCorner = Instance.new("UICorner", header)
headerCorner.CornerRadius = UDim.new(0, 10)
local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -10, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "MM2 Script | draggable"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 14
title.Font = Enum.Font.SourceSansBold
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

-- Drag системы
local dragging = false
local dragStart = nil
local startPos = nil
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

mainFrame.Parent = gui
header.Parent = mainFrame

-- Функция создания кнопки-переключателя
local function createToggle(parent, yPos, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 6)
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. (state and ": ON" or ": OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(60, 60, 60)
        callback(state)
    end)
    btn.Parent = parent
    return btn
end

-- Функция создания строки с двумя кнопками +/- и значением
local function createValueControl(parent, yPos, name, min, max, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -20, 0, 30)
    holder.Position = UDim2.new(0, 10, 0, yPos)
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0

    local label = Instance.new("TextLabel", holder)
    label.Size = UDim2.new(0, 100, 1, 0)
    label.Text = name
    label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    label.Font = Enum.Font.SourceSansSemibold
    label.TextSize = 13
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left

    local val = default
    local valLabel = Instance.new("TextLabel", holder)
    valLabel.Size = UDim2.new(0, 40, 1, 0)
    valLabel.Position = UDim2.new(1, -120, 0, 0)
    valLabel.Text = tostring(val)
    valLabel.TextColor3 = Color3.new(1, 1, 1)
    valLabel.Font = Enum.Font.SourceSansBold
    valLabel.TextSize = 14
    valLabel.BackgroundTransparency = 1
    valLabel.TextXAlignment = Enum.TextXAlignment.Center

    local minus = Instance.new("TextButton", holder)
    minus.Size = UDim2.new(0, 30, 0, 26)
    minus.Position = UDim2.new(1, -75, 0, 2)
    minus.Text = "-"
    minus.TextColor3 = Color3.new(1, 1, 1)
    minus.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    minus.Font = Enum.Font.SourceSansBold
    minus.TextSize = 18
    minus.BorderSizePixel = 0
    local minusC = Instance.new("UICorner", minus); minusC.CornerRadius = UDim.new(0, 4)

    local plus = Instance.new("TextButton", holder)
    plus.Size = UDim2.new(0, 30, 0, 26)
    plus.Position = UDim2.new(1, -40, 0, 2)
    plus.Text = "+"
    plus.TextColor3 = Color3.new(1, 1, 1)
    plus.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    plus.Font = Enum.Font.SourceSansBold
    plus.TextSize = 18
    plus.BorderSizePixel = 0
    local plusC = Instance.new("UICorner", plus); plusC.CornerRadius = UDim.new(0, 4)

    local function update()
        val = math.clamp(math.floor(val), min, max)
        valLabel.Text = tostring(val)
        callback(val)
    end

    minus.MouseButton1Click:Connect(function() val = val - 1; update() end)
    plus.MouseButton1Click:Connect(function() val = val + 1; update() end)

    holder.Parent = parent
    update()
    return holder
end

-- Добавляем контролы в mainFrame
local y = 40
createToggle(mainFrame, y, "Auto Farm", function(enabled)
    _G.AutoFarm = enabled
end); y = y + 35

createToggle(mainFrame, y, "Fly", function(enabled)
    _G.Fly = enabled
    if enabled and LocalPlayer.Character then
        -- подготовка
        local char = LocalPlayer.Character
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if root and hum then
            hum.PlatformStand = true
        end
    end
end); y = y + 35

createToggle(mainFrame, y, "Fling Player", function(enabled)
    _G.Fling = enabled
end); y = y + 35

createValueControl(mainFrame, y, "WalkSpeed", 16, 200, 16, function(val)
    _G.WalkSpeed = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end); y = y + 35

createValueControl(mainFrame, y, "JumpPower", 50, 500, 50, function(val)
    _G.JumpPower = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = val
    end
end); y = y + 35

-- ESP контрол (всегда включен)
local espLabel = Instance.new("TextLabel", mainFrame)
espLabel.Size = UDim2.new(1, -20, 0, 20)
espLabel.Position = UDim2.new(0, 10, 0, y)
espLabel.Text = "Role ESP: Active"
espLabel.TextColor3 = Color3.new(0.5, 1, 0.5)
espLabel.Font = Enum.Font.SourceSansSemibold
espLabel.TextSize = 13
espLabel.BackgroundTransparency = 1

-- ===== Auto Farm (исправленный) =====
_G.AutoFarm = false
RunService.RenderStepped:Connect(function()
    if not _G.AutoFarm then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local coins = {}
    -- Поиск монет: все BasePart с именем Coin (включая MeshPart)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name == "Coin" or obj.Name == "Coin_Server") then
            table.insert(coins, obj)
        end
    end
    
    -- поиск в папках
    for _, folderName in ipairs({"Coins", "CoinContainer", "CoinFolder", "ServerCoins"}) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, obj in ipairs(folder:GetDescendants()) do
                if obj:IsA("BasePart") then
                    table.insert(coins, obj)
                end
            end
        end
    end

    -- Если монеты – модели с PrimaryPart
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name == "Coin" or obj:FindFirstChild("Coin")) then
            local prim = obj.PrimaryPart or obj:FindFirstChild("Coin") or obj:FindFirstChildOfClass("BasePart")
            if prim then
                table.insert(coins, prim)
            end
        end
    end

    if #coins > 0 then
        -- сортируем по расстоянию
        table.sort(coins, function(a, b)
            return (root.Position - a.Position).Magnitude < (root.Position - b.Position).Magnitude
        end)
        root.CFrame = coins[1].CFrame
    end
end)

-- ===== Fly (простая версия на CFrame) =====
local flyConnection
local function startFly()
    flyConnection = RunService.RenderStepped:Connect(function()
        if not _G.Fly then return end
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = true end

        local moveDirection = Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDirection += Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDirection -= Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDirection -= Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDirection += Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDirection += Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection -= Vector3.new(0, 1, 0) end

        if moveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + moveDirection.Unit * 0.5 -- скорость полёта
            root.Velocity = Vector3.new(0, 0, 0) -- убираем гравитацию
        else
            root.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end
startFly()

-- ===== Fling =====
RunService.RenderStepped:Connect(function()
    if not _G.Fling then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        root.Velocity = Vector3.new(math.random(-8000, 8000), math.random(6000, 10000), math.random(-8000, 8000))
        root.RotVelocity = Vector3.new(math.random(-200, 200), math.random(-200, 200), math.random(-200, 200))
    end
end)

-- ===== Role ESP =====
local drawingCache = {}

local function clearESP()
    for _, obj in ipairs(drawingCache) do
        if obj.box then obj.box:Remove() end
        if obj.text then obj.text:Remove() end
    end
    drawingCache = {}
end

local function getRole(player)
    -- Смотрим в Backpack и Character на предметы
    local char = player.Character
    if not char then return "Unknown" end
    -- проверяем в детях персонажа
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            local name = child.Name:lower()
            if name:find("knife") or name:find("murder") then
                return "Murderer"
            elseif name:find("gun") or name:find("sheriff") or name:find("pistol") then
                return "Sheriff"
            end
        end
    end
    -- проверяем в Backpack
    local bp = player:FindFirstChild("Backpack")
    if bp then
        for _, child in ipairs(bp:GetChildren()) do
            if child:IsA("Tool") then
                local name = child.Name:lower()
                if name:find("knife") or name:find("murder") then
                    return "Murderer"
                elseif name:find("gun") or name:find("sheriff") or name:find("pistol") then
                    return "Sheriff"
                end
            end
        end
    end
    -- Innocent по умолчанию
    return "Innocent"
end

local function createESP(target, role, color)
    local box = Drawing.new("Square")
    box.Color = color
    box.Thickness = 1
    box.Filled = false
    box.Visible = false

    local txt = Drawing.new("Text")
    txt.Color = color
    txt.Size = 14
    txt.Center = true
    txt.Outline = true
    txt.Visible = false

    local function update()
        local char = target.Character
        if not char then
            box.Visible = false; txt.Visible = false; return
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not root or not head then
            box.Visible = false; txt.Visible = false; return
        end
        local cam = Workspace.CurrentCamera
        local pos, onScreen = cam:WorldToViewportPoint(root.Position)
        if onScreen then
            local dist = (cam.CFrame.Position - root.Position).Magnitude
            local scale = math.clamp(60 / dist, 0.3, 1.5)
            local headPos = cam:WorldToViewportPoint(head.Position)
            local height = (pos - headPos).Magnitude * 1.2
            local width = height * 0.6
            box.Size = Vector2.new(width, height)
            box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
            box.Visible = true
            txt.Position = Vector2.new(pos.X, pos.Y - height/2 - 14)
            txt.Text = role .. " | " .. target.Name
            txt.Visible = true
        else
            box.Visible = false; txt.Visible = false
        end
    end

    table.insert(drawingCache, {box = box, txt = txt, update = update})
    return update
end

local roleESPfunctions = {}
RunService.RenderStepped:Connect(function()
    -- удаляем неактуальные
    local newESP = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if roleESPfunctions[plr] then
                newESP[plr] = roleESPfunctions[plr]
            else
                local role = getRole(plr)
                local color
                if role == "Murderer" then
                    color = Color3.new(1, 0.2, 0.2)
                elseif role == "Sheriff" then
                    color = Color3.new(0.3, 0.6, 1)
                else
                    color = Color3.new(0.4, 1, 0.4)
                end
                local updateFunc = createESP(plr, role, color)
                newESP[plr] = updateFunc
            end
        end
    end
    roleESPfunctions = newESP
    -- обновляем позиции
    for plr, func in pairs(roleESPfunctions) do
        func()
    end
end)

-- очистка при перезаходе персонажа
LocalPlayer.CharacterAdded:Connect(function()
    clearESP()
    roleESPfunctions = {}
end)

-- подсказка
print("MM2 Full Menu активирован. Перетаскивай окно за заголовок.")
