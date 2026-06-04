-- BeamNG.drive AGA Global Mod Structure (Overview)
-- Bu mod tek bir dosya değil, tüm araçlara otomatik etki eden 3 parçalı bir plugindir.

-- ==============================================
-- DOSYA 1: lua/ge/extensions/auto/agaManager.lua 
-- (Oyun Motoru Seviyesi - Her araca otomatik enjekte eder)
-- ==============================================
local M = {}
local function onVehicleSwitched(oldVehicleId, newVehicleId)
    local currVehicle = scenetree.findObject(newVehicleId)
    if currVehicle then
        -- Araba değiştiği an agaPhysics.lua scriptini araca yükler ("şak" diye aktif olur)
        currVehicle:queueLuaCommand('extensions.load("agaPhysics")')
    end
end
local function onInit()
    setExtensionUnloadMode(M, "manual") 
end
M.onVehicleSwitched = onVehicleSwitched
M.onInit = onInit

-- ==============================================
-- DOSYA 2: lua/vehicle/extensions/agaPhysics.lua 
-- (Araç Fizik Seviyesi - 2000Hz AC Advanced Hesaplamaları)
-- ==============================================
local M = {}
-- AGA Parametreleri (UI App tarafından anlık güncellenebilir)
M.config = {
    speed_sensitivity = 0.045,
    exp_gamma = 1.6,
    countersteer = 0.90,
    max_steer_speed = 10.0
}
local current_steering = 0
local function updateGFX(dt)
    -- Adam10603 algoritmasının BeamNG versiyonu (Hız, Slip Angle Hesaplaması)
    local vx = electrics.values.vx or 0
    local speed_kmh = math.abs(vx) * 3.6
    local raw_steer = input.state.steering or 0
    
    -- Gamma
    local stick_sign = raw_steer >= 0 and 1 or -1
    local soft_input = stick_sign * (math.abs(raw_steer) ^ M.config.exp_gamma)
    
    -- Speed Limit
    local limit_factor = 1.0 / (1.0 + speed_kmh * M.config.speed_sensitivity)
    local target = soft_input * limit_factor
    
    -- Slide Angle & Countersteer
    local vy = electrics.values.vy or 0
    local slip_angle = (math.abs(vx) > 1.2) and math.atan2(vy, math.abs(vx)) or 0
    
    if math.abs(slip_angle) > 0.07 then
        target = target - (slip_angle * M.config.countersteer)
    end
    
    -- Sınırlayıcı ve Uygulayıcı
    target = math.max(-1.0, math.min(1.0, target))
    local steer_error = target - current_steering
    current_steering = current_steering + steer_error * math.min(1.0, dt * M.config.max_steer_speed)
    
    -- 1 değeri filtre device türüdür. Default gamepad inputunu ezer
    input.event("steering", current_steering, 1) 
end

local function setConfig(cfg)
    if cfg.speed_sensitivity then M.config.speed_sensitivity = cfg.speed_sensitivity end
    if cfg.countersteer then M.config.countersteer = cfg.countersteer end
    if cfg.max_steer_speed then M.config.max_steer_speed = cfg.max_steer_speed end
    if cfg.exp_gamma then M.config.exp_gamma = cfg.exp_gamma end
end

M.updateGFX = updateGFX
M.setConfig = setConfig

-- ==============================================
-- DOSYA 3: ui/modules/apps/AdvancedGamepadAssist/app.js 
-- (Arayüz Seviyesi - Ayarları AGA Physics'e Canlı Yollar)
-- ==============================================
-- Kullanıcı slider'ı çektiğinde çalışan kod:
-- bngApi.activeObjectLua("if extensions.agaPhysics then extensions.agaPhysics.setConfig(...) end");
return M