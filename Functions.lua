#!/usr/bin/lua

local curl = require("lcurl")
local cjson = require("cjson")
local socket = require("socket")

local funcs = {}

local function download_progress_callback(dltotal, dlnow, _, _)
    if easy:getinfo(curl.INFO_RESPONSE_CODE) == 404 then
        return false, error("server returned 404 code", 0)
    end
    local elapsed_time = socket.gettime() - test_time
    local curr_speed = dlnow / elapsed_time / 1024 / 1024 * 8
    if curr_speed > 0 then
        io.write(string.format("\rDownload speed: %.2f",curr_speed))
        io.flush()
    end
end
------------------------------------------------------------------
function funcs.measure_download(url)
    if not url then error("Bad url.", 0) end
    local output_file = io.open("/dev/null", "r+")
    local download_speed
    if not output_file then
        error("Couldn't open /dev/null",0)
    else
        print("\nPreparing download speed test \n")
    end
    
    easy = curl.easy{
        httpheader = {
            "User-Agent: curl/7.81.0", "Accept: */*", "Cache-Control: no-cache"
        },
        url = url .. "/download",
        writefunction = output_file,
        progressfunction = download_progress_callback,
        timeout = 15,
        noprogress = false,
    }
    test_time = socket.gettime()
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
--====================================================
local function upload_progress_callback(dltotal, dlnow, ultotal, ulnow)
    if easy:getinfo(curl.INFO_RESPONSE_CODE) == 404 then
        return false, error("server returned 404 code", 0)
    end
    --print(dlnow,ulnow)
    local elapsed_time = socket.gettime() - test_time
    local curr_speed = ulnow / elapsed_time / 1024 / 1024 * 8
    if curr_speed > 0 then
        io.write(string.format("\rUpload speed: %.2f",curr_speed))
        io.flush()
    end
end

local function read_function_callback(size, nitems)
    if easy:getinfo(curl.INFO_RESPONSE_CODE) == 404 then

        print(easy:getinfo(curl.INFO_RESPONSE_CODE))
        return false, error("server returned 404 code", 0)
    end
    --print(easy:getinfo(curl.INFO_RESPONSE_CODE))
    local input_file = io.open("/dev/zero", "r+")
    if not input_file then
        error("Could not open input file",0)
    end
    local upload_data = input_file:read(4096)
    --print(size,nitems)
    return upload_data

end


function funcs.upload_speed(url)
    if not url then error("Bad url.", 0) end
    easy = curl.easy({
        httpheader = {
            "User-Agent: curl/7.81.0", "Accept: */*", "Cache-Control: no-cache"
        },
        url = url .. "/upload",
        post = true,
        noprogress = false,
        writefunction = io.open("/dev/null", "r+"),
        progressfunction = upload_progress_callback,
        httppost = curl.form({
            file = {file = "/dev/zero", type = "text/plain", name = "zeros"}
        }),
        timeout = 15
    })

    test_time = socket.gettime()
    status, value = pcall(easy.perform, easy)
    if not status and value ~=
        "[CURL-EASY][OPERATION_TIMEDOUT] Timeout was reached (28)" then
        easy:close()
        error("Error: " .. value .. " while testing upload speed with host " ..
                  url, 0)
    end

    local up_speed = easy:getinfo(curl.INFO_SPEED_UPLOAD) / 1024 / 1024 * 8

    easy:close()

    return up_speed
end
--====================================================
------------------------------------------------------------------
function funcs.measure_upload(url)
    if not url then error("Bad url.", 0) end
    print("\nPreparing upload speed test\n")

    local input_file = io.open("/dev/zero", "r+")
    if not input_file then
        error("Could not open input file",0)
    end
    local upload_data = input_file:read(500000000)
    io.close(input_file)

    easy = curl.easy{
        httpheader = {
            "User-Agent: curl/7.81.0", "Accept: */*", "Cache-Control: no-cache"
        },
        url = url .. "/upload",
        post = true,
        noprogress = false,
        progressfunction = upload_progress_callback,
        --readfunction = read_function_callback,
        postfields = upload_data,
        httppost = curl.form({
            file = {file = "/dev/zero",
                    type = "text/plain", 
                    name = "zeros"}
        }),
        timeout = 15,
    }


    test_time = socket.gettime()
    local status, response = pcall(easy.perform, easy)

    if not status then
        local error_code = tonumber(string.sub(response,-3,-2))
        if not error_code == 28 then
            easy:close()
            error("Error: " .. response .. " with " .. url,0)
        end
    end

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
            error("Error: " .. response,0)
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
    print("\nStarting searching for best server")
    for i, value in ipairs(server_list) do

        if string.find(location[1]["country"], value["country"]) then

            local easy = curl.easy{
                url = value["host"],
            }

            local status, response = pcall(easy.perform, easy)

            if not status then
                easy:close()

                local error_code = string.sub(response,-3,-2)
                if not error_code == "7 "then
                    error("Error: " .. response .. " while fetching server " .. value["host"],0)
                end
                break

            else

                local latency = easy:getinfo(curl.INFO_TOTAL_TIME)/1024/1024 *8

                local_servers[latency] = value
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