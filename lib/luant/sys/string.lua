-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：string.lua
-- 简介：string的扩充

local String = Class('lib.sys.string', string)

-- 依赖
local crc32 = require('lib.crc32')

-- 编码相关
-- crc32
function String.crc32(str)
    return crc32.hash(str)
end

-- -- encode base64  
-- function String.encode_base64(str)
--     return ngx.encode_base64(str)
-- end

-- -- decode base64  
-- function String.decode_base64(str)
--     return ngx.decode_base64(str)
-- end

-- -- md5 
-- function String.md5(str)
--     return ngx.md5(str)
-- end

-- 类型判断
-- return：true|false
function String.is_string(s)
    return type(s) == 'string' 
end

-- 是否为空string
-- return：true|false
function String.is_empty_string(s)
    return type(s) == 'string' and s == '' 
end

-- 是否为非空string
-- return：true|false
function String.is_noempty_string(s)
    return type(s) == 'string' and s ~= ''
end

-- 去除字符串头尾空字符
-- return：string
function String.trim(s)
    if type(s) == 'string' then
        return string.gsub(s, "^%s*(.-)%s*$", "%1")
    end
    return s
end

-- 查找子串第一次出现位置
function String.index_of(str, substr)
    return string.find(str, substr, 1, true)
end

-- 查找子串最后一次出现位置
function String.last_index_of(str, substr)
    return string.match(str, '.*()' .. substr)
end

-- 判断字符串开头
-- return：true|false|nil
function String.startswith(s, sub)
    -- return String.index_of(s, sub) == 1
    if type(s) == 'string' and type(sub) == 'string' then
        if string.find(s, sub) == 1 then
            return true
        else
            return false
        end
    end
end

-- 判断字符串结尾
-- return：true|false|nil
function String.endswith(s, sub)
    -- return String.last_index_of(s, sub) + string.len(sub) == string.len(s)
    if type(s) == 'string' and type(sub) == 'string' then
        t_s = string.reverse(s)
        t_sub = string.reverse(sub)
        if string.find(t_s, t_sub) == 1 then
            return true
        else
            return false
        end
    end
end

-- 字符串分割
-- return：table
function String.split(str, delim, maxNb)
    -- 类型容错
    if type(str) ~= 'string' then
        return {}
    end 

    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0 -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end

return String