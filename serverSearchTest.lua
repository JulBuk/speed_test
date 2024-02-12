#!/usr/bin/lua
local lu = require('luaunit')

local utils = require("Functions")

local data = require("Tests.mock")

TestServers = {}

function TestServers:testFindBestServer()
    local server_list = data:server_list()
    local user_location = data:user_location()
    
    lu.assertFunction(utils.find_best_server)
    lu.assertTable(utils.find_best_server(server_list, user_location))

end

return TestServers                           