--- This config is only used for initially populating the database. Once a gang is in the database, modifying or removing the gang will have no effect. Instead, either use core exports or modify the data in the database directly (only when the server is offline!)

---@type table<string, Gang>
return {
	['none'] = {
		label = 'No Gang',
		grades = {
            [0] = {
                name = 'Unaffiliated'
            },
        },
	},
	['lostmc'] = {
		label = 'The Lost MC',
		grades = {
            [0] = {
                name = 'Recruit'
            },
			[1] = {
                name = 'Enforcer'
            },
			[2] = {
                name = 'Shot Caller'
            },
			[3] = {
                name = 'Boss',
                isboss = true,
                bankAuth = true
            },
        },
	},
	['ballas'] = {
		label = 'Ballas',
		grades = {
            [0] = {
                name = 'Recruit'
            },
			[1] = {
                name = 'Enforcer'
            },
			[2] = {
                name = 'Shot Caller'
            },
			[3] = {
                name = 'Boss',
                isboss = true,
                bankAuth = true
            },
        },
	},
	['vagos'] = {
		label = 'Vagos',
		grades = {
            [0] = {
                name = 'Recruit'
            },
			[1] = {
                name = 'Enforcer'
            },
			[2] = {
                name = 'Shot Caller'
            },
			[3] = {
                name = 'Boss',
                isboss = true,
                bankAuth = true
            },
        },
	},
	['cartel'] = {
		label = 'Cartel',
		grades = {
            [0] = {
                name = 'Recruit'
            },
			[1] = {
                name = 'Enforcer'
            },
			[2] = {
                name = 'Shot Caller'
            },
			[3] = {
                name = 'Boss',
                isboss = true,
                bankAuth = true
            },
        },
	},
	['families'] = {
		label = 'Families',
		grades = {
            [0] = {
                name = 'Recruit'
            },
			[1] = {
                name = 'Enforcer'
            },
			[2] = {
                name = 'Shot Caller'
            },
			[3] = {
                name = 'Boss',
                isboss = true,
                bankAuth = true
            },
        },
	},
	['triads'] = {
		label = 'Triads',
		grades = {
            [0] = {
                name = 'Recruit'
            },
			[1] = {
                name = 'Enforcer'
            },
			[2] = {
                name = 'Shot Caller'
            },
			[3] = {
                name = 'Boss',
                isboss = true,
                bankAuth = true
            },
        },
	}
}
