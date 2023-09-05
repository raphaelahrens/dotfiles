local sysctl = require "sysctl"
local function noop()
end
return {
    test_sysctl = function(widget, keys, fun)
        local state = true
        for _,k in pairs(keys) do
            local result, _ = pcall(sysctl.get, k)
            state = state and result
        end
        if state then
            widget.visibe = true
            return fun
        end
        widget.visibe = false
        return noop
    end,
    sysctl_get = function(key, default)
        local result, value = pcall(sysctl.get, key)
        if result then
            return value
        end
        return default
    end
}
