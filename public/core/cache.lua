-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：cache.lua
-- 简介：luant全局缓存
-- 功能：设｜取｜删 luant全局缓存
-- 使用：lcache.${method}(...)

local _M = {}

function _M.getC(k, default_v)
    if not LUANT_C[k] then
        return default_v
    else
        return LUANT_C[k]
    end
end

function _M.setC(k, v)
    LUANT_C[k] = v
end

function _M.delC(k)
    LUANT_C[k] = nil
end

function _M.getD(k, default_v)
    if not LUANT_D[k] then
        return default_v
    else
        return LUANT_D[k]
    end
end

function _M.setD(k, v)
    LUANT_D[k] = v
end

function _M.delD(k)
    LUANT_D[k] = nil
end

return _M