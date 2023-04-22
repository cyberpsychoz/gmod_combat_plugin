PLUGIN.name = "Combat Mode"
PLUGIN.description = "A plugin that allows players to enter and exit combat mode with a key press."
PLUGIN.author = "Крыжовник"

-- Создаем функцию, которая вызывается при нажатии клавиши H
function PLUGIN:KeyPress(ply, key)
    -- Проверяем, что игрок нажал клавишу H
    if (key == IN_RELOAD) then
        -- Проверяем, находится ли игрок в режиме боя
        if (ply:GetNWBool("inCombat")) then
            -- Выходим из режима боя
            ply:SetNWBool("inCombat", false)
            -- Размораживаем игрока
            ply:Freeze(false)
            -- Отправляем сообщение в локальный чат
            chat.AddText(ply, Color(255, 255, 255), " has exited combat mode.")
        else
            -- Входим в режим боя
            ply:SetNWBool("inCombat", true)
            -- Замораживаем игрока
            ply:Freeze(true)
            -- Устанавливаем количество ходов равным 10
            ply:SetNWInt("turns", 10)
            -- Отправляем сообщение в локальный чат
            chat.AddText(ply, Color(255, 255, 255), " has entered combat mode.")
        end
    end
end

-- Создаем хук KeyPress, который вызывает нашу функцию при нажатии клавиши
hook.Add("KeyPress", "CombatMode", function(ply, key)
    PLUGIN:KeyPress(ply, key)
end)
