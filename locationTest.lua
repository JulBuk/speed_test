#!/usr/bin/lua
local lu = require('luaunit')

local utils = require("Functions")

TestGetLocation = {}

function TestGetLocation:testGetLocation()

    lu.assertFunction( utils.get_location)
    lu.assertTable( utils.get_location())
end

return TestGetLocation