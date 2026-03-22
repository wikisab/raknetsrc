-- Fancy RakNet Desync GUI (Synapse + Delta)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local rk = Raknet or raknet
local desync = false

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "RaknetDesyncGUI"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

-- MAIN FRAME
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,240,0,140)
frame.Position = UDim2.new(0.5,-120,0.5,-70)
frame.BackgroundColor3 = Color3.fromRGB(22,22,22)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner",frame)
corner.CornerRadius = UDim.new(0,12)

local stroke = Instance.new("UIStroke",frame)
stroke.Color = Color3.fromRGB(70,70,70)

-- TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "RakNet Desync"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- DESYNC BUTTON
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1,-20,0,40)
toggleButton.Position = UDim2.new(0,10,0,40)
toggleButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
toggleButton.Text = "DESYNC OFF"
toggleButton.TextScaled = true
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.Font = Enum.Font.Gotham
toggleButton.Parent = frame

local btnCorner = Instance.new("UICorner",toggleButton)
btnCorner.CornerRadius = UDim.new(0,8)

-- SERVER POSITION LABEL
local posLabel = Instance.new("TextLabel")
posLabel.Size = UDim2.new(1,-20,0,30)
posLabel.Position = UDim2.new(0,10,0,90)
posLabel.BackgroundTransparency = 1
posLabel.TextColor3 = Color3.fromRGB(200,200,200)
posLabel.TextScaled = true
posLabel.Font = Enum.Font.Gotham
posLabel.Text = "Server Pos: ..."
posLabel.Parent = frame

-- SHOW/HIDE BUTTON
local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0,120,0,40)
openButton.Position = UDim2.new(0,50,0,200)
openButton.BackgroundColor3 = Color3.fromRGB(30,30,30)
openButton.Text = "Toggle GUI"
openButton.TextScaled = true
openButton.TextColor3 = Color3.new(1,1,1)
openButton.Font = Enum.Font.Gotham
openButton.Parent = gui

Instance.new("UICorner",openButton)

-- DRAG FUNCTION
local function makeDraggable(obj)

	local dragging = false
	local dragStart
	local startPos

	obj.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			dragStart = input.Position
			startPos = obj.Position
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then

			local delta = input.Position - dragStart

			obj.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)

		end
	end)

end

makeDraggable(frame)
makeDraggable(openButton)

-- TOGGLE GUI
openButton.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

-- DESYNC TOGGLE
toggleButton.MouseButton1Click:Connect(function()

	desync = not desync

	if rk and rk.desync then
		rk.desync(desync)
	end

	if desync then
		toggleButton.Text = "DESYNC ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(60,140,80)
	else
		toggleButton.Text = "DESYNC OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
	end

end)

-- 3D SERVER POSITION MARKER
local marker = Instance.new("Part")
marker.Shape = Enum.PartType.Ball
marker.Size = Vector3.new(2,2,2)
marker.Material = Enum.Material.Neon
marker.Color = Color3.fromRGB(255,70,70)
marker.Anchored = true
marker.CanCollide = false
marker.Parent = workspace

RunService.RenderStepped:Connect(function()

	local char = player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local pos = hrp.Position

	posLabel.Text = string.format(
		"Server: %.1f %.1f %.1f",
		pos.X,pos.Y,pos.Z
	)

	marker.Position = pos

end)
