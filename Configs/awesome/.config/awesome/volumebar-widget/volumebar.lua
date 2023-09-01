-------------------------------------------------
-- Volume Bar Widget for Awesome Window Manager
-- Shows the current volume level
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/volumebar-widget

-- @author Pavel Makhov
-- @copyright 2017 Pavel Makhov
-------------------------------------------------

local awful = require("awful")
local gears = require("gears")
local spawn = require("awful.spawn")
local watch = require("awful.widget.watch")
local wibox = require("wibox")

local request_command = 'mixer vol'

local bar_color = "#74aeab"
local mute_color = "#ff0000"
local background_color = "#3a3a3a"

local volumebar_widget = wibox.widget {
    max_value = 1,
    forced_width = 50,
    paddings = 0,
    border_width = 0.5,
    color = bar_color,
    background_color = background_color,
    shape = gears.shape.bar,
    clip = true,
    margins       = {
        top = 10,
        bottom = 10,
    },
    widget = wibox.widget.progressbar
}

local update_graphic = function(widget, stdout, _, _, _)
    local mute = "on"
    local volume = string.match(stdout, "(1?%d?%d):1?%d?%d")
    volume = tonumber(string.format("%3d", volume))

    if mute == "off" then
        widget.color = mute_color
        widget.value = volume / 100;
    else
        widget.color = bar_color
        widget.value = volume / 100;
    end
end

volumebar_widget:connect_signal("button::press", function(_,_,_,button)
    if (button == 4)     then
        awful.spawn("mixer vol +5", false)
        volumebar_widget.value = 0.5
    elseif (button == 5) then
        awful.spawn("mixer vol -5", false)
        volumebar_widget.value = 0.5
    elseif (button == 1) then
        awful.spawn("mixer vol 0", false)
        volumebar_widget.value = 0
    end

--    spawn.easy_async(request_command, function(stdout, stderr, exitreason, exitcode)
--        update_graphic(volumebar_widget, stdout, stderr, exitreason, exitcode)
--    end)
end)

watch(request_command, 60, update_graphic, volumebar_widget)

return volumebar_widget
