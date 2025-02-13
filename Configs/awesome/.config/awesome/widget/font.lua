local beautiful = require("beautiful")

local font_name = beautiful.font:gsub("%s%d+$", "") or "Play"

local function sized_font(size)
    return string.format("%s %d", font_name, size)
end

return {
    widget_default = sized_font(7),
    get_sized_font = sized_font,
}
