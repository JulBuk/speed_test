#!/usr/bin/lua
local lu = require('luaunit')

package.path = package.path .. ";../?.lua"

require("Tests.speedTestSystem")

ConnectionTest = require("Tests.connectionTest")
ServerListTest = require("Tests.serverListTest")
LocationTest = require("Tests.locationTest")
ServerSearchTest = require("Tests.serverSearchTest")
InternetSpeedTest = require("Tests.ispSpeedTest")

os.exit( lu.LuaUnit.run() )