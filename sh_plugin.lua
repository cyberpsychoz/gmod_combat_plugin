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

-- Создаем опцию Target в контекстном меню
properties.Add("Target", {
    -- Устанавливаем текст и иконку опции
    MenuLabel = "Target",
    MenuIcon = "icon16/eye.png",

    -- Создаем функцию проверки, которая возвращает true, если выбранный объект является игроком и находится в зоне видимости
    Filter = function(self, ent, ply)
        -- Проверяем, что объект является игроком
        if (!IsValid(ent) or !ent:IsPlayer()) then return false end
        -- Проверяем, что объект находится в зоне видимости
        local trace = ply:GetEyeTrace()
        if (trace.Entity != ent) then return false end
        -- Возвращаем true
        return true
    end,

    -- Создаем функцию действия, которая устанавливает выбранный объект как цель для атаки
    Action = function(self, ent)
        -- Получаем локального игрока
        local ply = LocalPlayer()
        -- Устанавливаем выбранный объект как цель
        ply:SetNWEntity("target", ent)
        -- Отправляем сообщение в локальный чат
        chat.AddText(Color(255, 255, 255), "You have selected ", ent:Nick(), " as your target.")
    end
})
