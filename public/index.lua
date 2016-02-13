-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：index.lua
-- 简介：luant分发入口
-- 功能：将uri分发至各个模块
-- 使用：在nginx对应location中添加：content_by_lua_file '${LUANT_PATH}/public/index.lua';

local Request = lroute.require("public.core.request")

local function init()
    ngx.ctx.request = Request:new()
end

local function execute()
    local class, func = lroute.assert_get_class_function(ngx.var.uri)
    -- 调用
    res = func(ngx.ctx.request)
    -- 释放资源
    if type(class.clear) == 'function' then
        class.clear()
    end
    -- 返回值处理
    if type(res) == 'table' then
        if not res.err_no then
            res = {result=res}
        end
    elseif type(res) == 'nil' then
        res = {err_no=0}
    else
        res = {result=res}
    end
    -- 返回
    lexception.success(res)
    
end

local function process()
    init()
    execute()
end

process()