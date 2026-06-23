local sysctl = require("sysctl")

function test_sysctl (widget, keys, fun)
    local state = true
    for _,k in pairs(keys) do
        local result, _ = pcall(sysctl.get, k)
        if result then
            return false
        end
    end
    return true
end

lib = {
    autostart={
        "/usr/local/bin/keepassxc",
    },
    battery = {
        available=test_sysctl({'hw.acpi.acline', 'hw.acpi.battery.life'}),
    },
    temp={
        available=test_sysctl({'dev.cpu.0.temperature'}),
    }
}
function lib.battery.state() 
    local acline = sysctl.get('hw.acpi.acline')
    local battery_life = sysctl.get('hw.acpi.battery.life')
    return {
        acline= acline,
        battery_life= battery_life
    }
end
function lib.temp.cpu() 
    local temp_raw = sysctl.get('dev.cpu.0.temperature')
    -- remove 270 since the tempsensor seems to be of by 27°C
    local temp = (temp_raw - 2731 - 270) / 10
    return temp
end

return lib
