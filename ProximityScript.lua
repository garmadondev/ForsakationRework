-- ProximityScript.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Получаем или создаем ProximityPrompt
local proximityPrompt = script.Parent:FindFirstChild("ProximityPrompt")
if not proximityPrompt then
    proximityPrompt = Instance.new("ProximityPrompt")
    proximityPrompt.Parent = script.Parent
    proximityPrompt.ActionText = "Взаимодействовать"
    proximityPrompt.MaxActivationDistance = 15
    proximityPrompt.HoldDuration = 0
end

-- Ваша оригинальная функция проверки расстояния
local function checkDistance(player)
    if (player.Character:GetPivot().Position - script.Parent:GetPivot().Position).Magnitude <= 15 then
        return "kevinshop"
    end
end

-- Обработчик ProximityPrompt
proximityPrompt.Triggered:Connect(function(player)
    local shopType = checkDistance(player)
    if shopType == "kevinshop" then
        -- Получаем модуль Interactions из ReplicatedStorage/Modules
        local interactionsModule = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Interactions")
        
        -- Вызываем модуль (require)
        local interactions = require(interactionsModule)
        
        -- Активируем взаимодействие
        if interactions then
            interactions(player) -- или interactions.activate(player) в зависимости от структуры модуля
        end
    end
end)