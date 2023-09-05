local wibox = require("wibox")
local sysctl = require("sysctl")
local util = require("widget/util")

local widget = wibox.widget{
    font = "Play 7",
    widget = wibox.widget.textbox,
}

local update_fn = function ()
    local battery_life = sysctl.get('hw.acpi.battery.life')
    local battery_time = sysctl.get('hw.acpi.battery.time')
    local battery_state = "🔋"

    if battery_time < 0 then
        battery_state = "🔌"
    end
    widget:set_text(string.format("%s %i%% ",battery_state,  battery_life))
end

return {
    widget=widget,
    update_fn=util.test_sysctl(
        widget,
        {
            'hw.acpi.battery.life',
            'hw.acpi.battery.time',
        },
        update_fn
    ),
}
