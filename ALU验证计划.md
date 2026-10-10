# ALU 验证计划与阶段 1 验收

## 被测行为

8 位同步 ALU 在 `req_valid=1` 的时钟上升沿接收请求，更新 `result` 并产生响应；空闲时 `result` 保持，`rsp_valid` 随请求撤销。低有效复位异步清零两个输出。`op=0..5` 分别为加、减、与、或、异或、左移；`op=6..7` 的结果为零。加减及左移结果截断至 8 位。

## 测试矩阵

| 需求 | 当前检查方式 | 当前状态 |
|---|---|---|
| 六个合法操作码 | 定向用例、随机用例、记分板 | 已覆盖 |
| `op=6/7` 默认结果 | 定向用例、记分板 | 已覆盖，但不计入合法操作码覆盖率 |
| 加法溢出、减法回绕 | `ff+1`、`3-5`、记分板 | 已覆盖 |
| 左移边界 | 移位量 0、1、8；记分板 | 有定向用例，尚无专门覆盖点 |
| 请求后响应、空闲时无响应 | SVA 与记分板 | 两条 SVA 均已做反例验证 |
| 空闲时结果保持 | SVA | 已做反例验证 |
| 上电及运行中异步复位 | `reset_dut()` 检查输出，并在非零结果后再次复位 | 已覆盖 |

当前 `alu_coverage.sv` 仅统计 `op=0..5` 是否各出现过一次。因此 **100% 表示六个合法操作码都出现过，不表示操作数、边界、复位或时序需求全部覆盖**。删掉 20 条随机测试，定向用例仍可使该数字为 100%。下一轮覆盖率闭环应增加左移量边界、算术溢出、复位发生时机和请求间隔的覆盖点，并逐项追溯到上表需求。

## 回归与故障注入记录

运行 `cd sim` 后执行 `./run.bat`。`run.do` 对 12345、67890、24212 三个种子分别重新加载并运行测试；`regress.ps1` 打印每轮摘要，完整输出在 `sim/regression.log`。2026-10-10 在 QuestaSim 10.7c 中重新验收，每个种子均为 **PASS=37、FAIL=0、合法操作码覆盖率 100%**。

已进行一次不修改 RTL 的故障注入：在 80 ns 将接口 `result` 强制为 `8'hEE`，随后记分板立即报告 `expected=30 actual=238` 等不匹配，运行中复位检查也报错。这证明结果比较路径能发现输出故障。

三条 SVA 已分别做反例验证：第一个请求在 35 ns 上升沿被采样，在 41 ns 强制 `rsp_valid=0`，45 ns 触发 `a_valid_response`；在 41 ns 强制 `rsp_valid=1`，55 ns 触发 `a_no_spurious_response`；在 46 ns 强制 `result=0`，55 ns 触发 `a_result_hold`。每次都重新启动仿真，以免一次 `force` 干扰下一次实验。不要把注入故障后的运行当作正常回归通过。

故障注入复现命令（先正常编译一次，在 `sim` 目录执行）：

```powershell
& 'D:\Questasim\win64\vsim.exe' -c -sv_seed 12345 work.tb_top -do "onfinish stop; run 80ns; force -freeze /tb_top/vif/result 8'hEE; run -all; quit -f"
```

请求后响应断言的反例复现命令：

```powershell
& 'D:\Questasim\win64\vsim.exe' -c -sv_seed 12345 work.tb_top -do "onfinish stop; run 41ns; force -freeze /tb_top/vif/rsp_valid 1'b0; run -all; quit -f"
```

## 后续扩展方向

1. 增加左移量边界、算术进位/借位、复位时机与请求间隔的 coverpoint/cross。
2. 将 monitor 改为独立常驻线程，用 mailbox 或队列与 scoreboard 解耦。
3. 将现有组件迁移到 UVM，并在 CI 中执行回归与覆盖率检查。
