local Translations = {
    error = {
        not_online = 'Играчът не е онлайн',
        wrong_format = 'Некоректен формат',
        missing_args = 'Не всички аргументи са въведени (x, y, z)',
        missing_args2 = 'Всички аргументи трябва да бъдат попълнени!',
        no_access = 'Нямате достъп до тази команда',
        company_too_poor = 'Твоят работодател е фалирал',
        item_not_exist = 'Артикулът не съществува',
        too_heavy = 'Ивентарът е препълнен',
        location_not_exist = 'Локацията не съществува',
        duplicate_license = 'Намерен е дубликат на Rockstar лиценза',
        no_valid_license = 'Не е намерен валиден Rockstar лиценз',
        not_whitelisted = 'Вие не сте включени в белия списък за този сървър',
        server_already_open = 'Сървърът вече е отворен',
        server_already_closed = 'Сървърът вече е затворен',
        no_permission = 'Нямате разрешения за това ..',
        no_waypoint = 'Няма зададена точка.',
        tp_error = 'Грешка при телепортиране.',
        connecting_database_timeout = 'Свързването с базата данни изтече. (SQL сървърът работи ли?)',
    },
    success = {
        server_opened = 'Сървърът е отворен',
        server_closed = 'Сървърът е затворен',
        teleported_waypoint = 'Телепортиран до точка.',
    },
    info = {
        received_paycheck = 'Получихте заплатата си от $%{value}',
        job_info = 'Работа: %{value} | Ранг: %{value2} | Дежурство: %{value3}',
        gang_info = 'Банда: %{value} | Ранг: %{value2}',
        on_duty = 'Вече сте на дежурство!',
        off_duty = 'Вече не сте на дежурство!',
        checking_ban = 'Здравей %s. Проверяваме дали сте баннат.',
        join_server = 'Добре дошъл %s в {Име на сървъра}.',
        checking_whitelisted = 'Здравей %s. Проверяваме вашето разрешение.',
        exploit_banned = 'Бяхте баннат за измама. Проверете нашия Discord за повече информация: %{discord}',
        exploit_dropped = 'Бяхте изхвърлен за използване на експлоит',
    },
    command = {
        tp = {
            help = 'ТП към Играч или Координати (Само за админи)',
            params = {
                x = { name = 'id/x', help = 'ID на играча или X позиция' },
                y = { name = 'y', help = 'Y позиция' },
                z = { name = 'z', help = 'Z позиция' },
            },
        },
        tpm = { help = 'ТП до Маркер (Само за админи)' },
        togglepvp = { help = 'Превключване на PVP на сървъра (Само за админи)' },
        addpermission = {
            help = 'Дайте на играч разрешения (Само за Бог)',
            params = {
                id = { name = 'id', help = 'ID на играча' },
                permission = { name = 'permission', help = 'Ниво на разрешение' },
            },
        },
        removepermission = {
            help = 'Премахнете разрешенията на играча (Само за Бог)',
            params = {
                id = { name = 'id', help = 'ID на играча' },
                permission = { name = 'permission', help = 'Ниво на разрешение' },
            },
        },
        openserver = { help = 'Отворете сървъра за всички (Само за админи)' },
        closeserver = {
            help = 'Затворете сървъра за хора без разрешения (Само за админи)',
            params = {
                reason = { name = 'reason', help = 'Причина за затваряне (по избор)' },
            },
        },
        car = {
            help = 'Изваждане на превозно средство от джоба (Само за админи)',
            params = {
                model = { name = 'model', help = 'Модел на превозното средство' },
            },
        },
        dv = { help = 'Прибиране на превозно средство в джоба (Само за админи)' },
        givemoney = {
            help = 'Дайте на играч пари (Само за админи)',
            params = {
                id = { name = 'id', help = 'ID на играча' },
                moneytype = { name = 'moneytype', help = 'Тип пари (cash, bank, crypto)' },
                amount = { name = 'amount', help = 'Сума пари' },
            },
        },
        setmoney = {
            help = 'Задайте сумата на парите на играча (Само за админи)',
            params = {
                id = { name = 'id', help = 'ID на играча' },
                moneytype = { name = 'moneytype', help = 'Тип пари (cash, bank, crypto)' },
                amount = { name = 'amount', help = 'Сума пари' },
            },
        },
        job = { help = 'Проверка на работата ви' },
        setjob = {
            help = 'Задайте работата на играча (Само за админи)',
            params = {
                id = { name = 'id', help = 'ID на играча' },
                job = { name = 'job', help = 'Име на работата' },
                grade = { name = 'grade', help = 'Ранг на работата' },
            },
        },
        gang = { help = 'Проверете вашата банда' },
        setgang = {
            help = 'Задайте бандата на играча (Само за админи)',
            params = {
                id = { name = 'id', help = 'ID на играча' },
                gang = { name = 'gang', help = 'Име на бандата' },
                grade = { name = 'grade', help = 'Ранг на бандата' },
            },
        },
        ooc = { help = 'OOC чат съобщение' },
        me = {
            help = 'Показване на локално съобщение',
            params = {
                message = { name = 'message', help = 'Съобщение за изпращане' }
            },
        },
    },
}

if GetConvar('qb_locale', 'en') == 'bg' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
