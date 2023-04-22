PLUGIN.name = "Combat system like Rehost"
PLUGIN.author = "Крыжовник#4511"
PLUGIN.description = "Combat system from Cyberpunk Rehost."

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
            -- Разрешаем игроку двигаться и атаковать
            hook.Remove("StartCommand", "CombatModeRestrictions")
            -- Создаем меню атак на клавишу "I"
            hook.Add("PlayerButtonDown", "CombatAttackKey", function(client, key)
                if key == KEY_I then
                    -- Создаем панель меню
                    local panel = vgui.Create("DFrame")
                    panel:SetSize(300, 200)
                    panel:Center()
                    panel:SetTitle("Меню атак")
                    panel:MakePopup()
                    -- Создаем кнопку для обычной атаки
                    local attackButton = vgui.Create("DButton", panel)
                    attackButton:SetSize(100, 50)
                    attackButton:SetPos(100, 50)
                    attackButton:SetText("Атаковать")
                    attackButton.DoClick = function()
                        -- Проверяем, что у игрока есть ходы
                        if combatMoves > 0 then
                            -- Отнимаем один ход
                            combatMoves = combatMoves - 1
                            -- Выводим сообщение об атаке в локальный чат и уведомление об оставшихся ходах
                            ix.chat.Send(LocalPlayer(), "me", "атакует "..LocalPlayer().combatTarget:Name()..".")
                            ix.util.Notify("У вас "..combatMoves.." ходов.")
                            -- Наносим урон цели в зависимости от оружия игрока
                            local weapon = LocalPlayer():GetActiveWeapon()
                            if weapon then
                                local damage = weapon:GetDamage()
                                LocalPlayer().combatTarget:TakeDamage(damage, LocalPlayer(), weapon)
                            end
                        else
                            -- Иначе выводим сообщение об ошибке
                            ix.util.Notify("У вас нет ходов.")
                        end
                        -- Закрываем меню атак
                        panel:Close()
                    end
                end
            end)
        else
            -- Если игрок закончил ход
            -- Выводим сообщение в локальный чат и уведомление о конце хода 
            ix.chat.Send(LocalPlayer(), "me", "заканчивает свой ход.")
            ix.util.Notify("Ваш ход закончился.")
            -- Запрещаем игроку двигаться и атаковать
            hook.Add("StartCommand", "CombatModeRestrictions", function(client, cmd)
                cmd:ClearMovement()
                cmd:ClearButtons()
            end)
            -- Удаляем меню атак с клавиши "I"
            hook.Remove("PlayerButtonDown", "CombatAttackKey")
            -- Восстанавливаем количество ходов до стандартного значения
            combatMoves = 10
        end
    else
        -- Если игрок не находится в боевом режиме или не имеет цели для атаки, выводим сообщение об ошибке
        ix.util.Notify("Вы не можете начать или закончить ход без боевого режима и цели.")
    end
end

-- Привязываем функцию к клавише "J"
hook.Add("PlayerButtonDown", "CombatTurnKey", function(client, key)
    if key == KEY_J then
        ToggleCombatTurn()
    end
end)
