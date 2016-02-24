-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：request.lua
-- 简介：请求参数处理
-- 功能：处理应用层请求参数
-- 使用：Request.${method}(...)

local Request = Class("pubilc.core.request")

-- 依赖
local tostring = tostring
local tonumber = tonumber
local strupper = string.upper

-- 初始化
function Request.init(self)
    self.args = {}
    self:init_args()
    --[[
    self.host = ngx.var.host
    self.hostname = ngx.var.hostname
    self.uri = ngx.var.uri
    self.schema = ngx.var.schema
    self.request_uri = ngx.var.request_uri
    self.request_method = ngx.var.request_method
    self.request_filename = ngx.var.request_filename
    self.remote_addr = ngx.var.remote_addr
    self.remote_port = ngx.var.remote_port
    self.remote_user = ngx.var.remote_user
    self.remote_passwd = ngx.var.remote_passwd
    self.content_type = ngx.var.content_type
    self.content_length = ngx.var.content_length
    self.http_user_agent = ngx.var.http_user_agent
    self.query_string = ngx.var.query_string
    self.headers = ngx.req.get_headers()
    self.socket = ngx.req.socket
    ]]
end

-- 初始化参数
function Request.init_args(self)
    -- get
    self.args = ngx.req.get_uri_args()
    -- get data参数特殊支持
    if self.args.data then
        json_args = json.json_decode(self.args.data)
        self.args = table.merge(self.args, json_args)
    end
    -- post
    method = strupper(ngx.var.request_method)
    if method == "POST" then
        ngx.req.read_body()
        post_data = ngx.req.get_body_data()
        post_args = json.json_decode(post_data)
        self.args = table.merge(self.args, post_args)
    end
end

function Request.get_ngx_var(self, k, default_v)
    if ngx.var[k] then
        return ngx.var[k]
    else
        return default_v
    end
end

function Request.get_arg(self, k, default_v)
    if self.args[k] then
        return self.args[k]
    else
        return default_v
    end
end

function Request.assert_get(self, k)
    if self.args[k] then
        return self.args[k]
    end
    lexception.throw_param_error(k, self.args[k])
end

function Request.assert_get_str(self, k)
    if self.args[k] then
        return tostring(self.args[k])
    end
    lexception.throw_param_error(k, self.args[k])
end

function Request.assert_get_number(self, k)
    if self.args[k] then
        return tonumber(self.args[k])
    end
    lexception.throw_param_error(k, self.args[k])
end

-- return：table
function Request.get_args(self, keys)
    -- 获取批量参数
    if type(keys) == 'table' then
        local r = {}
        for k, v in pairs(keys) do
            if type(k) == 'number' then
                r[v] = self.args[v]
            elseif self.args[k] then
                r[k] = self.args[k]
            else
                r[k] = v
            end
        end
        return r
    end
    -- 获取单个参数
    if type(keys) == 'string' then
        return self.args[keys]
    end
    -- 获取所有参数
    return self.args
end

function Request.assert_get_args(self, keys)
    if type(keys) == 'table' then
        local r = {}
        for k, v in pairs(keys) do
            if self.args[v] then 
                r[v] = self.args[v]
            else
                lexception.throw_param_error(v, self.args[v])
            end
        end
        return r
    end
end

return Request