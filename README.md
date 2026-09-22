# SystemVerilog 验证平台：从零到验证工程师

这个仓库采用“每一步都能运行、每一步只增加一个核心概念”的方式学习数字 IC 验证。

完整的 ALU 学习任务与当前验收结果见 [Obsidian 教程：从零搭建 ALU SystemVerilog 验证平台](https://aidenicv.online/技术文章/ALU验证平台/)。下文“第 1 课”保留了项目初期的练习记录。

## 第 1 课：最小自检验证平台

当前 DUT 是一个 8 位同步 ALU，支持：

| `op` | 运算 | 说明 |
|---:|---|---|
| 0 | `a + b` | 只保留低 8 位 |
| 1 | `a - b` | 只保留低 8 位 |
| 2 | `a & b` | 按位与 |
| 3 | `a \| b` | 按位或 |
| 4 | `a ^ b` | 按位异或 |

平台的数据流是：

```text
测试用例 -> drive_and_check -> DUT -> 实际结果
                    |                  |
                    +-> 参考模型 ------+-> 自动比较 -> PASS/FAIL
```

### 文件职责

- `rtl/simple_alu.sv`：待验证设计（DUT）。
- `tb/alu_if.sv`：把 DUT 的接口信号集中管理。
- `tb/tb_top.sv`：时钟、复位、激励、参考模型、检查器和测试用例。
- `sim/run.do`：Questa/ModelSim 编译与运行脚本。
- `sim/run.ps1`：Windows 一键运行入口。

### 第一次运行

在终端中进入 `sim` 目录。Windows 推荐直接运行批处理文件，它不受 PowerShell 脚本执行策略影响：

```powershell
.\run.bat
```

也可以仅为这一次绕过 PowerShell 的脚本限制：

```powershell
powershell -ExecutionPolicy Bypass -File .\run.ps1
```

不建议为了本课程永久放宽整台电脑的执行策略。

看到下面两行就说明平台完整跑通：

```text
TEST SUMMARY: PASS=6 FAIL=0
TEST PASSED
```

### 你现在应该理解的五件事

1. **DUT** 是被测设计，验证代码不能依赖 DUT 的内部实现。
2. **激励** 是输入给 DUT 的操作数和操作码。
3. **参考模型** 用另一套独立逻辑计算正确答案。
4. **检查器** 比较期望结果与 DUT 实际结果，不能只看波形猜对错。
5. **测试结束条件** 必须明确；失败时返回非零结果，方便以后做回归。

### 动手练习

按顺序完成，每次修改后重新运行：

1. 增加一条 `7 + 9` 的测试。
2. 推导 `8'hff + 1` 为什么得到 0。
3. 在 DUT 的 XOR 分支中故意把 `^` 改为 `|`，确认平台能报错，然后改回。
4. 给 ALU 增加左移操作 `op=5`，同时修改 DUT、参考模型和测试用例。

## 学习路线

| 阶段 | 要增加的能力 | 工程产物 |
|---|---|---|
| 1. 自检基础 | 时钟、复位、task、参考模型、自动比较 | 当前版本 |
| 2. 分层平台 | transaction、generator、driver、monitor、scoreboard | 非 UVM class 平台 |
| 3. 约束随机 | `randomize()`、约束、seed、可复现失败 | 随机回归 |
| 4. 覆盖率驱动 | functional coverage、cross、覆盖率闭环 | 覆盖率报告 |
| 5. 断言 | SVA、协议时序、复位检查 | assertion checker |
| 6. UVM | sequence、sequencer、driver、monitor、agent、env、test | 标准 UVM 平台 |
| 7. 工程化 | regression、配置、日志、超时、错误注入、CI | 可维护验证项目 |
| 8. 项目实战 | FIFO/APB/SPI/AHB/AXI 子系统验证 | 简历级项目 |

建议不要直接背 UVM 宏。先掌握“数据从哪里来、由谁驱动、由谁观察、在哪里比较”，再把相同职责迁移到 UVM，会容易很多。
