---@class Scaleform : OxClass
---@field name string
---@field scaleform number
---@field draw boolean
---@field target number
---@field targetName string
---@field handle number
local Scaleform = lib.class('Scaleform')

---@param details table | string
---@return nil
---@description Create a new scaleform class
function Scaleform:constructor(details)
    local detailProvided = type(details) == "table"
    self.name = detailProvided and details.name or details -- Set the name

    local scaleform = lib.requestScaleformMovie(self.name) -- Request the scaleform movie

    if not scaleform then -- If the scaleform is nil
        return error(('Failed to request scaleform movie - [%s]'):format(self.name)) -- Error the failed scaleform request
    end

    self.handle = scaleform -- Set the scaleform handle
    self.draw = false -- Set the draw to false
    self.fullScreen = detailProvided and details.fullScreen or true -- Set default for full screen

    if detailProvided then
        self.x = details.x
        self.y = details.y
        self.width = details.width
        self.height = details.height

        if details.renderTarget then
            self:renderTarget(details.renderTarget.name, details.renderTarget.model)
        end
    end
end

local function convertArgs(argsTable)
    for i=1, #argsTable do -- loop through the args
        local arg = argsTable[i] -- Set the value to the current arg
        if type(arg) == 'string' then -- If the type of v is a string
            ScaleformMovieMethodAddParamPlayerNameString(arg) -- Add the player name string
        elseif type(arg) == 'number' then -- If the type of v is a number
            if math.type(arg) == 'integer' then -- If the math type of v is an integer
                ScaleformMovieMethodAddParamInt(arg) -- Add the integer
            else -- If the math type of v is not an integer
                ScaleformMovieMethodAddParamFloat(arg) -- Add the float
            end
        elseif type(arg) == 'boolean' then -- If the type of v is a boolean
            ScaleformMovieMethodAddParamBool(arg) -- Add the boolean
        else
            error(('Unsupported Parameter type [%s]'):format(type(arg))) -- Error unsupported type
        end
    end
end

---@param type 'bool' | 'int' | 'string'
---@return boolean | integer | string
---@description Awaits the return value, and converts it to a usable data type
local function retrieveReturnValue(type)
    local result = EndScaleformMovieMethodReturnValue() -- End the scaleform movie method with a return value

    lib.waitFor(function()
        if IsScaleformMovieMethodReturnValueReady(result) then
            return true
        end
    end, "Failed to retrieve return value", 1000)

    if type == "int" then -- If the type is an integer
        return GetScaleformMovieMethodReturnValueInt(result) -- Get the return value as an integer
    elseif type == "bool" then
        return GetScaleformMovieMethodReturnValueBool(result) -- Get the return value as a boolean
    else -- If the type is not an integer
        return GetScaleformMovieMethodReturnValueString(result) -- Get the return value as a string
    end
end

---@param name string
---@param args? table
---@param returnValue? string
---@return any
---@description Call a scaleform function, with optional args or return value.
function Scaleform:method(name, args, returnValue)
    if not self.handle then -- If the scaleform handle is nil
        return error('Scaleform handle is nil') -- Error the scaleform handle is nil
    end

    if args and type(args) ~= 'table' then -- If the type of args is not a table
        return error('Args must be a table') -- Error args must be a table
    end

    BeginScaleformMovieMethod(self.handle, name) -- Begin the scaleform movie method

    -- Converts the arguments into data types usable by scaleform
    if args then
        convertArgs(args)
    end

    -- When wanting a return value, the scaleform has to be ended with a different native
    if returnValue then
        retrieveReturnValue(returnValue)
    else
        EndScaleformMovieMethod() -- End the scaleform movie method
    end
end

---@param isFullscreen boolean
---@return nil
---@description Set the scaleform to render in full screen
function Scaleform:setFullScreen(isFullscreen)
    self.fullScreen = isFullscreen
end

---@param x number
---@param y number
---@param width number
---@param height number
---@return nil
---@description Set the properties of the scaleform (Requires SetFullScreen to be false)
function Scaleform:setProperties(x, y, width, height)
    if self.fullScreen then -- If the full screen is true
        return error('Cannot set properties when full screen is enabled') -- Error cannot set properties when full screen is enabled
    end
    self.x = x
    self.y = y
    self.width = width
    self.height = height
end

---@param name string
---@param model string|number
---@return nil
---@description Create a render target for the scaleform - optional , only if you want to render the scaleform in 3D
function Scaleform:renderTarget(name, model)

    -- ensures theres no Targets still active, since this could cause a memory leak
    -- if the render targets are not released.
    if self.target then
        ReleaseNamedRendertarget(self.targetName)
    end

    if type(model) == 'string' then -- If the type of model is a string
        model = joaat(model) -- Convert the model to a hash
    end

    if not IsNamedRendertargetRegistered(name) then -- If the named render target is not registered
        RegisterNamedRendertarget(name, false) -- Register the named render target

        if not IsNamedRendertargetLinked(model) then -- If the named render target is not linked
            LinkNamedRendertarget(model) -- Link the named render target
        end

        self.target = GetNamedRendertargetRenderId(name) -- Get the named render target render id
        self.targetName = name -- Set the target name
    end
end

---@return nil
---@description Set The Scaleform to draw
function Scaleform:startDrawing()
    if self.draw then -- If the draw is equal to should draw
        return error("Scaleform Already Drawing")
    end

    self.draw = true
    CreateThread(function()  -- Create a thread
        while self.draw do -- While the draw is true

            if self.target then -- If the render target is true
                SetTextRenderId(self.target) -- Set the text render id
                SetScriptGfxDrawOrder(4) -- Set the script gfx draw order
                SetScriptGfxDrawBehindPausemenu(true) -- allow it to draw behind pause menu
                SetScaleformFitRendertarget(self.handle, true)
            end

            if self.fullScreen then
                DrawScaleformMovieFullscreen(self.handle, 255, 255, 255, 255, 0)
            else
                if not self.x or not self.y or not self.width or not self.height then
                    error('Properties not set for scaleform') -- Error properties not set for scaleform
                    DrawScaleformMovieFullscreen(self.handle, 255, 255, 255, 255, 0)
                else
                    DrawScaleformMovie(self.handle, self.x, self.y, self.width, self.height, 255, 255, 255, 255, 0)
                end
            end

            if self.target then -- If the render target is true
                SetTextRenderId(1) -- Reset the text render id
            end

            Wait(0)
        end
    end)
end

---@return nil
---@description stop the scaleform from drawing, use this to only temporarily disable it, use Dispose otherwise.
function Scaleform:stopDrawing()
    if not self.draw then
        return
    end
    self.draw = false
end

---@return nil
---@description Dispose of the scaleform
function Scaleform:dispose()
    if self.handle then -- If the handle exists
        SetScaleformMovieAsNoLongerNeeded(self.handle) -- Set the scaleform movie as no longer needed
    end

    if self.target then -- If the render target exists
        ReleaseNamedRendertarget(self.targetName) -- Release the named render target
    end

    -- Reset the values
    self.handle = nil -- Set the handle to nil
    self.target = nil -- Set the render target to nil
    self.draw = false -- Set the draw to false
end

---@return Scaleform
return Scaleform