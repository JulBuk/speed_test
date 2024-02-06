#!/usr/bin/lua
--local curl = require("lcurl")
local cjson = require("cjson")
local argparse = require("argparse")

local utils = require("Functions")

local check = utils.check_connection()

if not check then error("No internet connection") end

local server_list = utils.get_server_list()
local location = utils.get_location()

local isp

local isp_name = location[1]["isp"]
for i, obj in ipairs(server_list) do
        if string.find(isp_name, obj.provider)then
            isp = obj
            break
        end
    end

local isp_url = isp["host"]

local parser = argparse("script", "An example.")
parser:flag("-f --full", "Execute the full test")
parser:flag("-s --server", "Find best server")
parser:flag("-l --location", "Find user location")
parser:flag("-d --download", "Download speed test")
parser:flag("-u --upload", "Upload speed test")

local args = parser:parse()

if args["full"] then
    
    local location = utils.get_location()
    print("Your current location is: ".. location[1]['city'] .. ", " .. location[1]["country"])
    local download_speed = utils.measure_download(isp_url)
    print("Your internet download speed: ".. string.format("%.2f ", download_speed).. "Mbps")
    local upload_speed = utils.measure_upload(isp_url)
    print("Your internet upload speed: ".. string.format("%.2f ", upload_speed).. "Mbps")
    local best_isp = utils.find_best_server(server_list,location)
    print("Your best internet service provider: ".. best_isp)

    local test_data = {
        location = location,
        download_speed = download_speed,
        upload_speed = upload_speed,
        best_isp = best_isp,
    }
    local test_json = cjson.encode(test_data)
    local file = io.open("test.json", "w")
    if file then
        file:write(test_json)
        file:close()
    else
        print("Failed to write to json file")
    end
    
elseif args["server"] then

    local best_isp = utils.find_best_server(server_list,location)
    print("Your best internet service provider: ".. best_isp)

    local test_data = {
        best_isp = best_isp,
    }
    local test_json = cjson.encode(test_data)
    local file = io.open("test.json", "w")
    if file then
        file:write(test_json)
        file:close()
    else
        print("Failed to write to json file")
    end

elseif args["location"] then

    local location = utils.get_location()
    print("Your current location is: ".. location[1]['city'] .. ", " .. location[1]["country"])

    local test_data = {
        location = location,
    }
    local test_json = cjson.encode(test_data)
    local file = io.open("test.json", "w")
    if file then
        file:write(test_json)
        file:close()
    else
        print("Failed to write to json file")
    end

elseif args["download"] then

    local download_speed = utils.measure_download(isp_url)
    print("Your internet download speed: ".. string.format("%.2f ", download_speed).. "Mbps")

    local test_data = {
        download_speed = download_speed,
    }
    local test_json = cjson.encode(test_data)
    local file = io.open("test.json", "w")
    if file then
        file:write(test_json)
        file:close()
    else
        print("Failed to write to json file")
    end

elseif args["upload"] then

    local upload_speed = utils.measure_upload(isp_url)
    print("Your internet upload speed: ".. string.format("%.2f ", upload_speed).. "Mbps")

    local test_data = {
        upload_speed = upload_speed,
    }
    local test_json = cjson.encode(test_data)
    local file = io.open("test.json", "w")
    if file then
        file:write(test_json)
        file:close()
    else
        print("Failed to write to json file")
    end

end