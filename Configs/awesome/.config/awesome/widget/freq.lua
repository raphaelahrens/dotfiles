local wibox = require("wibox")
local sysctl = require("sysctl")
local util = require("widget/util")
local font = require("widget/font")


local widget = wibox.widget{
    font = font.widget_default,
    widget = wibox.widget.textbox,
}


local update_fn =  function ()
    local cpu_freq = sysctl.get('dev.cpu.0.freq')
    widget:set_text(string.format("CPU %s", cpu_freq))
end

return util.test_sysctl(widget,
    {
        "dev.cpu.0.freq",
    },
    update_fn
)
