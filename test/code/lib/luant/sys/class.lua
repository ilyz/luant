-- Copyright (C) 2016 Jian Zhang (Jack)
-- 文件：json.lua
-- 简介：lib.luant.sys.class单元测试

describe("test.code.lib.luant.sys.class", function()

  -- Class 功能测试
  local Test = Class('test.code.lib.luant.sys.class')
  local self = nil

  function Test.init(this)
    self = this
    self.msg = 'hello luant!'
  end

  function Test.test()
    return self.msg
  end

  -- Class
  describe("Class", function()
    it("table", function()
        test = Test:new()
        assert.are.same('hello luant!', test.test())
    end)
  end)

end)