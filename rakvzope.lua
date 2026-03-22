local ReGui = loadstring(game:HttpGet("https://api.lithium.wtf/misc/regui"))()

local Window = ReGui:Window({
    Title = "RakNet Desync | Position Tracker",
    Size = UDim2.fromOffset(250, 150),
})

-- Проверка наличия Raknet библиотеки
local hasRaknet = Raknet ~= nil

if not hasRaknet then
    local Popup = Window:PopupModal({ Title = "ERROR" })
    Popup:Label({ Text = "Raknet library not found!" })
    Popup:Label({ Text = "Make sure you have a compatible executor" })
    Popup:Separator()
    Popup:Button({
        Text = "Close",
        Callback = function()
            Popup:ClosePopup()
        end,
    })
end

-- Создаем партиклы для визуализации
local function createParticle(position, color, text)
    local part = Instance.new("Part")
    part.Size = Vector3.new(1, 1, 1)
    part.Position = position
    part.BrickColor = BrickColor.new(color)
    part.Material = Enum.Material.Neon
    part.Anchored = true
    part.CanCollide = false
    part.Parent = workspace
    
    -- Добавляем билборд с текстом
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Parent = part
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = color == "Bright red" and Color3.new(1, 0, 0) or Color3.new(0, 1, 0)
    textLabel.TextStrokeTransparency = 0.3
    textLabel.TextScaled = true
    textLabel.Parent = billboard
    
    -- Автоудаление через 2 секунды
    game:GetService("Debris"):AddItem(part, 2)
    
    return part
end

-- Создаем GUI для отображения позиций
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game:GetService("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 100)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.new(1, 1, 1)
frame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 25)
titleLabel.Text = "RakNet Desync Status"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true
titleLabel.Parent = frame

local realPosLabel = Instance.new("TextLabel")
realPosLabel.Size = UDim2.new(1, 0, 0, 25)
realPosLabel.Position = UDim2.new(0, 0, 0, 25)
realPosLabel.Text = "Real Position: ---"
realPosLabel.TextColor3 = Color3.new(0, 1, 0)
realPosLabel.BackgroundTransparency = 1
realPosLabel.Font = Enum.Font.Gotham
realPosLabel.TextScaled = true
realPosLabel.Parent = frame

local serverPosLabel = Instance.new("TextLabel")
serverPosLabel.Size = UDim2.new(1, 0, 0, 25)
serverPosLabel.Position = UDim2.new(0, 0, 0, 50)
serverPosLabel.Text = "Server Position: ---"
serverPosLabel.TextColor3 = Color3.new(1, 0, 0)
serverPosLabel.BackgroundTransparency = 1
serverPosLabel.Font = Enum.Font.Gotham
serverPosLabel.TextScaled = true
serverPosLabel.Parent = frame

local desyncStatusLabel = Instance.new("TextLabel")
desyncStatusLabel.Size = UDim2.new(1, 0, 0, 25)
desyncStatusLabel.Position = UDim2.new(0, 0, 0, 75)
desyncStatusLabel.Text = "Desync: OFF"
desyncStatusLabel.TextColor3 = Color3.new(1, 0, 0)
desyncStatusLabel.BackgroundTransparency = 1
desyncStatusLabel.Font = Enum.Font.GothamBold
desyncStatusLabel.TextScaled = true
desyncStatusLabel.Parent = frame

-- Переменные для отслеживания
local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local realPosition = character:WaitForChild("HumanoidRootPart").Position
local desyncActive = false

-- Функция обновления позиций
local function updatePositions()
    if not character or not character.Parent then
        character = player.Character
        if not character then return end
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Реальная позиция (то, где вы находитесь на клиенте)
    local currentRealPos = rootPart.Position
    realPosition = currentRealPos
    
    -- Получаем серверную позицию через NetworkServer
    local serverPosition = currentRealPos
    
    if hasRaknet and desyncActive then
        -- Если десинк активен, пытаемся получить серверную позицию из RakNet
        pcall(function()
            serverPosition = Raknet.getServerPosition() or currentRealPos
        end)
    end
    
    -- Обновляем текстовые метки
    realPosLabel.Text = string.format("Real Position: X: %.1f Y: %.1f Z: %.1f", 
        currentRealPos.X, currentRealPos.Y, currentRealPos.Z)
    
    serverPosLabel.Text = string.format("Server Position: X: %.1f Y: %.1f Z: %.1f", 
        serverPosition.X, serverPosition.Y, serverPosition.Z)
    
    -- Создаем партиклы для визуализации
    if desyncActive then
        -- Зеленый партикл на реальной позиции
        createParticle(currentRealPos, "Bright green", "REAL POS")
        
        -- Красный партикл на серверной позиции (если отличается)
        if (currentRealPos - serverPosition).Magnitude > 3 then
            createParticle(serverPosition, "Bright red", "SERVER POS")
            
            -- Показываем линию между позициями
            local line = Instance.new("Part")
            line.Size = Vector3.new(0.2, 0.2, (currentRealPos - serverPosition).Magnitude)
            line.CFrame = CFrame.new(currentRealPos:Lerp(serverPosition, 0.5), serverPosition)
            line.BrickColor = BrickColor.new("Bright yellow")
            line.Material = Enum.Material.Neon
            line.Anchored = true
            line.CanCollide = false
            line.Parent = workspace
            game:GetService("Debris"):AddItem(line, 0.5)
        end
    end
end

-- Запускаем цикл обновления позиций
local updateLoop
updateLoop = game:GetService("RunService").RenderStepped:Connect(function()
    updatePositions()
end)

-- Создаем чекбокс для десинка
Window:Checkbox({
    Value = false,
    Label = "Enable RakNet Desync",
    Callback = function(self, Value)
        if not hasRaknet then
            local Popup = Window:PopupModal({ Title = "ERROR" })
            Popup:Label({ Text = "Raknet library not available!" })
            Popup:Button({
                Text = "OK",
                Callback = function()
                    Popup:ClosePopup()
                end,
            })
            return
        end
        
        desyncActive = Value
        
        if Value then
            desyncStatusLabel.Text = "Desync: ACTIVE"
            desyncStatusLabel.TextColor3 = Color3.new(1, 0.5, 0)
            
            -- Включаем десинк через Raknet
            pcall(function()
                Raknet.desync(true)
            end)
        else
            desyncStatusLabel.Text = "Desync: OFF"
            desyncStatusLabel.TextColor3 = Color3.new(1, 0, 0)
            
            -- Выключаем десинк
            pcall(function()
                Raknet.desync(false)
            end)
        end
    end,
})

-- Кнопка для спавна маркера на позиции
Window:Button({
    Text = "Spawn Marker at Current Position",
    Callback = function()
        if character and character:FindFirstChild("HumanoidRootPart") then
            local pos = character.HumanoidRootPart.Position
            local marker = createParticle(pos, "Bright blue", "MARKER")
            marker.Size = Vector3.new(2, 2, 2)
        end
    end,
})

-- Информационная метка
Window:Label({ Text = "Green = Real | Red = Server" })
Window:Label({ Text = "Yellow line shows desync distance" })

-- Очистка при закрытии
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(newChar)
    character = newChar
    desyncStatusLabel.Text = "Desync: OFF (Character respawned)"
    desyncActive = false
    if hasRaknet then
        pcall(function()
            Raknet.desync(false)
        end)
    end
    wait(2)
    desyncStatusLabel.Text = desyncActive and "Desync: ACTIVE" or "Desync: OFF"
end)
