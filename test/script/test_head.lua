-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：test_head.lua
-- 简介：单测头信息

-- luant环境配置
package.path = '/data/greentea/luant/?.lua;/data/greentea/luant/lib/?.lua;' .. package.path
package.cpath = '/data/greentea/luant/lib/?.so;' .. package.cpath

-- 单元测试环境
UNIT_TEST = true

-- 系统功能
Class = require("lib.luant.sys.class")
string = require('lib.luant.sys.string')
table = require('lib.luant.sys.table')
json = require('lib.luant.sys.json')

-- luant核心库
lcache = require("public.core.cache")
lroute = require("public.core.route")
lexception = require("public.core.exception")

-- ngx_lua相关功能moc
ngx = {}

ngx.msgs = {}

ngx.quote_sql_str = function(str)
    if type(str) == 'string' then
        return "'" .. str .. "'"
    else
        return str
    end
end

ngx.say = function(msg)
    table.insert(ngx.msgs, msg)    
end

ngx.exit = function(msg)
    return ngx.msgs
end

require 'busted.runner'()