-- This should work since FreeBSD and Ubuntu support os-release
os_str = ""
os_release_file = io.open("/etc/os-release")
result = os_release_file:read("*all"):gmatch("ID=(%w+)")()
os_release_file:close()
if result ~= nil then
    os_str = result
end

if os_str == "freebsd" then
    return require("freebsd")
elseif os_str == "ubuntu" then
    return require("ubuntu")
end

function get_executable(full_cmd)
    local cmd = full_cmd:gmatch("(%w+)", "%1")()
    if cmd == nil then
        error("Not a command?", 2)
    end
    return cmd
end

function is_cmd(full_cmd)
    local ok,cmd = pcall(function ()get_executable(full_cmd) end)
end

return {
    autostart={},
    battery={
        available=false,
        state=function()
            return {
                acline=0,
                battery_life=0,
            }
        end,
    }
}
