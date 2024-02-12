#!/usr/bin/lua
local lu = require('luaunit')

local utils = require("Functions")

local data = require("Tests.mock")

TestCurlSpeed = {}

local best_isp = data:best_isp()

function TestCurlSpeed:testDownloadSpeed()

    lu.assertFunction( utils.measure_download)
    lu.assertNumber( utils.measure_download(best_isp["host"]))

end


function TestCurlSpeed:testUploadSpeed()

    lu.assertFunction( utils.measure_upload)
    lu.assertNumber( utils.measure_upload(best_isp["host"]))
end

return TestCurlSpeed