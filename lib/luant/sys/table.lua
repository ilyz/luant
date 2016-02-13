-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：table.lua
-- 简介：Table功能补充
-- 使用：table.${method}(...)

local Table = Class('lib.sys.table', table)

-- 类型判断
-- return：true|false
function Table.is_table(t)
    return type(t) == 'table';
end

-- 是否为空table
-- return：true|false|nil
function Table.is_empty_table(t)
    if type(t) == 'table' then
        for k, v in pairs(t) do
            return false
        end
        return true
    end
end

-- 是否为非空table
-- return：true|false|nil
function Table.is_noempty_table(t)
    if type(t) == 'table' then
        for k, v in pairs(t) do
            return true
        end
        return false
    end
end

-- 判断key是否存在
-- return：true|false|nil
function Table.key_exists(t, k)
    if type(t) == 'table' then
        for key, v in pairs(t) do
            if key == k then
                return true
            end
        end
        return false
    end
end

-- 判断val是否存在
-- return：true|false|nil
function Table.value_exists(t, v)
    if type(t) == 'table' then
        for k, val in pairs(t) do
            if val == v then
                return true
            end
        end
        return false
    end
end

-- 计算表长度(array&&dict)
-- array：=#t
-- dict：元素总数
-- return：number|nil
function Table.len(t)
    if type(t) == 'table' then
        len = 0
        for k,v in pairs(t) do
            len = len + 1
        end
        return len
    end
end

-- 获取table表中第一个值对的k v(array&&dict)
-- return：k, v|nil
function Table.first_kv(t)
    if type(t) == 'table' then
        for k, v in pairs(t) do
            return k, v 
        end
    end
end

-- 将t2表中的元素merge入t1表中(array&&dict)
-- 若为dict，则用key做唯一标识
-- 若为数组，则用value做唯一标识
-- return：table|nil
function Table.merge(t1, t2)
    if type(t1) == 'table' and type(t2) == 'table' then
        for k, v in pairs(t2) do
            if type(k) ~= 'number' then
                t1[k] = v
            elseif not Table.value_exists(t1, v) then
                table.insert(t1, v)
            end
        end
        return t1
    end
end

-- 从表中摘取需要的key val(array&&dict)
-- return：table
function Table.select(t, keys)
    r = {}
    if type(t) == 'table' and type(keys) == 'table' then
        for k, v in pairs(keys) do
            r[v] = t[v]
        end
    end
    return r
end

return Table