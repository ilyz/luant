-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：json.lua
-- 简介：json的扩充

local cjson = require('cjson')
local Json = Class('lib.sys.json', cjson)

-- json encode
function Json.json_encode(t)
    local ok, str = pcall(Json.encode, t)
    if ok then
        return str
    else
        return nil
    end
end

-- json decode
function Json.json_decode(s)
    local ok, list = pcall(Json.decode, s)
    if ok then
        return list
    else
        return nil
    end
end

return Json