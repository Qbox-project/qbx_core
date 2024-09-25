---@class Scaleform : OxClass
---@field name string
---@field scaleform number
---@field draw boolean
---@field renderTarget number
---@field targetName string
---@field handle number
local Scaleform = lib.class('Scaleform')

---@param name string
---@return nil
---@description Create a new scaleform class
function Scaleform:constructor(name)
    self.name = name -- Set the name

    local scaleform = lib.requestScaleformMovie(name) -- Request the scaleform movie

    if not scaleform then -- If the scaleform is nil
        return error(('Failed to request scaleform movie - [%s]'):format(name)) -- Error the failed scaleform request
    end

    self.handle = scaleform -- Set the scaleform handle
    self.draw = false -- Set the draw to false
end

---@param name string
---@param args table
---@return nil
---@description Request a scaleform method with parameters
function Scaleform:MethodArgs(name, args)
    if not self.handle then -- If the scaleform handle is nil
        return error('Scaleform handle is nil') -- Error the scaleform handle is nil
    end
    if type(args) ~= 'table' then -- If the type of args is not a table
        return error('Args must be a table') -- Error args must be a table
    end

    BeginScaleformMovieMethod(self.handle, name) -- Begin the scaleform movie method
    for i=1, #args do -- loop through the args
        local arg = args[i] -- Set the value to the current arg
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
    EndScaleformMovieMethod() -- End the scaleform movie method
end

---@param name string
---@return nil
---@description Request a scaleform method with no return value or parameters
function Scaleform:Method(name)
    if not self.handle then -- If the scaleform handle is nil
        return error('Scaleform handle is nil') -- Error the scaleform handle is nil
    end

    BeginScaleformMovieMethod(self.handle, name) -- Begin the scaleform movie method
    EndScaleformMovieMethod() -- End the scaleform movie method
end

---@param name string
---@param type string
---@return number|string | boolean
---@description Request a scaleform method with a return value
function Scaleform:MethodReturn(name, type)
    if not self.handle then -- If the scaleform handle is nil
        return error('Scaleform handle is nil') -- Error the scaleform handle is nil
    end

    BeginScaleformMovieMethod(self.handle, name) -- Begin the scaleform movie method
    local result = EndScaleformMovieMethodReturnValue() -- End the scaleform movie method with a return value

    local timeout = 0
    while not IsScaleformMovieMethodReturnValueReady(result) do  -- While the return value is not ready
        Wait(0) -- Wait 0
        timeout = timeout + 1 -- Increment the timeout
        if timeout > 1000 then -- If the timeout is greater than 1000
            error(('Return value failed - [%s]'):format(name)) -- Error the timeout waiting for scaleform method return value
            return false
        end
    end -- End the while loop

    if type == "int" then -- If the type is an integer
        return GetScaleformMovieMethodReturnValueInt(result) -- Get the return value as an integer
    elseif type == "bool" then
        return GetScaleformMovieMethodReturnValueBool(result) -- Get the return value as a boolean
    else -- If the type is not an integer
        return GetScaleformMovieMethodReturnValueString(result) -- Get the return value as a string
    end
end

---@param name string
---@param model string|number
---@return nil
---@description Create a render target for the scaleform - optional , only if you want to render the scaleform in 3D
function Scaleform:RenderTarget(name, model)
    if type(model) == 'string' then -- If the type of model is a string
        model = joaat(model) -- Convert the model to a hash
    end

    if not IsNamedRendertargetRegistered(name) then -- If the named render target is not registered
        RegisterNamedRendertarget(name, false) -- Register the named render target

        if not IsNamedRendertargetLinked(model) then -- If the named render target is not linked
            LinkNamedRendertarget(model) -- Link the named render target
        end

        self.renderTarget = GetNamedRendertargetRenderId(name) -- Get the named render target render id
        self.targetName = name -- Set the target name
    end
end

---@param shouldDraw boolean
---@return nil
---@description Draw the scaleform
function Scaleform:Draw(shouldDraw)
    if self.draw == shouldDraw then -- If the draw is equal to should draw
        return -- Return
    end

    self.draw = shouldDraw -- Set the draw to should draw
    if shouldDraw then -- If should draw is true

       CreateThread(function()  -- Create a thread
            while self.draw do -- While the draw is true

                if self.renderTarget then -- If the render target is true
                    SetTextRenderId(self.renderTarget) -- Set the text render id
                    SetScriptGfxDrawOrder(4) -- Set the script gfx draw order
                    SetScriptGfxDrawBehindPausemenu(true) -- allow it to draw behind pause menu
                end

                DrawScaleformMovieFullscreen(self.handle, 255, 255, 255, 255, 0)

                if self.renderTarget then -- If the render target is true
                    SetTextRenderId(1) -- Reset the text render id
                end

                Wait(0)
            end
       end)

    end
end

---@return nil
---@description Dispose of the scaleform
function Scaleform:Dispose()
    if self.handle then -- If the handle exists
        SetScaleformMovieAsNoLongerNeeded(self.handle) -- Set the scaleform movie as no longer needed
    end

    if self.renderTarget then -- If the render target exists
        ReleaseNamedRendertarget(self.targetName) -- Release the named render target
    end

    -- Reset the values
    self.handle = nil -- Set the handle to nil
    self.renderTarget = nil -- Set the render target to nil
    self.draw = false -- Set the draw to false
end

---@return Scaleform
return Scaleform