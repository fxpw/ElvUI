# План рефакторинга Nameplates — Версия 2

> Обновлённая редакция от 2026-04-26. Базовый план (v1) лежит в [Nameplates_Refactor_Plan.md](Nameplates_Refactor_Plan.md) и сохраняется как исходный контекст. v2 фиксирует фактическое состояние работ, консолидирует подзадачи по портированию StyleFilter и переопределяет приоритет следующих шагов.

---

## 1) Контекст и цели v2

Цель v2: довести функциональный паритет nameplate-модуля Sirus WotLK 3.3.5a с retail-веткой ElvUI, при этом:

- Сохранить уже работающие Sirus-специфичные подсистемы (тотемы, уникальные юниты, IconChanged/IconOnlyChanged, FixRussianTotemNames, ScaleIconFrame).
- Не ломать существующий рефакторинг каркаса nameplate'ов на ветке `new_plates` (см. v1, фазы 0–4 — уже частично выполнены).
- Поэтапно заменить устаревший StyleFilter на верный порт retail-версии с гейтированием retail-only веток (`if E.Retail then ... end`).

Целевой источник: `D:\repos\ElvUI_retail\ElvUI\Core\Modules\Nameplates\StyleFilter.lua` (1759 строк).
Целевой файл: [Modules/Nameplates/StyleFilter.lua](Modules/Nameplates/StyleFilter.lua) (текущий — 1026 строк, OLD-модель).

Окружение:

- WotLK 3.3.5a, Interface 30300, Sirus-патчи (поглощения и т.п.).
- ElvUF = E.oUF; LSM = E.Libs.LSM; ACH = E.Libs.ACH.
- Ни `E.Retail`, ни `E.Wrath` не выставлены — обе ветки трактуются как `false`.
- В Sirus доступен `C_Timer:NewTimer(sec, func)` (через двоеточие) — прямая замена retail-вызова `C_Timer.NewTimer(sec, func)`. Возвращаемый объект поддерживает `:Cancel()`. AceTimer-3.0 как fallback оставляем, но для StyleFilter-тикеров не нужен.
- `E.Compat.StatusBarPrototype` — для эмуляции `SetReverseFill`.

---

## 2) Состояние работ (по v1 + новые подзадачи)

### Уже сделано (вне рамок v2-плана, но фиксируется)

- [x] Фаза 0–1 v1: ветка `new_plates`, базовый снимок поведения.
- [x] Фаза 3 v1: каркас модуля Nameplates перенесён, разбит на Elements/Plugins.
- [x] Базовые элементы: Health, Power, Castbar, Auras (Buffs_/Debuffs_), Tags, Threat, RaidTargetIndicator, Portrait, CutawayHealth (flat), HealCommBar, ClassPower (заглушка), TargetIndicator, ThreatIndicator, Highlight, IconFrame.
- [x] `NamePlateCallBack` заполняет: `classification`, `creatureType`, `isPlayer`, `isFriend`, `reaction`, `faction`, `unitName`, `unitRealm`, `className`, `classFile`, `npcID`, `unitGUID`, `classColor`.
- [x] Bugfix: `Health_UpdateColor` — корректная распаковка `oUF.colors.class[CLASSNAME]` (массив `{r,g,b}`, а не `{.r,.g,.b}`).
- [x] Хелперы: `ScalePlate`, `SetFrameScale`, `PlateFade`, `DisablePlate`, `Update_Portrait`, `ThreatIndicator_PreUpdate(self, unit, pass)` (сигнатура совместима с retail-вызовом), `StyleFilterChanges`.
- [x] Поля элементов: `Power.token`, `Buffs.tickers = {}`, `Debuffs.tickers = {}`.

### Подстадия 1 — Аудит + леса ✅ ЗАВЕРШЕНА

- [x] Аудит: подтверждено, что бóльшая часть инфраструктуры под retail-StyleFilter уже на месте.
- [x] Добавлены хелперы в [Modules/Nameplates/Nameplates.lua](Modules/Nameplates/Nameplates.lua):
  - `NP:UnitExists(unit)` — обёртка над глобальным `UnitExists`.
  - `NP:SetupTarget(nameplate, _)` — no-op-рефреш `TargetIndicator` (полноценный classbar в WotLK не порт.).
- [x] Отложено в более поздние подстадии (когда реально потребуется логикой):
  - `frame.Cutaway = { Health = ..., Power = ... }` shim → подстадия 4.
  - `frame.battleFaction`, `frame.repReaction`, `frame.isFocused`, `frame.isPet`, `frame.RaidTargetIndex`, `frame.isTargetingMe` setters → подстадия 6.

### Подстадия 2 — Библиотеки ⬜ В ПЛАНЕ (следующий шаг)

- [ ] Подключить **LibCustomGlow-1.0** в `Libraries/LibCustomGlow-1.0/` (источник — общий fork-репо `fxpw/ElvUI_Libraries` или upstream).
  - Зарегистрировать как `E.Libs.CustomGlow = LibStub('LibCustomGlow-1.0')` в [Init.lua](Init.lua).
  - Добавить XML-загрузчик и включить в [Libraries/Load_Libraries.xml](Libraries/Load_Libraries.xml).
- [ ] Подключить **LibDispel-1.0** в `Libraries/LibDispel-1.0/` (WotLK-совместимый список dispels + bleed-list).
  - Зарегистрировать как `E.Libs.Dispel = LibStub('LibDispel-1.0')`.
  - Добавить в `Load_Libraries.xml`.
- [ ] Портировать хелпер `E:IsDispellableByMe(auraType)` из retail Core в [Core/API.lua](Core/API.lua).
- [ ] Проверить `BleedList = E.Libs.Dispel:GetBleedList()`.

### Подстадия 3 — Aura Check / Aura Data / Dispel Check ⬜

- [ ] Портировать `StyleFilterTickerCallback` / `StyleFilterTickerCreate` / `StyleFilterAuraWait` — заменить `C_Timer.NewTimer(sec, cb)` (точка) на `C_Timer:NewTimer(sec, cb)` (двоеточие, Sirus API). API возврата `:Cancel()` совпадает.
- [ ] Портировать `StyleFilterAuraData` + расширенный `StyleFilterAuraCheck` (новые параметры: `tickers`, `fromPet`, `onPet`, `mustHaveAll`).
- [ ] Адаптер для `UnitAura` под 3.3.5a (отсутствует `modRate`, сдвинут `isStealable`).
- [ ] Портировать `StyleFilterDispelCheck` через `E.Libs.Dispel` + `BleedList`.
- [ ] Портировать `StyleFilterCooldownCheck` (без `GetSpellCharges` — вернуть `nil`, без `IsPlayerSpell` — fallback на `IsSpellKnown`).

### Подстадия 4 — Set/Clear Changes + Flash + Border + ThreatUpdate ⬜

- [ ] Портировать `StyleFilterSetChanges` со всеми новыми action-ветками:
  - `HealthColor`, `PowerColor`, `Borders`, `HealthFlash`, `HealthTexture`, `HealthGlow`,
  - `Scale`, `Alpha`,
  - `NameTag`, `PowerTag`, `HealthTag`, `TitleTag`, `LevelTag`,
  - `Portrait`, `NameOnly`, `Visibility`.
- [ ] Портировать `StyleFilterClearChanges` с симметричной очисткой.
- [ ] Портировать `StyleFilterFinishedFlash` / `StyleFilterSetupFlash`.
- [ ] Портировать `StyleFilterBorderLock`.
- [ ] Портировать `StyleFilterHiddenState` + `StyleFilterClearVisibility`.
- [ ] Портировать `StyleFilterBaseUpdate` + `StyleFilterThreatUpdate`.
- [ ] **Слить** Sirus-специфичные действия `IconChanged` / `IconOnlyChanged` (для icon-only nameplate display).
- [ ] Адаптировать flat `frame.CutawayHealth` ↔ retail-вложенное `frame.Cutaway.Health` (выбрано: добавить shim `frame.Cutaway = { Health = frame.CutawayHealth }` в `StylePlate`).

### Подстадия 5 — Condition Check ⬜

- [ ] Полный faithful-порт `StyleFilterConditionCheck` (1759-строчный гигант).
- [ ] Гейтирование retail-only веток через `if E.Retail then ... end` (петбатлы, спецификации, queqsts, vehicles, focus и пр.).
- [ ] **Слить** Sirus-специфичные триггеры:
  - Тотем-система (~150 строк, полные WotLK totem spell IDs по школам air/earth/fire/water/other).
  - UniqueUnits (Shadow Fiend 34433, Kinetic Bomb 72052).
  - FixRussianTotemNames.
- [ ] Сохранить `ScaleIconFrame` helper как 3.3.5a fallback.

### Подстадия 6 — Events / Pooler / SetVariables / Watch / Register ⬜

- [ ] Портировать `StyleFilterEventFunctions` table.
- [ ] Портировать `StyleFilterSetVariables` / `StyleFilterClearVariables`.
- [ ] Портировать `StyleFilterTriggerList` / `StyleFilterEvents` / `StyleFilterPlateEvents` / `StyleFilterDefaultEvents` / `StyleFilterCastEvents` / `StyleFilterWatchEvents`.
- [ ] Портировать `StyleFilterConfigure`.
- [ ] Портировать pooler-фрейм (oUF event injection через fake_register).
- [ ] Портировать `StyleFilterEvents` / `StyleFilterUpdate` / `StyleFilterAddCustomCheck` / `StyleFilterRemoveCustomCheck`.
- [ ] Дозаполнить frame-поля в `NamePlateCallBack`: `battleFaction`, `repReaction`, `isFocused`, `isPet`, `RaidTargetIndex`, `isTargetingMe`.

### Подстадия 7 — Pass / Clear / Sort / Defaults / Options ⬜

- [ ] Портировать `StyleFilterPass` / `StyleFilterClear` / `StyleFilterSort` / `StyleFilterVehicleFunction` / `StyleFilterTargetFunction`.
- [ ] Портировать `StyleFilterClearDefaults(tbl)` / `StyleFilterCopyDefaults` / `StyleFilterInitialize` / `PLAYER_LOGOUT`.
- [ ] Обновить `E.StyleFilterDefaults` в [Settings/Profile.lua](Settings/Profile.lua) (новые ключи: `PowerColor`, `HealthGlow`, теги, `Portrait`, `Visibility`, `NameOnly`).
- [ ] Обновить опции в [ElvUI_OptionsUI/Filters.lua](../ElvUI_OptionsUI/Filters.lua) — новые триггеры / actions / гейтинг retail-only от пользователя (скрытые опции).
- [ ] Локализация: добавить недостающие строки в [Locales/](Locales/) (см. retail `E.CreatureTypes` локаль-таблица — портировать только русскую/английскую).

---

## 3) API-разрывы (для справки в ходе портирования)

| Retail API | Замена для Sirus 3.3.5a |
|---|---|
| `C_Timer.NewTimer(sec, cb)` (точка) | `C_Timer:NewTimer(sec, cb)` (двоеточие) — нативный Sirus API; возврат поддерживает `:Cancel()` |
| `UnitAura` (с `modRate`) | adapter в Auras: `modRate = 1` по умолчанию; сдвиг позиции `isStealable` |
| `GetSpecializationInfo` | пропустить ветку (gate `if false then`) |
| `IsPlayerSpell` | fallback `IsSpellKnown(spellID)` |
| `IsSpellKnownOrOverridesKnown` | fallback `IsSpellKnown(spellID)` |
| `UnitIsQuestBoss` | пропустить ветку |
| `UnitIsUnconscious` | пропустить ветку |
| `UnitHasIncomingResurrection` | пропустить ветку |
| `UnitInVehicle` | пропустить ветку |
| `C_PetBattles.*` | пропустить ветку |
| `UnitIsOwnerOrControllerOfUnit` | пропустить или fallback `UnitIsUnit` |
| `UnitIsOtherPlayersPet` | пропустить ветку |
| `UnitGroupRolesAssigned` | использовать `NP.GroupRoles[name]` + `GetPartyAssignment('MAINTANK')` |
| `GetSpellCharges` | вернуть `nil` |
| `E.MapInfo.*` | если потребуется — добавить минимальный shim в `Core/Distributor.lua` |
| `E:RegisterEventForObject` / `HasFunctionForObject` | проверить наличие; если нет — заменить на `frame:SetScript('OnEvent', ...)` |
| `E.TagFunctions.GetQuestData/GetTitleNPC` | проверить; если нет — пропустить связанные триггеры |

---

## 4) Решения, зафиксированные на старте v2

1. **Стратегия: stepwise, ~7 подстадий, несколько сессий** (выбрано пользователем).
2. **Обе библиотеки** (LibCustomGlow + LibDispel) **подключаем в `Libraries/`**, а не выносим во внешние плагины.
3. **Faithful-порт**: retail-only ветки **сохраняем, но гейтим** через `if E.Retail then ... end` — не удаляем.
4. **Sirus-специфика**: тотемы / unique-units / IconChanged / FixRussianTotemNames / ScaleIconFrame **сливаем в портированный код**.
5. **CutawayHealth**: оставляем flat-поле; добавляем `frame.Cutaway = { Health = frame.CutawayHealth }` shim, чтобы retail-ветки `frame.Cutaway.Health` не падали.

---

## 5) Definition of Done для v2

1. [Modules/Nameplates/StyleFilter.lua](Modules/Nameplates/StyleFilter.lua) приведён к функциональному паритету с retail (1759 строк → ~1500 после удаления чисто retail-веток, либо ~1759 если сохраним под gate).
2. Все Sirus-специфичные триггеры/actions работают как раньше.
3. Подключены `E.Libs.CustomGlow` + `E.Libs.Dispel`; `E:IsDispellableByMe` работает.
4. Профили мигрируются без потерь; новые ключи получают безопасные дефолты.
5. В реальных сценариях (PvE/PvP/raid) нет lua-ошибок и регрессий по производительности.
6. Опции в ElvUI_OptionsUI отражают новые actions/triggers; устаревшие/неподдерживаемые скрыты.

---

## 6) Артефакты v2

- Этот файл (`Nameplates_Refactor_Plan_v2.md`).
- Live-план в session memory: `/memories/session/stylefilter-port-plan.md`.
- Backup транскрипта: `c:\Users\fxpw\AppData\Roaming\Code\User\workspaceStorage\2c9584db7be570601d93ba4c13653bf0\GitHub.copilot-chat\transcripts\1b7f3aa6-d9e6-4b42-8f1d-a58fb197b369.jsonl`.

## 7) Текущий чекпоинт

| Подстадия | Статус |
|---|---|
| 1. Audit + scaffolding | ✅ DONE |
| 2. Libraries (LibCustomGlow + LibDispel) | ⬜ NEXT |
| 3. AuraCheck / AuraData / DispelCheck | ⬜ |
| 4. SetChanges / ClearChanges / Flash / Border / Hidden / BaseUpdate / ThreatUpdate | ⬜ |
| 5. ConditionCheck (faithful + Sirus merge) | ⬜ |
| 6. Events / pooler / SetVariables / Watch / Register | ⬜ |
| 7. Pass / Clear / Defaults / Profile + Options | ⬜ |



---

# v2.1 — РАСШИРЕННЫЙ СКОУП (full retail-like rewrite)

> Выбор пользователя 27.04.2026: «плейты на сирусе можно переписать полностью под retail like».
> Substages 1–3 закрыты (см. §7). Substage 4 пересматривается — старая модель Sirus-плейтов с `frame.StyleChanged`+`bordertop/bottom/left/right`+`CutawayHealth`+`IconFrame` заменяется retail-моделью.

## 8) Решения скоупа v2.1

| # | Решение |
|---|---|
| 1 | Бордеры Health/Power → `backdrop` + `SetBackdropBorderColor` (retail-style); удалить `bordertop/bottom/left/right` |
| 2 | `CutawayHealth` → объединённый `frame.Cutaway = { Health=…, Power=… }` |
| 3 | Tag-движок: `frame:Tag(text, format)` + `text:UpdateTag()` (обёртка над текущим Sirus tag-движком) |
| 4 | Добавить `frame.Power.token` |
| 5 | Удалить Sirus-only элементы: `HealComm.lua`, `HealerIcon.lua`, `ComboPoints.lua` (есть `ClassPower`), `Elite.lua`, `Highlight.lua`, `RaidIcon.lua` (есть `RaidTargetIndicator`), `IconFrame.lua` |
| 6 | Удалить из StyleFilter ветки `IconChanged` / `IconOnlyChanged` и `mod.Totems` / `mod.UniqueUnits` / `totemTypes` / `uniqueUnitTypes` / `ScaleIconFrame` / тотем-ID-листы |
| 7 | Добавить новые элементы: `Portrait.lua` (полноценный oUF Portrait, заменить текущий `Portraits.lua`), `PvP.lua` (PvP flag) |
| 8 | НЕ включаем: `BossMods.lua` (DBM/BigWigs), `Plugins.lua` |
| 9 | StyleFilter Set/ClearChanges → retail-сигнатура (HealthColor, PowerColor, Borders, HealthFlash, HealthTexture, HealthGlow, Scale, Alpha, NameTag/PowerTag/HealthTag/TitleTag/LevelTag, Portrait, NameOnly, Visibility) с таблицей `frame.StyleFilterChanges` |
| 10 | Удалить из Profile/OptionsUI устаревшие ключи (HealComm/HealerIcon/IconFrame/ComboPoints/Elite/Highlight/RaidIcon секции) |

## 9) Подстадии v2.1

| # | Подстадия | Содержание | Статус |
|---|---|---|---|
| 4a | StyleFilter helper-шимы | `StyleFilterChanges`, `StyleFilterHiddenState`, `StyleFilterBorderLock`, `StyleFilterFinishedFlash`, `StyleFilterSetupFlash`, `StyleFilterClearVisibility`, `StyleFilterBaseUpdate`, `StyleFilterThreatUpdate`. **Не трогает Set/ClearChanges.** Создаёт фундамент. | ⬜ NEXT |
| 4b | Element refactor: Cutaway | Объединить `CutawayHealth.lua` → `Cutaway.lua` с `.Health` + `.Power`. Update Power.lua/Health.lua call-sites. | ⬜ |
| 4c | Element refactor: Health backdrop | Переписать `Health.lua` + `HealthBar.lua` под retail backdrop+bordercolor; убрать 4 `border*` текстуры; обновить `Construct` + `Configure`. Сохранить визуал. | ⬜ |
| 4d | Element refactor: Power backdrop + token | То же для `Power.lua`; добавить `frame.Power.token` (обновлять в `UNIT_DISPLAYPOWER`). | ⬜ |
| 4e | Tag wrapper | Подключить `frame:Tag(text, format)` + `text:UpdateTag()` в `Tags.lua` / `Construct`. | ⬜ |
| 4f | StyleFilter Set/ClearChanges retail-style | Полностью переписать обе функции под retail-сигнатуру, заменить `frame.HealthColorChanged`-флаги на `frame.StyleFilterChanges`-таблицу. Поправить call-сайты в ConditionCheck. | ⬜ |
| 4g | Удаление Sirus-only элементов | Снести `HealComm.lua`, `HealerIcon.lua`, `ComboPoints.lua`, `Elite.lua`, `Highlight.lua`, `RaidIcon.lua`, `IconFrame.lua`. Поправить `Load_Nameplates.xml`, `Nameplates.lua` `Construct`/`Style`/`Update`. Чистка StyleFilter от тотем/uniqueUnit логики (~250 строк). | ⬜ |
| 5 | ConditionCheck (faithful + retail-only под `if E.Retail then`) | Полный retail-список триггеров. | ⬜ |
| 6 | Events / pooler / SetVariables / Watch / Register | Полный retail event-pipeline. | ⬜ |
| 7 | Pass / Clear / Defaults / Profile + OptionsUI cleanup | Удалить устаревшие ключи в Profile/Options; добавить новые секции (cutaway, glow, portrait, tags, healthFlash). | ⬜ |
| 8a | Element: Portrait (full oUF) | Заменить `Portraits.lua` retail-вариантом. | ⬜ |
| 8b | Element: PvP flag | Портировать `PvP.lua`. | ⬜ |

## 10) Definition of Done v2.1

1. `Modules/Nameplates/StyleFilter.lua` функционально эквивалентен retail (без BossMods/Plugins ветвей).
2. `Modules/Nameplates/Elements/` содержит ТОЛЬКО: `Auras`, `CastBar`, `ClassPower`, `Cutaway`, `Glow`, `Health`, `HealthBar`, `Level`, `Name`, `Portrait`, `Power`, `PvP`, `RaidTargetIndicator`, `Tags`, `Threat`.
3. Удалённые элементы (HealComm, HealerIcon, ComboPoints, Elite, Highlight, RaidIcon, IconFrame, Portraits) больше не загружаются.
4. Профили мигрируются: устаревшие ключи игнорируются, новые получают defaults.
5. Нет lua-ошибок при `/elvui` и переключении target/focus/combat/instance.
6. OptionsUI не содержит мёртвых секций для удалённых элементов.

