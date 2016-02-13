-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：factory.lua
-- 简介：sql操作相关定义

local _M = {}

-- operation
_M.INSERT = 'INSERT'
_M.MULTI_INSERT = 'MULTI_INSERT'
_M.DELETE = 'DELETE'
_M.UPDATE = 'UPDATE'
_M.SELECT = 'SELECT'
_M.INSERT_OR_UPDATE = 'INSERT_OR_UPDATE'
_M.ALTER_TABLE = 'ALTER_TABLE'

-- condition
_M.BETWEEN = 'BETWEEN'
_M.IN = 'IN'
_M.LIKE = 'LIKE'
_M.FIND_IN_SET = 'FIND_IN_SET'

-- append
_M.ORDER_BY = 'ORDER BY'
_M.ASC = 'ASC'
_M.DESC = 'DESC'
_M.LIMIT = 'LIMIT'
_M.GROUP_BY = 'GROUP BY'

-- 
_M.SELF_ADD = 'SELF_ADD'
_M.SELF_SUB = 'SELF_SUB'

--
-- example: `field1` = `field2` + 1
-- 			 field1` = function('xxx')
-- 上面这类不能加引号时使用，所以此类操作不转义，
-- 注意：此时需要自行控制防止sql注入
_M.NO_QUOTATION = 'NO_QUOTATION'

--
_M.OR = 'OR'
_M.AND = 'AND'

--
_M.LAST_INSERT_ID = 'last_insert_id'

--
_M.RETURN_KEY = 'return_key'

return _M