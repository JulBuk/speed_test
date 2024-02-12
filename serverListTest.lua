#!/usr/bin/lua
local lu = require('luaunit')

local utils = require("Functions")

TestGetList = {}
local server_list = {}

function TestGetList:testRunGetServerList()

    lu.assertFunction( utils.get_server_list)
    lu.assertTable( utils.get_server_list())
end
    --server_list = utils.get_server_list()

return TestGetList--, server_list