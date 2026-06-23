local wibox = require("wibox")
local font = require("widget/font")

local oslib = require("oslib")

if oslib.battery.available == false then
    return {
        widget=nil,
        update_fn=nil,
    }
end

local widget = wibox.widget{
    font = font.widget_default,
    widget = wibox.widget.textbox,
}

local update_fn = function ()
    local battery = oslib.battery.state()
    local battery_state = "🔋"

    if battery.acline == 1 then
        battery_state = "🔌"
    end
    widget:set_text(string.format("%s %i%% ",battery_state,  battery.battery_life))
end

return {
    widget=widget,
    update_fn=update_fn
}
