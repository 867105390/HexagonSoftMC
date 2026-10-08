# Hexagon softMC 项目指南

本文件面向维护本仓库的 Agent 和工程师。先读本文件，再读当前分支的源码；不能把其他分支的机器参数或实现当作本分支的事实。本文是跨分支指南，描述的分支现状以 2026-10-07 为基准，后续修改相关功能时应同步更新。

## 1. 项目与操作边界

这是 Hexagon 测量设备在 Servotronix softMC 控制器上运行的应用层工程：MC-BASIC `.PRG` 任务、`.LIB` 库、EtherCAT CDHD 驱动器，以及上位机通信和运动控制。不是 VB/VB.NET、PLC Structured Text 或普通桌面程序。代码可能直接接入真实运动系统。

- 用户要求解释、核查或写文档时，只做相应的只读检查或文档修改；不因此连接、初始化、下载、复位、使能或运动设备。
- 实机测试须有明确授权，并确认急停、限位、接线、机械位置、其他客户端和任务状态。历史测试地址 `90.0.0.1` 不代表以后可以随时操作。
- 不凭推测改变速度、加速度、行程、极性、位置比例、回零方式、驱动器型号或安全设置。仿真通过不证明实机安全。
- 保留用户已有改动。不要强制重置、删除分支或覆盖工作区；提交范围应清晰。当前约定是本地提交、不主动 push，除非用户另行要求。
- 不将凭据、设备私有配置、完整通信日志等无关内容加入提交。

## 2. 分支区别：先确认分支再改代码

| 分支 | 应用轴与参数布局 |
| --- | --- |
| `master` | X/Y/Z；`XY_SU.PRG` 已移除，应用参数集中到 `PARA.PRG` 的轴及轴组 sub |
| `Liner_Master` | Linear 机型；同样已合并 PARA/XY_SU，但机器数值不同。实际 Git 名是 `Liner_Master`，不是 `Linear_Master` |
| `Master_Duo` | 基于 master 增加 X_F、Z_F 两实轴；五轴配置、使能、回零及 1:1 电子齿轮见第 8 节 |
| `Fix_Stop_Group_bug`、`HomeBug`、`dev_418_support`、`dev_418_support_homingFlag`、`dev_settle_property` | 历史实现，仍存在并启动 `XY_SU.PRG`，随后执行 `PARA.PRG`；不能宣称已完成参数合并 |
| `test/` 下的 `Liner_Master_0806` 历史分支 | 仍有 XY_SU；实际分支名在斜杠后含 U+200C 隐藏字符，必须从 Git 枚举取得原名，不要手输或擅自重命名 |

其余旧分支虽然可能设置 `sys.naxes=5`，不等于已经配置五根物理应用轴；需要核对 `Axes[]`、轴名、Dadd 和总线映射。`AXIS_F.LIB` 是通用轴功能库，其存在不表示有跟随轴。不要因为添加这份文档就顺便合并历史分支的功能。

## 3. 启动链与文件地图

上电从 `CONFIG.PRG` / `AUTOEXEC.PRG` 开始，具体 Load、StartTask 和等待顺序以本分支 `AUTOEXEC.PRG` 为准。

- `CONFIG.PRG`：声明轴组、通用轴数组、系统共享变量，命名轴并设置系统初始状态。`gXYZ` 的声明留在配置中，不搬进普通任务或库。
- `AUTOEXEC.PRG`：启动编排；识别 `0.4.21` / `0.4.18` 固件，未知固件会进入仿真分支。不要把启动末尾的一句成功打印当作全部硬件操作成功。
- `ECCONFIG.PRG`：加载对应固件的 EtherCAT/驱动/公共库；4.21 与 4.18 的库及轴配置文件不同。
- `EC_SETUP.PRG`：从站发现、PDO/SDO 配置和总线启动。跟随轴总线配置也放这里，不另建 `EC_DUO.PRG`。
- `AXISEC.PRG` / `AXISECO.PRG`：固件对应的轴总线及驱动地址映射。
- `AX_SETUP.PRG`：基础轴配置，主体源于生成器；不要无故重写原三轴生成配置。Master_Duo 已按用户要求在此增加 A4/A5。
- `ROBOT.PRG`：XYZ 轴组设置。`SIMSETUP.PRG`：仿真轴初始化，不是实机配置替代品。
- `PARA.PRG`：应用最终参数，包括对 AX_SETUP/ROBOT 的覆盖；历史分支此前还执行 XY_SU。
- `AXIS_F.LIB`：上位机调用的轴/组功能、运动请求、回零、位置比较、相机锁存及共享状态。
- `COMM.LIB`、`SERVER.PRG`、`TCPCOM.PRG`：命令解析、响应和状态通信。TCPCOM 的状态流主要仍是 X/Y/Z，不自动等于五轴完整诊断。
- `MVAXES.PRG` / `MVGROUP.PRG`：根据请求标志执行轴或轴组运动；与 `semMove` 及调用方协作，不是随意并行启动的独立测试任务。
- `MHGR.PRG`、`GR_HMING.LIB`：回零任务和库；Duo 使用对应的 `DUOHOME.LIB`。不同历史分支的回零等待逻辑并不完全一致。
- `JOG_X/Y/Z.PRG`、`JMAP.PRG`、`RSJOG.PRG`、`SWVEL.PRG`、`TMAN.PRG`：摇杆、模式及运动任务生命周期。
- `ERRACT.PRG`、`VELLIM.PRG`、`MSOCKET.PRG`：错误、速度限制和连接监控；修改使能/回零时也要检查这些入口。
- `LATCH.PRG`：相机锁存后台采集。`PROBE*.PRG/LIB`：另一套测头业务，不能混淆。
- `.apj`（例如 `CONTROLSTUDIO.apj` / `CSFW.apj`）只用于 ControlStudio 组织工程，不作为 MC-BASIC 运行依赖或参数来源；本项目修改可忽略，不要求核查或同步维护。运行关系以 `.PRG/.LIB` 的实际加载和调用为准。不要随意修改许可证、`.dat/.asn/.pse` 等辅助文件。

实机常见初始化顺序为 ECCONFIG → EC_SETUP → AXISEC/AXISECO → AX_SETUP → ROBOT →（历史分支 XY_SU）→ PARA → 应用任务。Master_Duo 在 PARA 后执行 DUOSET；仿真路径跳过硬件总线初始化，不能照搬实机顺序。

## 4. 参数维护与编码

- `master` / `Liner_Master`：在 `SetXAxisParameters`、`SetYAxisParameters`、`SetZAxisParameters`、`SetGroupParameters` 内直接设置应用参数。Duo 另有 `SetXFParameters` / `SetZFParameters`。
- 已集中实现的 `master` / `Liner_Master` / `Master_Duo` 按目标分支自己的原 PARA 数值维护，不按 XY_SU 的螺距/倍率计算结果重建值，也不拿另一机型的 PARA 覆盖。序列号、行程、速度、回零参数均可能不同。
- 历史分支的 XY_SU 仍实际设置 VMax/AMax/Jerk/VelocityOverSpeed 等，PARA 只覆盖部分属性。维护这些分支时应追踪 XY_SU → PARA 的最终有效值，不能因为某项未写进 PARA 就认定不存在或无用。
- `PARA.PRG` 可以覆盖 `AX_SETUP.PRG`。例如目标机型有 `y.VelocityOverSpeed=1.2*y.VMax` 时，应保留这一应用覆盖，而不是以基础配置已有设置为由删掉。
- 删除变量前，全仓查声明、赋值和读取，以及启动链、库和上位机接口。只有确认无实际用途才删。不要把同名不同作用域误判为同一个变量。
- `Screw_lift`、`Jvmax`、`AccVratio` 等旧计算辅助量在已合并分支中不再用于重新计算应用速度/加速度；历史分支仍有旧代码，先核查再改。
- `MotionBusVelocityBase/Scale` 属于驱动器总线速度表示与换算配置，不是可随便移除的螺距/加速倍率。核对驱动对象、单位及使用处后再修改。
- `.PRG/.LIB` 的现有中文通常为 GBK/CP936。先确认编码，保留原编码、换行和未修改内容；不要用 UTF-8 默认写回整份旧源码。`AGENTS.md` 使用 UTF-8。
- Windows 显示大小写不敏感，控制器文件引用和工程清单仍应保持既有拼写。新增控制器文件优先沿用短文件名，避免未验证的文件名兼容问题。

## 5. MC-BASIC 写法速览

以本分支已运行的写法为模板；名称大小写一般不敏感，但不要擅自改公共接口拼写。

### 作用域和入口

- `common shared` 是系统共享，跨加载任务/库可见；通常声明在 PROGRAM 前，必须核对声明类型与初始化顺序。
- `dim shared` 是当前任务的共享变量，不是跨任务全局。`dim` 是 PROGRAM/SUB/FUNCTION 内局部变量；在执行语句前声明。同名局部或任务变量会遮蔽系统共享变量。
- 常见类型有 `long`、`double`、`string`、`generic axis`、`generic group`、`error`、`semaphore`。不要用另一种 BASIC 的类型/语法替换。
- 普通 `program ... end program` 经 LOAD 翻译后还需 `StartTask` / `Stas`；`program continue` 在 LOAD 时自动运行，不要再重复启动。
- `end program` 后任务仍加载；`terminate program` 会卸载。`.LIB` 的公共 sub/function 需由相应全局库加载后使用。
- `call Foo(args)` 调 sub；无参调用可沿用 `call Foo`。函数通过给函数名赋值返回，不是 `return expression`。

下面仅是语法示意，不访问轴、不作为需要新增到启动链的任务：

```basic
dim shared exampleValue as double = 0

program
  dim requestedValue as double
  requestedValue = 1
  call StoreExample(requestedValue)
  print exampleValue
end program

sub StoreExample(byval newValue as double)
  exampleValue = newValue
end sub
```

### 条件、数组和兼容性

- 注释用 `'`；优先块式 `if ... then` / `end if`，`while` / `end while`，`for` / `next`，沿用源码中的 `select case` 写法。
- `and/or/not` 与位运算 `band/bor` 不混用。DS402 状态字检查要使用相应位掩码，不能把普通真假判断当位测试。
- 原生布尔真值可能为 `-1`，例如 IsMoving；一般用条件或 `<>0`，不能一律比较 `=1`。业务标志明确约定 0/1 时按其协议处理。
- 既有数组通常按 1..3 或 1..5 使用（声明形如 `[3]` / `[5]`）；查清语言语义及所有索引，不要照搬其他语言改为 0 起始。
- 当前实测固件 `MULTIBUS 0.4.21.2r20-C2` 的翻译器对单行 IF、多值 CASE、保留字局部名等有兼容限制；字符串常量应保持不超过 80 字符。这里指常量，不是说所有字符串变量只有 80 字符。这些是该固件实测约束，不宣称所有 softMC 版本均如此。
- 沿用已验证的属性、缩写、枚举和单位，例如 `PFB/PCMD`、`GEAR/OFF/NONE`。不确定的命令先查官方文档，不能从 VB 或其他控制器语言猜测。

## 6. 任务、占用与错误处理

- 常见 `task.State` 基值：1 运行、4 错误、7 就绪、10 结束/被杀；还可能附加 locked 256、事件错误处理被中断 512。新增状态判断须考虑文档中的组合状态。
- LOAD 成功只说明翻译/加载成功；State=10 也不说明业务成功。初始化或运动等待要核对任务错误、实际结果、超时和取消状态。
- 轮询必须有适当 `sleep`；新增等待不能仅无限等待 `state=10` 而忽略错误状态。不要在周期任务里忙等或做无界阻塞操作。
- `attach` 是任务对轴/组的独占控制。组被占用时不能任意单独占用成员；不要为消除报错强夺其他运动任务的轴。
- `detach` 可能等运动结束；`DetachFrom/AttachTo` 只用于受控的任务生命周期切换。检查 `AttachedTo`，空任务名不要直接传入跨任务操作。
- 按正常和异常路径释放占用、清请求标志、恢复模式，并逐轴尝试安全清理，不能因一根轴清理失败就跳过其余轴失能。遵守 `semMove` 的既有配对使用方式。
- `try ... catch else ... end try` 中先保存 `errornumber` 供诊断。`throw` 使用已声明的 error 名称，或裸 `throw`；不接受动态整数错误码。`Error.num/.msg` 不作为可任意写入的字段。
- 裸 throw 使用任务最后错误；清理操作产生的新错误可能覆盖原错误。保留首个业务错误，另报清理错误，不要用空 catch 把新增关键故障隐藏掉。
- `KillTask` 不会替你执行 catch/清理。回零中应请求取消并等清理结束，不能直接杀任务后当作已安全复位。
- 不写 `PFB`（反馈位置只读）；通过 Displacement 等改坐标可能影响主从同步，须核对失能、解绑与坐标语义。不能靠置零坐标假装完成物理回零。

## 7. 总线、协议与相机锁存

### EtherCAT / 驱动

- SDO 是对象访问/配置，PDO 是已映射的周期数据。使用当前固件对应的库，核对对象索引、子索引、位宽、地址、总线状态和单位。
- 控制器轴号、Dadd 从站地址、系统 DIO 地址、驱动物理 DI/DO 端子不是同一个概念，不能按数字相同就推断接线。
- 映射建立后才能依赖相应 PDO 读写；读回值/状态字与写入命令的意义不同。回零速度的原 VFac/AFac 换算不要无依据修改。

### 上位机接口

- 保留函数名、参数顺序、序号和响应格式，包括既有拼写 `sendResponce`。`COMM.LIB` 的 `gInsertLocalSocket` 会加入本地 socket 参数，不能误当成上位机发送的轴号。
- “请求已接受”、同步返回和 `sendDeferredResponce` 的异步完成响应不是一回事。修改调用链要检查响应次数，不要重复或漏回。
- 发出命令的日志只能证明发送行为，不能证明驱动写入成功、动作完成或运动安全。必要时核对对象读回、PDO、驱动状态和任务错误。

### 相机 Latch 不等于 Probe

相机链主要在 `AXIS_F.LIB` / `LATCH.PRG`：配置位置比较 → 开关比较输出 → 初始化位置捕获 → 后台收集锁存位置。以下对象值以当前 master / Master_Duo 源码为例，其他分支应对照自己的实现。测头 `PROBE*` 是独立业务；底层对象名包含 TouchProbe 也不能据此混为一谈。

- `setPcomPositionPeriodic`：暂关比较（0x2191=0），配置起点 0x219B、终点 0x219D、间距 0x219F，位置按该轴 PFAC 换算。
- `pcomSwitch`：设置 0x2191（周期 25、表 19、关闭 0）及 0x2195 方向，具体参数含义以函数源码为准。
- `latchArrayClear`：清软件缓存，不是复位驱动器全部捕获配置。
- `latchInit`：写 0x60B8=1，等待 20ms，再写 0x13 以配置连续正沿捕获。
- `LatchGetPosition`：读映射的 0x60BA 位置；现有 `LATCH.PRG` 主要采集 Z/ax3，`zLatch[1]` 保存数量，后续元素存位置。
- 这些既有设置函数多有吞异常、无成功回包的行为；不能自动把正常返回当作写入成功，也不能未经要求修改上位机协议。
- 相机函数链本身不能确认固定物理 DI/DO。`PROBEMAP.PRG` 的 DI11 / INMODE27 是 Probe 配置，不应套给相机。EC_SETUP 的 0x2191/0x2192 → HWA1006/1007 是系统映射地址，不是物理 DO 号；Duo 新驱动使用另配地址。实际触发/反馈引脚必须核查驱动器配置和现场接线。

## 8. Master_Duo 专用约定

本节仅用于含 Duo 实现的分支；不要将这些函数或默认值套到其他分支。

- A1=X、A2=Y、A3=Z、A4=X_F、A5=Z_F；`gXYZ` 仍是三维 X/Y/Z 组，不改为五轴 group。
- `EC_SETUP.PRG` 配置五个 CDHD 驱动，Dadd 1..5；X_F 的 PDO/SDO 配置对应 X，Z_F 对应 Z。当前识别值 vendor 0x2E1、product 0x2EC，接入硬件仍须核实实际设备。
- `AX_SETUP.PRG` 保留原三轴基础设置，并增加 A4/A5 的对应基础配置。`PARA.PRG` 的 SetXF/SetZF 从对应主轴复制应用覆盖。新增主轴覆盖时核查从轴是否也需同步，不能遗漏或把 X 参数给 Z_F。
- `DUOSET.PRG` / `DUO.LIB` 负责检查和绑定，不再负责复制基础参数。X_F 跟随 X.PCMD、Z_F 跟随 Z.PCMD，GEAR 比例 1:1。
- 只有两对位置分别在对应主轴 `PESettle` 容差内才绑定；不一致时等待上位机回零，不上电自动移动对齐。
- 上位机原 `grEn` 入口转到 `grEnable` / `DuoEnableGroup`：使能时先从轴再 gXYZ，失能时覆盖组和从轴。直接 `gXYZ.En=1` 不等价于五轴使能；轴入口还需考虑 `DuoEnableAxis` 的成对处理。
- 主轴 SlaveDisable=1、从轴 SlaveDisconnect=0 的联锁依赖已绑定状态；不能当作未绑定时也有的机械安全保证。
- 不独立 Move/Jog/Stop 齿轮从轴；Stop 等操作可能拆开齿轮关系。从轴齿轮状态下 IsMoving 可能在静止时仍为 -1，不能仅据此判断真正运动或零速。
- 回零沿用上位机命令。`MHGR.PRG` / `DUOHOME.LIB` 在解绑后采用原驱动器内部回零方法，阶段为 Z/Z_F → X/X_F → Y；检查 DS402 状态、模式、错误、超时与取消，完成清理/恢复模式后仅在位置匹配时重绑。
- 新轴原点开关和极性必须独立核实；数值坐标相同不等于龙门机械已调方。成对使能/启动是顺序命令，不承诺硬件严格同步。
- 复位通过 `duoHomeCancel` 等待回零清理，再进行后续处理；TMAN 的任务切换需保留回零忙状态保护。

### 仿真开关与验证边界

- `Master_Duo` 当前 CONFIG 的 `sys_simulated=1` 默认仿真；其他现有分支默认通常为 0。必须读目标分支，不能按文档假定已处于仿真。
- Duo 仿真跳过 EtherCAT 硬件初始化，SIMSETUP 对五轴设置 Sim=1 / Dadd=0，之后仍执行必要的 AX_SETUP 从轴设置、PARA 和 DUOSET。
- 改持久化 `sys_simulated` 后要经过安全的完整重新初始化，不能只改运行变量就认为总线/轴/后台任务已切换。`sys.NoMotion` 是另一项系统运动设置，不是仿真开关，不能为跑通实机测试随意放开。
- `DUOTEST.PRG` 仅手动测试，不放 AUTOEXEC；运行前核对五轴均为仿真，以及其他任务和连接状态。临时测试设置应有恢复路径。
- 历史记录：90.0.0.1、MULTIBUS 0.4.21.2r20-C2、无从站条件下，Duo 仿真 18 项断言通过，涵盖跟随、五轴使能、位置不一致拒绝、回零/取消/恢复等。这不是本次自动测试结果，更不是实机 EtherCAT、回零接线或机械安全验收。

## 9. 修改与验证流程

1. 查当前分支、工作区及已有改动，读入口和相关库；用全仓搜索追踪目标变量/属性/函数的声明、读写、调用及任务顺序。
2. 做最小范围修改。跨机型移植逻辑时，保留目标机型数据；新增/删除运行文件检查启动链、库加载和实际调用引用，忽略 `.apj` 组织文件。
3. 核对 diff：编码无损、原机器数值不被意外改动、公共接口兼容，且正常/错误/取消路径都处理资源和使能状态。
4. 用 ControlStudio 或控制器翻译器验证语法和库加载。仓库没有通用的 `npm test` 或离线 MC-BASIC 编译入口；不要虚构已执行的验证，也不为此安装无关运行时。
5. 在授权的仿真条件下验证任务状态和应用结果；需要实机验证时，列明未验证项目并交由现场工程师按安全条件执行。不能把“翻译成功”“发送成功”“仿真成功”写成“实机安全通过”。
6. 按请求提交，说明改动、实际验证和剩余限制。只改文档时不运行运动测试；不因为用户要求所有分支有文档就改变各分支控制逻辑。

## 10. 官方参考

语法及属性以目标固件支持情况和官方 softMC 文档为准；网页中的命令例子不替代本机驱动手册、接线图和实测。

- [MC-BASIC 命令索引](http://softmc.servotronix.com/wiki/Category:MC-Basic:Commands)
- [PROGRAM / END PROGRAM](http://softmc.servotronix.com/wiki/MC-Basic:PROGRAM_..._END_PROGRAM)、[task.STATE](http://softmc.servotronix.com/wiki/MC-Basic:task.STATE)
- [COMMON SHARED](http://softmc.servotronix.com/wiki/MC-Basic:COMMON_SHARED_..._AS_LONG_or_DOUBLE_or_STRING_or_STRING_OF_UTF8)、[DIM SHARED](http://softmc.servotronix.com/wiki/MC-Basic:DIM_SHARED_..._AS_LONG_or_DOUBLE_or_STRING_or_STRING_OF_UTF8)
- [ATTACH](http://softmc.servotronix.com/wiki/MC-Basic:ATTACH)、[DETACH](http://softmc.servotronix.com/wiki/MC-Basic:DETACH)、[THROW](http://softmc.servotronix.com/wiki/MC-Basic:THROW)、[KILLTASK](http://softmc.servotronix.com/wiki/MC-Basic:KILLTASK)
- [MASTERSOURCE](http://softmc.servotronix.com/wiki/MC-Basic:axis.MASTERSOURCE)、[GEARRATIO](http://softmc.servotronix.com/wiki/MC-Basic:axis.GEARRATIO)、[SLAVE](http://softmc.servotronix.com/wiki/MC-Basic:axis.SLAVE)、[Gantry Issues](http://softmc.servotronix.com/wiki/Gantry_Issues)

本文件采用仓库根目录标准文件名 `AGENTS.md`；Agent 还应检查路径上更具体的指令文件。可参考 [Codex 的 AGENTS.md 发现规则](https://learn.chatgpt.com/docs/agent-configuration/agents-md)。不要假定新建文件会让已经运行的其他任务自动重读。
