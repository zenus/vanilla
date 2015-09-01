-- dep
local json = require 'cjson'

-- perf
local error = error
local jdecode = json.decode
local pcall = pcall
local rawget = rawget
local setmetatable = setmetatable


local View = {}
View.__index = View

function View:new(ngx)
    -- read body
    ngx.req.read_body()
    local body_raw = ngx.req.get_body_data()

    -- parse body
    local body = nil
    if body_raw == nil then
         body = nil
    else
        ok, json_or_error = pcall(function() return jdecode(body_raw) end)
        if ok == false then error({ code = 103 }) end
        if json_or_error[1] ~= nil then error({ code = 104 }) end
        body = json_or_error
    end

    -- init instance
    local instance = {
        ngx = ngx,
        uri = ngx.var.uri,
        method = ngx.var.request_method,
        headers = ngx.req.get_headers(),
        body_raw = body_raw,
        body= body,
        api_version = nil,
        __cache = {}
    }
    setmetatable(instance, View)
    return instance
end

function View:__index(index)
    local out = rawget(rawget(self, '__cache'), index)
    if out then return out end

    if index == 'uri_params' then
        self.__cache[index] = ngx.req.get_uri_args()
        return self.__cache[index]

    else
        return rawget(self, index)
    end
end

function View:assign()
end

function View:display()
end

function View:getScriptPath()
end

function View:render()
end

function View:setScriptPath()
end

return View