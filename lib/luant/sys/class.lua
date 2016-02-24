-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：class.lua
-- 简介：luant类声明
-- 功能：声明类
-- 使用：Class(${CLASS_PATH}, ${SUPER_PATH})

-- classname，类名，建议使用路径
-- super可以是类路径也可以是类对象
-- 创建的类以init作为默认初始化函数
function class(classname, super)
    local cls = {}

    -- clone super
    if type(super) == 'string' then
        super = lroute.require(super)
    end
    if type(super) ~= "function" and type(super) ~= "table" then
        super = nil
    end
    if super then
        setmetatable(cls, {__index = super})
        cls.super = super
    end

    -- define this
    cls.__cname = classname
    cls.__index = cls

    function cls.new(self, ...)
        local instance = setmetatable({}, cls)
        instance.class = cls
        if instance.init and type(instance.init) == 'function' then
            instance:init(...)
        end
        return instance
    end
    return cls
end

return class