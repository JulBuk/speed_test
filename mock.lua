#!/usr/bin/lua
local lu = require('luaunit')

local utils = require("Functions")
    local server_list
    local user_location
    local best_isp
data = {}
function data:server_list()
    server_list = utils.get_server_list()
    return server_list
end
function data:user_location()
    user_location = utils.get_location()
    return user_location
end
function data:best_isp()
    best_isp = utils.find_best_server(data:server_list(),data:user_location())
    return best_isp
end

return data