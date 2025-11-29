local awful = require("awful")

local lib = {}
function lib.run_raise_as_master(cmd, match_rule)
    return function()
        local matcher = function (c)
            if awful.rules.match(c, match_rule) then
                local old_master = awful.client.getmaster()
                if old_master ~= nil then
                    c:swap(old_master)
                end
                return true
            end
            return false
        end
        awful.client.run_or_raise(cmd, matcher)
    end
end
return lib
