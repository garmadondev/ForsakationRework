-- OriginalScript_Updated.lua
-- Обновленная версия вашего оригинального скрипта с ProximityPrompt

return function(player) --[[Anonymous function at line 1]]
    -- Проверяем расстояние до игрока
    if (player.Character:GetPivot().Position - script.Parent:GetPivot().Position).Magnitude <= 15 then
        -- Получаем ProximityPrompt
        local proximityPrompt = script.Parent:FindFirstChild("ProximityPrompt")
        
        if not proximityPrompt then
            -- Создаем ProximityPrompt если его нет
            proximityPrompt = Instance.new("ProximityPrompt")
            proximityPrompt.Parent = script.Parent
            proximityPrompt.ActionText = "Открыть магазин"
            proximityPrompt.ObjectText = "Kevin Shop"
            proximityPrompt.MaxActivationDistance = 15
            proximityPrompt.HoldDuration = 0
            proximityPrompt.RequiresLineOfSight = false
            
            -- Подключаем обработчик события
            proximityPrompt.Triggered:Connect(function(triggeringPlayer)
                -- Активируем скрипт Interactions
                local interactionsScript = script.Parent:FindFirstChild("Interactions")
                if interactionsScript and interactionsScript:FindFirstChild("ActivateShop") then
                    interactionsScript.ActivateShop:Fire(triggeringPlayer)
                else
                    print("Магазин активирован для игрока:", triggeringPlayer.Name)
                    -- Базовая логика если Interactions не найден
                end
            end)
        end
        
        -- Показываем ProximityPrompt
        proximityPrompt.Enabled = true
        
        return "kevinshop"
    else
        -- Скрываем ProximityPrompt если игрок далеко
        local proximityPrompt = script.Parent:FindFirstChild("ProximityPrompt")
        if proximityPrompt then
            proximityPrompt.Enabled = false
        end
    end
    
    return nil
end