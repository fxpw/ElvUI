# Детальный план реализации Nameplate Unit Frames

## 1. Цель
Создать новую группу юнитфреймов "Nameplate", которая будет отображать фреймы для юнитов `nameplate1` - `nameplate40`. Эти фреймы должны полностью копировать функционал и внешний вид `Raid10/Raid40`, включая все индикаторы, ауры и настройки.

## 2. Архитектура и компоненты

### 2.1. Логика фреймов (`ElvUI/Modules/UnitFrames/Groups/Nameplate.lua`)
*   **Конструктор (`UF:Construct_NameplateFrames`)**:
    *   Создание `RaisedElementParent`.
    *   Инициализация всех элементов: `Health`, `Power`, `Portrait` (2D/3D), `Name`, `Buffs`, `Debuffs`, `AuraWatch` (Buff Indicators), `RaidDebuffs`, `DebuffHighlight`, `ResurrectIndicator`, `RaidRoleFrames`, `MouseGlow`, `TargetGlow`, `ThreatIndicator`, `GroupRoleIndicator`, `RaidTargetIndicator`, `ReadyCheckIndicator`, `SummonIndicator`, `HealCommBar`, `GPS`, `Fader`, `Cutaway`, `InfoPanel`.
    *   Установка `unitframeType = "nameplate"`.
*   **Обновление фрейма (`UF:Update_NameplateFrames`)**:
    *   Применение настроек из БД (`db`).
    *   Настройка размеров, ориентации, панелей питания, портретов и всех индикаторов.
    *   **Позиционирование**: Фреймы будут располагаться внутри общего контейнера `NameplateHeader` аналогично Boss или Arena фреймам, но с поддержкой до 40 элементов.
*   **Заголовок и Мувер (`UF:Update_NameplateHeader`)**:
    *   Создание контейнера `NameplateHeader` (если не создан).
    *   Создание Мувера через `E:CreateMover` для управления положением всей группы фреймов.
    *   Управление видимостью и макетом (направление роста, отступы, количество колонок/рядов).
*   **Регистрация**: Добавление в `UF.unitgroupstoload.nameplate = {40}` для автоматической загрузки 40 юнитов.

### 2.2. Настройки по умолчанию (`ElvUI/Settings/Profile.lua`)
*   Добавление таблицы `P.unitframe.units.nameplate`.
*   Копирование всех параметров из `raid10` или `raid40` для обеспечения идентичного поведения "из коробки".

### 2.3. Интерфейс настроек (`ElvUI_OptionsUI/UnitFrames.lua`)
*   Добавление нового раздела `nameplate` в меню настроек UnitFrames.
*   Реализация всех вкладок: General, Health, Power, Name, Portrait, Buffs, Debuffs, Buff Indicator (AuraWatch), Raid Debuffs, Raid Icon, Ready Check, Custom Texts и др.
*   Использование `UF:CreateAndUpdateUFGroup("nameplate", 40)` для применения изменений.

### 2.4. Регистрация модуля (`ElvUI/Modules/UnitFrames/Groups/Load_Groups.xml`)
*   Добавление `<Script file="Nameplate.lua"/>` для подключения нового файла.

### 2.5. Интеграция в ядро (`ElvUI/Core/Core.lua`)
*   Добавление `nameplate` в список `rangeCheckUnits` для работы проверки дистанции.
*   Добавление `nameplate` в список `healPredictionUnits` для отображения входящего исцеления.

## 3. Этапы работы
1.  **Настройки**: Добавление дефолтов в `Profile.lua`.
2.  **Логика**: Создание `Nameplate.lua` с полной реализацией конструктора и обновлений (на 40 юнитов).
3.  **Подключение**: Регистрация в `Load_Groups.xml`.
4.  **Опции**: Реализация интерфейса настроек в `OptionsUI`.
5.  **Ядро**: Интеграция в `Core.lua`.
6.  **Тестирование**: Проверка мувера, отображения элементов и применения настроек при большом количестве фреймов.

## 4. Особенности
*   В отличие от рейдовых фреймов, Nameplate UF будет использовать индивидуальные фреймы для юнитов `nameplate1-40`. Это позволит избежать проблем с защищенными заголовков (SecureGroupHeader) при работе с неймплейтами.
*   Мувер будет управлять всей сеткой фреймов. Логика сетки будет адаптирована для компактного отображения 40 фреймов (настраиваемое количество колонок/рядов).
