# Kevin Shop - ProximityPrompt System

Система скриптов для создания интерактивного магазина с использованием ProximityPrompt в Roblox.

## Файлы

1. **ProximityScript.lua** - Основной скрипт с ProximityPrompt
2. **Interactions.lua** - Скрипт обработки взаимодействий с магазином
3. **OriginalScript_Updated.lua** - Обновленная версия вашего оригинального скрипта

## Установка

### В Roblox Studio:

1. Поместите `ProximityScript.lua` как **ServerScript** в объект, рядом с которым должен появляться магазин
2. Поместите `Interactions.lua` как **ServerScript** в тот же объект
3. ProximityPrompt будет создан автоматически, если его нет

### Структура в Explorer:
```
YourObject (Part/Model)
├── ProximityScript (ServerScript)
├── Interactions (ServerScript)
└── ProximityPrompt (создается автоматически)
```

## Как это работает

1. **Проверка расстояния**: Скрипт проверяет, находится ли игрок в радиусе 15 studs от объекта
2. **Показ ProximityPrompt**: Когда игрок приближается, появляется интерактивная подсказка
3. **Активация**: При нажатии E (или кнопки взаимодействия) активируется скрипт Interactions
4. **Обработка**: Скрипт Interactions обрабатывает логику магазина

## Настройки ProximityPrompt

В `ProximityScript.lua` вы можете изменить:

```lua
proximityPrompt.ActionText = "Открыть магазин"      -- Текст действия
proximityPrompt.ObjectText = "Kevin Shop"           -- Название объекта
proximityPrompt.MaxActivationDistance = 15          -- Максимальное расстояние
proximityPrompt.HoldDuration = 0                    -- Время удержания (0 = мгновенно)
proximityPrompt.RequiresLineOfSight = false         -- Требуется ли прямая видимость
```

## Кастомизация магазина

В `Interactions.lua` вы можете:

1. **Изменить товары магазина**:
```lua
local shopItems = {
    {name = "Ваш товар", price = 100, id = "item_id"},
    -- добавить больше товаров
}
```

2. **Добавить GUI магазина**:
```lua
local playerGui = player:WaitForChild("PlayerGui")
local shopGui = ReplicatedStorage:FindFirstChild("ShopGui")
if shopGui then
    shopGui:Clone().Parent = playerGui
end
```

3. **Использовать RemoteEvents**:
```lua
local openShopRemote = ReplicatedStorage:FindFirstChild("OpenShopRemote")
if openShopRemote then
    openShopRemote:FireClient(player, "kevinshop")
end
```

## События и функции

### BindableEvents в Interactions.lua:
- `ActivateShop` - Событие активации магазина

### BindableFunctions в Interactions.lua:
- `GetShopItems` - Получить список товаров
- `BuyItem` - Купить товар

## Использование в других скриптах

```lua
-- Активировать магазин
local interactionsScript = workspace.YourObject.Interactions
interactionsScript.ActivateShop:Fire(player)

-- Получить товары магазина
local items = interactionsScript.GetShopItems:Invoke()

-- Купить товар
local success = interactionsScript.BuyItem:Invoke(player, "health_potion")
```

## Отладка

Скрипты выводят информацию в консоль:
- "Активирован магазин для игрока: [имя]"
- "Скрипт Interactions загружен успешно"
- "Не удалось отправить уведомление: [ошибка]"

## Требования

- Roblox Studio
- ServerScript для серверной логики
- LocalScript для клиентской части GUI (если используется)