local awful = require("awful")
local wibox = require("wibox")
local util = require("widget/util")
local sysctl = require("sysctl")
local math = require("math")
local font = require("widget/font")

local widget = wibox.widget{
    font = font.widget_default,
    widget = wibox.widget.textbox,
}
local text_widget = wibox.widget{
    font = font.widget_default,
    widget = wibox.widget.textbox,
}

local popup = awful.popup {
    widget = {
        {
            text_widget,
            layout = wibox.layout.fixed.vertical,
        },
        margins = 10,
        widget  = wibox.container.margin
    },
    visible      = false,
    ontop        = true,
}

local function rotate(index, mask)
    return (index-1 & mask) +1
end

local function chain(one, two)
    local current = one
    return function()
        local r = current()
        if r == nil and current == one then
            current = two
            return two()
        end
        return r
    end
end

local function slice_iterator(ring, start, stop)
   local index = start -1
   return function ()
      index = index + 1
      if index <= stop
      then
         return ring[index]
      end
   end
end

local history ={
    values={},
    last_avg = 0,
    next = 1,
    mask = 1023,
    total_max = 0,
    total_min = 1000,
    slice = function (self, n)
        local stop = rotate(self.next -1, self.mask)
        local start =  rotate(stop-n, self.mask)
        local values = self.values
        if start <= stop then
            return slice_iterator(values, start, stop)
        end
        return chain(slice_iterator(values, start, #values), slice_iterator(values, 1, stop))

    end,
    average = function(self, n)
        if n==nil or #self.values < n then
            n = #self.values
        end
        local sum = 0
        for value in self.slice(self, n) do
            sum = sum + value
        end
        return sum/(n +1)
    end,
    insert = function (self, value)
        self.values[self.next] = value
        self.next = (self.next & self.mask) + 1
    end
}

local function update_popup()
    local cur = history:slice(3)
    local cur3 = cur() or 0.0
    local cur2 = cur() or 0.0
    local cur1 = cur() or 0.0
    local avg_10 = history:average(10)
    local avg_100 = history:average(100)
    local avg = history:average(1000)
    local max_value = math.max(table.unpack(history.values))
    local min_value = math.min(table.unpack(history.values))
    history.last_avg = avg
    local lines = [==[
Cur: % 3.1f°C % 3.1f°C % 3.1f°C
Avg: % 3.1f°C % 3.1f°C % 3.1f°C
Max: % 3.1f°C % 3.1f°C
Min: % 3.1f°C % 3.1f°C
%d / %d
    ]==]
    text_widget:set_text(string.format(lines, cur1, cur2, cur3,  avg_10, avg_100, avg, max_value, history.total_max, min_value, history.total_min, history.next, #history.values))
end

local update_fn =  function ()
    local temp_raw = sysctl.get('dev.cpu.0.temperature')
    -- remove 270 since the tempsensor seems to be of by 27°C
    local temp = (temp_raw - 2731 - 270) / 10
    history:insert(temp)
    history.total_max = math.max(history.total_max, temp)
    history.total_min = math.min(history.total_min, temp)
    widget:set_text(string.format("% 3.1f°C", temp))
    if popup.visible then
        update_popup()
    end
end

widget:connect_signal("mouse::enter", function (_)
    update_popup()
    popup.visible = true
    popup:move_next_to(mouse.current_widget_geometry)
end)
widget:connect_signal("mouse::leave", function (_) popup.visible = false end)

return util.test_sysctl(widget,
    {"dev.cpu.0.temperature",},
    update_fn
)
