-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：statement.lua
-- 简介：将各种SQL操作组装成完整的SQL语句

local statement = lroute.require('lib.luant.sql.statement')

local _M = {}

-- insert
function _M.insert(database, table, fields)
	str_fields = statement.fields_write(fields)
	if not string.is_noempty_string(str_fields) then
		return lexception.throw_assemble_error('FIELDS IS EMPTY')
	end
	table = statement.wrap_table(database, table)
	return string.format('INSERT %s SET %s;', table, str_fields)
end

-- delete
function _M.delete(database, table, condition)
	str_condition = statement.condition(condition)
	if not string.is_noempty_string(str_condition) then
		return lexception.throw('CONTION IS EMPTY')
	end
	table = statement.wrap_table(database, table)
	return string.format('DELETE FROM %s WHERE %s;', table, str_condition)
end

-- update
function _M.update(database, table, fields, condition)
	str_fields = statement.fields_write(fields)
	if not string.is_noempty_string(str_fields) then
		return lexception.throw('FIELDS IS EMPTY')
	end
	str_condition = statement.condition(condition)
	if not string.is_noempty_string(str_condition) then
		return lexception.throw('CONTION IS EMPTY')
	end
	table = statement.wrap_table(database, table)
	return string.format('UPDATE %s SET %s WHERE %s;', table, str_fields, str_condition)
end

-- select
function _M.select(database, table, fields, condition, append)
	str_table = statement.wrap_table(database, table)
	str_fields = statement.fields_read(fields)
	str_condition = statement.condition(condition)
	str_append = statement.append(append)

	sql = string.format('SELECT %s FROM %s', str_fields, str_table)
	if string.is_noempty_string(str_condition) then
		sql = sql .. ' WHERE ' .. str_condition
	end
	if string.is_noempty_string(str_append) then
		sql = sql .. str_append
	end
	sql = sql .. ';'
	return sql
end

-- insert or update
function _M.insert_or_update(database, table, fields, condition)
	str_insert_fields = statement.fields_write(fields)
	if condition then
		str_update_fields = statement.fields_write(condition)
	else
		str_update_fields = str_insert_fields
	end
	table = statement.wrap_table(database, table)
	return string.format('INSERT %s SET %s ON DUPLICATE KEY UPDATE %s;', table, str_insert_fields, str_update_fields)
end

return _M