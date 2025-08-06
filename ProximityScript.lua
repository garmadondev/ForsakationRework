-- ProximityScript.lua
-- Скрипт для обработки ProximityPrompt и активации Interactions

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Получаем ProximityPrompt (предполагаем что он находится в том же объекте что и скрипт)
local proximityPrompt = script.Parent:FindFirstChild("ProximityPrompt")

-- Если ProximityPrompt не найден, создаем его
if not proximityPrompt then
    proximityPrompt = Instance.new("ProximityPrompt")
    proximityPrompt.Parent = script.Parent
end

-- Настройки ProximityPrompt
proximityPrompt.ActionText = "Открыть магазин"
proximityPrompt.ObjectText = "Kevin Shop"
proximityPrompt.MaxActivationDistance = 15
proximityPrompt.HoldDuration = 0
proximityPrompt.RequiresLineOfSight = false

-- Функция проверки расстояния (ваша оригинальная функция)
local function checkDistance(player)
    if (player.Character:GetPivot().Position - script.Parent:GetPivot().Position).Magnitude <= 15 then
        return "kevinshop"
    end
    return nil
end

-- Функция активации Interactions
local function activateInteractions(player)
    -- Ищем скрипт Interactions
    local interactionsScript = script.Parent:FindFirstChild("Interactions")
    
    if interactionsScript then
        -- Если скрипт Interactions найден, вызываем его функцию
        if interactionsScript:FindFirstChild("ActivateShop") then
            interactionsScript.ActivateShop:Fire(player)
        else
            -- Если функция не найдена, выполняем базовую логику
            print("Активирован магазин для игрока:", player.Name)
            -- Здесь можно добавить логику открытия GUI магазина
        end
    else
        print("Скрипт Interactions не найден!")
    end
end

-- Обработчик события ProximityPrompt
proximityPrompt.Triggered:Connect(function(player)
    local shopType = checkDistance(player)
    if shopType == "kevinshop" then
        activateInteractions(player)
    end
end)

-- Обработчик для показа/скрытия ProximityPrompt в зависимости от расстояния
local function updateProximityPrompt()
    local players = Players:GetPlayers()
    local shouldShow = false
    
    for _, player in pairs(players) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character:GetPivot().Position - script.Parent:GetPivot().Position).Magnitude
            if distance <= 15 then
                shouldShow = true
                break
            end
        end
    end
    
    proximityPrompt.Enabled = shouldShow
end

-- Обновляем видимость ProximityPrompt каждую секунду
spawn(function()
    while true do
        updateProximityPrompt()
        wait(1)
    end
end)