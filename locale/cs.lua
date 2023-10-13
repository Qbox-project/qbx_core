local Translations = {
    error = {
        not_online = 'Hráč není online',
        wrong_format = 'Nesprávný formát',
        missing_args = 'Ne každý argument byl zadán (x, y, z)',
        missing_args2 = 'Všechny argumenty musí být vyplněny!',
        no_access = 'Žádný přístup k této příkazu',
        company_too_poor = 'Váš zaměstnavatel je na mizině',
        item_not_exist = 'Položka neexistuje',
        too_heavy = 'Inventář je příliš plný',
        location_not_exist = 'Místo neexistuje',
        duplicate_license = 'Nalezen duplicitní Rockstar License',
        no_valid_license  = 'Nenalezena platná Rockstar License',
        not_whitelisted = 'Nejste na whitelistu pro tento server',
        server_already_open = 'Server je již otevřen',
        server_already_closed = 'Server je již uzavřen',
        no_permission = 'Nemáte oprávnění pro toto..',
        no_waypoint = 'Není nastaven žádný waypoint.',
        tp_error = 'Chyba při teleportaci.',
        connecting_database_timeout = 'Připojení k databázi vypršelo. (Je SQL server zapnutý?)',
        connecting_error = 'Při připojování k serveru došlo k chybě. (Zkontrolujte serverovou konzoli)',
        no_match_character_registration = 'Jsou povoleny pouze písmena, mezery na konci nejsou povoleny a slova musí začínat velkým písmenem ve vstupních polích. Můžete však přidat slova s mezerami mezi nimi.'
    },
    success = {
        server_opened = 'Server byl otevřen',
        server_closed = 'Server byl uzavřen',
        teleported_waypoint = 'Teleportováno na waypoint.',
        character_deleted = 'Postava smazána!',
        character_deleted_citizenid = 'Postavu s občanským průkazem %{citizenid} jste úspěšně smazali.'
    },
    info = {
        received_paycheck = 'Obdrželi jste svůj plat ve výši $%{value}',
        job_info = 'Zaměstnání: %{value} | Stupeň: %{value2} | Úkoly: %{value3}',
        gang_info = 'Gang: %{value} | Stupeň: %{value2}',
        on_duty = 'Nyní jste v práci!',
        off_duty = 'Nyní jste mimo službu!',
        checking_ban = 'Ahoj %s. Kontrolujeme, zda jste zakázaný.',
        join_server = 'Vítejte %s na {Název Serveru}.',
        checking_whitelisted = 'Ahoj %s. Kontrolujeme vaši povolenost.',
        exploit_banned = 'Byli jste zakázáni za podvádění. Podívejte se na náš Discord pro více informací: %{discord}',
        exploit_dropped = 'Byli jste vyhoštěni za zneužívání',
        multichar_title = 'Qbox Multichar',
        multichar_new_character = 'Nová postava #%{number}',
        char_male = 'Muž',
        char_female = 'Žena',
        play = 'Hrát',
        play_description = 'Hrát jako %{playerName}',
        delete_character = 'Smazat postavu',
        delete_character_description = 'Smazat %{playerName}',
        logout_command_help = 'Odhlásí vás z vaší aktuální postavy',
        deletechar_command_help = 'Smazat postavu hráče',
        deletechar_command_arg_player_id = 'ID hráče',
        character_registration_title = 'Registrace postavy',
        first_name = 'Jméno',
        last_name = 'Příjmení',
        nationality = 'Národnost',
        gender = 'Pohlaví',
        birth_date = 'Datum narození',
        select_gender = 'Vyberte své pohlaví...'
    },
    command = {
        tp = {
            help = 'TP k hráči nebo souřadnicím (pouze pro adminy)',
            params = {
                x = { name = 'id/x', help = 'ID hráče nebo X pozice'},
                y = { name = 'y', help = 'Y pozice'},
                z = { name = 'z', help = 'Z pozice'},
            },
        },
        tpm = { help = 'TP na značku (pouze pro adminy)' },
        togglepvp = { help = 'Zapne/vypne PVP na serveru (pouze pro adminy)' },
        addpermission = {
            help = 'Přidat hráči oprávnění (pouze pro Bohy)',
            params = {
                id = { name = 'id', help = 'ID hráče' },
                permission = { name = 'permission', help = 'Úroveň oprávnění' },
            },
        },
        removepermission = {
            help = 'Odebrat hráči oprávnění (pouze pro Bohy)',
            params = {
                id = { name = 'id', help = 'ID hráče' },
                permission = { name = 'permission', help = 'Úroveň oprávnění' },
            },
        },
        openserver = { help = 'Otevřít server pro všechny (pouze pro adminy)' },
        closeserver = {
            help = 'Uzavřít server pro lidi bez oprávnění (pouze pro adminy)',
            params = {
                reason = { name = 'reason', help = 'Důvod uzavření (nepovinný)' },
            },
        },
        car = {
            help = 'Spawnout vozidlo (pouze pro adminy)',
            params = {
                model = { name = 'model', help = 'Název modelu vozidla' },
            },
        },
        dv = { help = 'Smazat vozidlo (pouze pro adminy)' },
        givemoney = {
            help = 'Dát hráči peníze (pouze pro adminy)',
            params = {
                id = { name = 'id', help = 'ID hráče' },
                moneytype = { name = 'moneytype', help = 'Typ peněz (hotovost, banka, kryptoměna)' },
                amount = { name = 'amount', help = 'Množství peněz' },
            },
        },
        setmoney = {
            help = 'Nastavit hráči množství peněz (pouze pro adminy)',
            params = {
                id = { name = 'id', help = 'ID hráče' },
                moneytype = { name = 'moneytype', help = 'Typ peněz (hotovost, banka, kryptoměna)' },
                amount = { name = 'amount', help = 'Množství peněz' },
            },
        },
        job = { help = 'Zkontrolovat své zaměstnání' },
        setjob = {
            help = 'Nastavit zaměstnání hráče (pouze pro adminy)',
            params = {
                id = { name = 'id', help = 'ID hráče' },
                job = { name = 'job', help = 'Název zaměstnání' },
                grade = { name = 'grade', help = 'Stupeň zaměstnání' },
            },
        },
        gang = { help = 'Zkontrolovat svůj gang' },
        setgang = {
            help = 'Nastavit gang hráče (pouze pro adminy)',
            params = {
                id = { name = 'id', help = 'ID hráče' },
                gang = { name = 'gang', help = 'Název gangu' },
                grade = { name = 'grade', help = 'Stupeň gangu' },
            },
        },
        ooc = { help = 'OOC zpráva do chatu' },
        me = {
            help = 'Zobrazit místní zprávu',
            params = {
                message = { name = 'message', help = 'Zpráva k odeslání' }
            },
        },
    },
}

if GetConvar('qb_locale', 'en') == 'cs' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
