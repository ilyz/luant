-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：json.lua
-- 简介：lib.luant.sys.json单元测试

-- 注意：
-- table中数值下标key值json_decode(json_encode(t))后的键值会被改为字符串
-- json_decode(json_encode(nil))的值为userdata 0

describe("test.code.lib.luant.sys.json", function()

  -- json_encode 功能测试
  describe("json_encode", function()
    it("table", function()
        assert.are.same(json.json_encode({'a','b'}), '["a","b"]')
        assert.are.same(json.json_encode({a='a',b='b'}), '{"a":"a","b":"b"}')
        assert.are.same(json.json_encode({'a',b='b'}), '{"1":"a","b":"b"}')
    end)
    it("bool", function()
        assert.are.same(json.json_encode(false), 'false')
        assert.are.same(json.json_encode(true), 'true')
    end)
    it("number", function()
        assert.are.same(json.json_encode(1), '1')
        assert.are.same(json.json_encode(1.1), '1.1')
    end)
    it("nil", function()
        assert.are.same(json.json_encode(nil), 'null')
    end)
    it("functin", function()
        assert.falsy(json.json_encode(function () end))
    end)
  end)

  -- json_decode 功能测试
  describe("json_encode", function()
    it("table", function()
        assert.are.same(json.json_decode('["a","b"]'), {'a','b'})
        assert.are.same(json.json_decode('{"a":"a","b":"b"}'), {a='a',b='b'})
        assert.are.same(json.json_decode('{"1":"a","b":"b"}'), {['1']='a',b='b'})
    end)
    it("bool", function()
        assert.are.same(json.json_decode('false'), false)
        assert.are.same(json.json_decode('true'), true)
    end)
    it("number", function()
        assert.are.same(json.json_decode('1'), 1)
        assert.are.same(json.json_decode('1.1'), 1.1)
    end)
    it("null", function()
        assert.are_not.same(nil, json.json_decode('null'))
    end)
    it("nil", function()
        assert.falsy(json.json_decode('{"a",}'))
    end)
  end)

end)