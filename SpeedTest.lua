#!/usr/bin/lua
--local curl = require("lcurl")
local cjson = require("cjson")
local argparse = require("argparse")

local utils = require("Functions")

local check = utils.check_connection()


local server_list = utils.get_server_list()

local parser = argparse("Modes", "Internet speed test use modes to run speed tests.")
parser:flag("-f --full", "Execute the full test")
parser:flag("-s --server", "Find best server")
parser:flag("-l --location", "Find user location")
parser:option("-d --download_url", "Download speed test")--user specified
parser:option("-u --upload_url", "Upload speed test")--user specified

local args = parser:parse()

if not next(args) then
    print(parser:get_help())
    return
end

if not check then 
    error("No internet connection") 
else
    print("Beginning tests\n")
end

local function write_to_json(test_data)
    local test_json = cjson.encode(test_data)
    local file = io.open("test.json", "w")
    if file then
        file:write(test_json)
        file:close()
    else
        error("Failed to write to json file")
    end
end

if args["full"] then
    
    local statusl, location = pcall(utils.get_location)
    if statusl then
        print("Your current location is: ".. location[1]['city'] .. ", " .. location[1]["country"])
    end
    local statuss, best_isp = pcall(utils.find_best_server,server_list,location)
    if statuss then
        print("\nYour best internet service provider: ".. best_isp["provider"].." from: ".. best_isp["city"]..", "..best_isp["country"])
        print("With server: "..best_isp["host"])       
    end
    local statusd, download_speed = pcall(utils.measure_download,best_isp["host"])
    if statusd then
        print("\nYour internet download speed: ".. string.format("%.2f ", download_speed).. "Mbps")
    end
    local statusu, upload_speed = pcall(utils.measure_upload,best_isp["host"])
    if statusu then
        print("\nYour internet upload speed: ".. string.format("%.2f ", upload_speed).. "Mbps")
    end

    if statusl and statusd and statusu and statuss then
        local test_data = {
            location = location,
            download_speed = download_speed,
            upload_speed = upload_speed,
            best_isp = best_isp,
        }
        write_to_json(test_data)
    else
        error("Failed to write to json file")
    end
elseif args["server"] then
    local statusl, location = pcall(utils.get_location)
    if statusl then
        local statuss, best_isp = pcall(utils.find_best_server,server_list,location)
        if statuss then
            print("Your best internet service provider: ".. best_isp["provider"].." from: ".. best_isp["city"]..", "..best_isp["country"])
            print("With server: "..best_isp["host"])       

            local test_data = {
                best_isp = best_isp,
            }
            write_to_json(test_data)
        end
    else
        error("User location not found")
    end
elseif args["location"] then

    local statusl, location = pcall(utils.get_location)
    if statusl then
        print("Your current location is: ".. location[1]['city'] .. ", " .. location[1]["country"])
    
    
        local test_data = {
            location = location,
        }
        write_to_json(test_data)
    end
elseif args["download_url"] then

    local url = args["download_url"]
    local _, statuscon = pcall(utils.check_connection, url)
    if statuscon then
        local statusd, download_speed = pcall(utils.measure_download,url)
        
        if statusd then
            print("\nYour internet download speed: ".. string.format("%.2f ", download_speed).. "Mbps")
        
        
            local test_data = {
                download_speed = download_speed,
            }
            write_to_json(test_data)
        end
    else
        error("Server: " .. url .. " is not working")
    end
elseif args["upload_url"] then

    local url = args["upload_url"]
    local _, statuscon = pcall(utils.check_connection, url)
    if statuscon then
        local statusu, upload_speed = pcall(utils.measure_upload,url)
        if statusu then
            print("\nYour internet upload speed: ".. string.format("%.2f ", upload_speed).. "Mbps")
        
        
            local test_data = {
                upload_speed = upload_speed,
            }
            write_to_json(test_data)
        end
    else
        error("Server: " .. url .. " is not working")
    end
end