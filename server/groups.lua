---@enum GroupType
GroupType = {
    JOB = 'job',
    GANG = 'gang'
}

---@type table<string, Job>
local jobs = require 'shared.jobs'

---@type table<string, Gang>
local gangs = require 'shared.gangs'

for name in pairs(jobs) do
    if name ~= name:lower() then
        lib.print.error(('jobs.lua contains a job name with capital letters: %s'):format(name))
    end
end

for name in pairs(gangs) do
    if name ~= name:lower() then
        lib.print.error(('gangs.lua contains a gang name with capital letters: %s'):format(name))
    end
end

--- Removes any quotes to ensure functionality
---@param str string
---@return string
local function escapeQuotes(str)
	str = str.gsub(str, '([%c%z\\"\'])', {
		['\\'] = '\\\\',
		['"'] = '\\"',
		['\''] = '\\\'',
		['\b'] = '\\b',
		['\f'] = '\\f',
		['\n'] = '\\n',
		['\r'] = '\\r',
		['\t'] = '\\t',
		['\0'] = '\\0'
	})
	return str
end

-- Converts groups to plain text for committing to shared file
---@param groupTable table<string, Job>
---@param type string
local function convertGroupsToPlainText(groupTable, type)
    local lines = {
        '---' .. type .. ' names must be lower case (top level table key)',
        '---@type table<string, ' .. type .. '>',
        'return {'
    }

    -- Iterate through job table and format them according to QBox structure
    for groupName, groupData in pairs(groupTable) do
        -- Add group entry (convert to lower case for group name)
        local groupLine = string.format("    ['%s'] = {", groupName:lower())
        table.insert(lines, groupLine)

        -- Add group label
        local labelLine = string.format("        label = '%s',", escapeQuotes(groupData.label))
        table.insert(lines, labelLine)

        if type == 'Job' then
            -- Add defaultDuty and offDutyPay
            if groupData.defaultDuty ~= nil then
                local defaultDutyLine = string.format("        defaultDuty = %s,", tostring(groupData.defaultDuty))
                table.insert(lines, defaultDutyLine)
            end
            if groupData.offDutyPay ~= nil then
                local offDutyPayLine = string.format("        offDutyPay = %s,", tostring(groupData.offDutyPay))
                table.insert(lines, offDutyPayLine)
            end
        end

        -- Add grades table
        table.insert(lines, "        grades = {")
        for gradeIndex, gradeData in pairs(groupData.grades) do
            -- Start the grade entry
            local gradeLine = string.format("            [%d] = { name = '%s'", gradeIndex, escapeQuotes(gradeData.name))

            if type == 'Job' then
                gradeLine = string.format(gradeLine .. ', payment = %d', gradeData.payment)
            end

            -- Add isBoss if true
            if gradeData.isboss then
                gradeLine = gradeLine .. ", isboss = true"
            end

            -- Add bankAuth if true
            if gradeData.bankAuth then
                gradeLine = gradeLine .. ", bankAuth = true"
            end

            -- Close the grade entry
            gradeLine = gradeLine .. " },"
            table.insert(lines, gradeLine)
        end
        table.insert(lines, "        },")

        -- Close the group entry
        table.insert(lines, "    },")
    end

    -- Close the groups table
    table.insert(lines, '}')
    return table.concat(lines, '\n')
end

--- Adds or updates a job entry in shared/jobs.lua.
--- If the job already exists, it will be overwritten.
--- @param jobName string The unique name of the job.
--- @param job table The job data containing relevant job properties.
--- @param commitToFile boolean Whether to commit the job data to the shared file.
--- @return boolean success Whether the operation was successful.
--- @return string? message An optional message indicating success or failure.
function CreateJob(jobName, job, commitToFile)
    -- Validate jobName
    if type(jobName) ~= "string" or jobName:match("^%s*$") then
        return false, "Invalid parameter: jobName must be a non-empty string."
    end

    -- Validate job table
    if type(job) ~= "table" then
        return false, "Invalid parameter: job must be a table."
    end

    -- Store the job data
    jobs[jobName] = job

    -- Notify server and clients about the job update
    TriggerEvent('qbx_core:server:onJobUpdate', jobName, job)
    TriggerClientEvent('qbx_core:client:onJobUpdate', -1, jobName, job)

    -- Commit the job data to the shared file
    if commitToFile then
        local modifiedData = convertGroupsToPlainText(jobs, 'Job')
        SaveResourceFile(GetCurrentResourceName(), 'shared/jobs.lua', modifiedData, -1)
    end

    return true, string.format("Job '%s' created/updated successfully.", jobName)
end

exports('CreateJob', CreateJob)

--- Adds or updates multiple jobs in shared/jobs.lua.
--- Calls CreateJob for each job in the provided table.
--- @param newJobs table<string, table> A table where keys are job names and values are job data tables.
--- @param commitToFile boolean Whether to commit the job data to the shared file.
--- @return boolean success Whether all jobs were successfully created/updated.
--- @return string? message An optional message indicating success or failure.
function CreateJobs(newJobs, commitToFile)
    -- Validate input type
    if type(newJobs) ~= "table" then
        return false, "Invalid parameter: newJobs must be a table."
    end

    local hasError = false
    local failedJobs = {}

    -- Iterate through jobs and attempt to create them
    for jobName, job in pairs(newJobs) do
        local success, errMsg = CreateJob(jobName, job)
        if not success then
            hasError = true
            table.insert(failedJobs, string.format("%s (%s)", jobName, errMsg or "Unknown error"))
        end
    end

    -- Return failure message if any jobs failed
    if hasError then
        return false, string.format("Some jobs failed to create: %s", table.concat(failedJobs, ", "))
    end

    -- Commit the job data to the shared file
    if commitToFile then
        local modifiedData = convertGroupsToPlainText(jobs, 'Job')
        SaveResourceFile(GetCurrentResourceName(), 'shared/jobs.lua', modifiedData, -1)
    end

    return true, "All jobs created/updated successfully."
end

exports('CreateJobs', CreateJobs)

-- Single Remove Job
---@param jobName string
---@param commitToFile boolean Whether to commit the job data to the shared file.
---@return boolean success
---@return string message
function RemoveJob(jobName, commitToFile)
    if type(jobName) ~= 'string' then
        return false, 'invalid_job_name'
    end

    if not jobs[jobName] then
        return false, 'job_not_exists'
    end

    jobs[jobName] = nil
    TriggerEvent('qbx_core:server:onJobUpdate', jobName, nil)
    TriggerClientEvent('qbx_core:client:onJobUpdate', -1, jobName, nil)

    if commitToFile then
        local modifiedData = convertGroupsToPlainText(jobs, 'Job')
        SaveResourceFile(GetCurrentResourceName(), 'shared/jobs.lua', modifiedData, -1)
    end
    return true, 'success'
end

exports('RemoveJob', RemoveJob)

---Adds or overwrites gangs in shared/gangs.lua
---@param newGangs table<string, Gang>
---@param commitToFile boolean Whether to commit the gang data to the shared file.
function CreateGangs(newGangs, commitToFile)
    for gangName, gang in pairs(newGangs) do
        gangs[gangName] = gang
        TriggerEvent('qbx_core:server:onGangUpdate', gangName, gang)
        TriggerClientEvent('qbx_core:client:onGangUpdate', -1, gangName, gang)
    end

    if commitToFile then
        local modifiedData = convertGroupsToPlainText(gangs, 'Gang')
        SaveResourceFile(GetCurrentResourceName(), 'shared/gangs.lua', modifiedData, -1)
    end
end

exports('CreateGangs', CreateGangs)

-- Single Remove Gang
---@param gangName string
---@param commitToFile boolean Whether to commit the gang data to the shared file.
---@return boolean success
---@return string message
function RemoveGang(gangName, commitToFile)
    if type(gangName) ~= 'string' then
        return false, 'invalid_gang_name'
    end

    if not gangs[gangName] then
        return false, 'gang_not_exists'
    end

    gangs[gangName] = nil

    TriggerEvent('qbx_core:server:onGangUpdate', gangName, nil)
    TriggerClientEvent('qbx_core:client:onGangUpdate', -1, gangName, nil)

    if commitToFile then
        local modifiedData = convertGroupsToPlainText(gangs, 'Gang')
        SaveResourceFile(GetCurrentResourceName(), 'shared/gangs.lua', modifiedData, -1)
    end
    return true, 'success'
end

exports('RemoveGang', RemoveGang)

---@return table<string, Job>
function GetJobs()
    return jobs
end

exports('GetJobs', GetJobs)

---@return table<string, Gang>
function GetGangs()
    return gangs
end

exports('GetGangs', GetGangs)

---@param name string
---@return Job?
function GetJob(name)
    return jobs[name]
end

exports('GetJob', GetJob)

---@param name string
---@return Gang?
function GetGang(name)
    return gangs[name]
end

exports('GetGang', GetGang)

---@param name string
---@param data JobData
---@param commitToFile boolean Whether to commit the job data to the shared file.
local function upsertJobData(name, data, commitToFile)
    if jobs[name] then
        jobs[name].defaultDuty = data.defaultDuty
        jobs[name].label = data.label
        jobs[name].offDutyPay = data.offDutyPay
        jobs[name].type = data.type
    else
        jobs[name] = {
            defaultDuty = data.defaultDuty,
            label = data.label,
            offDutyPay = data.offDutyPay,
            type = data.type,
            grades = {},
        }
    end
    TriggerEvent('qbx_core:server:onJobUpdate', name, jobs[name])
    TriggerClientEvent('qbx_core:client:onJobUpdate', -1, name, jobs[name])
    if commitToFile then
        local modifiedData = convertGroupsToPlainText(jobs, 'Job')
        SaveResourceFile(GetCurrentResourceName(), 'shared/jobs.lua', modifiedData, -1)
    end
end

exports('UpsertJobData', upsertJobData)

---@param name string
---@param data GangData
---@param commitToFile boolean Whether to commit the gang data to the shared file.
local function upsertGangData(name, data, commitToFile)
    if gangs[name] then
        gangs[name].label = data.label
    else
        gangs[name] = {
            label = data.label,
            grades = {},
        }
    end
    TriggerEvent('qbx_core:server:onGangUpdate', name, gangs[name])
    TriggerClientEvent('qbx_core:client:onGangUpdate', -1, name, gangs[name])
    if commitToFile then
        local modifiedData = convertGroupsToPlainText(gangs, 'Gang')
        SaveResourceFile(GetCurrentResourceName(), 'shared/gangs.lua', modifiedData, -1)
    end
end

exports('UpsertGangData', upsertGangData)

---@param name string
---@param grade integer
---@param data JobGradeData
---@param commitToFile boolean Whether to commit the job data to the shared file.
local function upsertJobGrade(name, grade, data, commitToFile)
    if not jobs[name] then
        lib.print.error('Job must exist to edit grades. Not found:', name)
        return
    end
    jobs[name].grades[grade] = data
    TriggerEvent('qbx_core:server:onJobUpdate', name, jobs[name])
    TriggerClientEvent('qbx_core:client:onJobUpdate', -1, name, jobs[name])
    if commitToFile then
        local modifiedData = convertGroupsToPlainText(jobs, 'Job')
        SaveResourceFile(GetCurrentResourceName(), 'shared/jobs.lua', modifiedData, -1)
    end
end

exports('UpsertJobGrade', upsertJobGrade)

---@param name string
---@param grade integer
---@param data GangGradeData
---@param commitToFile boolean Whether to commit the gang data to the shared file.
local function upsertGangGrade(name, grade, data, commitToFile)
    if not gangs[name] then
        lib.print.error('Gang must exist to edit grades. Not found:', name)
        return
    end
    gangs[name].grades[grade] = data
    TriggerEvent('qbx_core:server:onGangUpdate', name, gangs[name])
    TriggerClientEvent('qbx_core:client:onGangUpdate', -1, name, gangs[name])
    if commitToFile then
        local modifiedData = convertGroupsToPlainText(gangs, 'Gang')
        SaveResourceFile(GetCurrentResourceName(), 'shared/gangs.lua', modifiedData, -1)
    end
end

exports('UpsertGangGrade', upsertGangGrade)

---@param name string
---@param grade integer
---@param commitToFile boolean Whether to commit the job data to the shared file.
local function removeJobGrade(name, grade, commitToFile)
    if not jobs[name] then
        lib.print.error('Job must exist to edit grades. Not found:', name)
        return
    end
    jobs[name].grades[grade] = nil
    TriggerEvent('qbx_core:server:onJobUpdate', name, jobs[name])
    TriggerClientEvent('qbx_core:client:onJobUpdate', -1, name, jobs[name])
    if commitToFile then
        local modifiedData = convertGroupsToPlainText(jobs, 'Job')
        SaveResourceFile(GetCurrentResourceName(), 'shared/jobs.lua', modifiedData, -1)
    end
end

exports('RemoveJobGrade', removeJobGrade)

---@param name string
---@param grade integer
---@param commitToFile boolean Whether to commit the gang data to the shared file.
local function removeGangGrade(name, grade, commitToFile)
    if not gangs[name] then
        lib.print.error('Gang must exist to edit grades. Not found:', name)
        return
    end
    gangs[name].grades[grade] = nil
    TriggerEvent('qbx_core:server:onGangUpdate', name, gangs[name])
    TriggerClientEvent('qbx_core:client:onGangUpdate', -1, name, gangs[name])
    if commitToFile then
        local modifiedData = convertGroupsToPlainText(gangs, 'Gang')
        SaveResourceFile(GetCurrentResourceName(), 'shared/gangs.lua', modifiedData, -1)
    end
end

exports('RemoveGangGrade', removeGangGrade)

---Allow clients to fetch group cache
---@return table
lib.callback.register('qbx_core:server:getGroups', function()
    return {
        jobs = jobs,
        gangs = gangs,
    }
end)
