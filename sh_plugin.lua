-- Создаем переменные для хранения состояния боевого режима и количества ходов
local combatMode = false
local combatTurn = false
local combatMoves = 10

-- Создаем функцию для входа и выхода из боевого режима на клавишу "H"
function ToggleCombatMode()
    -- Проверяем, что игрок не находится в ходе
    if not combatTurn then
        -- Переключаем состояние боевого режима
        combatMode = not combatMode
        -- Если игрок вошел в боевой режим
        if combatMode then
            -- Выводим сообщение в локальный чат
            ix.chat.Send(LocalPlayer(), "me", "входит в боевой режим.")
            -- Запрещаем игроку двигаться и атаковать
            hook.Add("StartCommand", "CombatModeRestrictions", function(client, cmd)
                cmd:ClearMovement()
                cmd:ClearButtons()
            end)
            -- Добавляем пункт Target в контекстное меню
            hook.Add("PopulateContextMenu", "CombatModeTarget", function(panel)
                panel:AddOption("Target", function()
                    -- Получаем трассировку луча от курсора игрока
                    local trace = LocalPlayer():GetEyeTrace()
                    -- Если луч попал в другого игрока
                    if trace.Entity:IsPlayer() then
                        -- Задаем его как цель для атаки
                        LocalPlayer().combatTarget = trace.Entity
                        -- Выводим сообщение об этом
                        ix.util.Notify("Вы выбрали "..trace.Entity:Name().." как цель.")
                    else
                        -- Иначе выводим сообщение об ошибке
                        ix.util.Notify("Вы должны выбрать игрока как цель.")
                    end
                end)
            end)
        else
            -- Если игрок вышел из боевого режима
            -- Выводим сообщение в локальный чат
            ix.chat.Send(LocalPlayer(), "me", "выходит из боевого режима.")
            -- Удаляем ограничения на движение и атаку
            hook.Remove("StartCommand", "CombatModeRestrictions")
            -- Удаляем пункт Target из контекстного меню
            hook.Remove("PopulateContextMenu", "CombatModeTarget")
            -- Сбрасываем цель для атаки
            LocalPlayer().combatTarget = nil
        end
    else
        -- Если игрок находится в ходе, выводим сообщение об ошибке
        ix.util.Notify("Вы не можете покинуть боевой режим во время хода.")
    end
end

-- Привязываем функцию к клавише "H"
hook.Add("PlayerButtonDown", "CombatModeKey", function(client, key)
    if key == KEY_H then
        ToggleCombatMode()
    end
end)

-- Создаем функцию для начала и окончания хода на клавишу "J"
function ToggleCombatTurn()
    -- Проверяем, что игрок находится в боевом режиме и имеет цель для атаки
    if combatMode and LocalPlayer().combatTarget then
        -- Переключаем состояние хода
        combatTurn = not combatTurn
        -- Если игрок начал ход
        if combatTurn then
            -- Выводим сообщение в локальный чат и уведомление об оставшихся ходах 
            ix.chat.Send(LocalPlayer(), "me", "начинает свой ход.")
            ix.util.Notify("У вас "..combatMoves.." ходов.")
            -- Р
