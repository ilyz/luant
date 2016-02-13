-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：statement.lua
-- 简介：sql组装器

local quote = ngx.quote_sql_str
local factory = lroute.require('lib.luant.sql.factory')
local exception = lroute.require('public.core.exception')

local _M = {}

---------------------------通用功能---------------------------

_M.OPT = {'=', '>', '>=', '<', '<=', '!=', '<>'}

-- 获取表字段
local function _get_quote(field)
	-- 函数(例如：count(*))和field两种情况
	if string.index_of(field, '(') then
		return field
	else
		return '`' .. field .. '`'
	end
end

-- 获取表字段对应的值
local function _get_qoute_value(v)
	t = type(v)
	if t == 'string' then
		return quote(v)
	elseif t == 'number' then
		return v
	elseif t == 'table' then
		return quote(json.json_encode(v))
	else
		return 'null'
	end
end

-- 组装单条条件语句
local function _kv_pair(k, op, v)
	if table.value_exists(_M.OPT, op) then
		return string.format('`%s` %s %s', k, op, _get_qoute_value(v))
	end
	return lexception.throw('Invalid Opertator [' .. op .. ']')
end

-- 组装=语句
local function _kv_pair_equal(k, v)
	return _kv_pair(k, '=', v)
end

-- 组装自赋值语句
local function _self_op(k, op, v)
	return string.format('`%s` = `%s` %s %s', k, k, op, v)
end

---------------------------获取表名---------------------------

-- 生成数据表名
function _M.wrap_table(database, table)
	if not table then
		return lexception.throw_table_error('')
	end

	t = '`' .. table .. '`'
	if database then
		t = '`' .. database .. '`' .. '.' .. t
	end
	return t
end

---------------------------fields---------------------------

-- select的fields
--[[
fields = {
	'field1',
	field1='name1'
}
--]]
-- 常见范例
-- nil => '*'
-- {'a', 'b'} => '`a`, `b`'
-- {a='a', b='b'} => '`a` AS `a`, `b` AS `b`'
-- {['count(*)']=>num} => 'count(*) AS `num`'
function _M.fields_read(fields)
	if table.is_table(fields) then 
		local select_fields = {}
		for k, v in pairs(fields) do
			if string.is_string(k) then
				table.insert(select_fields, _get_quote(k) .. ' AS ' .. _get_quote(v))
			else
				table.insert(select_fields, _get_quote(v))
			end
		end
		return table.concat(select_fields, ', ')
	end
	return '*'
end

-- insert/update fields
--[[
fields = {
	'field1',
	field1='name1'
}
-- 常见范例
--]]
-- nil => ''
-- {a='a', b='b'} => "`a` = 'a', `b` = 'b'"
-- {a={[factory.SELF_ADD]=1}} => "`a` = `a` + 1"
-- {a={[factory.SELF_SUB]=2}} => "`a` = `a` - 2"
-- {a={[factory.NO_QUOTATION]='`a` * 5'}} => "`a` = `a` * 5"
-- {a={'a', 'b'}} => '`a` = \'["a","b"]\''
-- {a={[factory.NO_QUOTATION]='null'}}) => "`a` = null"
function _M.fields_write(fields)
	if table.is_table(fields) then 
		local set_fields = {}
		for k, v in pairs(fields) do
			if string.is_string(k) then
				if table.is_table(v) then
					item_key, item_val = table.first_kv(v)
					-- 支持自增
					if item_key == factory.SELF_ADD then
						table.insert(set_fields, _self_op(k, '+', item_val))
					-- 支持自减
					elseif item_key == factory.SELF_SUB then
						table.insert(set_fields, _self_op(k, '-', item_val))
					-- 支持自定义操作
					elseif item_key == factory.NO_QUOTATION then
						table.insert(set_fields, '`' .. k .. '` = ' .. item_val)
					-- 字段=数组，序列化保存
					else
						table.insert(set_fields, _kv_pair_equal(k, v))
					end
				else
					table.insert(set_fields, _kv_pair_equal(k, v))
				end
			end
		end
		return table.concat(set_fields, ', ')
	end
	return ''
end

---------------------------append---------------------------

--[[
append = {
	GROUP_BY = {
		field1,
		field2,
	},
	ORDER_BY = {
		'field1 DESC',		-- 有序
		'field1'			-- 有序，等价于'field1 ASC'
		{field1='DESC'},	-- 有序
		{'field1'},			-- 有序，等价于{field1='ASC'}
		field1='DESC',		-- 无序
	},
	LIMIT = {
		1,
		2
	}
}
--]]
-- {[factory.GROUP_BY]={'a', 'b'}} => ' GROUP BY `a`, `b`'
-- {[factory.ORDER_BY]={'f1 DESC', 'f2', {f3='DESC'}, {f4}}} => ' ORDER BY f1 DESC, f2 ASC, f3 DESC, f4 ASC'
-- {[factory.ORDER_BY]={f1='DESC', f2='DESC'}} => ' ORDER BY f1 DESC, f2 DESC'
-- {[factory.LIMIT]={1,2}} => ' LIMIT 1, 2'
-- {[factory.LIMIT]={1}} => ' LIMIT 1'
function _M.append(append)
	-- string
	if type(append) == 'string' then 
		return append
	end
	-- no table
	if not table.is_table(append) then
		return ''
	end
	-- table
	group_by = append[factory.GROUP_BY]
	order_by = append[factory.ORDER_BY]
	limit = append[factory.LIMIT]

	str_append = ''
	-- group by
	if group_by then
		if table.is_noempty_table(group_by) then
			group_str = '`' .. table.concat(group_by, '`, `') .. '`'
		elseif string.is_string(group_by) then
			group_str = group_by
		end
		if group_str then
			str_append = str_append .. ' GROUP BY ' .. group_str
		end
	end
	-- order by
	if order_by then
		if table.is_noempty_table(order_by) then
			orders = {}
			for k, v in pairs(order_by) do
				if type(k) == 'number' and table.is_noempty_table(v) then
					k, v = table.first_kv(v)
				end
				if string.is_string(k) and string.is_string(v) then
					table.insert(orders, '`' .. k .. '` ' .. v)
				elseif string.is_string(v) then
					table.insert(orders, v)
				end
			end
			if #orders > 0 then
				order_str = table.concat(orders, ', ')
			end
		elseif string.is_string(order_by) then
			order_str = order_by
		end
		if order_str then
			str_append = str_append .. ' ORDER BY ' .. order_str
		end
	end
	-- limit
	if limit then
		if table.is_table(limit) then
			if #limit == 1 then
				limit_str = limit[1]
			elseif #limit >=2 then
				limit_str = limit[1] .. ', ' .. limit[2]
			end
		else
			limit_str = limit
		end
		if limit_str then
			str_append = str_append .. ' LIMIT ' .. limit_str
		end
	end
	return str_append
end

---------------------------condition---------------------------

local function _in(k, v)
	if table.is_noempty_table(v) then
		ins = {}
		for i, val in pairs(v) do
			table.insert(ins, _get_qoute_value(val))
		end
		str_val = table.concat(ins, ',')
	else
		str_val = _get_qoute_value(v)
	end
	return string.format('`%s` IN (%s)', k, str_val)
end

local function _between(k, s, e)
	return '`' .. k ..'`' .. ' BETWEEN ' .. _get_qoute_value(s) .. ' AND ' .. _get_qoute_value(e)
end

local function _like(k, v)
	if string.is_string(v) then
		return string.format("`%s` LIKE %s", k, _get_qoute_value(v))
	end
end

local function _unify(k, op, v)
	-- 默认值转换
	if type(op) == 'number' or op == nil then
		op = '='
	end
	if op == factory.IN then
		return _in(k, v)
	elseif op == factory.BETWEEN then
		return _between(k, v[1], v[2])
	elseif op == factory.LIKE then
		return _like(k, v)
	else
		return _kv_pair(k, op, v)
	end
end

--[[
condition = {
	['a'] = {['>'] = 123},
	['b'] = {['BETWEEN'] = {1, 9}},
	['c'] = {['IN'] = {1, 9}},
	['d'] = 'value',
	['OR'] = {e='e', f='f'},
	['AND'] = {g='g', h='h'},
}
--]]
function _M.condition(conds, rel)
	-- string
	if type(conds) == 'string' then
		return conds
	end
	-- no table
	if type(conds) ~= 'table' then
		return ''
	end
	-- table
	if not rel then
		rel = 'AND'
	end
	local condition = {}
	for k, v in pairs(conds) do
		if type(v) ~= 'table' then
			table.insert(condition, _kv_pair_equal(k, v))
		else
			if k == factory.OR then 
				-- return _M.condition(v, 'OR')
				table.insert(condition, '(' .. _M.condition(v, 'OR') .. ')')
			elseif k == factory.AND then
				-- return _M.condition(v, 'AND')
				table.insert(condition, '(' .. _M.condition(v, 'AND') .. ')')
			else
				for k1, v1 in pairs(v) do
					table.insert(condition, _unify(k, k1, v1))
				end
			end
		end
	end
	if #condition > 0 then
		return table.concat(condition, ' ' .. rel .. ' ')
	end
	return ''
end

return _M