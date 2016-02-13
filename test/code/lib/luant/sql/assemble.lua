-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：assemble.lua
-- 简介：lib.luant.sql.assenble单元测试

describe("test.code.lib.luant.sql.assemble", function()

  assemble = require('lib.luant.sql.assemble')
  factory = require('lib.luant.sql.factory')

  -- insert
  describe("insert", function()
    it("insert", function()
      res = "INSERT `database`.`table` SET `a` = 'a', `b` = 'b';"
      assert.are.same(res, assemble.insert('database', 'table', {a='a', b='b'}))
    end)
    it("insert", function()
      res = assemble.insert('database', 'table', {})
      assert.is_string(res)
      ret = json.json_decode(res)
      assert.are_not.same(nil, ret.err_no)
      assert.are_not.same(0, ret.err_no)
    end)
  end)

  -- delete
  describe("delete", function()
    it("delete", function()
      res = "DELETE FROM `database`.`table` WHERE `a` = 'a' AND `b` = 'b';"
      assert.are.same(res, assemble.delete('database', 'table', {a='a', b='b'}))
    end)
    it("delete", function()
      res = assemble.delete('database', 'table', {})
      assert.is_string(res)
      ret = json.json_decode(res)
      assert.are_not.same(nil, ret.err_no)
      assert.are_not.same(0, ret.err_no)
    end)
  end)

  -- update
  describe("update", function()
    it("update", function()
      res = "UPDATE `database`.`table` SET `a` = 'a', `b` = 'b' WHERE `a` = 'a' AND `c` = 'c' AND `b` = 'b';"
      assert.are.same(res, assemble.update('database', 'table', {a='a', b='b'}, {a='a',b='b',c='c'}))
    end)
    it("no condition", function()
      --  no condition
      res = assemble.update('database', 'table', {a='a', b='b'})
      assert.is_string(res)
      ret = json.json_decode(res)
      assert.are_not.same(nil, ret.err_no)
      assert.are_not.same(0, ret.err_no)
    end)
    it("no fields", function()
      --  no fields
      res = assemble.update('database', 'table', nil, {a='a',b='b',c='c'})
      assert.is_string(res)
      ret = json.json_decode(res)
      assert.are_not.same(nil, ret.err_no)
      assert.are_not.same(0, ret.err_no)
    end)
  end)

  -- select
  describe("select", function()
    it("select", function()
      res = "SELECT `a`, `b` FROM `database`.`table` WHERE `a` = 'a' AND `b` = 'b' LIMIT 1, 2;"
      assert.are.same(res, assemble.select('database', 'table', {'a', 'b'}, {a='a', b='b'}, ' LIMIT 1, 2'))
    end)
    it("no fields", function()
      res = "SELECT * FROM `database`.`table` WHERE `a` = 'a' AND `b` = 'b' LIMIT 1, 2;"
      assert.are.same(res, assemble.select('database', 'table', nil, {a='a', b='b'}, ' LIMIT 1, 2'))
    end)
    it("no condition", function()
      res = "SELECT `a`, `b` FROM `database`.`table` LIMIT 1, 2;"
      assert.are.same(res, assemble.select('database', 'table', {'a', 'b'}, nil, ' LIMIT 1, 2'))
    end)
    it("no append", function()
      res = "SELECT `a`, `b` FROM `database`.`table` WHERE `a` = 'a' AND `b` = 'b';"
      assert.are.same(res, assemble.select('database', 'table', {'a', 'b'}, {a='a', b='b'}))
    end)
  end)

  -- insert_or_delete
  describe("insert_or_delete", function()
    it("insert_or_delete", function()
      res = "INSERT `database`.`table` SET `a` = 'a', `b` = 'b' ON DUPLICATE KEY UPDATE `c` = 'c';"
      assert.are.same(res, assemble.insert_or_update('database', 'table', {a='a', b='b'}, {c='c'}))
    end)
    it("no condition", function()
      res = "INSERT `database`.`table` SET `a` = 'a', `b` = 'b' ON DUPLICATE KEY UPDATE `a` = 'a', `b` = 'b';"
      assert.are.same(res, assemble.insert_or_update('database', 'table', {a='a', b='b'}))
    end)
  end)

end)