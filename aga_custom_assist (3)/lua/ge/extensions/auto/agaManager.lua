local M = {}
local function onVehicleSwitched(oldVehicleId, newVehicleId)
    local currVehicle = scenetree.findObject(newVehicleId)
    if currVehicle then
        currVehicle:queueLuaCommand('extensions.load("agaPhysics")')
    end
end
local function onInit()
    setExtensionUnloadMode(M, "manual")
end
M.onVehicleSwitched = onVehicleSwitched
M.onInit = onInit
return M
