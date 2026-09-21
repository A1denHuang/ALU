# SystemVerilog 验证平台学习与实验记录

> 记录范围：2026 年 9 月 9 日至 9 月 17 日，本次整理请求之前的学习对话与实验。
> 目标读者：已了解基本 Verilog，希望从自检 testbench 逐步学习分层验证平台的初学者。
> 本文区分实际运行结果、学习者反馈和待完成能力，不把规划中的功能写成已实现功能。

## 1. 项目目标与实验环境

从一个简单、可运行的 SystemVerilog 自检平台开始，逐步引入 transaction、driver、monitor、scoreboard 和 package，再向约束随机、覆盖率、断言、并行验证和 UVM 深入。

实验工程位于：`C:/Users/15354/Desktop/ICverification`。

环境确认过程：

- 初次通过终端默认路径运行的是 ModelSim Intel FPGA Edition 2020.1。
- 学习者实际使用的图形界面是 **QuestaSim-64 10.7c**，不是 ModelSim。
- 后续验收明确使用 `D:/Questasim/win64/vlog.exe` 和 `D:/Questasim/win64/vsim.exe`。

**经验：命令名相同，不代表调用的是同一个安装版本。** 排查问题时，应确认启动程序、版本和路径。

## 2. 被测设计：8 位同步 ALU

### 2.1 接口与行为

DUT 为 `rtl/simple_alu.sv`，接口集中在 `tb/alu_if.sv`。

| 信号 | 方向（相对 DUT） | 含义 |
|---|---|---|
| `clk` | 输入 | 时钟，上升沿执行操作 |
| `rst_n` | 输入 | 低有效异步复位 |
| `req_valid` | 输入 | 当前输入操作有效 |
| `op` | 输入 | 3 位操作码 |
| `a`、`b` | 输入 | 8 位操作数 |
| `rsp_valid` | 输出 | 本次采样对应的响应有效标志 |
| `result` | 输出 | 8 位运算结果 |

当 `rst_n=1`，在时钟上升沿采样 `req_valid`：若为 1，则根据 `op` 更新结果；`rsp_valid` 同样在该上升沿更新。若请求无效，结果保持，响应有效标志清零。本设计没有 ready、背压或多笔未完成事务。

| `op` | 运算 | 来源 |
|---:|---|---|
| 0 | `a + b` | 初始工程 |
| 1 | `a - b` | 初始工程 |
| 2 | `a & b` | 初始工程 |
| 3 | `a \| b` | 初始工程 |
| 4 | `a ^ b` | 初始工程 |
| 5 | `a << b` | 学习者新增 |
| 6、7 | 输出零 | 当前默认分支，尚未作为定向用例覆盖 |

### 2.2 结果宽度与边界

输出只保留 8 位，不提供 carry、borrow 或 overflow 标志。

- `255 + 1 = 256`，低 8 位为 0。
- `3 - 5` 的低 8 位为 `8'hfe`，按无符号十进制打印为 254。
- `8'h81 << 1` 的结果为 `8'h02`，最高位被移出。
- 8 位操作数左移 8 位，结果为零。

这里的“回绕/截断”不要与有符号运算的 overflow 标志混为一谈；当前平台使用无符号操作数。

## 3. 实验推进记录

### 实验 1：最小自检平台

初始平台把时钟、复位、激励、参考模型、比较和测试结束逻辑都放在 `tb_top` 中。

核心数据流：

```text
测试输入 ──→ DUT ──→ 实际结果
    └─────→ 参考模型 ──→ 期望结果
                         ↓
                     自动比较
                         ↓
                     PASS / FAIL
```

初始 6 条测试在 ModelSim 中实际通过：`PASS=6 FAIL=0`。

最重要的变化不是“能看波形”，而是**平台能自动判断结果是否正确**。

### 实验 2：新增运算与边界测试

学习者完成：

1. 添加 `7 + 9` 用例。
2. 在 DUT 和参考模型中添加 `op=5` 左移运算。
3. 添加 `1 << 2` 用例。
4. 添加左移边界：不移位、最高位移出、移位量等于位宽。

新增左移实现：

```systemverilog
localparam logic [2:0] OP_LEFTSHIFT = 3'd5;
// 在 case 内：
OP_LEFTSHIFT: result <= a << b;
```

前 8 条测试在 QuestaSim 10.7c 中实际通过：`PASS=8 FAIL=0`。

故障注入练习：把 XOR 暂时改成 OR。学习者反馈：

```text
a        = 11110000
b        = 01011010
expected = 10101010  （XOR，十进制 170）
actual   = 11111010  （OR，十进制 250）
```

故障注入后应恢复 DUT。该失败现象由学习者报告；后续正常验收确认 XOR 已恢复。

### 实验 3：引入 transaction

新增 `tb/alu_transaction.sv`，用 class 描述一次操作：

```systemverilog
class alu_transaction;
  logic [2:0] op;
  logic [7:0] a;
  logic [7:0] b;

  function new(
    logic [2:0] op = 0,
    logic [7:0] a = 0,
    logic [7:0] b = 0
  );
    this.op = op;
    this.a  = a;
    this.b  = b;
  endfunction

  function void display();
    $display("[TRANS] op=%0d a=%0d b=%0d", op, a, b);
  endfunction
endclass
```

`this.op` 是对象成员，构造函数参数 `op` 是传入的数据。`this` 用来明确区分同名成员和参数。

使用方式：

```systemverilog
alu_transaction tr;       // 只声明句柄，默认是 null
tr = new(3'd0, 8'd7, 8'd9); // 创建对象
tr.display();
```

第一次排查类型可见性后，使用 `-mfcu` 临时验证，实际通过 `PASS=12 FAIL=0`。

### 实验 4：所有测试通过事务传递

驱动任务由接收三个独立参数，改为接收一个事务句柄：

```systemverilog
task automatic drive_and_check(input alu_transaction tr);
```

任务通过 `tr.op`、`tr.a`、`tr.b` 读取操作内容。每次测试执行新的 `new()`，再传入任务。

额外通过事务添加 `10 - 3` 和 `3 << 2` 用例。此后共有 14 条正常测试，实测 `PASS=14 FAIL=0`。

空句柄保护先采用 `$error + 失败计数 + return`，随后统一改为 `$fatal`，避免无法安全继续的对象访问。

### 实验 5：拆出 driver

新增 `tb/alu_driver.sv`：

- 持有 `virtual alu_if #(8) vif`。
- 构造时接收 top 中实际接口的句柄。
- `drive(tr)` 在下降沿驱动请求，在下一上升沿后等待 `#1`，让 DUT 输出更新。
- `idle()` 在下降沿撤销 `req_valid`。
- 不计算期望值，不比较结果。

top 创建：

```systemverilog
drv = new(vif);
```

驱动与空闲逻辑全部迁移后，实测 `PASS=14 FAIL=0`。

### 实验 6：拆出 monitor

transaction 增加 `rsp_valid` 和 `result` 字段，保存输出快照。

新增 `tb/alu_monitor.sv`，`sample()` 创建一个新事务，从接口读取输入与输出并返回。

top 中顺序为：

```systemverilog
drv.drive(tr);
observed = mon.sample();
```

此时 driver 已等到上升沿后 `#1`，monitor 可以立即读取结果；**不要再额外等待一个上升沿**。

monitor 只读接口、不驱动、不判分。验收结果：`PASS=14 FAIL=0`。

### 实验 7：拆出 scoreboard

新增 `tb/alu_scoreboard.sv`，迁入：

- 独立参考模型 `reference_model()`。
- 期望与实际结果比较 `check(sent, observed)`。
- `pass_count` 和 `fail_count`。

top 只协调：

```systemverilog
drv.drive(tr);
observed = mon.sample();
scb.check(tr, observed);
drv.idle();
```

响应有效检查采用：

```systemverilog
if (observed.rsp_valid !== 1'b1)
```

这样 `0、X、Z` 都明确判失败。最终汇总必须读取 `scb.pass_count` 和 `scb.fail_count`，不能继续使用 top 中不再更新的旧计数器。

经过类定义保存、对象创建、参考模型迁移、位宽修正后，实际验收：编译 0 错误、0 警告，`PASS=14 FAIL=0`。

### 实验 8：迁移到 package

新增 `tb/alu_pkg.sv`：

```systemverilog
package alu_pkg;
  `include "alu_transaction.sv"
  `include "alu_driver.sv"
  `include "alu_monitor.sv"
  `include "alu_scoreboard.sv"
endpackage
```

top 在模块内部、类句柄声明前写：

```systemverilog
import alu_pkg::*;
```

类文件作为包的一部分，不再单独列入编译命令；interface 不放进 package，仍先独立编译。

正确编译行（在 `sim` 目录运行）：

```tcl
vlog -sv +incdir+../tb ../rtl/simple_alu.sv ../tb/alu_if.sv ../tb/alu_pkg.sv ../tb/tb_top.sv
```

不使用 `-mfcu` 的实际验收：0 错误、0 警告，`PASS=14 FAIL=0`。

整理时确认：磁盘上的 `run.do` 已保存正确的 `+incdir+../tb` 和独立 DUT 文件参数。

## 4. 当前 14 条测试清单

| 编号 | 操作 | a | b | 期望 result |
|---:|---|---:|---:|---:|
| 1 | ADD | 7 | 9 | 16 |
| 2 | SUB | 10 | 3 | 7 |
| 3 | LEFTSHIFT | 3 | 2 | 12 |
| 4 | ADD | 10 | 20 | 30 |
| 5 | ADD | 255 | 1 | 0 |
| 6 | ADD | 7 | 9 | 16 |
| 7 | SUB | 3 | 5 | 254 |
| 8 | AND | 240 | 90 | 80 |
| 9 | OR | 240 | 90 | 250 |
| 10 | XOR | 240 | 90 | 170 |
| 11 | LEFTSHIFT | 1 | 2 | 4 |
| 12 | LEFTSHIFT | 129 | 0 | 129 |
| 13 | LEFTSHIFT | 129 | 1 | 2 |
| 14 | LEFTSHIFT | 255 | 8 | 0 |

编号 1 和 6 是重复场景。因此“14 条 PASS”不等于覆盖了 14 种不同情况，更不等于设计已经充分验证。

## 5. 疑问、报错与解决记录

### 5.1 PowerShell 无法运行 run.ps1

现象：提示系统禁止运行脚本，异常类型为 `PSSecurityException`。

原因：PowerShell 执行策略拦截，不是 SV 编译失败。

当前工程补充了 `sim/run.bat`，可在终端中运行：

```powershell
.\run.bat
```

另一种按次使用的方式：

```powershell
powershell -ExecutionPolicy Bypass -File .\run.ps1
```

不需要为这个实验永久放宽系统执行策略。若程序版本不符合预期，检查脚本实际调用的 `vsim` 路径。

### 5.2 result <= '0 中的 '0 是什么

`'0` 是不指定宽度、用于填充的字面量。赋值给 `result` 时，将它的所有位填为零。

```systemverilog
result <= '0; // 8 位 result 时为 8'b0000_0000
```

类似还有 `'1`、`'x`、`'z`。注意 `'1` 表示全 1，不是数值 1。

`1'b0` 则是明确的 1 位零；赋值给更宽变量时，零扩展也会得到全零，但它不是自适应填充字面量。

### 5.3 -novopt 已弃用，但手动命令能运行，Start Simulation 报错

报错：`vsim-12110`，指出 `-novopt` 关闭优化，已弃用。

直接启动可用：

```tcl
vsim -voptargs="+acc" work.tb_top
```

`+acc` 用于保留调试对象的可见性，不是自动修复代码。

图形界面最终确认的原因：**Start Simulation 主窗口底部的 Enable optimization 未勾选**，界面因此自动附加禁用优化选项。

优化子窗口中的 `-O4` 只是优化级别；它不能替代主窗口的启用优化总开关。不应仅屏蔽报错来掩盖旧选项。

曾尝试电脑控制技能查看并操作旧版 Questa 子窗口。成功观察到复选框未选中，但工具定位不稳定，未可靠完成勾选，因此交由学习者手动操作；不能把“尝试点击”写成“设置已修改”。

### 5.4 Full optimization 会修改源码或纠正错误吗

不会。它优化内部仿真模型，提高执行效率，不会把修改写回 `.sv`，也不会把语法合法但功能错误的 `a - b` 自动改成 `a + b`。

- 编译器报告语法、类型等问题。
- 仿真优化器处理模型执行效率和对象可见性。
- 验证平台发现与规格不一致的行为。
- 工程师负责分析并修复错误。

### 5.5 alu_transaction is an unknown type

最初的指导只要求 class 文件排在 top 前面，这不足以保证可见性，是本次学习中必须纠正的一点。

独立文件顶层的 class 属于其编译单元作用域；Questa 默认的独立编译单元方式下，top 不一定能看到另一个文件的顶层类型。

曾采用的过渡方案：

```tcl
vlog -sv -mfcu ... ../tb/alu_transaction.sv ../tb/tb_top.sv
```

`-mfcu` 让同一次编译命令中的文件共享编译单元。**单纯调整顺序不是完整解决方案。**

另一种小型练习方案是 top 中 `include` class 文件；但不要同时重复编译同一份定义。

当前正式采用 package：包内定义类型，top 通过 import 使用。它明确表达类型所属作用域，适合多个组件共享类型。

另外，初期 `ALU.mpf` 只登记了三个原始文件。GUI 的 Compile All 与 `run.do` 是两套配置，修改脚本不会自动更新工程文件列表或 GUI 编译方式。

### 5.6 near tr: syntax error, expecting ')'

实际代码将类名误写为 `alutransaction`：

```systemverilog
// 错误：缺少下划线
task automatic drive_and_check(input alutransaction tr);
// 正确
task automatic drive_and_check(input alu_transaction tr);
```

报错位置在 `tr`，但根因是它前面的类型名写错。排查时不能只看报错指向的那个词。

### 5.7 一个 tr 反复修改，还是创建多个对象

推荐在类文件中只定义类，在测试中用一个句柄变量，每次创建新对象：

```systemverilog
tr = new(3'd0, 8'd7, 8'd9);
drive_and_check(tr);
tr = new(3'd1, 8'd10, 8'd3);
drive_and_check(tr);
```

两次 `new()` 创建两个不同对象。句柄不是对象本体；通过赋值传递句柄也不是复制对象。

当前顺序测试中复用同一对象可以工作，但未来 mailbox 和并行组件可能仍持有它。再次修改对象，可能改变尚未处理的事务，造成难以复现的错误。

### 5.8 driver / scoreboard 文件为空，或者 scb 找不到

多次验收发现新增文件为 0 字节，或 top 仍是旧版本。原因可能是未保存，或编辑了另一份同名文件。

确认顺序：检查完整路径 → Save All → 检查文件大小和内容 → 编译 → 加载 → 运行。

新增 scoreboard 后还必须：

```systemverilog
alu_scoreboard scb; // 声明句柄
// 在 initial 中、测试前：
scb = new();        // 创建对象
```

文件存在、加入编译列表、声明句柄、创建对象是不同步骤，缺一不可。

### 5.9 scoreboard 找不到 reference_model

参考模型仍定义在 top 内，而 scoreboard 直接调用该函数。类不能因 top 中存在同名函数，就自动访问它。

修正：将函数搬到 `class alu_scoreboard` 内部；删除 top 中旧函数和旧调用。

### 5.10 Undefined variable: WIDTH

搬函数时保留了 `[WIDTH-1:0]`，但 `WIDTH` 只定义在 top 中，不在 scoreboard 的作用域。

当前练习修正为三处 `[7:0]`：函数返回值、参数 a、参数 b。driver、monitor、transaction 和 scoreboard 当前都固定 8 位；整个验证平台尚未实现完整参数化。

### 5.11 +incdir 后面误写成源文件

错误命令片段：

```tcl
+incdir+../rtl/simple_alu.sv
```

它把文件路径当作 include 搜索目录，不会编译 DUT。由于旧库里可能已经存在 DUT，命令甚至可能编译成功，使遗漏不易被发现。

正确片段：

```tcl
+incdir+../tb ../rtl/simple_alu.sv
```

前者指定查找目录，后者才是源文件参数。**只看 Errors=0 不够，还要确认日志确实出现 Compiling module simple_alu。**

## 6. QuestaSim 操作与脚本知识

### 6.1 打开整个工程

可通过 File → Open 选择 `.mpf` 工程文件，也可在 Transcript 中使用：

```tcl
project open C:/Users/15354/Desktop/ICverification/ALU.mpf
```

新增文件可在 Project 页签中使用 Add to Project → Existing File。包内被 include 的类文件可以用于浏览，但避免在 GUI 中又把它们作为独立源文件重复编译；当前学习以脚本为统一编译入口。

如果源码窗口无法编辑，可能打开的是 Source 查看窗口。可以尝试 Project 中的 Edit，或使用外部编辑器修改真实文件。此原因在对话中未通过后续截图正式确认，不作为唯一结论。

### 6.2 清空 Transcript

在 QuestaSim 命令窗口使用：

```tcl
.main clear
```

清空的是显示内容，不是结束仿真，也不是删除文件。

### 6.3 .sv 与 .do 的注释不同

```systemverilog
// .sv 中的单行注释
```

```tcl
# .do 使用 Tcl 语法，建议注释单独占一行
```

### 6.4 quit -f、$finish 与查看结果

- Tcl 的 `quit -f`：强制退出仿真器，适合批处理。
- SV 的 `$finish`：请求结束仿真，GUI 是否退出还受 onfinish 设置影响。
- `onfinish stop`：在设计加载之后设置，方便运行到 `$finish` 后停留在界面。

对话中曾在加载设计前尝试 `onfinish stop`，Questa 提示必须在 elaboration 后使用。因此应放在 `vsim` 之后。

下面是供交互学习参考的加载与运行片段，**不是声称当前 run.do 已采用该版本**：

```tcl
vsim -voptargs="+acc" work.tb_top
onfinish stop
add wave -r /*
log -r /*
run -all
# 学习时不执行 quit -f
```

运行后在 Transcript 查看判分，在 Wave 中使用 Zoom Full 查看完整时段。

运行使用相对路径的脚本前，先切换目录：

```tcl
cd C:/Users/15354/Desktop/ICverification/sim
do run.do
```

不要在仍加载设计时随意删除其 work 库。本次曾出现库内优化设计被锁定、无法删除的警告。应先卸载仿真（例如 `quit -sim`），必要时关闭占用同一库的其他仿真进程，再重建生成库；不要盲删工程目录。

## 7. 常用系统任务

| 任务 | 用途 | 典型行为 |
|---|---|---|
| `$display` | 打印日志 | 自动换行 |
| `$info` | 普通信息 | 不结束仿真 |
| `$warning` | 警告 | 通常继续 |
| `$error` | 错误报告 | 通常继续，可受仿真器配置影响 |
| `$fatal` | 致命错误 | 终止仿真 |
| `$stop` | 调试暂停 | 交互模式下暂停，批处理行为可配置 |
| `$finish` | 正常结束请求 | 结束行为受仿真器配置影响 |

`fatal` 的意思是“致命的”：如空句柄导致无法安全继续，适合立即停止。

```systemverilog
if (tr == null)
  $fatal(1, "Transaction handle is null");
```

`$fatal` 的第一个参数 0、1、2 控制结束诊断信息，不是失败计数或严重等级。常用 1，输出时间和位置等诊断；2 可附带更多统计信息。

一次结果不匹配通常可以继续收集其他失败：

```systemverilog
$error("Mismatch: expected=%0d actual=%0d", expected, actual);
fail_count++;
```

`$error` 不会替自定义计数器加一。最终应基于 scoreboard 的失败计数决定 `$finish` 或 `$fatal`。

## 8. 当前平台边界与后续学习

目前具备：定向激励、自动比较、class 事务、virtual interface driver、采样 monitor、scoreboard 和 package。

目前仍是 **top 顺序调用的分层平台**，不是完整的并行验证环境：

- monitor 由 top 调用，不是独立常驻观察线程。
- driver 的完成时刻与 monitor 的采样有明确耦合，只适合当前简单协议。
- `#1` 是教学中的采样延迟；后续应统一时间单位，并学习 clocking block 和调度区，不能把它当作通用消除竞争的方法。
- 复位仍由 top 管理；当前复位释放写在上升沿附近，后续应改为明确避开采样边沿，防止调度竞争。
- 没有 mailbox、队列匹配、超时、背压和流水线多事务支持。
- 没有约束随机、functional coverage、SVA 或 UVM。
- 参考模型目前与 DUT 使用类似运算表达式，后续需要更多人工可推导用例和独立规格校验，防止两边一起写错。

建议下一阶段：

1. 为 transaction 输入字段添加 `rand` 和合法操作约束。
2. 每次创建新对象，检查 `randomize()` 返回值，再发送事务。
3. 保留定向边界测试，增加随机测试；记录 seed，确保失败可重现。
4. 引入功能覆盖率，区分“测试通过”与“场景覆盖充分”。
5. 再引入并行 monitor、mailbox、scoreboard 队列和超时机制。

## 9. 留给后续学习者的排错清单

1. 编辑的是正确路径吗？全部保存了吗？新增文件是否为空？
2. 第一条报错是什么？后续是否只是连带错误？
3. 名字、下划线、大小写一致吗？
4. 类型在哪里定义？当前作用域是否能看到？
5. package 已先编译、import 已写在使用之前吗？
6. 句柄已声明，也已 new 了吗？
7. 编译列表是否漏了源文件，或重复编译 include 文件？
8. 期望值计算、接口驱动、输出观察、比较统计分别属于谁？
9. 汇总是否读取真正更新的计数器？
10. 编译成功后是否实际加载、运行，并出现最终 TEST PASSED？
11. 是否有旧编译库掩盖遗漏，或已加载的库导致锁定？
12. 是否把规划、临时验证、学习者反馈与正式落盘结果区分清楚？

> 核心结论：先让测试自动判对错，再让组件职责独立，最后让类型与编译组织清晰。每一步都保留能运行的回归测试，不靠波形目测或“编译没报错”代替功能验收。
