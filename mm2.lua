--[[
    MM2 FULL MENU: AutoFarm, Fly (Mobile), Teleport, Fling, Noclip, Speed, Jump, Role ESP
    Для Delta Executor
    Исправления:
    - Fling: телепорт к цели, вращение с огромной скоростью, отбрасывание цели; после выключения возврат на твёрдую поверхность
    - ESP: возможность включения/выключения, автоматическое обновление ролей каждую секунду
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Глобальные переменные для функций
_G.AutoFarm = false
_G.Fly = false
_G.Noclip = false
_G.Fling = false
_G.ESPEnabled = false        -- ESP выключен по умолчанию
_G.SelectedTarget = nil
_G.WalkSpeed = 16
_G.JumpPower = 50
_G.ESPRefresh = false        -- флаг для принудительного обновления ролей

-- ===== GUI создание =====
local gui = Instance.new("ScreenGui")
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

-- Главный фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 400)
mainFrame.Position = UDim2.new(0.5, -130, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = gui

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 10)

-- Заголовок (Красный)
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner", header)
headerCorner.CornerRadius = UDim.new(0, 10)

-- Название (Желтый)
local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "MM2 Script | draggable"
title.TextColor3 = Color3.fromRGB(255, 255, 0)
title.TextSize = 14
title.Font = Enum.Font.SourceSansBold
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка скрыть/свернуть [-]
local minimizeBtn = Instance.new("TextButton", header)
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -30, 0, 0)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextSize = 20
minimizeBtn.Font = Enum.Font.SourceSansBold

-- Кнопка развернуть (Желтая, изначально скрыта)
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 80, 0, 40)
openBtn.Position = UDim2.new(0.5, -40, 0.2, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
openBtn.Text = "Open MM2"
openBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
openBtn.TextSize = 14
openBtn.Font = Enum.Font.SourceSansBold
openBtn.Visible = false
openBtn.Active = true
openBtn.Parent = gui

local openCorner = Instance.new("UICorner", openBtn)
openCorner.CornerRadius = UDim.new(0, 8)

-- ===== Система перетаскивания (Универсальная) =====
local function makeDraggable(dragArea, moveTarget)
    local dragging = false
    local dragStart = nil
    local startPos = nil

    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = moveTarget.Position
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            moveTarget.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

makeDraggable(header, mainFrame)
makeDraggable(openBtn, openBtn)

-- Логика скрытия
minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    openBtn.Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset + 90, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset)
    openBtn.Visible = true
end)

-- Логика разворачивания
local clickStartPos
openBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        clickStartPos = input.Position
    end
end)
openBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if clickStartPos and (input.Position - clickStartPos).Magnitude < 10 then
            openBtn.Visible = false
            mainFrame.Position = UDim2.new(openBtn.Position.X.Scale, openBtn.Position.X.Offset - 90, openBtn.Position.Y.Scale, openBtn.Position.Y.Offset)
            mainFrame.Visible = true
        end
    end
end)

-- ===== Элементы интерфейса =====
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
    local btnCorner = Instance.new("UICorner", btn); btnCorner.CornerRadius = UDim.new(0, 6)

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

local function createButton(parent, yPos, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 100, 200)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextSize = 13
    local btnCorner = Instance.new("UICorner", btn); btnCorner.CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    btn.Parent = parent
    return btn
end

local function createInputControl(parent, yPos, name, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -20, 0, 30)
    holder.Position = UDim2.new(0, 10, 0, yPos)
    holder.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    local hC = Instance.new("UICorner", holder); hC.CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel", holder)
    label.Size = UDim2.new(0, 100, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = name
    label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    label.Font = Enum.Font.SourceSansSemibold
    label.TextSize = 13
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left

    local input = Instance.new("TextBox", holder)
    input.Size = UDim2.new(0, 60, 1, -10)
    input.Position = UDim2.new(1, -70, 0, 5)
    input.Text = tostring(default)
    input.TextColor3 = Color3.new(1, 1, 1)
    input.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    input.Font = Enum.Font.SourceSansBold
    input.TextSize = 14
    local inputC = Instance.new("UICorner", input); inputC.CornerRadius = UDim.new(0, 4)

    input.FocusLost:Connect(function()
        local val = tonumber(input.Text)
        if val then
            callback(val)
        else
            input.Text = tostring(default)
        end
    end)
    holder.Parent = parent
    callback(default)
    return holder
end

local function createTargetSelector(parent, yPos)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -20, 0, 30)
    holder.Position = UDim2.new(0, 10, 0, yPos)
    holder.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    local hC = Instance.new("UICorner", holder); hC.CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel", holder)
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 30, 0, 0)
    label.Text = "Target: None"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSansSemibold
    label.TextSize = 13
    label.BackgroundTransparency = 1

    local btnPrev = Instance.new("TextButton", holder)
    btnPrev.Size = UDim2.new(0, 30, 1, 0)
    btnPrev.Text = "<"
    btnPrev.TextColor3 = Color3.new(1, 1, 1)
    btnPrev.BackgroundTransparency = 1
    btnPrev.Font = Enum.Font.SourceSansBold
    btnPrev.TextSize = 16

    local btnNext = Instance.new("TextButton", holder)
    btnNext.Size = UDim2.new(0, 30, 1, 0)
    btnNext.Position = UDim2.new(1, -30, 0, 0)
    btnNext.Text = ">"
    btnNext.TextColor3 = Color3.new(1, 1, 1)
    btnNext.BackgroundTransparency = 1
    btnNext.Font = Enum.Font.SourceSansBold
    btnNext.TextSize = 16

    local targetIndex = 1
    local function getPlayers()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(list, p) end
        end
        return list
    end

    local function updateTarget()
        local list = getPlayers()
        if #list == 0 then
            label.Text = "Target: None"
            _G.SelectedTarget = nil
            return
        end
        if targetIndex > #list then targetIndex = 1 end
        if targetIndex < 1 then targetIndex = #list end
        _G.SelectedTarget = list[targetIndex]
        label.Text = "Target: " .. _G.SelectedTarget.Name
    end

    btnPrev.MouseButton1Click:Connect(function() targetIndex = targetIndex - 1; updateTarget() end)
    btnNext.MouseButton1Click:Connect(function() targetIndex = targetIndex + 1; updateTarget() end)
    
    task.spawn(function()
        while task.wait(2) do
            if _G.SelectedTarget and not _G.SelectedTarget.Parent then updateTarget() end
        end
    end)
    holder.Parent = parent
    updateTarget()
end

-- Добавляем элементы в главное окно
local y = 40
createToggle(mainFrame, y, "Auto Farm", function(state) _G.AutoFarm = state end); y = y + 35
createToggle(mainFrame, y, "Fly", function(state) 
    _G.Fly = state 
    if state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = true
    end
end); y = y + 35
createToggle(mainFrame, y, "Noclip", function(state) _G.Noclip = state end); y = y + 35

-- Цели и Телепорт
createTargetSelector(mainFrame, y); y = y + 35
createButton(mainFrame, y, "Teleport to Target", function()
    if _G.SelectedTarget and _G.SelectedTarget.Character and _G.SelectedTarget.Character:FindFirstChild("HumanoidRootPart") then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = _G.SelectedTarget.Character.HumanoidRootPart.CFrame
        end
    end
end); y = y + 35

createToggle(mainFrame, y, "Target Fling", function(state) 
    _G.Fling = state
    if not state then
        -- При выключении сбросим флаг активации
        _G.FlingJustActivated = false
    end
end); y = y + 35

createInputControl(mainFrame, y, "WalkSpeed", 16, function(val)
    _G.WalkSpeed = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end); y = y + 35

createInputControl(mainFrame, y, "JumpPower", 50, function(val)
    _G.JumpPower = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = val
    end
end); y = y + 35

createToggle(mainFrame, y, "Role ESP", function(state) 
    _G.ESPEnabled = state
    if not state then
        -- При выключении удаляем все ESP
        clearESP()
        roleESPfunctions = {}
    end
end); y = y + 35

-- ===== Логика скриптов =====

-- Noclip
RunService.Stepped:Connect(function()
    if _G.Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Fling (улучшенный)
_G.FlingJustActivated = false  -- флаг для однократного толчка
local WasFlinging = false

-- Функция поиска твёрдой поверхности под позицией
local function findGround(position)
    local rayOrigin = position + Vector3.new(0, 10, 0)
    local rayDirection = Vector3.new(0, -500, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character or game:GetService("Players").LocalPlayer.CharacterAdded:Wait()}
    
    local result = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    if result then
        return result.Position + Vector3.new(0, 3, 0)  -- немного выше земли
    else
        return position + Vector3.new(0, 0, 0)  -- если не нашли, вернуть исходную с Y = 0?
    end
end

RunService.Stepped:Connect(function()
    if _G.Fling and _G.SelectedTarget and _G.SelectedTarget.Character then
        local char = LocalPlayer.Character
        local tChar = _G.SelectedTarget.Character
        if char and tChar then
            local root = char:FindFirstChild("HumanoidRootPart")
            local tRoot = tChar:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if root and tRoot and hum then
                WasFlinging = true
                if tRoot.Position.Y > -50 then
                    hum.PlatformStand = true
                    root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 2)  -- телепорт чуть впереди цели
                    root.Velocity = Vector3.new(0, 0, 0)
                    root.RotVelocity = Vector3.new(15000, 15000, 15000)

                    -- Однократный мощный толчок цели при активации
                    if _G.FlingJustActivated then
                        tRoot.Velocity = Vector3.new(math.random(-2000, 2000), 5000, math.random(-2000, 2000))
                        _G.FlingJustActivated = false
                    end

                    -- Отключаем коллизии нашего персонажа, чтобы не мешать
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                else
                    hum.PlatformStand = false
                    root.RotVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
    elseif WasFlinging then
        WasFlinging = false
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if hum and not _G.Fly then hum.PlatformStand = false end
            if root then
                -- Возвращаем на твёрдую поверхность
                local groundPos = findGround(root.Position)
                root.CFrame = CFrame.new(groundPos)
                root.Velocity = Vector3.new(0, 0, 0)
                root.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

-- Auto Farm
RunService.RenderStepped:Connect(function()
    if not _G.AutoFarm then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local coins = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name == "Coin" or obj.Name == "Coin_Server") then table.insert(coins, obj) end
    end
    for _, folderName in ipairs({"Coins", "CoinContainer", "CoinFolder", "ServerCoins"}) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, obj in ipairs(folder:GetDescendants()) do
                if obj:IsA("BasePart") then table.insert(coins, obj) end
            end
        end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name == "Coin" or obj:FindFirstChild("Coin")) then
            local prim = obj.PrimaryPart or obj:FindFirstChild("Coin") or obj:FindFirstChildOfClass("BasePart")
            if prim then table.insert(coins, prim) end
        end
    end

    if #coins > 0 then
        table.sort(coins, function(a, b) return (root.Position - a.Position).Magnitude < (root.Position - b.Position).Magnitude end)
        root.CFrame = coins[1].CFrame
    end
end)

-- Fly
local PlayerModule = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
RunService.RenderStepped:Connect(function()
    if not _G.Fly then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local hum = char:FindFirstChild("Humanoid")
    if hum then hum.PlatformStand = true end

    local moveVector = PlayerModule:GetControls():GetMoveVector()
    local moveDirection = Vector3.new()

    if moveVector.Magnitude > 0 then
        moveDirection = (Camera.CFrame.RightVector * moveVector.X) + (Camera.CFrame.LookVector * -moveVector.Z)
    end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDirection += Vector3.new(0, 1, 0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection -= Vector3.new(0, 1, 0) end

    if moveDirection.Magnitude > 0 then
        root.CFrame = root.CFrame + moveDirection.Unit * 1.5
        root.Velocity = Vector3.new(0, 0, 0)
    else
        root.Velocity = Vector3.new(0, 0, 0)
    end
end)

-- Role ESP
local drawingCache = {}
local function clearESP()
    for _, obj in ipairs(drawingCache) do
        if obj.box then obj.box:Remove() end
        if obj.text then obj.text:Remove() end
    end
    drawingCache = {}
end

local function getRole(player)
    local char = player.Character
    if char then
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") then
                local name = child.Name:lower()
                if name:find("knife") or name:find("murder") then return "Murderer"
                elseif name:find("gun") or name:find("sheriff") or name:find("pistol") then return "Sheriff" end
            end
        end
    end
    local bp = player:FindFirstChild("Backpack")
    if bp then
        for _, child in ipairs(bp:GetChildren()) do
            if child:IsA("Tool") then
                local name = child.Name:lower()
                if name:find("knife") or name:find("murder") then return "Murderer"
                elseif name:find("gun") or name:find("sheriff") or name:find("pistol") then return "Sheriff" end
            end
        end
    end
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
        if not char then box.Visible = false; txt.Visible = false; return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not root or not head then box.Visible = false; txt.Visible = false; return end
        local cam = Workspace.CurrentCamera
        local pos, onScreen = cam:WorldToViewportPoint(root.Position)
        if onScreen then
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

-- Цикл обновления ролей каждую секунду
task.spawn(function()
    while true do
        if _G.ESPEnabled then
            _G.ESPRefresh = true
        end
        task.wait(1)
    end
end)

RunService.RenderStepped:Connect(function()
    if not _G.ESPEnabled then return end

    -- Если флаг обновления, сбрасываем весь ESP и создаём заново
    if _G.ESPRefresh then
        _G.ESPRefresh = false
        clearESP()
        roleESPfunctions = {}
    end

    local newESP = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if roleESPfunctions[plr] then
                newESP[plr] = roleESPfunctions[plr]
            else
                local role = getRole(plr)
                local color = Color3.new(0.4, 1, 0.4)
                if role == "Murderer" then color = Color3.new(1, 0.2, 0.2)
                elseif role == "Sheriff" then color = Color3.new(0.3, 0.6, 1) end
                newESP[plr] = createESP(plr, role, color)
            end
        end
    end
    roleESPfunctions = newESP
    for plr, func in pairs(roleESPfunctions) do func() end
end)

LocalPlayer.CharacterAdded:Connect(function()
    clearESP()
    roleESPfunctions = {}
end)

print("MM2 Full Menu v5 (Fling fix, ESP toggle + auto-refresh) загружен!")
