local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local font = require("widget/font")
local dpi = require("beautiful.xresources").apply_dpi

local xl_font = font.get_sized_font(22)
local l_font = font.get_sized_font(10)
local s_font = font.get_sized_font(7)

local warn_cmd = "/home/tant/.cargo/bin/razer_light"
local warn_color = {
    critical = "x440000",
    normal = "x10FF10",
    none = "x002200"
}

local icons = {
    none = "󰂜",
    some = "󰂚"
}

local function shape_fn(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 8)
end

local widget = wibox.widget{
    font = font.widget_default,
    widget = wibox.widget.textbox,
}

local function row(notification)
    local title = notification.title or ""
    return wibox.widget {
                {
                    {
                        {
                            {
                                {
                                    markup = '<b>!</b>',
                                    font = l_font,
                                    align = 'center',
                                    widget = wibox.widget.textbox
                                },
                                margins = 4,
                                layout = wibox.container.margin
                            },
                            {
                                {
                                    {
                                        markup = '<b>' .. title .. '</b>',
                                        align = 'left',
                                        font = s_font,
                                        widget = wibox.widget.textbox
                                    },
                                    strategy = "exact",
                                    width = 90,
                                    height = dpi(7),
                                    widget = wibox.container.constraint,
                                },
                                {
                                    text = notification.text,
                                    font = s_font,
                                    widget = wibox.widget.textbox
                                },
                                spacing = 2,
                                layout = wibox.layout.align.vertical
                            },
                            spacing = 4,
                            layout = wibox.layout.fixed.horizontal
                        },
                        strategy = "exact",
                        width = 200,
                        widget = wibox.container.constraint,
                    },
                    margins = 4,
                    layout = wibox.container.margin
                },
                bg = beautiful.notification_bg,
                shape = shape_fn,
                widget = wibox.container.background
            }
end

local function selected(notification)
    local title = notification.title or ""
    return wibox.widget {
                {
                    {
                        {
                            {
                                markup = '<b>!</b>',
                                font = xl_font,
                                align = 'center',
                                widget = wibox.widget.textbox
                            },
                            margins = 8,
                            layout = wibox.container.margin
                        },
                        {
                            {
                                markup = '<b>' .. title .. '</b>',
                                align = 'left',
                                font = l_font,
                                widget = wibox.widget.textbox
                            },
                            {
                                text = notification.text,
                                font = l_font,
                                widget = wibox.widget.textbox
                            },
                            layout = wibox.layout.align.vertical
                        },
                        spacing = 8,
                        layout = wibox.layout.fixed.horizontal
                    },
                    margins = 8,
                    layout = wibox.container.margin
                },
                bg = beautiful.notification_bg,
                shape = shape_fn,
                widget = wibox.container.background
            }
end

local empty =  wibox.widget {
    markup = '<b>All gone !</b>',
    font = xl_font,
    align = 'center',
    widget = wibox.widget.textbox
}

local main = wibox.widget{
    empty,
    widget = wibox.container.place,
    valign = "center",
    forced_height = 600,
    height = 600,
    fill_vertical=true,
}
local notify_list = wibox.widget {
    forced_height = 100,
    height = 100,
    spacing = 4,
    layout = wibox.layout.fixed.horizontal,
}

local w  = wibox.widget{
        main,
        wibox.widget{
            notify_list,
            widget = wibox.container.place,
        },
        layout = wibox.layout.ratio.vertical,
}

w:set_ratio(1, 0.6)
w:set_ratio(2, 0.4)

local popup = wibox{
    widget  = w,
    ontop = true,
    height = 400,
    width = 800,
    shape = shape_fn,
    visible      = false,
    ontop        = true,
}

local state = {
    values={},
    next=1,
    mask=15,
    insert=function (self, value)
        table.insert(self.values, value)
    end,
    remove=function (self)
        table.remove(self.values, 1)
    end,
    clear=function (self)
        self.values = {}
        self.next = 1
    end,
    first = function(self)
        if #self.values > 0 then
            return selected(self.values[1])
        else
            return empty
        end
    end
}

local function update_widget()
    local bell = icons.none
    if #state.values > 0 then
        bell = icons.some
    end
    widget:set_text(string.format("%s% 2d", bell, #state.values))
end

local function update(args)
    if #state.values == 0 then
        awful.spawn({warn_cmd, "logo", "breath", warn_color.normal})
    end
    state:insert(args)
    update_widget()
    return args
end
local function update_popup()
    main.widget = state:first()
    local children = {}
    for i=2,#state.values,1 do
        table.insert(children, row(state.values[i]))
    end
    notify_list:set_children(children)
    awful.placement.centered(popup)
    -- popup:move_next_to(mouse.current_widget_geometry)
end

local function hide()
    popup.visible = false
end

local function set_empty()
    awful.spawn({warn_cmd, "logo", "off"})
end

local function remove_top()
    state:remove()
    main.widget = state:first()
    update_widget()
    update_popup()
    if #state.values == 0 then
        set_empty()
    end
end

local function clear()
    state:clear()
    update_widget()
    notify_list:reset()
    main.widget = empty
    set_empty()
end

local kg = awful.keygrabber {
    keybindings = {
        {{}, 'x', remove_top},
        {{}, 'c', clear},
    },
    -- Note that it is using the key name and not the modifier name.
    stop_key           = 'q',
    stop_event         = 'press',
    stop_callback      = hide,
    export_keybindings = false,
    autostart = false,
}
local function toggle_popup()
    popup.visible = not popup.visible
    if popup.visible then
        kg:start()
        update_popup()
    else 
        kg:stop()
    end
end
--widget:connect_signal("mouse::enter", toggle_popup)
widget:buttons(
    gears.table.join(
        awful.button({}, 3, clear),
        awful.button({}, 1, toggle_popup)
    )
)

update_widget()

return {
    widget = widget,
    update = update,
    state = function() return state end,
    toggle = toggle_popup,
}

