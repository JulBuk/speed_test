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

local parser = argparse("Tests", "run modes.")
parser:flag("-f --full", "Execute the full test")
parser:flag("-s --server", "Find best server")
parser:flag("-l --location", "Find user location")
parser:flag("-d --download", "Download speed test")
parser:flag("-u --upload", "Upload speed test")

local args = parser:parse()

if args["full"] then
    
    local statusl, location = pcall(utils.get_location)
    if statusl then
        print("Your current location is: ".. location[1]['city'] .. ", " .. location[1]["country"])
    end
    local statusd, download_speed = pcall(utils.measure_download,isp_url)
    if statusd then
        print("Your internet download speed: ".. string.format("%.2f ", download_speed).. "Mbps")
    end
    local statusu, upload_speed = pcall(utils.measure_upload,isp_url)
    if statusu then
        print("Your internet upload speed: ".. string.format("%.2f ", upload_speed).. "Mbps")
    end
    local statuss, best_isp = pcall(utils.find_best_server,server_list,location)
    if statuss then
        print("Your best internet service provider: ".. best_isp)        
    end

    if statusl and statusd and statusu and statuss then
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
            error("Failed to write to json file")
        end
    else
        error("Failed to write to json file")
    end
elseif args["server"] then

    local statuss, best_isp = pcall(utils.find_best_server,server_list,location)
    if statuss then
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
            error("Failed to write to json file")
        end
    end
elseif args["location"] then

    local statusl, location = pcall(utils.get_location)
    if statusl then
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
            error("Failed to write to json file")
        end
    end
elseif args["download"] then

    local statusd, download_speed = pcall(utils.measure_download,isp_url)
    if statusd then
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
            error("Failed to write to json file")
        end
    end
elseif args["upload"] then

    local statusu, upload_speed = pcall(utils.measure_upload,isp_url)
    if statusu then
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
            error("Failed to write to json file")
        end
    end
end