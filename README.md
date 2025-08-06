# ProximityPrompt для модуля Interactions

Простой скрипт для привязки ProximityPrompt к модулю Interactions из ReplicatedStorage/Modules.

## Установка

1. Поместите `ProximityScript.lua` как **ServerScript** в объект рядом с которым должен появляться ProximityPrompt
2. Убедитесь что модуль `Interactions` находится в `ReplicatedStorage > Modules > Interactions`

## Как работает

1. При приближении игрока на 15 studs появляется ProximityPrompt
2. При нажатии E проверяется расстояние (ваша оригинальная функция)
3. Если расстояние <= 15, вызывается модуль `Interactions` из `ReplicatedStorage/Modules`
4. Модуль выполняется с передачей игрока как параметра

## Структура

```
ReplicatedStorage
└── Modules
    └── Interactions (ModuleScript)

YourObject (Part/Model)
└── ProximityScript (ServerScript)
```

## Примечание

Если структура вашего модуля Interactions отличается (например, нужно вызывать `interactions.activate(player)` вместо `interactions(player)`), измените строку в скрипте:

```lua
interactions(player) -- замените на нужный вызов
```