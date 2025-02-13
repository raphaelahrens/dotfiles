local wibox = require("wibox")
local sysctl = require("sysctl")
local util = require("widget/util")
local font = require("widget/font")

local widget = wibox.widget{
    font = font.widget_default,
    widget = wibox.widget.textbox,
}

local update_fn = function ()
    local acline = sysctl.get('hw.acpi.acline')
    local battery_life = sysctl.get('hw.acpi.battery.life')
    --local battery_time = sysctl.get('hw.acpi.battery.time')
    local battery_state = "🔋"

    if acline == 1 then
        battery_state = "🔌"
    end
    widget:set_text(string.format("%s %i%% ",battery_state,  battery_life))
end

return util.test_sysctl(widget,
    {
        'hw.acpi.acline',
        'hw.acpi.battery.life',
        'hw.acpi.battery.time',
    },
    update_fn
)
