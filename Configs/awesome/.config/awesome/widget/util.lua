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
            return {
                widget=widget,
                update_fn=fun
                }
        end
        return {
            widget=nil,
            update_fn=noop
            }
    end,
}
