-- Desync UI (Mobile + PC Support)

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local gui = Instance.new("ScreenGui")
gui.Name = "DesyncUI"
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 120)
frame.Position = UDim2.new(0.5, -125, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true -- IMPORTANT FOR MOBILE
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Desync Toggle"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local toggleBg = Instance.new("Frame")
toggleBg.Size = UDim2.new(0, 60, 0, 30)
toggleBg.Position = UDim2.new(0.5, -30, 0.5, -10)
toggleBg.BackgroundColor3 = Color3.fromRGB(50,50,50)
toggleBg.Parent = frame
Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

local toggleCircle = Instance.new("Frame")
toggleCircle.Size = UDim2.new(0, 26, 0, 26)
toggleCircle.Position = UDim2.new(0, 2, 0.5, -13)
toggleCircle.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggleCircle.Parent = toggleBg
Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(1, 0)

local enabled = false

local function toggle()
	enabled = not enabled
	
	if enabled then
		TweenService:Create(toggleCircle, TweenInfo.new(0.25), {
			Position = UDim2.new(1, -28, 0.5, -13)
		}):Play()
		
		TweenService:Create(toggleBg, TweenInfo.new(0.25), {
			BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		}):Play()

		raknet.desync(true)
	else
		TweenService:Create(toggleCircle, TweenInfo.new(0.25), {
			Position = UDim2.new(0, 2, 0.5, -13)
		}):Play()
		
		TweenService:Create(toggleBg, TweenInfo.new(0.25), {
			BackgroundColor3 = Color3.fromRGB(50,50,50)
		}):Play()

		raknet.desync(false)
	end
end

-- ✅ Works for BOTH click and tap
toggleBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		toggle()
	end
end)

-- 📱 Mobile Drag Fix
local dragging = false
local dragStart, startPos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

frame.InputChanged:Connect(function(input)
	if dragging and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then
		local delta = input.Position - dragStart
		
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)
