---@class GroupData
---@field label string

---@class JobData : GroupData
---@field type? string
---@field defaultDuty boolean
---@field offDutyPay boolean

---@class GangData : GroupData

---@class GradeData
---@field name string
---@field isboss? boolean
---@field bankAuth? boolean

---@class JobGradeData : GradeData
---@field payment number

---@class GangGradeData : GradeData

---@class Job : JobData
---@field grades table<integer, JobGradeData>

---@class Gang : GangData
---@field grades table<integer, GangGradeData>

---@enum GroupType
local GroupType = {
    JOB = 'job',
    GANG = 'gang'
}

---@param name string
---@param groupType GroupType
---@param data GroupData
local function upsertGroupEntity(name, groupType, data)
    MySQL.insert.await('INSERT INTO groups (name, type, data) VALUES (:name, :type, :data) ON DUPLICATE KEY UPDATE name = :name, type = :type, data = :data', {
        name = name,
        type = groupType,
        data = json.encode(data)
    })
end

---@param group string
---@param groupType GroupType
---@param grade integer
---@param data GradeData
local function upsertGradeEntity(group, groupType, grade, data)
    MySQL.insert.await('INSERT INTO group_grades (group, type, grade, data) VALUES (:group, :type, :grade, :data) ON DUPLICATE KEY UPDATE group = :group, type = :type, grade = :grade, data = :data', {
        group = group,
        type = groupType,
        grade = grade,
        data = json.encode(data)
    })
end

---@param name string
---@param groupType GroupType
local function deleteGroupEntity(name, groupType)
    MySQL.update.await('DELETE FROM groups WHERE name = ? AND groupType = ?', {name, groupType})
end

---@param name string
---@param groupType GroupType
---@param grade integer
local function deleteGradeEntity(name, groupType, grade)
    MySQL.update.await('DELETE FROM group_grades WHERE name = ? AND groupType = ? AND grade = ?', {name, groupType, grade})
end

---@return table<string, Job>
---@return table<string, Gang>
function FetchGroups()
    local jobs = {}
    local gangs = {}

    local groups = MySQL.query.await('SELECT name, type, data FROM groups')
    if groups then
        for i = 1, #groups do
            local group = groups[i]
            local data = json.decode(group.data)
            data.grades = {}
            if group.type == GroupType.JOB then
                jobs[group.name] = group.data
            else
                gangs[group.name] = group.data
            end
        end
    end

    local grades = MySQL.query.await('SELECT group, type, grade, data FROM group_grades')
    if grades then
        for i = 1, #grades do
            local grade = grades[i]
            if grade.type == GroupType.JOB then
                jobs[grade.group].grades[grade.grade] = json.decode(grade.data)
            else
                gangs[grade.group].grades[grade.grade] = json.decode(grade.data)
            end
        end
    end

    return jobs, gangs
end

-- ===============
-- JOBS
-- ===============

---@param name string
---@param data JobData
function UpsertJobEntity(name, data)
    upsertGroupEntity(name, GroupType.JOB, data)
end

---@param job string
---@param grade integer
---@param data JobGradeData
function UpsertJobGradeEntity(job, grade, data)
    upsertGradeEntity(job, GroupType.JOB, grade, data)
end

---@param name string
function DeleteJobEntity(name)
    deleteGroupEntity(name, GroupType.JOB)
end

---@param name string
---@param grade integer
function DeleteJobGradeEntity(name, grade)
    deleteGradeEntity(name, GroupType.JOB, grade)
end

---@param name string
---@param job Job
function UpsertJob(name, job)
    local jobEntityData = {
        defaultDuty = job.defaultDuty,
        label = job.label,
        offDutyPay = job.offDutyPay,
        type = job.type
    }

    local queries = {
        {
            query = 'INSERT INTO groups (name, type, data) VALUES (@name, @type, @data) ON DUPLICATE KEY UPDATE data = @data',
            values = {
                name = name,
                type = GroupType.JOB,
                data = json.encode(jobEntityData)
            }
        },
    }

    for grade, gradeData in pairs(job.grades) do
        queries[#queries+1] = {
            query = 'INSERT INTO group_grades (group, type, grade, data) VALUES (@name, @type, @grade, @data) ON DUPLICATE KEY UPDATE group = @name, type = @type, grade = @grade, data = @data',
            values = {
                name = name,
                type = GroupType.JOB,
                grade = grade,
                data = json.encode(gradeData)
            }
        }
    end

    MySQL.transaction.await(queries)
end

-- ===============
-- GANGS
-- ===============

---@param name string
---@param data GangData
function UpsertGangEntity(name, data)
    upsertGroupEntity(name, GroupType.GANG, data)
end

---@param gang string
---@param grade integer
---@param data GangGradeData
function UpsertGangGradeEntity(gang, grade, data)
    upsertGradeEntity(gang, GroupType.GANG, grade, data)
end

---@param name string
function DeleteGangEntity(name)
    deleteGroupEntity(name, GroupType.GANG)
end

---@param name string
---@param grade integer
function DeleteGangGradeEntity(name, grade)
    deleteGradeEntity(name, GroupType.GANG, grade)
end

---@param name string
---@param gang Gang
function UpsertGang(name, gang)
    local gangEntityData = {
        label = gang.label
    }

    local queries = {
        {
            query = 'INSERT INTO groups (name, type, data) VALUES (@name, @type, @data) ON DUPLICATE KEY UPDATE data = @data',
            values = {
                name = name,
                type = GroupType.GANG,
                data = json.encode(gangEntityData)
            }
        },
    }

    for grade, gradeData in pairs(gang.grades) do
        queries[#queries+1] = {
            query = 'INSERT INTO group_grades (group, type, grade, data) VALUES (@name, @type, @grade, @data) ON DUPLICATE KEY UPDATE group = @name, type = @type, grade = @grade, data = @data',
            values = {
                name = name,
                type = GroupType.GANG,
                grade = grade,
                data = json.encode(gradeData)
            }
        }
    end

    MySQL.transaction.await(queries)
end
