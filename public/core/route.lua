-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：route.lua
-- 简介：luant APP路由相关信息
-- 功能：读取路由、配置、文件
--      所有文件均缓存于lcache中
-- 使用：lroute.${method}(...)

local Route = {}

local ACTION_DIR = 'app.action'
local CONFIG_DIR = 'app.config'

-- 输出require错误信息，便于调试
local function _say_require_err(err)
    if DEBUG then
        ngx.say('error: ' .. err .. '<br>')
        ngx.say('<br>' .. debug.traceback() .. '<br>')
    end
end

-- 加载文件
function Route.require(path)
    local ok, res = pcall(require, path)
    if not ok and DEBUG then
        xpcall(require, _say_require_err, path)
        -- require(path)
    end
    return res
end

-- 断言：一定能加载到文件
function Route.assert_require(path)
    local res = Route.require(path)
    if not res then
        lexception.throw_require_error(path)
    end
    return res
end

-- 加载配置文件
function Route.require_conf(path)
    if not string.startswith(path, CONFIG_DIR) then
        path = CONFIG_DIR .. '.' .. path
    end
    return Route.require(path)
end

-- 断言：一定能加载到配置文件
function Route.assert_require_conf(path)
    res = Route.require_conf(path)
    if not res then
        lexception.throw_config_error(path)
    end
    return res
end

-- 提取类和函数名
local function _get_class_func_names(uri)
    if string.is_noempty_string(uri) then
        -- 规范uri
        uri = string.trim(uri)
        if string.startswith(uri, '/') then
            uri = string.sub(uri, 2, string.len(uri))
        end
        if string.endswith(uri, '/') then
            uri = string.sub(uri, 1, string.len(uri) - 1)
        end
        -- 提取路径
        paths = string.split(uri, '/')
        func = paths[#paths]
        class = ACTION_DIR
        for i = 1, #paths - 1, 1 do
            class = class .. '.' .. paths[i]
        end
        return class, func
    end
end

-- 获取类和函数
function Route.get_class_function(uri)
    local class_name, func_name = _get_class_func_names(uri)
    if class_name then
        local class = Route.require(class_name)
        if type(class.new) == 'function' then
            class = class:new()
        end
        return class, class[func_name]
    end
end

-- 断言：一定能获取到类和函数
function Route.assert_get_class_function(uri)
    local class, func = Route.get_class_function(uri)
    if type(class) ~= 'table' then
        c_name, f_name = _get_class_func_names(uri)
        lexception.throw_load_class_error(c_name)
    end
    if type(func) ~= 'function' then
        c_name, f_name = _get_class_func_names(uri)
        lexception.throw_load_func_error(f_name)
    end
    return class, func
end

return Route