local players = require 'server.storage.players'
local groups = require 'server.storage.groups'

---@class StorageFunctions
---@field fetchGroups fun(): table<string, Job>, table<string, Gang>
---@field upsertJobEntity fun(name: string, data: JobData)
---@field upsertJobGradeEntity fun(job: string, grade: integer, data: JobGradeData)
---@field deleteJobEntity fun(name: string)
---@field deleteJobGradeEntity fun(name: string, grade: integer)
---@field upsertJob fun(name: string, job: Job)
---@field upsertGangEntity fun(name: string, data: GangData)
---@field upsertGangGradeEntity fun(gang: string, grade: integer, data: GangGradeData)
---@field deleteGangEntity fun(name: string)
---@field deleteGangGradeEntity fun(name: string, grade: integer)
---@field upsertGang fun(name: string, gang: Gang)
---@field insertBan fun(request: InsertBanRequest)
---@field fetchBan fun(request: GetBanRequest): BanEntity?
---@field deleteBan fun(request: GetBanRequest)
---@field upsertPlayerEntity fun(request: UpsertPlayerRequest)
---@field fetchPlayerSkin fun(citizenId: string): PlayerSkin?
---@field fetchPlayerEntity fun(citizenId: string): PlayerEntity?
---@field fetchAllPlayerEntities fun(license2: string, license?: string): PlayerEntity[]
---@field deletePlayer fun(citizenId: string): boolean success
---@field fetchIsUnique fun(type: UniqueIdType, value: string|number): boolean
---@field addPlayerToJob fun(citizenid: string, group: string, grade: integer)
---@field addPlayerToGang fun(citizenid: string, group: string, grade: integer)
---@field fetchPlayerGroups fun(citizenid: string): table<string, integer>, table<string, integer> jobs, gangs
---@field removePlayerFromJob fun(citizenid: string, group: string)
---@field removePlayerFromGang fun(citizenid: string, group: string)

---@type StorageFunctions
local storage = lib.table.merge(players, groups)
return storage