-- Interactions.lua
-- Скрипт для обработки взаимодействий с магазином

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

-- Создаем BindableEvent для связи с другими скриптами
local activateShop = Instance.new("BindableEvent")
activateShop.Name = "ActivateShop"
activateShop.Parent = script

-- Функция активации магазина
local function openShop(player)
    print("Открываем магазин Kevin для игрока:", player.Name)
    
    -- Здесь можно добавить логику открытия GUI магазина
    -- Например:
    -- local playerGui = player:WaitForChild("PlayerGui")
    -- local shopGui = ReplicatedStorage:FindFirstChild("ShopGui")
    -- if shopGui then
    --     shopGui:Clone().Parent = playerGui
    -- end
    
    -- Или отправить RemoteEvent на клиент
    -- local openShopRemote = ReplicatedStorage:FindFirstChild("OpenShopRemote")
    -- if openShopRemote then
    --     openShopRemote:FireClient(player, "kevinshop")
    -- end
    
    -- Пример простого уведомления
    local success, error = pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Kevin Shop";
            Text = "Добро пожаловать в магазин!";
            Duration = 3;
        })
    end)
    
    if not success then
        print("Не удалось отправить уведомление:", error)
    end
end

-- Подключаем функцию к событию
activateShop.Event:Connect(openShop)

-- Дополнительные функции для магазина
local shopItems = {
    {name = "Зелье здоровья", price = 50, id = "health_potion"},
    {name = "Зелье маны", price = 30, id = "mana_potion"},
    {name = "Меч", price = 200, id = "sword"},
    {name = "Щит", price = 150, id = "shield"}
}

-- Функция получения товаров магазина
local function getShopItems()
    return shopItems
end

-- Функция покупки товара
local function buyItem(player, itemId)
    local item = nil
    for _, shopItem in pairs(shopItems) do
        if shopItem.id == itemId then
            item = shopItem
            break
        end
    end
    
    if item then
        print(player.Name .. " покупает " .. item.name .. " за " .. item.price .. " монет")
        -- Здесь добавить логику списания денег и выдачи предмета
        return true
    else
        print("Товар не найден:", itemId)
        return false
    end
end

-- Экспортируем функции для использования в других скриптах
script.GetShopItems.OnInvoke = getShopItems
script.BuyItem.OnInvoke = buyItem

print("Скрипт Interactions загружен успешно")