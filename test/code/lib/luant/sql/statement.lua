-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：statement.lua
-- 简介：lib.luant.sql.statement单元测试

describe("test.code.lib.luant.sql.statement", function()

  statement = require('lib.luant.sql.statement')
  factory = require('lib.luant.sql.factory')
  
  describe("wrap_table", function()
    it("正常请求", function()
      res = statement.wrap_table('database', 'table')
      assert.are.same(res, '`database`.`table`')
    end)
    it("空数据库", function()
      res = statement.wrap_table(nil, 'table')
      assert.are.same(res, '`table`')
    end)
    it("空数据表", function()
      res = statement.wrap_table('database', nil)
      assert.is_string(res)
      ret = json.json_decode(res)
      assert.are_not.same(0, ret.err_no)
    end)
  end)

  -- 常见范例
  -- nil => '*'
  -- {'a', 'b'} => '`a`, `b`'
  -- {a='a', b='b'} => '`a` AS `a`, `b` AS `b`'
  -- {['count(*)']=>num} => 'count(*) AS `num`'
  describe("fields_read", function()
    it("普通表字段", function()
      assert.are.same(statement.fields_read(nil), '*')
      assert.are.same(statement.fields_read({'a', 'b'}), '`a`, `b`')
      assert.are.same(statement.fields_read({a='a', b='b'}), '`a` AS `a`, `b` AS `b`')
    end)
    it("函数功能", function()
      assert.are.same(statement.fields_read({'a', ['count(*)']='num'}), '`a`, count(*) AS `num`')
    end)
  end)

  -- 常见范例
  -- nil => ''
  -- {a='a', b='b'} => "`a` = 'a', `b` = 'b'"
  -- {a={[factory.SELF_ADD]=1}} = "`a` = `a` + 1"
  -- {a={[factory.SELF_SUB]=2}} = "`a` = `a` - 2"
  -- {a={[factory.NO_QUOTATION]='`a` * 5'}} => "`a` = `a` * 5"
  -- {a={'a', 'b'}} => '`a` = \'["a","b"]\''
  -- {a={[factory.NO_QUOTATION]='null'}}) => "`a` = null"
  describe("fields_write", function()
    it("非法字段", function()
      assert.are.same(statement.fields_write(nil), '')
      assert.are.same(statement.fields_write({'a', 'b'}), '')
    end)
    it("普通表字段", function()
      assert.are.same(statement.fields_write({a='a', b='b'}), "`a` = 'a', `b` = 'b'")
      assert.are.same(statement.fields_write({a=1, b=2}), "`a` = 1, `b` = 2")
      assert.are.same(statement.fields_write({a='null'}), "`a` = 'null'")
    end)
    it("自增、自减", function()
      assert.are.same(statement.fields_write({a={[factory.SELF_ADD]=1}}), "`a` = `a` + 1")
      assert.are.same(statement.fields_write({a={[factory.SELF_SUB]=2}}), "`a` = `a` - 2")
    end)
    it("数组", function()
      assert.are.same(statement.fields_write({a={'a', 'b'}}), '`a` = \'["a","b"]\'')
    end)
    it("自定义", function()
      assert.are.same(statement.fields_write({a={[factory.NO_QUOTATION]='`a` * 5'}}), "`a` = `a` * 5")
      assert.are.same(statement.fields_write({a={[factory.NO_QUOTATION]='null'}}), "`a` = null")
    end)
  end)

  -- 常见范例
  -- {[factory.GROUP_BY]={'a', 'b'}} => ' GROUP BY `a`, `b`'
  -- {[factory.ORDER_BY]={'f1 DESC', 'f2', {f3='DESC'}, {'f4'}}} => ' ORDER BY f1 DESC, f2, `f3` DESC, f4'
  -- {[factory.ORDER_BY]={f1='DESC', f2='DESC'}} => ' ORDER BY f1 DESC, f2 DESC'
  -- {[factory.LIMIT]={1,2}} => ' LIMIT 1, 2'
  -- {[factory.LIMIT]={1}} => ' LIMIT 1'
  describe("append", function()
    it("GROUP_BY", function()
      assert.are.same(statement.append({[factory.GROUP_BY]={'a', 'b'}}), ' GROUP BY `a`, `b`')
      assert.are.same(statement.append({[factory.GROUP_BY]='`a`, `b`'}), ' GROUP BY `a`, `b`')
    end)
    it("ORDER_BY", function()
      assert.are.same(statement.append({[factory.ORDER_BY]='f1 DESC'}), ' ORDER BY f1 DESC')
      assert.are.same(statement.append({[factory.ORDER_BY]={'f1 DESC'}}), ' ORDER BY f1 DESC')
      assert.are.same(statement.append({[factory.ORDER_BY]={'f1'}}), ' ORDER BY f1')
      assert.are.same(statement.append({[factory.ORDER_BY]={f1='DESC'}}), ' ORDER BY `f1` DESC')
      assert.are.same(statement.append({[factory.ORDER_BY]={{'f1'}}}), ' ORDER BY f1')
      assert.are.same(statement.append({[factory.ORDER_BY]={'f1 DESC', 'f2', {f3='DESC'}, {'f4'}}}), ' ORDER BY f1 DESC, f2, `f3` DESC, f4')
    end)
    it("LIMIT", function()
      assert.are.same(statement.append({[factory.LIMIT]={1, 2}}), ' LIMIT 1, 2')
      assert.are.same(statement.append({[factory.LIMIT]={1}}), ' LIMIT 1')
      assert.are.same(statement.append({[factory.LIMIT]='1, 2'}), ' LIMIT 1, 2')
    end)
    it("常见形式", function()
      array = {
        [factory.GROUP_BY]={'a', 'b'},
        [factory.ORDER_BY]={'f1 DESC', 'f2 ASC'},
        [factory.LIMIT]={1, 2}
      }
      assert.are.same(statement.append(array), ' GROUP BY `a`, `b` ORDER BY f1 DESC, f2 ASC LIMIT 1, 2')
    end)
    it("string", function()
      assert.are.same('LIMIT 1, 2', statement.append('LIMIT 1, 2'))
    end)
    it("nil", function()
      assert.are.same('', statement.append(nil))
    end)
  end)

  -- 常见范例
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
  -- {a={['>']=123}} => '`a` > 123'
  -- {[factory.ORDER_BY]={'f1 DESC', 'f2', {f3='DESC'}, {'f4'}}} => ' ORDER BY f1 DESC, f2, `f3` DESC, f4'
  -- {[factory.ORDER_BY]={f1='DESC', f2='DESC'}} => ' ORDER BY f1 DESC, f2 DESC'
  -- {[factory.LIMIT]={1,2}} => ' LIMIT 1, 2'
  -- {[factory.LIMIT]={1}} => ' LIMIT 1'
  describe("condition", function()
    it("常见条件形式", function()
      assert.are.same(statement.condition({a=123}), '`a` = 123')
      assert.are.same(statement.condition({a='a'}), "`a` = 'a'")
      assert.are.same(statement.condition({a='a', b='b'}), "`a` = 'a' AND `b` = 'b'")
      assert.are.same(statement.condition({a='a', b='b'}, factory.OR), "`a` = 'a' OR `b` = 'b'")
    end)
    it("IN", function()
      -- IN
      assert.are.same(statement.condition({a={[factory.IN]={'a', 'b'}}}), "`a` IN ('a','b')")
      assert.are.same(statement.condition({a={[factory.IN]='a'}}), "`a` IN ('a')")
    end)
    it("BETWEN", function()
      -- BETWEN
      assert.are.same(statement.condition({a={[factory.BETWEEN]={'a', 'b'}}}), "`a` BETWEEN 'a' AND 'b'")
      assert.are.same(statement.condition({a={[factory.BETWEEN]={1, 2}}}), "`a` BETWEEN 1 AND 2")
    end)
    it("LIKE", function()
      -- LIKE
      assert.are.same(statement.condition({a={[factory.LIKE]='%a%'}}), "`a` LIKE '%a%'")
      assert.are.same(statement.condition({a={[factory.LIKE]='%a'}}), "`a` LIKE '%a'")
    end)
    it("其它", function()
      -- =
      assert.are.same(statement.condition({a={['=']='a'}}), "`a` = 'a'")
      -- nil
      assert.are.same(statement.condition({a={'a'}}), "`a` = 'a'")
      -- 其它
      res = statement.condition({a={['ab']='a'}})
      assert.is_string(res)
      ret = json.json_decode(res)
      assert.are_not.same(0, ret.err_no)
    end)
    it("其它类型", function()
      -- nil
      assert.are.same(statement.condition(nil), "")
      -- string
      assert.are.same('a=1', statement.condition('a=1'))
    end)
    it("嵌套", function()
      assert.are.same(statement.condition({[factory.OR]={a='a',b='b'}}), "(`a` = 'a' OR `b` = 'b')")
      assert.are.same(statement.condition({[factory.AND]={a='a',b='b'}}), "(`a` = 'a' AND `b` = 'b')")
    end)
    it("空数组", function()
      assert.are.same('', statement.condition({}))
    end)
  end)

end)