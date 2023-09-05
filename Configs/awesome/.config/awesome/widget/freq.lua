local wibox = require("wibox")
local sysctl = require("sysctl")
local util = require("widget/util")


local widget = wibox.widget{
    font = "Play 7",
    widget = wibox.widget.textbox,
}
widget:set_text("  XXXXX°C XXXXX°C")


local update_fn =  function ()
    local cpu_freq = sysctl.get('dev.cpu.0.freq')
    widget:set_text(string.format("CPU %s", cpu_freq))
end

return {
    widget=widget,
    update_fn=util.test_sysctl(
        widget,
        {
            "dev.cpu.0.freq",
        },
        update_fn
    ),
}
