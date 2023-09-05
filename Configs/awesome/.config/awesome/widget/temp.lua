local wibox = require("wibox")
local util = require("widget/util")


local temp_widget = wibox.widget{
    font = "Play 7",
    widget = wibox.widget.textbox,
    visible = false,
}
temp_widget:set_text("  XXXXX°C XXXXX°C")

local history ={
    values={0, 0, 0, 0 ,0, 0},
    last_avg = 0
}

local update_fn =  function ()
    local temp_raw = util.sysctl_get('dev.cpu.0.temperature', 0)
    local cpu_freq = util.sysctl_get('dev.cpu.0.freq', -1)
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
end

return {
    widget=temp_widget,
    update_fn=util.test_sysctl(
        temp_widget,
        {
            "dev.cpu.0.temperature",
            "dev.cpu.0.freq",
        },
        update_fn
    ),
}
