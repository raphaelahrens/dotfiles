local lsf = require("lfs")

lib = {
    autostart={
        "/usr/bin/keepassxc",
        "/usr/bin/nm-applet",
        "/usr/bin/blueman-applet",
    },
    battery={
        available=true,
    },
    temp={
        available=false,
    }
}

local thermal_dir= "/sys/class/thermal/"
local zone_type_file = "thermal_zone"
local temp_files = "temp"

for f in lfs.dir(thermal_dir) do
    if f:sub(0,zone_type_file:len()) == zone_type_file then
        local type_file = io.open(thermal_dir.."/"..f.."/".."type")
        local type = type_file:read("*all")
        type_file:close()
        if type == "x86_pkg_temp\n" then
            lib.temp.cpu_temp_path = thermal_dir.."/"..f.."/".."temp"
            lib.temp.available = true
        end
    end
end

local thermal_dir = "/sys/class/thermal/"

local thermal_types = "/sys/class/thermal/thermal_zone*/type"

function lib.battery.state() 
    local bat_file = io.open("/sys/class/power_supply/BAT0/capacity")
    local battery_life = tonumber(bat_file:read("*all"))
    bat_file:close()
    local ac_file = io.open("/sys/class/power_supply/AC/online")
    local acline = tonumber(ac_file:read("*all"))
    ac_file:close()
    return {
        acline= acline,
        battery_life= battery_life
    }
end

function lib.temp.cpu() 
    local temp_file = io.open(lib.temp.cpu_temp_path)
    local temp_raw = tonumber(temp_file:read("*all"))
    temp_file:close()
    return temp_raw/1000
end

return lib
