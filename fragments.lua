
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

    run_time = socket.gettime()
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