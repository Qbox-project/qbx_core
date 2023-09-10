local Translations = {
    error = {
        not_online = 'Player not online',
        wrong_format = 'Incorrect format',
        missing_args = 'Not every argument has been entered (x, y, z)',
        missing_args2 = 'All arguments must be filled out!',
        no_access = 'No access to this command',
        company_too_poor = 'Your employer is broke',
        item_not_exist = 'Item does not exist',
        too_heavy = 'Inventory too full',
        location_not_exist = 'Location does not exist',
        duplicate_license = 'Duplicate Rockstar License Found',
        no_valid_license  = 'No Valid Rockstar License Found',
        not_whitelisted = 'You\'re not whitelisted for this server',
        server_already_open = 'The server is already open',
        server_already_closed = 'The server is already closed',
        no_permission = 'You don\'t have permissions for this..',
        no_waypoint = 'No Waypoint Set.',
        tp_error = 'Error While Teleporting.',
        connecting_database_timeout = 'Connection to database timed out. (Is the SQL server on?)',
        connecting_error = 'An error occurred while connecting to the server. (Check your server console)',
        no_match_character_registration = 'Anything other than letters aren\'t allowed, trailing whitespaces aren\'t allowed either and words must start with a capital letter in input fields. You can however add words with spaces inbetween.'
    },
    success = {
        server_opened = 'The server has been opened',
        server_closed = 'The server has been closed',
        teleported_waypoint = 'Teleported To Waypoint.',
        character_deleted = 'Character deleted!',
        character_deleted_citizenid = 'You successfully deleted the character with Citizen ID %{citizenid}.'
    },
    info = {
        received_paycheck = 'You received your paycheck of $%{value}',
        job_info = 'Job: %{value} | Grade: %{value2} | Duty: %{value3}',
        gang_info = 'Gang: %{value} | Grade: %{value2}',
        on_duty = 'You are now on duty!',
        off_duty = 'You are now off duty!',
        checking_ban = 'Hello %s. We are checking if you are banned.',
        join_server = 'Welcome %s to {Server Name}.',
        checking_whitelisted = 'Hello %s. We are checking your allowance.',
        exploit_banned = 'You have been banned for cheating. Check our Discord for more information: %{discord}',
        exploit_dropped = 'You Have Been Kicked For Exploitation',
        multichar_title = 'Qbox Multichar',
        multichar_new_character = 'New Character #%{number}',
        char_male = 'Male',
        char_female = 'Female',
        play = 'Play',
        play_description = 'Play as %{playerName}',
        delete_character = 'Delete Character',
        delete_character_description = 'Delete %{playerName}',
        logout_command_help = 'Logs you out of your current character',
        deletechar_command_help = 'Delete a players character',
        deletechar_command_arg_player_id = 'Player ID',
        character_registration_title = 'Character Registration',
        first_name = 'First Name',
        last_name = 'Last Name',
        nationality = 'Nationality',
        gender = 'Gender',
        birth_date = 'Birth Date'
    },
    command = {
        tp = {
            help = 'TP To Player or Coords (Admin Only)',
            params = {
                x = { name = 'id/x', help = 'ID of player or X position'},
                y = { name = 'y', help = 'Y position'},
                z = { name = 'z', help = 'Z position'},
            },
        },
        tpm = { help = 'TP To Marker (Admin Only)' },
        togglepvp = { help = 'Toggle PVP on the server (Admin Only)' },
        addpermission = {
            help = 'Give Player Permissions (God Only)',
            params = {
                id = { name = 'id', help = 'ID of player' },
                permission = { name = 'permission', help = 'Permission level' },
            },
        },
        removepermission = {
            help = 'Remove Player Permissions (God Only)',
            params = {
                id = { name = 'id', help = 'ID of player' },
                permission = { name = 'permission', help = 'Permission level' },
            },
        },
        openserver = { help = 'Open the server for everyone (Admin Only)' },
        closeserver = {
            help = 'Close the server for people without permissions (Admin Only)',
            params = {
                reason = { name = 'reason', help = 'Reason for closing (optional)' },
            },
        },
        car = {
            help = 'Spawn Vehicle (Admin Only)',
            params = {
                model = { name = 'model', help = 'Model name of the vehicle' },
            },
        },
        dv = { help = 'Delete Vehicle (Admin Only)' },
        givemoney = {
            help = 'Give A Player Money (Admin Only)',
            params = {
                id = { name = 'id', help = 'Player ID' },
                moneytype = { name = 'moneytype', help = 'Type of money (cash, bank, crypto)' },
                amount = { name = 'amount', help = 'Amount of money' },
            },
        },
        setmoney = {
            help = 'Set Players Money Amount (Admin Only)',
            params = {
                id = { name = 'id', help = 'Player ID' },
                moneytype = { name = 'moneytype', help = 'Type of money (cash, bank, crypto)' },
                amount = { name = 'amount', help = 'Amount of money' },
            },
        },
        job = { help = 'Check Your Job' },
        setjob = {
            help = 'Set A Players Job (Admin Only)',
            params = {
                id = { name = 'id', help = 'Player ID' },
                job = { name = 'job', help = 'Job name' },
                grade = { name = 'grade', help = 'Job grade' },
            },
        },
        gang = { help = 'Check Your Gang' },
        setgang = {
            help = 'Set A Players Gang (Admin Only)',
            params = {
                id = { name = 'id', help = 'Player ID' },
                gang = { name = 'gang', help = 'Gang name' },
                grade = { name = 'grade', help = 'Gang grade' },
            },
        },
        ooc = { help = 'OOC Chat Message' },
        me = {
            help = 'Show local message',
            params = {
                message = { name = 'message', help = 'Message to send' }
            },
        },
    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true,
})
