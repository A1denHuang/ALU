# 基于 SystemVerilog 的 ALU 分层验证平台

这是一个面向 8 位同步 ALU 的非 UVM、自检式 SystemVerilog 验证项目。平台采用 transaction、driver、monitor、scoreboard、functional coverage 和 SVA 分层组织，支持定向测试、约束随机测试、断言反例注入以及多种子回归。

> 当前验收：QuestaSim 10.7c 下，种子 `12345`、`67890`、`24212` 均为 **PASS=37、FAIL=0**，合法操作码覆盖率为 **100%**。

## 项目亮点

- 使用 `interface` 集中管理 DUT 信号，通过 `virtual interface` 将接口传递给 class-based driver 与 monitor。
- 使用 transaction 封装激励与观测结果，约束随机生成 `op/a/b`，并保留溢出、回绕、移位边界和非法操作码等定向场景。
- 使用独立 reference model 与 scoreboard 自动比较期望/实际结果，不依赖人工查看波形判定通过。
- 使用 covergroup 统计 6 种合法操作码；明确区分“场景被覆盖”和“结果正确”。
- 使用 3 条 SVA 检查请求—响应时序、禁止无请求响应、空闲期结果保持，并通过故障注入验证断言能实际触发。
- 使用 Tcl 与 PowerShell 自动执行多种子回归、解析摘要并保留完整日志。

## DUT 规格

| `op` | 运算 | 说明 |
|---:|---|---|
| 0 | `a + b` | 结果截断为 8 位 |
| 1 | `a - b` | 结果截断为 8 位 |
| 2 | `a & b` | 按位与 |
| 3 | `a \| b` | 按位或 |
| 4 | `a ^ b` | 按位异或 |
| 5 | `a << b` | 结果截断为 8 位 |
| 6、7 | 默认分支 | 输出 0 |

DUT 在上升沿接收有效请求，低有效异步复位清零 `rsp_valid` 与 `result`；空闲期 `result` 保持。

## 验证架构

```text
directed / constrained-random tests
                 |
                 v
          alu_transaction
                 |
                 v
alu_driver -> alu_if -> simple_alu
                 |          |
                 v          v
            alu_monitor   SVA checks
                 |
                 v
         alu_scoreboard ------ reference model
                 |
                 +------ PASS / FAIL summary

transaction --------------------------------> alu_coverage
```

当前平台由 top 顺序调度各组件，是理解 UVM 组件职责之前的轻量分层实现；它不是完整的 UVM 环境。

## 目录结构

```text
rtl/simple_alu.sv          # DUT
tb/alu_if.sv               # 接口信号集合
tb/alu_transaction.sv      # 事务与随机约束
tb/alu_driver.sv           # 输入驱动
tb/alu_monitor.sv          # 输出采样
tb/alu_scoreboard.sv       # 参考模型与自动比较
tb/alu_coverage.sv         # 功能覆盖率
tb/alu_assertions.sv       # SVA 协议检查
tb/alu_pkg.sv              # 验证类 package
tb/tb_top.sv               # 环境连接、定向/随机测试与汇总
sim/run.do                 # 编译及三种子仿真
sim/regress.ps1            # 回归结果解析
sim/assertion_negative.do  # SVA 反例注入
BASIC/                     # 独立的 SystemVerilog 基础练习
```

## 测试内容

- 17 条定向事务：六种合法运算、加法回绕、减法回绕、左移量 `0/1/8`、非法操作码 `6/7`、初始与运行中复位。
- 每个种子生成 20 条约束随机事务；合法随机操作码为 `0..5`，左移量约束为 `0..8`。
- 三条并发断言：
  - 请求后下一采样周期必须出现响应；
  - 无请求时下一采样周期不得出现响应；
  - 无请求时运算结果保持稳定。

## 运行方法

要求：Windows、QuestaSim，并将 `vsim` 加入 `PATH`；当前脚本也会优先查找 `D:\Questasim\win64\vsim.exe`。

```powershell
cd sim
.\run.bat
```

预期摘要：

```text
Seed    PASS  FAIL  OP coverage  Status
12345   37    0     100.0%       PASS
67890   37    0     100.0%       PASS
24212   37    0     100.0%       PASS
```

完整日志输出到 `sim/regression.log`，该文件属于仿真产物，不提交到仓库。

以“请求后无响应”为例验证 SVA 的失败路径：

```powershell
cd sim
vsim -c -do "set fault_case valid_response; do assertion_negative.do"
```

还可将 `fault_case` 改为 `spurious_response` 或 `result_hold`。反例测试应触发对应 assertion 的 `$fatal`，因此它的预期结果是失败，而不是 `TEST PASSED`。

## 验证结论与边界

当前 100% 是**合法操作码覆盖率**，不代表输入空间或所有时序场景被穷尽。三种子回归通过的准确含义是：在 111 笔测试事务及现有断言约束下未发现错误。后续可增加操作码与数据边界 cross、请求间隔覆盖、断言覆盖率，以及并行 monitor/mailbox 结构。

## 文档

- [验证计划与阶段验收](ALU验证计划.md)
- [完整学习与排错记录](SV验证平台学习与实验记录.md)
- [简历项目描述与面试提纲](简历项目说明.md)
- [在线 Obsidian 教程](https://aidenicv.online/技术文章/ALU验证平台/)
