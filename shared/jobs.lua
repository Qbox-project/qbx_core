---Job names must be lower case (top level table key)
---@type table<string, Job>
return {
    ['unemployed'] = {
        label = 'Civilian',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Freelancer',
                payment = 10
            }
        }
    },
    ['police'] = {
        label = 'LSPD',
        type = 'leo',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruit',
                payment = 20
            },
            [1] = {
                name = 'Cadet',
                payment = 30
            },
            [2] = {
                name = 'Officer',
                payment = 40
            },
            [3] = {
                name = 'Senior Officer',
                payment = 50
            },
            [4] = {
                name = 'Corporal',
                payment = 75
            },
            [5] = {
                name = 'Sergeant',
                payment = 100
            },
            [6] = {
                name = 'Lieutenant',
                payment = 125
            },
            [7] = {
                name = 'Captain',
                payment = 150
            },
            [8] = {
                name = 'Assistant Chief',
                payment = 175
            },
            [9] = {
                name = 'Chief',
                isboss = true,
                bankAuth = true,
                payment = 200
            }
        }
    },
    ['bcso'] = {
        label = 'BCSO',
        type = 'leo',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruit',
                payment = 20
            },
            [1] = {
                name = 'Cadet',
                payment = 30
            },
            [2] = {
                name = 'Deputy',
                payment = 40
            },
            [3] = {
                name = 'Senior Deputy',
                payment = 50
            },
            [4] = {
                name = 'Corporal',
                payment = 75
            },
            [5] = {
                name = 'Sergeant',
                payment = 100
            },
            [6] = {
                name = 'Lieutenant',
                payment = 125
            },
            [7] = {
                name = 'Captain',
                payment = 150
            },
            [8] = {
                name = 'Undersheriff',
                payment = 175
            },
            [9] = {
                name = 'Sheriff',
                isboss = true,
                bankAuth = true,
                payment = 200
            }
        }
    },
    ['sasp'] = {
        label = 'SASP',
        type = 'leo',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruit',
                payment = 50
            },
            [1] = {
                name = 'Master Trooper',
                payment = 100
            },
            [2] = {
                name = 'Sergeant',
                payment = 125
            },
            [3] = {
                name = 'Marshal',
                payment = 150
            },
            [4] = {
                name = 'Deputy Commissioner',
                payment = 250
            },
            [5] = {
                name = 'Commissioner',
                isboss = true,
                bankAuth = true,
                payment = 300
            }
        }
    },
    ['ambulance'] = {
        label = 'EMS',
        type = 'ems',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Trainee',
                payment = 25
            },
            [1] = {
                name = 'Emergency Medical Technician (EMT)',
                payment = 50
            },
            [2] = {
                name = 'Paramedic',
                payment = 75
            },
            [3] = {
                name = 'EMS Supervisor',
                payment = 100
            },
            [4] = {
                name = 'Deputy Chief',
                payment = 150
            },
            [5] = {
                name = 'Chief',
                isboss = true,
                bankAuth = true,
                payment = 200
            }
        }
    },
    ['realestate'] = {
        label = 'Real Estate',
        type = 'realestate',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruit',
                payment = 50
            },
            [1] = {
                name = 'House Sales',
                payment = 75
            },
            [2] = {
                name = 'Business Sales',
                payment = 100
            },
            [3] = {
                name = 'Broker',
                payment = 125
            },
            [4] = {
                name = 'Manager',
                isboss = true,
                bankAuth = true,
                payment = 150
            }
        }
    },
    ['cardealer'] = {
        label = 'Vehicle Dealer',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruit',
                payment = 50
            },
            [1] = {
                name = 'Showroom Sales',
                payment = 75
            },
            [2] = {
                name = 'Business Sales',
                payment = 100
            },
            [3] = {
                name = 'Finance',
                payment = 125
            },
            [4] = {
                name = 'Manager',
                isboss = true,
                bankAuth = true,
                payment = 150
            }
        }
    },
    ['mechanic'] = {
        label = 'Mechanic',
        type = 'mechanic',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruit',
                payment = 50
            },
            [1] = {
                name = 'Novice',
                payment = 75
            },
            [2] = {
                name = 'Experienced',
                payment = 100
            },
            [3] = {
                name = 'Advanced',
                payment = 125
            },
            [4] = {
                name = 'Manager',
                isboss = true,
                bankAuth = true,
                payment = 150
            }
        }
    },
    ['judge'] = {
        label = 'Honorary',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Judge',
                payment = 100
            }
        }
    },
    ['lawyer'] = {
        label = 'Law Firm',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Associate',
                payment = 50
            }
        }
    },
    ['reporter'] = {
        label = 'Reporter',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Journalist',
                payment = 50
            }
        }
    },
    ['taxi'] = {
        label = 'Taxi',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruit',
                payment = 50
            },
            [1] = {
                name = 'Driver',
                payment = 75
            },
            [2] = {
                name = 'Event Driver',
                payment = 100
            },
            [3] = {
                name = 'Sales',
                payment = 125
            },
            [4] = {
                name = 'Manager',
                isboss = true,
                bankAuth = true,
                payment = 150
            }
        }
    },
    ['diving'] = {
        label = 'Scuba',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Deep Sea Diver',
                payment = 15
            }
        }
    },
    ['electrician'] = {
        label = 'Electrician',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Technician',
                payment = 15
            }
        }
    },
    ['garbage'] = {
        label = 'Garbage',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Collector',
                payment = 15
            }
        }
    },
    ['gardener'] = {
        label = 'Gardening',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Landscaper',
                payment = 15
            }
        }
    },
    ['builder'] = {
        label = 'Construction',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Worker',
                payment = 15
            }
        }
    },
    ['gruppe'] = {
        label = 'Gruppe Sechs',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Delivery Personnel',
                payment = 15
            }
        }
    },
    ['lumberjack'] = {
        label = 'Lumberjack',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Feller',
                payment = 15
            }
        }
    },
    ['mining'] = {
        label = 'Miner',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Worker',
                payment = 15
            }
        }
    },
    ['oilrig'] = {
        label = 'Oil Rig',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Toolpusher',
                payment = 15
            }
        }
    },
    ['trucker'] = {
        label = 'Trucker',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Driver',
                payment = 50
            }
        }
    },
    ['tow'] = {
        label = 'Towing',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Driver',
                payment = 50
            }
        }
    },
    ['vineyard'] = {
        label = 'Vineyard',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Picker',
                payment = 50
            }
        }
    },
    ['bus'] = {
        label = 'Bus',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Driver',
                payment = 50
            }
        }
    },
    ['hotdog'] = {
        label = 'Hotdog',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Sales',
                payment = 50
            }
        }
    }
}
