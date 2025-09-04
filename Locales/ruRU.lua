-- Russian localization file for ruRU.
local E = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local L = E.Libs.ACL:NewLocale("ElvUI", "ruRU")

L[" |cff00ff00bound to |r"] = " |cff00ff00назначено для |r"
L["%s frame(s) has a conflicting anchor point, please change either the buff or debuff anchor point so they are not attached to each other. Forcing the debuffs to be attached to the main unitframe until fixed."] = "Обнаружен конфликт точек фиксирования во фрейме(ах) %s. Пожалуйста, переназначьте фиксирование баффов и дебаффов так, чтобы они не крепились друг к другу. Установлено принудительное крепление дебаффов к фрейму."
L["%s is attempting to share his filters with you. Would you like to accept the request?"] = "%s хочет передать Вам свои фильтры. Желаете ли Вы принять их?"
L["%s is attempting to share the profile %s with you. Would you like to accept the request?"] = "%s хочет передать Вам профиль %s. Желаете ли Вы принять его?"
L["%s: %s tried to call the protected function '%s'."] = "%s: %s tried to call the protected function '%s'."
L["(Hold Shift) Memory Usage"] = "(Зажать Shift) Использование памяти"
L["(Modifer Click) Collect Garbage"] = "(Клик с модификатором) Очистка мусора"
L["A raid marker feature is available by pressing Escape -> Keybinds scroll to the bottom under ElvUI and setting a keybind for the raid marker."] = "Функция рейдовых меток доступна в Escape -> Назначение клавиш. Прокрутите вниз до раздела ElvUI и назначьте клавишу для рейдовых меток."
L["A setting you have changed will change an option for this character only. This setting that you have changed will be uneffected by changing user profiles. Changing this setting requires that you reload your User Interface."] = "Настройка, которую Вы только что изменили, будет влиять только на этого персонажа. Она не будет изменяться при смене профиля. Также это изменение требует перезагрузки интерфейса для вступления в силу."
L["ABOVE_THREAT_FORMAT"] = "%s: %.0f%% [на %.0f%% опережаем |cff%02x%02x%02x%s|r]"
L["AFK"] = "АФК"
L["Accepting this will reset the UnitFrame settings for %s. Are you sure?"] = "Приняв это вы сбросите настройки для %s. Вы уверены?"
L["Accepting this will reset your Filter Priority lists for all auras on NamePlates. Are you sure?"] = "Приняв это вы сбросите ваши списки приоритетов для всех аур на индикаторах здоровья. Вы уверены?"
L["Accepting this will reset your Filter Priority lists for all auras on UnitFrames. Are you sure?"] = "Приняв это вы сбросите ваши списки приоритетов для всех аур на рамках юнитов. Вы уверены?"
L["Adjust the UI Scale to fit your screen, press the autoscale button to set the UI Scale automatically."] = "Измените масштаб интерфейса для вашего экрана. Нажмите автомасштаб, чтобы мы установили его сами."
L["All keybindings cleared for |cff00ff00%s|r."] = "Сброшены все назначения для |cff00ff00%s|r."
L["Already Running.. Bailing Out!"] = "Уже выполняется.. Бобер, выдыхай!"
L["Are you sure you want to apply this font to all ElvUI elements?"] = "Вы уверены, что хотите применить этот шрифт ко всем элементам ElvUI?"
L["Are you sure you want to disband the group?"] = "Вы уверены, что хотите распустить группу?"
L["Are you sure you want to reset all the settings on this profile?"] = "Вы уверены, что хотите сбросить все настройки для этого профиля?"
L["Are you sure you want to reset every mover back to it's default position?"] = "Вы уверены, что хотите сбросить все фиксаторы на позиции по умолчанию?"
L["Arena Frames"] = "Арена"
L["Arena Frame"] = "Фрейм Арены"
L["Aura Bars & Icons"] = "Полосы и иконки"
L["Auras Set"] = "Ауры установлены"
L["Auras"] = "Ауры"
L["Auto Scale"] = "Автоматический масштаб"
L["Avoidance Breakdown"] = "Распределение защиты"
L["BG"] = "ПБ"
L["BGL"] = "Лидер ПБ"
L["BNet Frame"] = "Оповещения BNet"
L["Bag Mover (Grow Down)"] = "Сумки (Рост вниз)"
L["Bag Mover (Grow Up)"] = "Сумки (Рост вверх)"
L["Bag Mover"] = "Фиксатор сумок"
L["Bags"] = "Сумки"
L["Bank Mover (Grow Down)"] = "Банк (Рост вниз)"
L["Bank Mover (Grow Up)"] = "Банк (Рост вверх)"
L["Bank"] = "Банк"
L["Bar "] = "Панель "
L["Bars"] = "Полосы"
L["Battleground datatexts temporarily hidden, to show type /bgstats or right click the 'C' icon near the minimap."] = "Информация поля боя временно скрыта. Для отображения введите /bgstat или ПКМ на иконке 'С' у миникарты."
L["Battleground datatexts will now show again if you are inside a battleground."] = "Информация поля боя снова будет отображаться, если Вы находитесь на них."
L["Binding"] = "Назначение"
L["Binds Discarded"] = "Назначения отменены"
L["Binds Saved"] = "Назначения сохранены"
L["BoE"] = true
L["BoU"] = "ПпИ"
L["Boss Frames"] = "Боссы"
L["Buffs"] = "Баффы"
L["CVars Set"] = "Настройки сброшены"
L["CVars"] = "Настройки игры"
L["Calendar"] = "Календарь"
L["Can't Roll"] = "Не могу бросить кости"
L["Can't buy anymore slots!"] = "Невозможно приобрести больше слотов!"
L["Caster DPS"] = "Заклинатель"
L["Character: "] = "Персонаж: "
L["Chat Set"] = "Чат настроен"
L["Chat"] = "Чат"
L["Choose a theme layout you wish to use for your initial setup."] = "Выберите тему, которую Вы хотите использовать."
L["Classbar"] = "Полоса класса"
L["Classic"] = "Классическая"
L["Combat Time"] = "Время боя"
L["Combobar"] = "Полоса серии"
L["Config Mode:"] = "Режим настройки:"
L["Confused.. Try Again!"] = "Что за?.. Попробуйте еще раз!"
L["Continue"] = "Продолжить"
L["Coords"] = "Коорд."
L["Count"] = "Кол-во"
L["DND"] = "ДНД"
L["DPS"] = "УВС"
L["Dark"] = "Темная"
L["Data From: %s"] = "Данные от: %s"
L["Data To: %s"] = true
L["Dead"] = "Труп"
L["Debuffs"] = "Дебаффы"
L["Deficit:"] = "Убыток:"
L["Delete gray items?"] = "Удалить серые предметы?"
L["Detected that your ElvUI OptionsUI addon is out of date. This may be a result of your Tukui Client being out of date. Please visit our download page and update your Tukui Client, then reinstall ElvUI. Not having your ElvUI OptionsUI addon up to date will result in missing options."] = "Мы обнаружили, что ElvUI OptionsUI устарел. Это может быть результатом устаревшей версии Tukui Client. Пожалуйста, посетите нашу страницу загрузок и обновите Tukui Client, а затем переустановите ElvUI. Устаревший ElvUI OptionsUI может привести к отсутствию некоторых опций."
L["Disable Warning"] = "Отключить предупреждение"
L["Disable"] = "Выключить"
L["Disband Group"] = "Распустить группу"
L["Discard"] = "Отменить"
L["Discord"] = true --Doesn't need translating
L["Do you enjoy the new ElvUI?"] = "Вам нравится ElvUI?"
L["Do you swear not to post in technical support about something not working without first disabling the addon/module combination first?"] = "Клянетесь ли Вы не постить на форуме технической поддержки, что что-то не работает, до того, как отключите другие аддоны/модули?"
L["Earned:"] = "Заработано"
L["ElvUI Installation"] = "Установка ElvUI"
L["ElvUI Plugin Installation"] = "Установка плагина ElvUI"
L["ElvUI has a dual spec feature which allows you to load different profiles based on your current spec on the fly. You can enable this from the profiles tab."] = "В ElvUI присутствует функция двойной специализации, которая позволит Вам использовать разные профили для разных наборов талантов. Вы можете включить эту функцию в разделе профилей."
L["ElvUI is five or more revisions out of date. You can download the newest version from https://github.com/ElvUI-WotLK/ElvUI"] = "Ваш ElvUI устарел более, чем на 5 версий. Обновите его на https://github.com/fxpw/ElvUI "
L["ElvUI is out of date. You can download the newest version from https://github.com/ElvUI-WotLK/ElvUI"] = "ElvUI устарел. Вы можете скачать последнюю версию с https://github.com/fxpw/ElvUI"
L["ElvUI needs to perform database optimizations please be patient."] = "ElvUI нужно провести оптимизацию базы данных. Подождите, пожалуйста."
L["ElvUI was updated while the game is still running. Please relaunch the game, as this is required for the files to be properly updated."] = "ElvUI обновился, вы можете скачать последнюю версию с https://github.com/fxpw/ElvUI"
L["Empty Slot"] = "Пустой слот"
L["Enable"] = "Включить"
L["Error resetting UnitFrame."] = "Ошибка сброса рамки юнита."
L["Experience Bar"] = "Полоса опыта"
L["Experience"] = "Опыт"
L["Export Now"] = "Экспортировать"
L["Farm Mode"] = "Режим фарма"
L["Filter download complete from %s, would you like to apply changes now?"] = "Завершена загрузка фильтров от %s. Желаете применить изменения сейчас?"
L["Finished"] = "Завершить"
L["Fishy Loot"] = "Улов"
L["Focus Castbar"] = "Полоса заклинаний фокуса"
L["Focus Frame"] = "Фокус"
L["FocusTarget Frame"] = "Цель фокуса"
L["For technical support visit us at https://github.com/ElvUI-WotLK."] = "За технической поддержкой обращайтесь на https://github.com/fxpw/ElvUI"
L["Frame"] = "Рамка"
L["Friends List"] = "Список друзей"
L["G"] = "Г"
L["GM Ticket Frame"] = "Запрос ГМу"
L["General"] = "Общие"
L["Ghost"] = "Призрак"
L["Gold"] = "Золото"
L["Grid Size:"] = "Размер сетки"
L["Guild"] = "Гильдия"
L["HP"] = "+ Исцел."
L["HPS"] = "ИВС"
L["Healer"] = "Лекарь"
L["Hit"] = "Хит"
L["BlockC"] = "Блок"
L["BlockA"] = "Блок у"
L["Hold Control + Right Click:"] = "Зажать Control + ПКМ:"
L["Hold Shift + Drag:"] = "Зажать shift и перетаскивать:"
L["Hold Shift + Right Click:"] = "Shift + ПКМ:"
L["Home Latency:"] = "Локальная задержка: "
L["Hover your mouse over any actionbutton or spellbook button to bind it. Press the ESC key to clear the current actionbutton's keybinding."] = "Наведите мышку на любую кнопку панели команд или книги заклинаний, чтобы создать назначение. Нажатие ESC убирает текущее назначение."
L["I Swear"] = "Я клянусь!"
L["INCOMPATIBLE_ADDON"] = "Аддон %s не совместим с модулем %s ElvUI. Пожалуйста, выберите отключить ли несовместимый аддон или модуль."
L["Icons Only"] = "Только иконки"
L["If you accidently remove a chat frame you can always go the in-game configuration menu, press install, go to the chat portion and reset them."] = "Если Вы случайно удалили вкладку чата, всегда можно сделать следующее: зайти в конфигурацию, запустить установку, дойти до шага настроек чата и сбросить их."
L["If you are experiencing issues with ElvUI try disabling all your addons except ElvUI, remember ElvUI is a full UI replacement addon, you cannot run two addons that do the same thing."] = "Если Вы испытываете проблемы с ElvUI, попробуйте отключить все аддоны, кроме самого ElvUI. Помните, ElvUI это аддон, полностью заменяющий интерфейс, Вы не можете одновременно использовать два аддона, выполняющих одинаковые функции."
L["If you have an icon or aurabar that you don't want to display simply hold down shift and right click the icon for it to disapear."] = "Если у вас есть иконка или полоса аур, которую вы не хотите отображать, просто shift+ПКМ на ней для занесения в черный список (она пропадет)."
L["Import Now"] = "Импортировать"
L["Importance: |cff07D400High|r"] = "Важность: |cff07D400Высокая|r"
L["Importance: |cffD3CF00Medium|r"] = "Важность: |cffD3CF00Средняя|r"
L["Importance: |cffFF0000Low|r"] = "Важность: |cffFF0000Низкая|r"
L["In Progress"] = "В процессе"
L["Installation Complete"] = "Установка завершена"
L["Invalid Target"] = "Неверная цель"
L["Item Level:"] = "Уровень предмета:"
L["Item Level:2"] = "Уровень предметов:"
L["KEY_ALT"] = "A"
L["KEY_CTRL"] = "C"
L["KEY_DELETE"] = "Del"
L["KEY_HOME"] = "Hm"
L["KEY_INSERT"] = "Ins"
L["KEY_MOUSEBUTTON"] = "M"
L["KEY_MOUSEWHEELDOWN"] = "MwD"
L["KEY_MOUSEWHEELUP"] = "MwU"
L["KEY_NUMPAD"] = "N"
L["KEY_PAGEDOWN"] = "PD"
L["KEY_PAGEUP"] = "PU"
L["KEY_SHIFT"] = "S"
L["KEY_SPACE"] = "SpB"
L["Key"] = "Клавиша"
L["LOGIN_MSG"] = "Добро пожаловать в %sElvUI|r версии %s%s|r, наберите /ec для доступа в меню настроек. Если Вам нужна техническая поддержка, посетите наш форум на https://github.com/fxpw/ElvUI или присоединяйтесь к серверу Discord: https://discord.gg/addonsforsirus"
L["Layout Set"] = "Расположение установлено"
L["Layout"] = "Расположение"
L["Left Chat"] = "Левый чат"
L["Left Click:"] = "ЛКМ:"
L["List of installations in queue:"] = "Очередь установки:"
L["Lock"] = "Закрепить"
L["Loot / Alert Frames"] = "Розыгрыш/оповещения"
L["Loot Frame"] = "Окно добычи"
L["Lord! It's a miracle! The download up and vanished like a fart in the wind! Try Again!"] = "Чтоб его! Загрузка была... да всплыла. Попробуйте еще раз!"
L["MA Frames"] = "Помощники"
L["MT Frames"] = "Танки"
L["Micro Bar"] = "Микроменю"
L["Minimap"] = "Миникарта"
L["MirrorTimer"] = "Таймер"
L["Miss Chance"] = "Вероятность промаха"
L["Mitigation By Level: "] = "Снижение на уровне: "
L["Movers"] = "Фиксаторы"
L["Must be in group with the player if he isn't on the same server as you."] = "Вы должны быть в группе в данным игроком, если он не с Вашего сервера."
L["No Guild"] = "Нет гильдии"
L["No bindings set."] = "Нет назначений"
L["No gray items to delete."] = "Нет предметов серого качества для удаления."
L["No, Revert Changes!"] = "Нет, обратить изменения!"
L["Nudge"] = "Сдвиг"
L["O"] = "Оф"
L["Objective Frame"] = "Задачи"
L["Offline"] = "Не в сети"
L["Oh lord, you have got ElvUI and Tukui both enabled at the same time. Select an addon to disable."] = "Японский городовой... у Вас одновременно включены ElvUi и Tukui. Выберите аддон для отключения."
L["On screen positions for different elements."] = "Положение разлицных элементов на экране"
L["One or more of the changes you have made require a ReloadUI."] = "Одно или несколько изменений требуют перезагрузки интерфейса"
L["One or more of the changes you have made will effect all characters using this addon. You will have to reload the user interface to see the changes you have made."] = "Одно или несколько изменений повлияют на всех персонажей, использующих этот аддон. Вы должны перезагрузить интерфейс для отображения этих изменений."
L["P"] = "Гр"
L["PL"] = "Лидер гр."
L["Party Frames"] = "Группа"
L["Pending"] = "Ожидает"
L["Pet Bar"] = "Панель питомца"
L["Pet Castbar"] = "Полоса заклинаний питомца"
L["Pet Frame"] = "Питомец"
L["PetTarget Frame"] = "Цель питомца"
L["Player Buffs"] = "Баффы игрока"
L["Player Castbar"] = "Полоса заклинаний игрока"
L["Player Debuffs"] = "Дебаффы игрока"
L["Player Frame"] = "Игрок"
L["Player Powerbar"] = "Полоса ресурса игрока"
L["Please click the button below so you can setup variables and ReloadUI."] = "Пожалуйста, нажмите кнопку ниже для установки переменных и перезагрузки интерфейса."
L["Please click the button below to setup your CVars."] = "Пожалуйста, нажмите кнопку ниже для сброса настроек."
L["Please press the continue button to go onto the next step."] = "Пожалуйста, нажмите кнопку 'Продолжить' для перехода к следующему шагу"
L["Preview Changes"] = "Посмотреть изменения"
L["Preview"] = "Предпросмотр"
L["Profile download complete from %s, but the profile %s already exists. Change the name or else it will overwrite the existing profile."] = "Загрузка профиля от %s завершена, но профиль %s уже существует. Измените его название или он перезапишет уже существующий профиль."
L["Profile download complete from %s, would you like to load the profile %s now?"] = "Загрузка профиля от %s завершена, хотите загрузить профиль %s сейчас?"
L["Profile request sent. Waiting for response from player."] = "Запрос на передачу профиля отправлен. Ждите, пожалуйста, ответа."
L["Profit:"] = "Прибыль:"
L["Purchase Bags"] = "Приобрести слот"
L["PvP"] = true
L["R"] = "Р"
L["RL"] = "РЛ"
L["RW"] = "Объявление"
L["Raid-10"] = "Рейд 10"
L["Raid-25"] = "Рейд 25"
L["Raid Frames"] = "Рейд"
L["Raid Menu"] = "Рейдовое меню"
L["Raid Pet Frames"] = "Питомцы рейда"
L["Raid-40 Frames"] = "Рейд 40"
L["Reload UI"] = "Перезагр UI"
L["Remaining:"] = "Осталось:"
L["Remove Bar %d Action Page"] = "Удалить панель %d из списка переключаемых"
L["Reputation Bar"] = "Полоса репутации"
L["Request was denied by user."] = "Запрос отклонен пользователем."
L["Reset Counters: Hold Shift + Left Click"] = "Сбросить счётчики: Shift + ЛКМ"
L["Reset Data: Hold Shift + Right Click"] = "Сбросить данные: Shift + ПКМ"
L["Reset Position"] = "Сбросить позицию"
L["Rested:"] = "Бодрость:"
L["Right Chat"] = "Правый чат"
L["Right Click:"] = "ПКМ:"
L["Middle Click:"] = "СКМ:"
L["ReloadUI"] = "Перезагрузить интерфейс"
L["SP"] = "+ Закл."
L["Save"] = "Сохранить"
L["Saved Dungeon(s)"] = "Сохраненнные подземелья"
L["Saved Raid(s)"] = "Сохраненные рейды"
L["Select the type of aura system you want to use with ElvUI's unitframes. Set to Aura Bar & Icons to use both aura bars and icons, set to icons only to only see icons."] = "Выберите тип си стемы аур, который будет применен к рамкам юнитов. Выберите \"Полосы и иконки\" для показа полос аур и иконок, выберите \"Только иконки\" для показа исключительно иконок."
L["Server: "] = "На сервере:"
L["Session:"] = "За сеанс:"
L["Setup CVars"] = "Сбросить настройки"
L["Setup Chat"] = "Настроить чат"
L["Show BG Texts"] = "Показать статистику бг"
L["Skip Process"] = "Пропустить установку"
L["Sort Bags"] = "Сортировать"
L["Spell/Heal Power"] = "Сила заклинаний"
L["Spent:"] = "Потрачено:"
L["Stance Bar"] = "Панель стоек"
L["Stats For:"] = "Статистика для:"
L["Steps"] = "Шаги"
L["Sticky Frames"] = "Клейкие фреймы"
L["System"] = "Система"
L["Talent Specialization:"] = "Таланты:"
L["Tank / Physical DPS"] = "Танк / Физ. урон"
L["Target Castbar"] = "Полоса заклинаний цели"
L["Target Frame"] = "Цель"
L["Target Powerbar"] = "Полоса ресурса цели"
L["TargetTarget Frame"] = "Цель цели"
L["TargetTargetTarget Frame"] = "Цель цели цели"
L["Targeted By:"] = "Является целью:"
L["Temporary Move"] = "Временное перемещение"
L["The UI Scale has been changed, if you would like to preview the change press the preview button. It is recommended that you reload your User Interface for the best appearance."] = "Масштаб интерфейса изменен. Если вы хотите посмотреть на результат, нажмите кнопку предпросмотра. Для лучшего результата рекомендуется перезагрузить интерфейс."
L["The chat windows function the same as Blizzard standard chat windows, you can right click the tabs and drag them around, rename, etc. Please click the button below to setup your chat windows."] = "Окна чата работают так же, как и в стандартном чате Blizzard. Вы можете нажать правую кнопку мыши на вкладках для перемещения, переименования и тд. Пожалуйста, нажмите кнопку ниже для настройки чата."
L["The focus unit can be set by typing /focus when you are targeting the unit you want to focus. It is recommended you make a macro to do this."] = "Запомненную цель (фокус) можно установить командой /focus при взятии нужного врага в цель. Для этого рекомендуется сделать макрос."
L["The in-game configuration menu can be accessed by typing the /ec command or by clicking the 'C' button on the minimap. Press the button below if you wish to skip the installation process."] = "Меню настроек можно вызвать командой /ес или кнопкой 'С' на миникарте. Нажмите кнопку ниже, если Вы хотите прервать процесс установки."
L["The profile you tried to import already exists. Choose a new name or accept to overwrite the existing profile."] = "Профиль, который вы хотите импортировать, уже существует. Задайте новой имя или примите для перезаписи существующего профиля."
L["The spell '%s' has been added to the Blacklist unitframe aura filter."] = "Заклинание \"%s\" было добавлено в фильтр \"Blacklist\" аур рамок юнитов."
L["Theme Set"] = "Тема установлена"
L["Theme Setup"] = "Тема"
L["This install process will help you learn some of the features in ElvUI has to offer and also prepare your user interface for usage."] = "Этот процесс установки поможет Вам узнать о некоторых функциях ElvUI и подготовить Ваш интерфейс к использованию."
L["This part of the installation process sets up your World of Warcraft default options it is recommended you should do this step for everything to behave properly."] = "Эта часть установки сбросит настройки World of Warcraft на конфигурацию по умолчанию. Рекомендуется выполнить этот шаг для надлежащей работы интерфейса."
L["This part of the installation process sets up your chat windows names, positions and colors."] = "Эта часть установки настроит названия, позиции и цвета вкладок чата."
L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."] = "Эта опция вызвала конфликт точек фиксации, в результате которого \"%s\" крепится к самому себе. Пожалуйста, проверьте настройки точек фиксации. \"%s\" будет прикреплено к \"%s\"."
L["This will change the layout of your unitframes and actionbars."] = "Это изменит расположение ваших рамок юнитов, рейда и панелей команд."
L["To move abilities on the actionbars by default hold shift + drag. You can change the modifier key from the actionbar options menu."] = "Для перемещения способностей по панелям команд нужно перемещать их с зажатой клавишей shift. Вы можете поменять модификатор в опциях панелей команд."
L["To setup which channels appear in which chat frame, right click the chat tab and go to settings."] = "Для настройки отображения каналов в чате кликните правой кнопкой мыши на закладке нужного чата и выберите пункт \"параметры\"."
L["Toggle Bags"] = "Показать сумки"
L["Toggle Chat Frame"] = "Показать/скрыть чат"
L["Toggle Configuration"] = "Конфигурация"
L["Tooltip"] = "Подсказка"
L["Total CPU:"] = "Использование процессора:"
L["Total Memory:"] = "Всего памяти:"
L["Total: "] = "Всего: "
L["Trigger"] = "Триггер"
L["Type /hellokitty to revert to old settings."] = "Напишите /hellokitty для возврата к предыдущим настройкам."
L["UI Scale"] = true
L["Unhittable:"] = "Полная защита от ударов"
L["Vehicle Seat Frame"] = "Техника"
L["Vendor / Delete Grays"] = "Продать/удалить серые предметы"
L["Vendored gray items for: %s"] = "Проданы серые предметы на сумму: %s"
L["Vendoring Grays"] = "Продаю хлам"
L["Welcome to ElvUI version %s!"] = "Добро пожаловать в ElvUI версии %s!"
L["Wintergrasp"] = "Озеро Ледяных Оков"
L["XP:"] = "Опыт:"
L["Yes, Keep Changes!"] = "Да, сохранить изменения!"
L["You are going to copy settings for |cffD3CF00\"%s\"|r from your current |cff4beb2c\"%s\"|r profile to |cff4beb2c\"%s\"|r profile. Are you sure?"] = "Вы собираетесь скопировать настройки для модуля |cffD3CF00\"%s\"|r из вашего текущего профиля |cff4beb2c\"%s\"|r в профиль |cff4beb2c\"%s\"|r. Вы уверены?"
L["You are going to copy settings for |cffD3CF00\"%s\"|r from |cff4beb2c\"%s\"|r profile to your current |cff4beb2c\"%s\"|r profile. Are you sure?"] = "Вы собираетесь скопировать настройки для модуля |cffD3CF00\"%s\"|r из вашего профиля |cff4beb2c\"%s\"|r в текущий профиль |cff4beb2c\"%s\"|r. Вы уверены?"
L["You are now finished with the installation process. If you are in need of technical support please visit us at https://github.com/fxpw/ElvUI"] = "Вы завершили процесс установки. Если Вам требуется техническая поддержка, посетите сайт https://github.com/fxpw/ElvUI"
L["You are using CPU Profiling. This causes decreased performance. Do you want to disable it or continue?"] = "Вы используете профайлинг ЦПУ. Это бьет по производительности. Вы точно уверены, что это нужно?"
L["You can access copy chat and chat menu functions by mouse over the top right corner of chat panel and left/right click on the button that will appear."] = "Вы можете получить доступ к функциям копирования чата и меню чата, наведя курсор на верхний правый угол панели чата и кликнув левой/правой кнопкой мыши на появившейся кнопке."
L["You can always change fonts and colors of any element of ElvUI from the in-game configuration."] = "Вы всегда можете изменить шрифты и цвета любого элемента ElvUI из меню конфигурации. Классическая и пиксельная темы не отличаются для русского клиента."
L["You can now choose what layout you wish to use based on your combat role."] = "Вы можете выбрать используемое расположение, основываясь на Вашей роли."
L["You can see someones average item level of their gear by holding shift and mousing over them. It should appear inside the tooltip."] = "Вы можете узнать средний уровень предметов игрока, зажав shift и наведя на них курсор. Информация будет отражена в подсказке."
L["You can set your keybinds quickly by typing /kb."] = "Вы можете быстро назначать клавиши, введя команду /kb."
L["You can toggle the microbar by using your middle mouse button on the minimap you can also accomplish this by enabling the actual microbar located in the actionbar settings."] = "Вы можете получить доступ к микроменю, кликнув средней кнопкой мыши на миникарте. Также Вы можете включить обычное микроменю в настройках панелей команд"
L["You can use the /resetui command to reset all of your movers. You can also use the command to reset a specific mover, /resetui <mover name>.\nExample: /resetui Player Frame"] = "Вы можете использовать команду /resetui чтобы сбросить положения всех фиксаторов. Вы также можете использовать команду /resetui <имя фиксатора> для сброса определенного фиксатора.\nПример: /resetui Player Frame"
L["You cannot copy settings from the same unit."] = "Вы не можете копировать установки из того же юнита."
L["You don't have enough money to repair all items."] = true
L["You don't have enough money to repair."] = "У вас недостаточно денег для ремонта."
L["You don't have permission to mark targets."] = "У вас нет разрешения на установку меток"
L["You have imported settings which may require a UI reload to take effect. Reload now?"] = "Вы импортировали настройки, которые могут потребовать перезагрузки для вступления в силу. Перезагрузить?"
L["You must purchase a bank slot first!"] = "Сперва Вы должны приобрести дополнительный слот в банке!"
L["You still have ElvUI_Config installed. ElvUI_Config has been renamed to ElvUI_OptionsUI, please remove it."] = true
L["Your items have been repaired for: "] = "Ремонт обошелся в "
L["Your items have been repaired using guild bank funds for: "] = "Ремонт обошелся гильдии в "
L["Your profile was successfully recieved by the player."] = "Ваш профиль успешно получен целью. Ура, товарищи!"
L["copperabbrev"] = "|cffeda55fм|r"
L["goldabbrev"] = "|cffffd700з|r"
L["lvl"] = "ур."
L["says"] = "говорит"
L["silverabbrev"] = "|cffc7c7cfс|r"
L["whispers"] = "шепчет"
L["yells"] = "кричит"
L["|cFFE30000Lua error recieved. You can view the error message when you exit combat."] = "|cFFE30000Обнаружена ошибка lua. Вы получите отчет о ней после завершения боя."

----------------------------------
L["RED_ENABLE"] = "|cFFff3333Включить|r"
L["GREEN_ENABLE"] = "|cFF33ff33Включить|r"
L["DESC_MOVERCONFIG"] = [=[Блокировка отключена. Передвиньте фреймы и нажмите "Закрепить", когда закончите.
Настройки:
  ЛКМ - Показать фрейм сдвига.
  ПКМ - Открыть конфигурацию фрейма.
  Shift + ПКМ - Спрятать фрейм на время.
  Ctrl + ПКМ - Сбросить фрейм до началальных настроек.
]=]

--- ru ru tags
L["Colors names by player class or NPC reaction"] = "Изменение цвета по класску игрока или реакции NPC"
L["Colors the power text based upon its type"] = "Цвета текста энергии класса на основе его типа"
L["Colors the following tags by difficulty, red for impossible, orange for hard, green for easy"] = "Цвета следующих тегов по сложности, красным для невозможного, оранжевый для сложного, зеленый для легкого"
L["Changes color of health text, depending on the unit's current health"] = "Меняет цвет здоровья текста, в зависимости от текущего здоровья .ybnf"
L["Changes color of health, depending on the unit's threat situation"] = "Меняет цвет здоровья, в зависимости от ситуации с угрозой"
L["Changes color of health, depending on the unit's classification"] = "Меняет цвет здоровья, в зависимости от классификации юнита"
L["Displays the unit's classification (e.g. 'ELITE' and 'RARE')"] = "Отображает классификацию юнита (например, «элита» и «редкий»)"
L["Displays the unit's classification in short form (e.g. '+' for ELITE and 'R' for RARE)"] = "Отображает классификацию юнита в короткой форме (например, «+» для элиты и «R» для редких)"
L["Displays 'Rare' when the unit is a rare or rareelite"] = "Отображает «редкий», когда юнит редкий или элитный"
L["Displays the guild name"] = "Отображает имя гильдии"
L["Displays the guild rank"] = "Отображает звание гильдии"
L["Displays the guild name with < > brackets (e.g. <GUILD>)"] = "Отображает имя гильдии с помощью <> скобок (например, <Guild>)"
L["Displays the guild name with < > and transliteration (e.g. <GUILD>)"]= "Отображает название гильдии с помощью <> и транслитерации (например, <Guild>))"
L["Displays the guild name with transliteration for cyrillic letters"]= "Отображает имя гильдии с транслитерацией для кириллических букв"
L["Displays the current HP without decimals"]= "Отображает текущие HP без десятичных"
L["Displays max HP without decimals"] = "Отображает максимальный HP без десятичных действий"
L["Displays percentage HP without decimals"]= "Отображает процент HP без десятичных"
L["Displays the health as a deficit and the name at full health"] = "Отображает здоровье как дефицит и имя при полном здоровье"
L["Displays the current health of the unit"] = "Отображает текущее здоровье юнита"
L["Displays the current and maximum health of the unit, separated by a dash"] = "Отображает текущее и максимальное здоровье юнита, разделенного тире"
L["Displays the current and maximum health of the unit, separated by a dash, without status"] = "Отображает текущее и максимальное здоровье юнита, разделенного тире, без статуса"
L["Displays the current and max hp of the unit, separated by a dash (% when not full hp)"] = "Отображает текущий и максимальный HP юнита, разделенный тире (%, когда не полный HP)"
L["Displays the current and max hp of the unit, separated by a dash (% when not full hp), without status"] = "Отображает текущий и максимальный HP юнита, разделенный тире (%, когда не полный HP) без статуса"
L["Displays the current health of the unit, without status"] = "Отображает текущее здоровье юнита, без статуса"
L["Displays the current hp of the unit (% when not full hp)"] = "Отображает текущий HP юнита (%, когда не полный HP)"
L["Displays the current hp of the unit (% when not full hp), without status"] = "Отображает текущий HP юнита (%, когда не полный HP) без статуса"
L["Displays the health of the unit as a deficit (Total Health - Current Health = -Deficit)"] = "Отображает здоровье юнита как дефицит (полное здоровье - нынешнее здоровье = -дефицит)"
L["Displays the health of the unit as a deficit, without status"] = "Отображает здоровье юнита как дефицит, без статуса"
L["Displays the health deficit as a percentage and the full name of the unit"] = "Отображает дефицит здоровья в процентах и полное имя юнита"
L["Displays the health deficit as a percentage and the name of the unit (limited to 20 letters)"] = "Отображает дефицит здоровья в процентах и название юнита (ограничено 20 букв)"
L["Displays the health deficit as a percentage and the name of the unit (limited to 15 letters)"] = "Отображает дефицит здоровья в процентах и название юнита (ограничено 15 букв)"
L["Displays the health deficit as a percentage and the name of the unit (limited to 10 letters)"] = "Отображает дефицит здоровья в процентах и название юнита (ограничено 10 букв)"
L["Displays the health deficit as a percentage and the name of the unit (limited to 5 letters)"] = "Отображает дефицит здоровья в процентах и название юнита (ограничено 5 букв)"
L["Displays the maximum health of the unit"] = "Отображает максимальное здоровье юнита"
L["Displays the current health of the unit as a percentage"] = "Отображает текущее здоровье юнита в процентах"
L["Displays the unit's current health as a percentage, without status"] = "Отображает текущее здоровье юнита как процент, без статуса"
L["Displays the missing health of the unit in whole numbers, when not at full health"] = "Отображает отсутствие здоровья юнита во всех числах, когда не полное здоровья"
L["Only display the unit's level if it is not the same as yours"] = "Отображать только уровень юнита, если он не такой, как ваш"
L["Displays the level of the unit"] = "Отображает уровень юнита"
L["Displays the unit's current amount of mana (e.g. 97200)"] = "Отображает текущую ману юнита (например, 97200)"
L["Displays the current amount of mana as a whole number and a percentage, separated by a dash"] = "Отображает текущее количество маны в целом и процент, разделенный тире"
L["Displays the current mana and max mana, separated by a dash"] = "Отображает текущую ману и макс маны, разделенные тире"
L["Displays the current mana and max mana, separated by a dash (% when not full power)"] = "Отображает текущую ману и макс маны,, разделенную тире (%, когда не фул энергия)"
L["Displays the mana of the unit as a percentage value"] = "Отображает ману юнита как процентное значение"
L["Displays the unit's maximum mana"] = "Отображает максимальную ману юнита"
L["Displays the mana deficit (Total Mana - Current Mana = -Deficit)"] = "Отображает дефицит маны  (Какое общее количество - Текущая мана = -Дефицит)"
L["Displays the current mana without decimals"] = "Отображает текущую ману без десятичных"
L["Displays the max amount of mana the unit can have"] = "Отображает максимальное количество маны юнита которое он может иметь"
L["Displays the full name of the unit without any letter limitation"] = "Отображает полное имя юнита без каких-либо ограничения букв"
L["Displays the name of the unit (limited to 5 letters)"] = "Отображает имя юнита (ограничено 5 букв)"
L["Displays the name of the unit (limited to 10 letters)"] = "Отображает имя юнита (ограничено 10 букв)"
L["Displays the name of the unit (limited to 15 letters)"] = "Отображает имя юнита (ограничено 15 букв)"
L["Displays the name of the unit (limited to 20 letters)"] = "Отображает имя юнита (ограничено 20 букв)"
L["Displays the name of the unit with transliteration for cyrillic letters (limited to 5 letters)"] = "Отображает имя юнита с транслитерацией для кириллических букв (ограничено 5 букв)"
L["Displays the name of the unit with transliteration for cyrillic letters (limited to 10 letters)"] = "Отображает имя юнита с транслитерацией для кириллических букв (ограничено 10 букв)"
L["Displays the name of the unit with transliteration for cyrillic letters (limited to 15 letters)"] = "Отображает имя юнита с транслитерацией для кириллических букв (ограничено 15 букв)"
L["Displays the name of the unit with transliteration for cyrillic letters (limited to 20 letters)"] = "Отображает имя юнита с транслитерацией для кириллических букв (ограничено 20 букв)"
L["Displays the name of the unit with abbreviation (e.g. 'Shadowfury Witch Doctor' becomes 'S. W. Doctor')"] = "Отображает название юнита со сокращением (например, «ShadowFury Witch Doctor» становится «S. W. Doctor»)"
L["Displays the name of the unit with abbreviation (limited to 5 letters)"] = "Отображает имя юнита с сокращением (ограничено 5 букв)"
L["Displays the name of the unit with abbreviation (limited to 10 letters)"] = "Отображает имя юнита с сокращением (ограничено 10 букв)"
L["Displays the name of the unit with abbreviation (limited to 15 letters)"] = "Отображает имя юнита с сокращением (ограничено 15 букв)"
L["Displays the name of the unit with abbreviation (limited to 20 letters)"] = "Отображает имя юнита с сокращением (ограничено 20 букв)"
L["Replace the name of the unit with 'DEAD' or 'OFFLINE' if applicable (limited to 5 letters)"] = "Заменяет имя юнита c «Dead» или «Offline», если применимо (ограничено 5 букв)"
L["Replace the name of the unit with 'DEAD' or 'OFFLINE' if applicable (limited to 10 letters)"] = "Заменяет имя юнита c «Dead» или «Offline», если применимо (ограничено 10 букв)"
L["Replace the name of the unit with 'DEAD' or 'OFFLINE' if applicable (limited to 15 letters)"] = "Заменяет имя юнита c «Dead» или «Offline», если применимо (ограничено 15 букв)"
L["Replace the name of the unit with 'DEAD' or 'OFFLINE' if applicable (limited to 20 letters)"] = "Заменяет имя юнита c «Dead» или «Offline», если применимо (ограничено 20 букв)"
L["Displays player name and title"] = "Отображает имя игрока и заголовок"
L["Displays the group number the unit is in ('1' - '8')"] = "Отображает номер группы юнита находищегося в ('1' - '8')"
L["Displays 'L' if the unit is the group/raid leader"] = "Отображает «L», если юнит является лидером группы / рейда"
L["Displays 'Leader' if the unit is the group/raid leader"] = "Отображает «лидер», если юнит является лидером  группы /  рейда"
L["Displays the unit's current amount of power"] = "Отображает текущий объем энергии юнита"
L["Displays the current power and power as a percentage, separated by a dash"] = "Отображает текущую энергию и энергию в процентах, разделенную тире"
L["Displays the current power and max power, separated by a dash"] = "Отображает текущую энергию и максимальную энергию, разделенную тире"
L["Displays the current power and max power, separated by a dash (% when not full power)"] = "Отображает текущую энергию и максимальную энергию, разделенную тире (%, когда не полная мощность)"
L["Displays the unit's power as a percentage"] = "Отображает энергию юнита в процентах"
L["Displays the unit's maximum power"] = "Отображает максимальную энергию юнита"
L["Displays the power as a deficit (Total Power - Current Power = -Deficit)"] = "Отображает энергию как дефицит (общая энергию - текущия энергию = -дефицит)"
L["Displays the unit's current power without decimals"] = "Отображает текущую энергию юнита без десятичных чисел"
L["Displays the unit's percentage power without decimals "] = "Отображает процентную энергию юнита без десятичных чисел"
L["Displays the max amount of power of the unit in whole numbers without decimals"] = "Отображает максимальное количество энергию юнита во всех числах без десятичных чисел"
L["Displays the missing power of the unit in whole numbers when not at full power"] = "Отображает отсутствующую энергию юнита во всех числах, когда не полная энергия"
L["Displays the server name"] = "Отображает имя сервера"
L["Displays the server name with transliteration for cyrillic letters"] = "Отображает имя сервера с транслитерацией для кириллических букв"
L["Displays the server name with a dash in front (e.g. -Realm)"] = "Отображает имя сервера с помощью тире спереди (например, -realm)"
L["Displays the server name with transliteration for cyrillic letters and a dash in front"] = "Отображает имя сервера с транслитерацией для кирилличных букв и тире спереди"
L["Displays zzz, dead, ghost, offline"] = "Отображает ZZZ, Dead, Ghost, Offline"
L["Displays a timer for how long a unit has had the status (e.g 'DEAD - 0:34')"] = "Отображает таймер для того, как долго юнит имеет статус (например, мертвый - 0:34 ')"
L["Displays <AFK> if the Unit is afk"] = "Отображает <AFK> если юнит отошел"
L["Displays <DEAD> if the unit is dead"] = "Отображает <Dead> если юнит мертв"
L["Displays zzz if the unit is dead"] = "Отображает ZZZ, если юнит мертв"
L["Displays 'PvP' if the unit is pvp flagged"] = "Отображает «PVP», если юнит является PVP помеченым"
L["Displays 'OFFLINE' if the unit is disconnected"] = "Отображает 'OFFLINE', если юнит отключен"
L["Displays the current target of the unit"] = "Отображает текущую цель юнита"
L["Displays the current target of the unit (limited to 5 letters)"] = "Отображает текущую цель юнита (ограничена 5 букв)"
L["Displays the current target of the unit (limited to 10 letters)"] = "Отображает текущую цель юнита (ограничена 10 букв)"
L["Displays the current target of the unit (limited to 15 letters)"] = "Отображает текущую цель юнита (ограничена 15 букв)"
L["Displays the current target of the unit (limited to 20 letters)"] = "Отображает текущую цель юнита (ограничена 20 букв)"
L["Displays the current target of the unit with transliteration for cyrillic letters"] = "Отображает текущую цель юнита с транслитерацией для кириллических букв"
L["Displays the current target of the unit with transliteration for cyrillic letters (limited to 5 letters)"] = "Отображает текущую цель юнита с транслитерацией для кириллических букв (ограничена 5 букв)"
L["Displays the current target of the unit with transliteration for cyrillic letters (limited to 10 letters)"] = "Отображает текущую цель юнита с транслитерацией для кириллических букв (ограничена 10 букв)"
L["Displays the current target of the unit with transliteration for cyrillic letters (limited to 15 letters)"] = "Отображает текущую цель юнита с транслитерацией для кириллических букв (ограничена 15 букв)"
L["Displays the current target of the unit with transliteration for cyrillic letters (limited to 20 letters)"] = "Отображает текущую цель юнита с транслитерацией для кириллических букв (ограничена 20 букв)"
L["Displays the current threat"] = "Отображает текущую угрозу"
L["Displays the current threat as a percent"] = "Отображает текущую угрозу в процентах"
L["Displays the current threat as a value"] = "Отображает текущую угрозу как значение"
L["Displays the player's class or creature's type"] = "Отображает класс игрока или типа существа"
L["Displays your current specialization as text"] = "Отображает вашу текущую специализацию в виде текста"
L["Displays the class of the unit, if that unit is a player"] = "Отображает класс юнита, если этот юнит - это игрок"
L["Changes color of the next tag based on how difficult the unit is compared to the players level"] = "Изменяет цвет следующего тега на основе того, насколько сложно юнит сравнивается с уровнем игрока"
L["Displays 'Alliance' or 'Horde' or 'Renegade'"] = "Отображает «Альянс» или «Орда» или «Ренегат»"
L["Displays faction icon"] = "Отображает иконку фракции"
L["Displays the character '+' if the unit is an elite or rare-elite"] = "Отображает символ «+», если юнит является элитой или редкой элитой"
L["Displays the arena number 1-5"] = "Отображает номер на арене 1-5"


L["Colors"] = "Цвета"
L["Classification"] = "Классификация"
L["Guild"] = "Гильдия"
L["Health"] = "Здоровье"
L["Level"] = "Уровень"
L["Mana"] = "Мана"
L["Names"] = "Имена"
L["Party and Raid"] = "Группа и Рейд"
L["Power"] = "Энергия"
L["Realm"] = "Область"
L["Status"] = "Статус"
L["Target"] = "Цель"
L["Threat"] = "Угроза"
L["Miscellaneous"] = "Разное"
L["Collections"] = "Коллекции"
L["EncounterJ"] = "Приключения"

L["Absorbs"] = "Поглощение"
L["Absorbs Prediction"] = "Прогноз поглощений"
L["Absorb StatusBar Texture"] = "Текстура полос состояния"
L["Display LFG Icons in chat."] = "Отображать иконки ролей в чате"
L["Displays all incoming heals"] = "Отображать любое входящее исцеление"
-- L["Displays an icon near your Guild Master in chat.\n\n|cffFF0000Note:|r Some messages in chat history may disappear on login."] = "Отображать иконку рядом с сообщениями главы вашей гильдии в чате.\n\n|cffFF0000Предупреждение:|r Некоторые сообщения могут исчезать из истории чата при входе в игру."
L["Displays only incoming heals from other units"] = "Отображать только входящее исцеление от других юнитов"
L["Displays only personal incoming heals"] = "Отображать только личное входящее исцеление"
L["Displays the amount of absorbs"] = "Отображать количество поглощения"
L["Displays the amount of absorbs in ()"] = "Отображать количество поглощения в ()"

L["Group Units"] = "Групповые юниты"
-- L["Guild Master Icon"] = "Иконка Главы гильдии"
L["Heal Absorbs"] = "Поглощение исцеления"
L["LFG Icons"] = "Стиль иконок"
L["Individual Units"] = "Одиночные юниты"
L["Links"] = "Ссылки"
L["Max Overflow is set to zero. Absorb Overflows will be hidden when using Overflow style.\nIf used together Max Overflow at zero and Overflow mode will act like Normal mode without the ending sliver of overflow."] = "Макс. переполнение установлено на значение 0. Отображение прогноза поглощения в режиме \"Переполнение\" будет скрыто.\nИспользование режима \"Переполнение\" совместно со значением макс. переполнения равным нулю, будет выглядеть так же, как использование режима \"Нормальный\" - без отображения полосы прогноза вне рамки юнита."
L["Modules"] = "Модули"
L["Normal"] = "Нормальный"
L["Options for customizing unit frames. Please don't change these setting when ElvUI's testing frames for bosses and arena teams are shown. That will make them invisible until retoggling."] = "Опции для дополнительной настройки рамок юнитов. Пожалуйста, не изменяйте эти настройки в то же время, когда включен тестовый режим рамок боссов и арены в ElvUI. Это сделает их невидимыми до повторного включения."
L["Absorb Style"] = "Стиль отображения"
L["Position"] = "Позиция"
L["Anchor Point"] = "Позиция"
L["Over Absorbs"] = "\"Лишнее\" поглощение"
L["Over Heal Absorbs"] = "\"Лишнее\" поглощение исцеления"
L["Overflow"] = "Переполнение"
L["Party"] = "Группа"
L["Raid"] = "Рейд"
L["Reversed"] = "Перевернутый"
L["Stacked"] = "Сложенный"
L["Show a prediction bar with all absorbs on the unitframe. Also displays a slightly different colored bar for heal absorbing shields"] = "Панель прогноза всех поглощений в рамке юнита. Также, отображает немного другой цвет для отображения поглощающих исцеление щитов."
L["Submodules and Coding:"] = "Модули и код:"
L["Target"] = "Цель"
L["You are using Overflow with Max Overflow at zero."] = "Вы используете режим \"Переполнение\" со значением макс. переполнения равным нулю."
L["Wrapped"] = "Обернутый"
L["Ghost Frame"] = "Фрейм призрака"
L["VehicleLeaveButton"] = "Высадить"
L["Fly Vehicle Exit"] = "Высадить"
L["PowerCostDisplay"] = "Предсказание траты ресурса"
L["PowerCostDisplaydesc"] = "Предсказание траты ресурса на панели ресурса, удар героя у воина, применение заклинаний и т.д"
L["Zodiac:"] = "Зодиак:"



--~afkwords
L["RandomWords"] = { ---- не может быть только одной записи рандомные цитаты
	"Я потратил на эту строчку 20 минут ©fxpw",
	"Не стой в огне!",
	"Зеленое бей, красное хиль",
	"Фельярд в 2020",
	"А я сейчас вам покажу, откуда на Беларусь готовилось нападение...",
	"Жизнь — странствие по пути познания себя",
	"Ходят слухи что Эскобар все еще стоит у банка орды в Даларане",
	"Слева это где левая рука, а справа - где правая",
	"Упал жди ролл",
	"Опять АФК да? А монетка все еще не покручена",
	"Человека можно вытащить из раздела Аниме, но нельзя вытащить раздел Аниме из человека ©Dezuron",
	"Три икс в кубе плюс константа...\n Ну что там?",
	"Нужно больше золота",
	"Знаете, я тут подумал. \nОтправляйтесь ка вы в Аниме ©Trautsolla",
	"Хилы почему упал танк?!\n ХП кончилось",
	"Make Love, Not WARcraft",
	"ДХ в среду",
	"На все бабки в босса ©Сырсколбасой",
	"Частица в сделку не входила",
	"Меньше целей - проще хилить",
	"Если серьезно, то мы стремимся сделать все классы в PvE равными ©Dezuron",
	"Кто не курит, тот бьет треш",
	"Во всем виновата сова",
	"А чем диспеллят паладины?",
	"Если отрубить Хищнику голову, он будет еще час разговаривать",
	"Уже можно крутить? А щас? Я хочу нажать БШ ©Величайший",
	"Тут может быть ваша реклама",
	"Критический успех",
	"Сон для слабых! Пока ты спишь, враг делает дейлики!",
	"**аная *****, срочно переписать, ужасный быдлокод, пиздец просто ©Nyll",
	"Оффтоп в спец разделе. Мем смешной, так что РО не будет",
	"За аурой в пм ©fxpw",
	"Продам гараж",
	"ВСЁ КОРАБЛЬ, ВСЁ В АРТСТАЙЛА, МИНУС АРТСТАЙЛ, КУРОНИТИ УБИРАЕТ АРТСТАЙЛА",
	"Человек родился усталым и живет, чтобы отдохнуть",
	"Как говорил мой дед: \"я твой дед\"",
	"Отдохни днем, чтобы ночью ты мог поспать",
	"Если видишь, что кто-то отдыхает - помоги ему.",
	"Делай меньше и только то, что можешь, а и то, что можешь, перепоручи другим.",
	"Когда случайно захочешь поработать, сядь, подожди - увидишь, это пройдет",
	"Когда видишь место, где едят и пьют - присоединяйся, когда видишь место, где работают - уходи, чтобы не мешать",
	"Если волк молчит то лучше его не перебивать",
	"Ты можешь быть бесконечно прав, но какой в этом смысл, если твой РЛ плачет ©Vakh",
	"\"Зато у меня есть курочка\" ©Лирой Дженкинс",
	"Чистите треш пока тут, а я пойду узнаю где надо",
	"Вещей 303 не будет в бронзовом святилище и не планировалось ©Crystal",
	"Он сам спулился",
	"Для того чтобы выбежать из лужи нажмите W",
	"А сколько у тебя брюлей?",
	"Лучше брюль в рулетке, чем в кармане",
	"Обходи эту шелупонь",
	"Новый Details в среду",
	"Пачините макросы пж(",
	"Майнер у тебя, а у них бабосики ©Dister",
	"Факт о человеческой лени №212682340236: Вы слишком ленивы, чтобы прочитать это число",
	"Общительная, симпатичная девушка без комплексов продаст вагон цемента",
	"Самый известный персонаж в World of Warcraft – безымянный мурлок",
	"Практически все названия достижений являются интернет-мемами, известными фразами или исковерканными слоганами",
	"Следующие выражение будет ложным",
	"Прошлое выражение было истиной",
	"У жезлов не было авто-атаки, нужно было постоянно кликать на них",
	"Маги могли топить противников, используя заклинания «Контроль»",
	"Vae, fratelle, praestupidus es, sit tibi terra levis ©Сократ",
	"Qui vocaris minus ad rem pertinet, plurimum interest cum te vocent ad bibendum",
	"Vivo, ut non satis dormiam",
	"Sit Vis tecum",
	"Я тонко намекну, после реворка т5, НИКТО не будет дамажить 50к и 40к тоже никто ©Dezuron",
	"Проблемы с агрогенерацией... их почти нет. ©Illusion",
	"Подземелья? Да, тут вышло неловко. ©Illusion",
	"Семь раз исправь, один раз получи бан",
	"Где бан там и мы",

	"Бану - время, потехе - час",
	"Не имей сто рублей, а имей сто маунтов",
	"Газерер от бана недалеко лежит",
	"Молодой симпатичный юноша, за ваши деньги сделает вам ВА любой сложности",
	"Семь репортов напиши - один отказ получи",
	"Тише пишешь - дольше бан будет",
	"Терпение и труд вас не забанят",

	"Rock and Stone",
	"Было ваше - стало наше",
	"Если волк молчит то лучше его не перебивай",
	"Ничего нет важнее семьи",
	"Я уже неделю на работу хожу и ни разу еще туда не пришел",
	"Бабы — они не бабы, они женщины",
	"Я, очень сильно на вас когда смотрю, у меня кажется, что все ваши волосы — это пшеница",
	"Как говорят американцы — кто хоть раз в жизни умирал, впредь уже точно не станет погибать",
	"Ты в глаза свои видел? В них интеллекта никакого, пустота да и только",
	"— Мальчик, а ты почему не дома? Ночь же на дворе! Ты чего? \n — А я заснуть никак не могу. Меня вопрос мучает. Как устроен кожух индукционной тигельной печи?",
	"Кто рано встает, тому Фалафель подает",
	"Напиши хороший код и ты будешь нужен пару дней, напиши плохой код и будешь нужен всегда",
	"Для того чтобы давать на 5к DPS больше необходимо...",
	"Хотите добавить свою смешную цитату? Пишите в https://discord.gg/addony-dlia-sirus-su-914079030125420565",
	"Можно убить архимонда старым бабкиным способом: нужно взять лишь пять...",
	"Чтобы не падать на Хладе хватает лишь одной чайной ложки...",
	"Главный астролог страны сообщил о появлении в космосе новой звезды, благосклонной лишь в этим знакам зодиака на Алгалоне...",
	"Для того чтобы убить треш перед 4м боссом в Хиджале необходимо достать...",
	"Люди в шоке, при траях утюга ушёл из жизни известный...",
	"Ванга предсказывала это кремлю, для того чтобы убить гидроса нужно лишь...",
	"Всего пару ложек этого средства и т6 будут выпадать комками...",
	"- Я уже сдался ©Шутка \n - Какой сдался, ты 2 по дпсу, работай ©Oyasumi",
	"Дворфы крутятся - Лавеха мутится",
	"-Почему треш в рейде? ©Лекарня \n -Это рейд в треше. ©Фалафель",
	"Пипяу ©Пристика",
	"Не могу стоять, пока другие работают... Пойду полежу. © Орк-рабочий",
	"— Первое условие бессмертия — смерть.",
	"Вскрытие показало: больной спал.",
	"Время лечит, но жрец — быстрее.",
	"— Мы должны разгромить гномов.\n	— Так мы и есть гномы!\n	— А-а… Ну да…",
	"Ваш аддон апдейтер просто кекс ©Флорин",
	"Траут Солловна? Энхи сируса передают вам привет. ©SatanaePet",
	"– Надеюсь после выхода Фельярда вам не придется перекачивать профы?\nНе волнуйтесь месье, у меня их нет.\n	©Такси",
	"Если вы запомнили ретрика, но не запомнили во что он был одет, значит он был одет идеально.\n © Дьявол носит Прада",
	"Догоняй рейд и пристраивайся, розовый. Быстрее, быстрее! Ты уже родился таким немощным или специально тренировался чтоб таким стать? Нажимай кнопки активнее! Рейд закончится, пока ты будешь давить свою тридцатку. Больше дпс! Ты че, еще и сдохнуть собрался, чтобы никто не заметил этого позора? Давай-давай, нажимай кнопочки! Че, пальцы запутались? Плохо? Может это от того, что ты пивка перед рейдом въе бахнул?",
	"Это мои аддоны. Таких аддонов много, но эти мои.\n ©Цельнометаллическая оболочка",
	"Энхи в список апа не входили\n ©Wi",
	"Выделяться должны вещи которые должны выделяться, а не то что захотел игрок ©Illusion",
	"Если выпивать по банке пива каждый раз когда падает х2, то за неделю можно стать алкоголиком",
	"Представь что я бутылка минералки, объясни нормально)\n ©Illusion",
	"Пирики сильнее апаются от постоянки, чем взрыв от прожимки © Dreamfish",
	"Лев если и заходил на сирус - то в рбк, и остров даже не делал, по злому, монетку взять, без удовольствия",
	"Я футбольный мячик ©Лекарня-х2",
	"Нормальные пацаны играют в геншит ©Генезис",
	"Скиньте макрос на шоки ©ix.temp",
	"Так, парни, мне скучно, надо срочно кого-то вывести на конфликт @Линдаа",
	"Не убивай кринжовую часть себя, убей ту, которая кринжует @Kayoshi",
	"Возьмем на акаму 6 дизармов, будет достаточно  @Wizlipuzli",
	"Мистер воук, какой кап крита на элема?\n @кап крита - 52%  @ix.temp",
	"ЖЕКА ПЕРЕЛЕТАЙ @Blackdogyy",
	"Лишь утратив все до конца, мы обретаем свободу @Бойцовский клуб",
	"Чтобы открыть какой-нибудь портал, надо сначала закрыть какой-нибудь портал, а у нас ЛичКинг на дворе.",
}