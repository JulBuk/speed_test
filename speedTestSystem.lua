#!/usr/bin/lua
local lu = require('luaunit')
local func = require("Functions")


function check_connection(provided_url)
    if not provided_url or #provided_url == 0 then
        if type(provided_url) == "nil" then
            if lu.assertEquals(type(provided_url),"nil") then

                error("Passed argument is not a string it is: ".. type(provided_url))
            end
        elseif not(type(provided_url) == "string") then
            error("Passed argument is not a string it is: ".. type(provided_url))    
        end
    end
    return func.check_connection(provided_url)
end


function get_server_list()
    return func.get_server_list()
end


function get_location()
    return func.get_location()
end


function find_best_server(server_list, location)
    if not lu.assertIsTable(server_list) or 
        not lu.assertIsTable(location) then
        
        error("Passed arguments are not a table")
    end
    return func.find_best_server(server_list,location)
end


function measure_download(url)
    if not lu.assertIsString(url) then
        error("Passed argument is not a string")
    end
    return func.measure_download(url)
end

function measure_upload(url)
    if not lu.assertIsString(url) then
        error("Passed argument is not a string")
    end
    return func.measure_upload(url)
end
