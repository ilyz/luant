# coding:utf-8
import os
import commands


class Build():
    def __init__(self):
        self.work_path = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        self.test_path = self.work_path + u'/test'
        self.test_code_path = self.test_path + u'/code'
        self.test_cove_path = self.test_path + u'/cove'
        self.test_script_path = self.test_path + u'/script'
        self.test_report = self.test_path + u'/report.txt'
        self.test_head = self.test_script_path + u'/test_head.lua'
        self.test_path = self.test_script_path + u'/test.lua'
        self.luacov_stats = self.test_script_path + u'/luacov.stats.out'
        self.luacov_report = self.test_script_path + u'/luacov.report.out'

    # 执行命令
    def execute(self, cmd, c_dir=u'', r_save=u''):
        if not c_dir:
            c_dir = self.work_path
        exe_cmd = u'cd %s; %s' % (c_dir, cmd)
        if r_save != u'':
            exe_cmd = u'%s > %s' % (exe_cmd, r_save)
        (status, output) = commands.getstatusoutput(exe_cmd)
        # 256为busted单测失败时的状态码
        if status != 0 and status != 256:
            print u'[Fail][执行命令出错] 命令[%s] 错误信息[%s]' % (exe_cmd, output)
            exit(1)
        return output

    # 创建文件夹
    def mkdir(self, path):
        if not os.path.exists(path):
            cmd = u'mkdir -p "%s"' % path
            self.execute(cmd)

    def build_path(self, path):
        test_file = os.path.join(self.test_code_path, path)
        if os.path.exists(test_file):
            if os.path.isdir(test_file):
                files = os.listdir(test_file)
                for file in files:
                    file_path = os.path.join(path, file)
                    self.build_path(file_path)
            else:
                if test_file.endswith(u'.lua'):
                    cmd = u'cat %s >> %s' % (test_file, self.test_path)
                    self.execute(cmd)
                    cmd = u'echo "\\n" >> %s' % self.test_path
                    self.execute(cmd)

    # 生成单侧代码
    def build_test(self):
        cmd = u'rm -rf %s' % self.test_path
        self.execute(cmd)

        cmd = u'touch %s' % self.test_path
        self.execute(cmd)

        self.build_path(self.test_head)
        self.build_path(u'')

    # 执行测试脚本
    def excute_test(self):
        cmd = u'rm -rf %s' % self.luacov_stats
        self.execute(cmd)

        cmd = u'lua -lluacov %s' % self.test_path
        self.execute(cmd, self.test_script_path, self.test_report)

    # 计算代码覆盖率
    def build_cove(self, path):
        test_file = os.path.join(self.test_code_path, path)
        if os.path.exists(test_file):
            if os.path.isdir(test_file):
                files = os.listdir(test_file)
                for file in files:
                    self.build_cove(os.path.join(path, file))
            else:
                luant_file = os.path.join(self.work_path, path)
                cmd = u'luacov %s %s' % (self.luacov_stats, luant_file)
                self.execute(cmd, self.test_script_path)

                cove_file = os.path.join(self.test_cove_path, path)
                self.mkdir(os.path.dirname(cove_file))
                cmd = u'mv %s %s' % (self.luacov_report, cove_file)
                self.execute(cmd, self.test_script_path)

    def process(self):
        self.build_test()
        print u'Case生成完成'
        self.excute_test()
        print u'Case执行完成'
        self.build_cove('')
        print u'代码覆盖率计算完成'


Build().process()