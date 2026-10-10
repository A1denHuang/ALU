# SystemVerilog 基础代码笔记：从看懂到能自己写

> 适合阶段：能看懂一些 Verilog/SystemVerilog，但面对空白文件不知道第一行写什么。
> 学习目标：不靠复制完整验证平台，也能独立写出小型 RTL 和自检 testbench。

## 0. 这份笔记应该怎样使用

每一节都按同一套动作学习：

1. 阅读最小模板，弄清每行的职责。
2. 运行 `BASIC/examples` 中的完整示例。
3. 关闭笔记，凭记忆重新敲一遍核心代码。
4. 完成“仿写任务”和“改错题”。
5. 打开对应的 `BASIC/exercises/*_todo.sv`，完成其中的 `TODO`。
6. 最后才看本文末尾的集中答案。

不要要求自己一次记住所有标点。先记住代码的骨架和书写顺序，再通过重复把细节变成习惯。

### 运行方法

双击或在终端中运行完整示例：

```powershell
cd BASIC
.\run.bat
```

运行带 `TODO` 的练习：

```powershell
.\run.bat exercises
```

未完成的练习会打印 `[TODO]`，补充正确后会打印 `[PASS]`。练习骨架本身能够编译，不需要先处理故意设置的语法错误。

---

## 1. module、端口与代码基本结构

### 学习目标

- 能从空白文件写出一个模块。
- 能分清输入、输出和模块内部代码。
- 养成“先写外壳，再填逻辑”的顺序。

### 最小模板

```systemverilog
module module_name (
  input  logic       input_a,
  input  logic [7:0] input_b,
  output logic [7:0] output_y
);
  // 功能代码写在这里
endmodule
```

### 逐行理解

- `module module_name (`：开始定义模块，`module_name` 是模块名。
- `input` 和 `output`：方向永远站在当前模块的角度判断。
- `logic [7:0]`：一个 8 位信号，位编号从 7 到 0。
- `);`：结束端口表。
- `endmodule`：结束模块定义，没有分号。

推荐固定书写顺序：模块名 → 参数 → 端口 → 内部信号 → 功能逻辑 → `endmodule`。

### 完整示例

第二组完整示例 [02_mux.sv](examples/02_mux.sv) 同时包含 DUT 和 testbench。先只观察 `svb_ex02_mux` 的外壳。

### 仿写任务

写一个 `not_gate`：输入 `logic a`，输出 `logic y`，功能是 `y` 等于 `a` 取反。

```systemverilog
module not_gate (
    input logic [7:0] a,
	output logic [7:0] y
);
	assign y = ~a;
endmodule
```



### 改错题

```systemverilog
module bad_module (
    input logic [7:0] a,
    output logic [7:0] y,
);
  assign y = a;
endmodule
```

这里缺少端口间的逗号、端口表后的分号，并且 `endmodule` 被错误地写成两个单词。

### 容易混淆

- 文件名可以与模块名不同，但初学时建议保持一致。
- 一个 `.sv` 文件可以放多个模块；练习中常把 DUT 和 testbench 放在一起。
- SystemVerilog 源文件使用 `.sv`，编译时需要开启 SystemVerilog 模式。

### 完成检查

- [ ] 能不看答案写出 `module ... endmodule`。
- [ ] 每个端口之间有逗号，端口表最后是 `);`。
- [ ] 能站在当前模块角度判断输入和输出。

---

## 2. logic、位宽、常量与有符号数

### 学习目标

- 会声明单比特和多比特信号。
- 会写二进制、十进制和十六进制常量。
- 理解结果超出位宽时会被截断。

### 最小模板

```systemverilog
logic       valid;          // 1 位
logic [7:0] data;           // 8 位无符号数
logic signed [7:0] delta;   // 8 位有符号数

data  = 8'hff;              // 8 位十六进制 FF
valid = 1'b1;               // 1 位二进制 1
delta = -8'sd2;             // 8 位有符号十进制 -2
data  = '0;                 // 按 data 的宽度全部填 0
```

常量的通用写法是：

```text
位宽 ' 进制 数值
 8   '  h    ff
```

常见进制：`b` 二进制、`d` 十进制、`h` 十六进制。`s` 表示 signed，例如 `8'sd2`。

### 位选择、切片与拼接

```systemverilog
logic [7:0] data = 8'hca;
logic       bit0;
logic [3:0] high;
logic [7:0] joined;

bit0   = data[0];             // 选择 1 位
high   = data[7:4];           // 选择连续 4 位
joined = {data[3:0], 4'b0011}; // 两段拼成 8 位
```

### 完整示例

运行 [01_types_ops.sv](examples/01_types_ops.sv)。其中 `8'hf0 + 8'd18 = 258`，但 `sum` 只有 8 位，所以保存的是 `258 % 256 = 2`。

### 仿写任务

声明一个 16 位信号 `word`，赋值为 `16'hABCD`，再分别取出高 8 位和低 8 位。

```systemverilog
logic [15:0] word = 16'hABCD;
logic [7:0] high;
logic [7:0] low;

high = word[15:8];
low = word[7:0];

```



### 改错题

```systemverilog
logic [7:0] a;
a = 8'hff;
```

`4'hff` 声称自己只有 4 位，却写了两位十六进制数字。应写成 `8'hff`，让位宽和意图一致。

### 容易混淆

- `[7:0]` 一共有 8 位，不是 7 位。
- `8'd10` 是十进制 10，`8'h10` 是十六进制 10，也就是十进制 16。
- 有符号和无符号数混算容易出现扩展问题；初学阶段尽量明确写出位宽和符号属性。
- `==` 遇到 `X/Z` 可能得到未知，testbench 中做严格检查常用 `===` 或 `!==`。

### 完成检查

- [ ] 能解释 `8'hff` 的三部分。
- [ ] 能写出位选择、切片和拼接。
- [ ] 能解释为什么 8 位的 `255 + 1` 得到 0。

---

## 3. 运算符：算术、比较、逻辑、按位与移位

### 学习目标

- 能根据需求选择正确的运算符。
- 分清逻辑运算与按位运算。

### 最小模板

```systemverilog
sum    = a + b;
diff   = a - b;
same   = (a == b);
both   = cond_a && cond_b; // 把两边当作真假条件
masked = a & b;            // 每一位分别做 AND
shift  = a << 2;
```

| 类别 | 常用运算符 | 例子 |
|---|---|---|
| 算术 | `+ - * / %` | `a + b` |
| 比较 | `== != < <= > >=` | `a >= b` |
| 逻辑 | `! && \|\|` | `valid && ready` |
| 按位 | `~ & \| ^` | `a ^ b` |
| 移位 | `<< >>` | `a << 1` |
| 拼接 | `{}` | `{carry, sum}` |

### 逐行理解

假设 `a = 4'b1010`、`b = 4'b1100`：

- `a & b` 得到 `1000`，因为逐位进行 AND。
- `a && b` 得到 `1`，因为 a、b 都不是零，都被视为真。
- `a ^ b` 得到 `0110`，相同为 0，不同为 1。
- `a << 1` 得到 `0100`，左边移出的位丢失，右边补零。

### 完整示例

继续观察 [01_types_ops.sv](examples/01_types_ops.sv)，并运行第三组 [03_case_alu.sv](examples/03_case_alu.sv)。

### 仿写任务

写四行表达式，分别计算 `a | b`、`a ^ b`、`a << 1` 和 `a == b`。

```systemverilog
logic [3：0] a;
logic [3:0] b;

logic [3:0] or_result;
logic [3:0] and_result;
logic [3:0]	lshift_result;
logic [3:0]	equal_result;

or_result = a|b;
and_result = a ^ b;
lshift_result = a<<1;
equal_result = a==b;
```



### 改错题

要求对两个 8 位数逐位做与，下面代码错在哪里？

```systemverilog
y = a && b;
```

这里误用了逻辑与，应改为 `y = a & b;`。

### 容易混淆

- `=` 是赋值，`==` 是比较。
- `&` 是按位与，`&&` 是逻辑与。
- 运算结果最终会适配左侧信号位宽；需要进位时，要把结果接到更宽的左侧。

### 完成检查

- [ ] 能区分 `&` 与 `&&`。 &为逐位与，&&为整体与
- [ ] 能区分 `=` 与 `==`。 =为赋值，==为等价判断符
- [ ] 知道如何用 `{carry, sum}` 接收加法进位。

---

## 4. 组合逻辑：assign、always_comb、if 与 case

### 学习目标

- 会写连续赋值和组合逻辑块。
- 能保证组合逻辑在所有分支都有赋值。
- 能根据条件数量选择 `if` 或 `case`。

### 最小模板

简单表达式可用 `assign`：

```systemverilog
assign y = a & b;
```

有条件分支时使用 `always_comb`：

```systemverilog
always_comb begin
  if (sel)
    y = d1;
  else
    y = d0;
end
```

多种互斥选择适合 `case`：

```systemverilog
always_comb begin
  case (op)
    2'd0: result = a + b;
    2'd1: result = a - b;
    2'd2: result = a & b;
    2'd3: result = a ^ b;
    default: result = '0;
  endcase
end
```

### 逐行理解

- `always_comb` 表示这段逻辑的输出只由当前输入决定，不保存历史状态。
- `begin/end` 把多条语句组成一个代码块。
- 组合逻辑通常使用阻塞赋值 `=`。
- 每一种输入情况都要给输出明确值，否则可能推导出锁存器。

### 完整示例

- [02_mux.sv](examples/02_mux.sv)：`if/else` 二选一。
- [03_case_alu.sv](examples/03_case_alu.sv)：`case` 四选一。

### 仿写任务

在 ALU 中增加 `op=2'd3` 的按位或功能，然后相应修改原有 XOR 操作码。

```systemverilog
always_comb begin
    case (op)
        2'd3: result - a | b;
    endcase
end
```



### 改错题

```systemverilog
always_comb begin
  if (enable)
    y = a;
  else
    y='0;
end
```

当 `enable=0` 时没有给 `y` 赋值。可增加 `else y = '0;`，或先在块开头写默认值。

### 容易混淆

- `assign` 后面是一条表达式；不要把它写进 `always_comb`。
- 组合逻辑重点不是“有没有时钟”，而是输出是否只取决于当前输入。
- `case` 的 `default` 能明确未列出情况的行为。

### 完成检查

- [ ] 能独立写出二选一 MUX。
- [ ] 能独立写出四分支 `case`。
- [ ] 会检查所有组合逻辑分支是否都给输出赋值。

---

## 5. 时序逻辑：always_ff、时钟、复位与非阻塞赋值

### 学习目标

- 会写带复位的寄存器或计数器。
- 理解组合逻辑与时序逻辑的根本区别。
- 形成时序逻辑使用 `<=` 的习惯。

### 最小模板

```systemverilog
always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    q <= '0;
  else if (enable)
    q <= d;
end
```

### 逐行理解

- `posedge clk`：只在时钟上升沿更新寄存器。
- `or negedge rst_n`：`rst_n` 从 1 变 0 时也立即执行，因此是异步低有效复位。
- `if (!rst_n)`：`rst_n=0` 时复位成立。
- `<=`：非阻塞赋值，在时序逻辑中表达“同一时钟沿一起更新”。
- 没有 `else` 给 `q` 赋值时，寄存器自然保持原值。

### 完整示例

运行 [04_counter.sv](examples/04_counter.sv)。它先验证复位，再计数 3 次，最后关闭 `enable` 检查保持行为。

### 仿写任务

把计数器改为：`enable=1` 时每次加 2，并说明 4 位计数器从 14 再加 2 后为什么得到 0。

```systemverilog

```



### 改错题

```systemverilog
always_ff @(posedge clk) begin
  q <= d;
end
```

时序逻辑不应使用阻塞赋值，应改为 `q <= d;`。

### 容易混淆

- `always_comb` 中通常用 `=`；`always_ff` 中用 `<=`。
- 低有效复位常命名为 `rst_n`，`_n` 表示低电平有效。
- testbench 在时钟沿驱动信号容易和 DUT 产生竞争；常在下降沿准备输入，让输入在下一上升沿前稳定。

### 完成检查

- [ ] 能独立写出异步低有效复位模板。
- [ ] 能解释 `posedge` 和 `negedge`。
- [ ] 能说明为什么时序逻辑使用 `<=`。

---

## 6. parameter、模块例化与端口连接

### 学习目标

- 会写一个可配置位宽的模块。
- 会在上层模块中创建 DUT 实例。
- 会使用推荐的按名称连接方式。

### 最小模板

```systemverilog
module adder #(
  parameter int WIDTH = 8
) (
  input  logic [WIDTH-1:0] a,
  input  logic [WIDTH-1:0] b,
  output logic [WIDTH-1:0] sum
);
  assign sum = a + b;
endmodule
```

例化时覆盖参数并连接端口：

```systemverilog
adder #(.WIDTH(4)) dut (
  .a   (a),
  .b   (b),
  .sum (sum)
);
```

### 逐行理解

- `parameter int WIDTH = 8`：默认宽度是 8，上层可以覆盖。
- `[WIDTH-1:0]`：WIDTH 为 8 时得到 `[7:0]`。
- `dut`：实例名，表示这个模块被创建出来的一份具体实例。
- `.a(a)`：左边是子模块端口名，右边是当前上层的信号名。

### 完整示例

运行 [05_parameter_adder.sv](examples/05_parameter_adder.sv)。模块默认 8 位，但 testbench 把它配置成 4 位。

### 仿写任务

把示例的实例改成 12 位，并测试 `12'hfff + 1`，观察 `carry` 和 `sum`。

```systemverilog
module adder #(
  parameter int WIDTH = 12
) (
  input  logic [WIDTH-1:0] a,
  input  logic [WIDTH-1:0] b,
  output logic [WIDTH-1:0] sum
);
  assign sum = a + b;
endmodule
```



### 改错题

```systemverilog
adder #(.WIDTH(4)) dut (
  .a(a),
  .b(b),
  .sum(sum)
);
```

这里遗漏了输入 `b`。除非端口有意不连接，否则应补上 `.b(b)`。

### 容易混淆

- 模块定义是“图纸”，实例才是上层设计中实际使用的一份电路。
- `parameter` 是结构配置，不是仿真过程中不断变化的普通信号。
- `.*` 可以自动连接同名端口，但初学和工程接口检查时，明确的按名称连接更容易发现遗漏。

### 完成检查

- [ ] 能写出 `#(.WIDTH(4))` 参数覆盖。
- [ ] 能解释 `.a(a)` 两边分别属于谁。
- [ ] 能用 `WIDTH` 代替写死的位宽。

---

## 7. for、数组、function 与 task

### 学习目标

- 会用数组保存多组同类型数据。
- 会用 `for` 处理重复操作。
- 分清有返回值的 `function` 和用于一串操作的 `task`。

### 最小模板

数组和循环：

```systemverilog
logic [7:0] data [0:2];
integer i;

for (i = 0; i < 3; i = i + 1)
  data[i] = '0;
```

函数：

```systemverilog
function automatic logic [7:0] add_one(input logic [7:0] value);
  begin
    add_one = value + 1'b1;
  end
endfunction
```

任务：

```systemverilog
task automatic drive(input logic [7:0] value);
  begin
    data = value;
    #1;
  end
endtask
```

### 逐行理解

- `data [0:2]` 表示有 3 个数组元素，每个元素是 8 位。
- `for` 的三段分别是初始化、继续条件、每轮结束后的更新。
- 函数通过给函数名赋值返回结果，不能包含耗时控制。
- task 可以包含 `#1`、`@(...)` 等耗时操作，适合复用一串激励和检查步骤。
- `automatic` 让每次调用拥有独立的局部变量，更适合可重入的 testbench 代码。

### 完整示例

- [06_function_array.sv](examples/06_function_array.sv)：数组、循环和奇偶校验函数。
- [07_task_stimulus.sv](examples/07_task_stimulus.sv)：task 驱动输入并自动检查。

### 仿写任务

写一个函数 `max8`，接收两个 8 位无符号数并返回较大者；再用一个 task 测试三组输入。

```systemverilog
function automatic logic max8(input logic [7:0] a, input logic [7:0] b, output logic [7:0] max)
    begin
      if (a < b)
        max = b;
      else
        max = a;
    end
endfunction

task automatic check()
        if
```



### 改错题

```systemverilog
function logic wait_and_get(input logic a);
  #1;
  wait_and_get = a;
endfunction
```

函数中不应包含 `#1` 这样的耗时控制。需要等待时，应使用 task。

### 容易混淆

- `logic [7:0] data [0:2]`：右边的 `[0:2]` 是数组，左边的 `[7:0]` 是每个元素的位宽。
- function 更像“立即计算一个结果”；task 更像“执行一段流程”。
- 循环边界最常见错误是把 `< 3` 写成 `<= 3`，导致访问不存在的第 4 个元素。

### 完成检查

- [ ] 能写出一个遍历 3 个元素的 `for`。
- [ ] 能写出有输入和返回值的 function。
- [ ] 能说明什么情况必须使用 task。

---

## 8. initial、时钟、复位与最小自检 testbench

### 学习目标

- 能为一个小 DUT 写出可以自动判定 PASS/FAIL 的 testbench。
- 会生成时钟、施加复位、驱动输入和检查输出。

### 最小模板

```systemverilog
module tb;
  logic clk = 1'b0;
  logic rst_n = 1'b0;

  always #5 clk = ~clk;

  dut_module dut (
    .clk   (clk),
    .rst_n (rst_n)
  );

  initial begin
    repeat (2) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;

    // 驱动和检查

    $display("[PASS] test completed");
    $finish;
  end
endmodule
```

### 逐行理解

- `initial` 从仿真时间 0 开始执行一次，常作为测试主流程。
- `always #5 clk = ~clk` 每 5 ns 翻转一次，形成周期 10 ns 的时钟。
- `@(posedge clk)` 等待下一个上升沿。
- `repeat (2)` 把后面的语句重复两次。
- `$display` 打印日志，`$finish` 正常结束仿真，`$fatal` 报告不可继续的失败。

一个真正的自检 testbench 至少要包含：输入、期望值、实际值比较、失败报告和明确结束条件。只打印波形、不比较结果，还不能算自检。

### 完整示例

运行 [08_selfcheck.sv](examples/08_selfcheck.sv)。它包含一个同步加法 DUT，以及负责驱动、等待和检查的 `send_and_check` task。

### 仿写任务

为完整示例再增加两组测试：`10 + 20` 和 `128 + 128`。写测试前先算出 8 位期望结果。

### 改错题

```systemverilog
@(posedge clk);
a = 8'd2;
b = 8'd3;
```

如果 DUT 也在这个上升沿采样输入，testbench 同时驱动会产生竞争。可在 `negedge clk` 驱动，让输入在下一个上升沿前稳定。

### 容易混淆

- `#1` 是延时 1 个时间单位；`@(posedge clk)` 是等待事件，两者含义不同。
- DUT 使用非阻塞赋值后，testbench 可在采样上升沿后等待很短时间再读取更新结果。
- `$error` 报错后通常还能继续；`$fatal` 会终止当前仿真。

### 完成检查

- [ ] 能从零写出时钟发生器。
- [ ] 能在下降沿驱动、上升沿后检查。
- [ ] testbench 能自动打印 PASS 或失败原因。

---

## 9. 综合练习：从空白写出小 DUT 和 testbench

不要复制已有文件，新建临时文件并完成下面需求。

### DUT 规格

- 模块名：`tiny_accumulator`
- 端口：`clk`、低有效异步复位 `rst_n`、输入有效 `valid`、8 位输入 `data`、8 位输出 `sum`
- 复位时 `sum` 清零。
- 每个时钟上升沿，如果 `valid=1`，执行 `sum <= sum + data`。
- 如果 `valid=0`，保持当前结果。

### testbench 规格

- 生成 10 ns 周期时钟。
- 复位至少保持两个时钟沿。
- 依次输入 3、5、250，期望累计结果依次为 3、8、2。
- 至少检查一次 `valid=0` 时结果保持不变。
- 错误时调用 `$fatal` 并打印期望值和实际值。
- 全部通过时打印 `[PASS] tiny accumulator` 并结束仿真。

### 推荐书写顺序

1. 先写 DUT 的模块外壳和端口。
2. 写 `always_ff`、复位分支和累加分支。
3. 写 testbench 信号和 DUT 例化。
4. 写时钟和复位流程。
5. 写一个 `send_and_check` task。
6. 添加测试并运行。

完成后回看 [08_selfcheck.sv](examples/08_selfcheck.sv)，比较代码结构，而不是逐字符比较。

---

## 10. 练习集中答案

请先真正敲过 `BASIC/exercises` 中的代码，再展开这一节核对。

### 练习 01：常量、切片与拼接

```systemverilog
sum          = a + b;
high_nibble  = a[7:4];
joined       = {a[7:4], b[3:0]};
```

`8'hc3 + 8'd61 = 256`，8 位结果截断后为 `8'h00`。

### 练习 02：MUX

```systemverilog
always_comb begin
  if (sel)
    y = d1;
  else
    y = d0;
end
```

两个分支都必须给 `y` 赋值。

### 练习 03：case ALU

```systemverilog
always_comb begin
  case (op)
    2'd0: result = a + b;
    2'd1: result = a - b;
    2'd2: result = a & b;
    2'd3: result = a ^ b;
    default: result = '0;
  endcase
end
```

虽然 2 位 `op` 只能表示 0 到 3，仍保留 `default` 是一个清晰、稳妥的习惯。

### 练习 04：计数器

```systemverilog
always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    count <= '0;
  else if (enable)
    count <= count + 1'b1;
end
```

没有最后的 `else` 时，`enable=0` 会保持计数值。

### 练习 05：参数化加法器

```systemverilog
{carry, sum} = a + b;
```

左侧总宽度是 `WIDTH+1`，因此能够同时接住进位和低 WIDTH 位结果。

### 练习 06：数组、循环与函数

函数中的循环：

```systemverilog
for (bit_index = 0; bit_index < 8; bit_index = bit_index + 1)
  parity8 = parity8 ^ value[bit_index];
```

数组处理循环：

```systemverilog
for (i = 0; i < 3; i = i + 1)
  parity[i] = parity8(data[i]);
```

### 练习 07：task 激励与检查

替换 task 中的 TODO 内容：

```systemverilog
a = lhs;
b = rhs;
#1;
if (equal !== expected)
  $fatal(1, "lhs=%0d rhs=%0d expected=%0b actual=%0b",
         lhs, rhs, expected, equal);
pass_count = pass_count + 1;
```

task 把“驱动 → 等待 → 检查 → 计数”封装成可以反复调用的动作。

### 练习 08：完整自检平台

DUT 的正常工作分支：

```systemverilog
result_valid <= valid;
if (valid)
  result <= a + b;
```

task 中的 TODO 内容：

```systemverilog
expected = lhs + rhs;
@(negedge clk);
valid = 1'b1;
a = lhs;
b = rhs;
@(posedge clk); #1;
if (result_valid !== 1'b1 || result !== expected)
  $fatal(1, "a=%0d b=%0d expected=%0d actual=%0d",
         lhs, rhs, expected, result);
pass_count = pass_count + 1;
@(negedge clk);
valid = 1'b0;
```

---

## 常见错误速查

| 现象 | 优先检查 |
|---|---|
| 编译器提示端口附近语法错误 | 上一行是否少逗号，端口表后是否是 `);` |
| 输出一直是 `X` | 信号是否初始化或复位，组合逻辑是否漏赋值 |
| 计数值少一次或多一次 | 在哪个时钟沿驱动、在哪个时钟沿检查 |
| 结果突然变成很小的数 | 左侧位宽是否导致截断 |
| `if` 判断和预想不同 | 是否把 `=`、`==`、`===` 混用 |
| 按位结果只有 0 或 1 | 是否把 `&` 写成了 `&&` |
| 时序逻辑行为顺序奇怪 | `always_ff` 中是否误用了阻塞赋值 `=` |
| 模块例化后信号不动 | 端口是否漏接、方向是否理解反了 |

## 下一步

当你能不看模板完成第 9 节，并能解释自己的时钟、复位、驱动和检查顺序，就可以回到当前 ALU 工程继续学习：

1. 用 `class` 表示 transaction。
2. 把激励、观察和检查拆成 driver、monitor、scoreboard。
3. 引入随机化、覆盖率和断言。
4. 最后再迁移到 UVM。

判断自己是否真正掌握的标准不是“这段代码看起来熟悉”，而是关闭示例后仍能从模块外壳开始写出来，并能根据编译和仿真结果独立修正。
