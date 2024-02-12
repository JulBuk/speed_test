#!/usr/bin/lua
local lu = require('luaunit')

local utils = require("Functions")

TestCurlConnection = {}

function TestCurlConnection:testConnection()
    
    lu.assertTrue(check_connection())
end

return TestCurlConnection                                                    