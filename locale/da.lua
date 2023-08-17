local Translations = {
    error = {
        not_online = 'Spilleren er ikke i byen',
        wrong_format = 'Inkorrekt format',
        missing_args = 'Ikke alle argumenter blev indtastet (x, y, z)',
        missing_args2 = 'Alle argumenter skal være udfyldt!',
        no_access = 'Du har ikke adgang til denne kommando',
        company_too_poor = 'Din arbejdsgiver er fattig',
        item_not_exist = 'Ting findes ikke',
        too_heavy = 'Inventaret er fyldt',
        location_not_exist = 'Lokationen eksisterer ikke',
        duplicate_license = 'Duplikeret Rockstar licens blev fundet',
        no_valid_license  = 'Ingen gyldig Rockstar licens blev fundet',
        not_whitelisted = 'Du er ikke whitelisted på denne server',
        server_already_open = 'Denne server er allerede åben',
        server_already_closed = 'Denne server er allerede lukket',
        no_permission = 'Du har ikke adgang til at gøre dette',
        no_waypoint = 'Ingen waypoint sat.',
        tp_error = 'Fejl opstod mens du teleporterede.',
        connecting_database_timeout = 'Forbindelsen til databasen gik tabt. (Er SQL serveren tændt?)',
    },
    success = {
        server_opened = 'Denne server er blevet åbnet',
        server_closed = 'Denne server er blevet lukket',
        teleported_waypoint = 'Teleporteret til Waypoint.',
    },
    info = {
        received_paycheck = 'Du modtog din løn på $%{value}',
        job_info = 'Arbejde: %{value} | Rang: %{value2} | Vagt: %{value3}',
        gang_info = 'Bande: %{value} | Rang: %{value2}',
        on_duty = 'Du er nu på arbejde!',
        off_duty = 'Du er ikke længere på arbejde!',
        checking_ban = 'Hej %s. Vi tjekker om du er udelukket.',
        join_server = 'Velkommen %s til {Server Name}.',
        checking_whitelisted = 'Hej %s. Vi tjekker din tilladelse.',
        exploit_banned = 'Du er blevet udelukket for at snyde. Tjek vores Discord for mere information: %{discord}',
        exploit_dropped = 'Du er blevet smidt ud for udnyttelse',
    },
    command = {
        tp = {
            help = 'TP Til Spiller eller Koordinater (Kun Admins)',
            params = {
                x = { name = 'id/x', help = 'ID på spilleren eller X koordinat'},
                y = { name = 'y', help = 'Y koordinat'},
                z = { name = 'z', help = 'Z koordinat'},
            },
        },
        tpm = { help = 'TP Til markør (Kun Admins)' },
        togglepvp = { help = 'Aktiver/deaktiver PVP på serveren (Kun Admins)' },
        addpermission = {
            help = 'Giv Spiller Tilladelse (Kun Gud)',
            params = {
                id = { name = 'id', help = 'ID på spilleren' },
                permission = { name = 'permission', help = 'Tilladelses niveau' },
            },
        },
        removepermission = {
            help = 'Fjern Spiller Tilladelse (Kun Gud)',
            params = {
                id = { name = 'id', help = 'ID på spilleren' },
                permission = { name = 'permission', help = 'Tilladelses niveau' },
            },
        },
        openserver = { help = 'Åben serveren for alle (Kun Admins)' },
        closeserver = {
            help = 'Luk serveren for alle uden tilladelse (Kun Admins)',
            params = {
                reason = { name = 'reason', help = 'Grundlaget for lukningen (valgfri)' },
            },
        },
        car = {
            help = 'Spawn Køretøj (Kun Admins)',
            params = {
                model = { name = 'model', help = 'Modelnavn på køretøjet' },
            },
        },
        dv = { help = 'Fjern Køretøj (Kun Admins)' },
        givemoney = {
            help = 'Giv en spiller penge (Kun Admins)',
            params = {
                id = { name = 'id', help = 'Spiller ID' },
                moneytype = { name = 'moneytype', help = 'Type af penge (cash, bank, crypto)' },
                amount = { name = 'amount', help = 'Mængde penge' },
            },
        },
        setmoney = {
            help = 'Sæt spillerens pengebeløb (Kun Admins)',
            params = {
                id = { name = 'id', help = 'Spiller ID' },
                moneytype = { name = 'moneytype', help = 'Type af penge (cash, bank, crypto)' },
                amount = { name = 'amount', help = 'Mængde penge' },
            },
        },
        job = { help = 'Tjek dit job' },
        setjob = {
            help = 'Sæt en spillers job (Kun Admins)',
            params = {
                id = { name = 'id', help = 'Spiller ID' },
                job = { name = 'job', help = 'Job Navn' },
                grade = { name = 'grade', help = 'Job Rang' },
            },
        },
        gang = { help = 'Tjek din bande' },
        setgang = {
            help = 'Sæt en spillers bande (Kun Admins)',
            params = {
                id = { name = 'id', help = 'Spiller ID' },
                gang = { name = 'gang', help = 'Bande Navn' },
                grade = { name = 'grade', help = 'Bande Rang' },
            },
        },
        ooc = { help = 'OOC Chat Besked' },
        me = {
            help = 'Vis lokale beskeder',
            params = {
                message = { name = 'message', help = 'Besked at sende' }
            },
        },
    },
}

if GetConvar('qb_locale', 'en') == 'da' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
