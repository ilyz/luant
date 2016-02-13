-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：request.lua
-- 简介：请求参数处理
-- 功能：处理应用层请求参数
-- 使用：Request.${method}(...)

local Request = Class("pubilc.core.request")
local self = nil

-- 初始化
function Request.init(this)
    self = this
    self.args = {}
    self.init_args()
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
function Request.init_args()
    -- get
    self.args = ngx.req.get_uri_args()
    -- get data参数特殊支持
    if self.args.data then
        json_args = json.json_decode(self.args.data)
        self.args = table.merge(self.args, json_args)
    end
    -- post
    method = string.upper(ngx.var.request_method)
    if method == "POST" then
        ngx.req.read_body()
        post_data = ngx.req.get_body_data()
        post_args = json.json_decode(post_data)
        self.args = table.merge(self.args, post_args)
    end
end

function Request.get_ngx_var(k)
    return ngx.var[k]
end

function Request.get_arg(k)
    return self.args[k]
end

function Request.get_args()
    return self.args
end

return Request