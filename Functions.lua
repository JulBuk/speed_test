#!/usr/bin/lua

local curl = require("lcurl")
local cjson = require("cjson")

local funcs = {}

------------------------------------------------------------------
function funcs.measure_download(url)
    local output_file = io.open("/dev/null", "r+")
    local download_speed
    if not output_file then
        error("Couldn't open /dev/null")
    end
    
    local easy = curl.easy{
        httpheader = {
            "Accept: */*", "User-Agent: -o"
        },
        url = url .. "/download",
        writefunction = output_file,
        [curl.OPT_TIMEOUT] = 10,
        noprogress = false,
    }

    local status, response = pcall(easy.perform, easy)
    if not status then
        local error_code = tonumber(string.sub(response,-3,-2))
        if not error_code == 28 then
            easy:close()
            error("Error: " .. response .. " with " .. url,0)
        else
        end
    end

    io.close(output_file)

    download_speed = easy:getinfo(curl.INFO_SPEED_DOWNLOAD)/1024/1024 *8
    easy:close()

    return download_speed
end
------------------------------------------------------------------
function funcs.measure_upload(url)
    local input_file = io.open("/dev/zero", "r+")
    
    if not input_file then
        error("Could not open input file")
    end
    
    local start_time = os.time()
    local duration = 10
    local upload_data

    upload_data = input_file:read(4096)
    local easy = curl.easy{
        httpheader = {
            "Accept: */*", "User-Agent: -o"
        },
        url = url .. "/upload",
        [curl.OPT_POSTFIELDS] = upload_data,
        [curl.OPT_TIMEOUT] = 10,
        noprogress = false,
    }

    local status, response = pcall(easy.perform, easy)

    if not status then
        local error_code = tonumber(string.sub(response,-3,-2))
        if not error_code == 28 then
            easy:close()
            error("Error: " .. response .. " with " .. url,0)
        end
    end
    
    io.close(input_file)

    local upload_speed = easy:getinfo(curl.INFO_SPEED_UPLOAD)/1024/1024 *8
    easy:close()
    return upload_speed
end
------------------------------------------------------------------
function funcs.get_server_list()
    local file_url = "https://raw.githubusercontent.com/JulBuk/speed_test/main/speedtest_server_list.json"
    
    local server_list

    local server_list_file = io.open("speedtest_server_list.json","r+")
    if server_list_file then
        server_list = cjson.decode(server_list_file:read())
        return server_list
    else
        local server_list_file = io.open("speedtest_server_list.json","w+")

        local response_string = ""

        local easy = curl.easy{
            url = file_url,
                writefunction = (function(response)
                    response_string = response_string .. response
                    return #response
                end)
        }
        local status, response = pcall(easy.perform, easy)

        if not status then
            --easy.close()
            error("Error: " .. response)
        end

        easy:close()
        server_list_file:write(response_string)
        server_list = cjson.decode(response_string)
        return server_list
    end
end
------------------------------------------------------------------
function funcs.find_best_server(server_list, location)

    local local_servers = {}

    local best_server = ""
    local min_latency = math.huge

    for i, value in ipairs(server_list) do

        if string.find(location[1]["country"], value["country"]) then

            local easy = curl.easy{
                url = value["host"],
                noprogress = false,
            }

            local status, response = pcall(easy.perform, easy)

            if not status then
                easy:close()

                local error_code = string.sub(response,-3,-2)
                if not error_code == "7 "then
                    error("Error: " .. response .. " while fetching server " .. value["host"])
                end
                break

            else

                local latency = easy:getinfo(curl.INFO_TOTAL_TIME)/1024/1024 *8

                local_servers[latency] = value["provider"]
                min_latency = math.min(min_latency,latency)

            end

            easy:close()
        end
    end

    best_server = local_servers[min_latency]

    return best_server
end
------------------------------------------------------------------
function funcs.get_location()
    local api_url = "http://ip-api.com/json/"

    local response_string = ""

    local easy = curl.easy{
        url = api_url,
            writefunction = (function(response)
                response_string = "[" .. response .. "]"
                return #response
            end)
    }

    local status, response = pcall(easy.perform, easy)
    
    easy:close()
    local location = cjson.decode(response_string)

    return location
end
------------------------------------------------------------------
function funcs.check_connection()
    local url = "https://1.1.1.1/"

    local easy = curl.easy{
        url = url,
            writefunction = (function(response)
                return #response
            end)
    }

    easy:setopt(curl.OPT_NOBODY, true)
    easy:setopt(curl.OPT_HEADER, true)

    local status, response = pcall(easy.perform, easy)
    
    easy:close()
    
    return status

end
return funcs