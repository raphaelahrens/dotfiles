local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local sysctl = require("sysctl")


local temp_widget = wibox.widget{
    font = "Play 7",
    widget = wibox.widget.textbox,
}

local history ={
    values={0, 0, 0, 0 ,0, 0},
    last_avg = 0
}

local timer = timer({ timeout = 10 })

timer:connect_signal("timeout", function ()
    local temp_raw = 0 -- get_syscall('dev.cpu.0.temperature', 0)
        local cpu_freq = sysctl.get('dev.cpu.0.freq')
        -- remove 270 since the tempsensor seems to be of by 27°C
    local temp = (temp_raw - 2731 - 270) / 10
    table.insert(history.values, temp)
    table.remove(history.values,1)
    local sum = 0
    for _,v in ipairs(history.values) do
        sum = sum + v
    end
    local avg = sum / #history.values
    local trend
    if avg > history.last_avg then
        trend = "↑"
    elseif avg < history.last_avg then
        trend = "↓"
    else
        trend = "·"
    end
    history.last_avg = avg

    temp_widget:set_text(string.format("CPU %s | %s% 3.1f°C % 3.1f°C", cpu_freq, trend, temp, avg))
end)
timer:start()
timer:emit_signal("timeout")

return temp_widget
