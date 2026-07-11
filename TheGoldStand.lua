local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

local gui = Instance.new("ScreenGui")
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 300)
mainFrame.Position = UDim2.new(0.5, -150, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Parent = gui

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Thickness = 2.5
stroke.LineJoinMode = Enum.LineJoinMode.Round
task.spawn(function()
    while true do
        for _, c in ipairs({Color3.fromRGB(255,200,0), Color3.fromRGB(255,230,50), Color3.fromRGB(255,170,0), Color3.fromRGB(255,215,0)}) do
            stroke.Color = c
            task.wait(0.4)
        end
    end
end)

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)

local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1, 0, 0, 36)
header.BackgroundColor3 = Color3.fromRGB(255,200,0)
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)
local hGrad = Instance.new("UIGradient", header)
hGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,220,50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,180,0))
})
hGrad.Rotation = 90

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 40, 0, 0)
title.Text = "The G0ld Stand HUB"
title.TextColor3 = Color3.fromRGB(180,0,0)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Center

local minimizeBtn = Instance.new("TextButton", header)
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -66, 0, 3)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.fromRGB(180,0,0)
minimizeBtn.TextSize = 22
minimizeBtn.Font = Enum.Font.GothamBold

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -33, 0, 3)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(180,0,0)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 100, 0, 40)
openBtn.Position = UDim2.new(0.5, -50, 0.2, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(255,200,0)
openBtn.Text = "HUB"
openBtn.TextColor3 = Color3.fromRGB(180,0,0)
openBtn.TextSize = 18
openBtn.Font = Enum.Font.GothamBold
openBtn.Visible = false
openBtn.Parent = gui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 10)

local function makeDraggable(dragArea, moveTarget)
    local dragging = false
    local startPos = nil
    local dragStart = nil
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

minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    openBtn.Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset + 110, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset)
    openBtn.Visible = true
end)

openBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local clickStart = input.Position
        openBtn.InputEnded:Connect(function(input2)
            if input2.UserInputType == Enum.UserInputType.MouseButton1 or input2.UserInputType == Enum.UserInputType.Touch then
                if (input2.Position - clickStart).Magnitude < 10 then
                    openBtn.Visible = false
                    mainFrame.Position = UDim2.new(openBtn.Position.X.Scale, openBtn.Position.X.Offset - 110, openBtn.Position.Y.Scale, openBtn.Position.Y.Offset)
                    mainFrame.Visible = true
                end
            end
        end)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local mm2Btn = Instance.new("TextButton", mainFrame)
mm2Btn.Size = UDim2.new(1, -20, 0, 50)
mm2Btn.Position = UDim2.new(0, 10, 0, 46)
mm2Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
mm2Btn.Text = "🔪 Murder Mystery 2"
mm2Btn.TextColor3 = Color3.new(1, 1, 1)
mm2Btn.Font = Enum.Font.GothamBold
mm2Btn.TextSize = 16
mm2Btn.BorderSizePixel = 0
mm2Btn.AutoButtonColor = false
Instance.new("UICorner", mm2Btn).CornerRadius = UDim.new(0, 10)

local btnGrad = Instance.new("UIGradient", mm2Btn)
btnGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 40))
})
btnGrad.Rotation = 90

mm2Btn.MouseButton1Click:Connect(function()
    
end)
