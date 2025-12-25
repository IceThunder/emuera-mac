# Emuera 原项目 vs Swift移植项目 功能对比

## 📊 总体对比

### 原项目 (C#)
- **命令数量**: 266个 (BuiltInFunctionCode.cs)
- **内置函数**: 200+个 (FunctionMethod)
- **图形命令**: PRINT_IMG, PRINT_RECT, PRINT_SPACE, GDRAWSPRITE, GFILLRECTANGLE等
- **音频命令**: ❌ 无
- **鼠标命令**: INPUTMOUSEKEY, MOUSEX, MOUSEY
- **高级图形**: 通过G系列函数实现 (GCREATE, GDRAWSPRITE等)

### Swift移植项目
- **命令数量**: ~100个 (进行中)
- **内置函数**: 231+个 (已完成)
- **图形命令**: 自定义10个 (DRAWSPRITE, DRAWRECT等)
- **音频命令**: 自定义7个 (计划中)
- **鼠标命令**: 计划5个
- **高级图形**: 自定义实现

---

## 🔍 详细对比分析

### 1. 图形绘制命令

#### 原项目 (C#)
```
命令:
- DRAWLINE - 绘制分隔线
- CUSTOMDRAWLINE - 自定义分隔线
- DRAWLINEFORM - 格式化分隔线
- BAR, BARL - 进度条
- PRINT_IMG - 打印图片
- PRINT_RECT - 打印矩形
- PRINT_SPACE - 打印空格

函数 (G系列):
- GDRAWSPRITE(id, x, y) - 绘制精灵
- GFILLRECTANGLE(id, color, x, y, w, h) - 填充矩形
- GCREATE, GDISPOSE - 图形创建/销毁
- GSETBRUSH, GSETPEN - 画笔/画笔设置
- GSETCOLOR - 设置颜色
```

#### Swift移植项目 (当前)
```
命令:
- DRAWSPRITE - 绘制精灵/图片 ✅
- DRAWRECT - 绘制矩形 ✅
- FILLRECT - 填充矩形 ✅
- DRAWCIRCLE - 绘制圆形 ✅
- FILLCIRCLE - 填充圆形 ✅
- DRAWLINEEX - 高级线条 ✅
- DRAWGRADIENT - 渐变填充 ✅
- SETBRUSH - 设置画笔 ✅
- CLEARSCREEN - 清屏 ✅
- SETBACKGROUNDCOLOR - 设置背景颜色 ✅

缺失的原项目功能:
- CUSTOMDRAWLINE - 自定义分隔线
- DRAWLINEFORM - 格式化分隔线
- PRINT_IMG - 打印图片 (原项目有)
- PRINT_RECT - 打印矩形 (原项目有)
- PRINT_SPACE - 打印空格 (原项目有)
- G系列函数 - 图形对象操作 (原项目有)
```

**分析**:
- ✅ 我们的实现覆盖了核心图形功能
- ⚠️ 原项目有PRINT_IMG/RECT/SPACE，我们没有
- ⚠️ 原项目有G系列函数用于图形对象，我们是直接绘制
- ❌ 原项目没有DRAWCIRCLE/FILLCIRCLE/DRAWGRADIENT，这些是我们新增的

**结论**: 我们的实现是**扩展性**的，不是完全复制。需要确认是否需要添加PRINT_IMG等命令。

---

### 2. 音频命令

#### 原项目 (C#)
```
❌ 无音频命令
```

#### Swift移植项目 (计划)
```
计划实现:
- PLAYBGM - 播放背景音乐
- STOPBGM - 停止背景音乐
- PLAYSE - 播放音效
- STOPSE - 停止音效
- PLAYVOICE - 播放语音
- VOLUME - 音量控制
- FADEBGM - 淡入淡出
```

**分析**:
- ❌ 原项目没有音频命令
- ✅ 这是我们新增的功能，属于扩展

**结论**: 音频功能是**新增特性**，原项目不支持。

---

### 3. 鼠标输入

#### 原项目 (C#)
```
命令:
- INPUTMOUSEKEY - 鼠标按键输入

函数:
- MOUSEX - 鼠标X坐标
- MOUSEY - 鼠标Y坐标
- GETKEY - 键盘状态
- GETKEYTRIGGERED - 键盘触发状态
```

#### Swift移植项目 (计划)
```
计划实现:
- INPUTMOUSE - 鼠标点击输入
- MOUSEPOS - 获取鼠标位置 (返回数组)
- MOUSESTATE - 鼠标状态检查
- MOUSESKIP - 鼠标跳过
- MOUSECLICK - 模拟点击
```

**分析**:
- ⚠️ 原项目有INPUTMOUSEKEY，我们计划INPUTMOUSE
- ⚠️ 原项目有MOUSEX/MOUSEY分开，我们计划MOUSEPOS返回数组
- ❌ 原项目有键盘相关函数，我们尚未实现

**结论**: 需要调整以匹配原项目风格，可能需要拆分MOUSEPOS为MOUSEX/MOUSEY。

---

### 4. 窗口管理命令

#### 原项目 (C#)
```
命令:
- CLEARLINE - 清除指定行
- REUSELASTLINE - 重用最后一行
- PRINTC - 居中打印
- PRINTLC - 左对齐打印
- PRINTCR - 右对齐打印
- PRINTFORMC - 格式化居中
- PRINTFORMLC - 格式化居中换行
- PRINTCK - 居中打印 (K模式)
- PRINTLCK - 左对齐打印 (K模式)
- PRINTFORMCK - 格式化居中 (K模式)
- PRINTFORMLCK - 格式化居中换行 (K模式)
- PRINTCD - 居中打印 (D模式)
- PRINTLCD - 左对齐打印 (D模式)
- PRINTFORMCD - 格式化居中 (D模式)
- PRINTFORMLCD - 格式化居中换行 (D模式)
- CLEARTEXTBOX - 清除文本框
- ALIGNMENT - 文本对齐
- SETFONT - 设置字体
- FONTBOLD - 粗体
- FONTITALIC - 斜体
- FONTREGULAR - 常规
- FONTSTYLE - 字体样式
```

#### Swift移植项目 (计划)
```
计划实现:
- CLEARLINE ✅ (Priority 1已完成)
- REUSELASTLINE ✅ (Priority 1已完成)
- PRINTC, PRINTLC, PRINTCR
- PRINTFORMC
- ALIGN
- INDENT, TAB, LINE, COLUMN
```

**分析**:
- ✅ CLEARLINE, REUSELASTLINE 已完成
- ⚠️ 原项目有K/D模式打印命令，我们尚未实现
- ⚠️ 原项目有字体相关命令，我们只有基础的
- ❌ 原项目有CLEARTEXTBOX，我们没有

**结论**: 需要补充K/D模式打印命令和字体命令。

---

### 5. 高级输入命令

#### 原项目 (C#)
```
命令:
- INPUTLIST - 列表选择 (推测)
- INPUTMULTI - 多选输入 (推测)
- INPUTCHAR - 字符输入 (推测)

函数:
- GETKEY - 键盘状态
- GETKEYTRIGGERED - 键盘触发
```

#### Swift移植项目 (计划)
```
计划实现:
- INPUTLIST
- INPUTMULTI
- INPUTCHAR
- INPUTDATE
- INPUTTIME
```

**分析**:
- ⚠️ 原项目可能有这些命令，需要进一步确认
- ❌ 原项目有键盘状态函数，我们尚未实现

---

### 6. 系统状态函数

#### 原项目 (C#)
```
函数:
- ISSKIP - 是否跳过
- MOUSESKIP - 鼠标跳过
- MESSKIP - 消息跳过
- GETCOLOR - 获取当前颜色
- GETDEFCOLOR - 获取默认颜色
- GETFOCUSCOLOR - 获取焦点颜色
- GETBGCOLOR - 获取背景颜色
- GETDEFBGCOLOR - 获取默认背景颜色
- GETSTYLE - 获取样式
- GETFONT - 获取字体
- CURRENTALIGN - 当前对齐
- CURRENTREDRAW - 当前重绘模式
- CLIENTWIDTH - 客户端宽度
- CLIENTHEIGHT - 客户端高度
- ISACTIVE - 窗口是否激活
```

#### Swift移植项目 (计划)
```
计划实现:
- ISSTOP
- ISANIME
- ISMOUSE
- ISSOUND
- GETSCREEN
- GETBGCOLOR
```

**分析**:
- ⚠️ 部分功能重叠，但命名不同
- ❌ 原项目有更多系统状态函数

---

## 📋 功能差异总结

### ✅ 已实现且匹配原项目
1. **基础命令**: PRINT系列, INPUT系列, 流程控制
2. **数学函数**: 数学运算, 数组操作
3. **字符串函数**: 字符串处理
4. **位运算**: SETBIT, CLEARBIT, INVERTBIT
5. **时间日期**: GETDATE, GETDATETIME等
6. **文件操作**: FILEEXISTS, FILECOPY等
7. **图形基础**: DRAWLINE, BAR, SETCOLOR
8. **窗口管理**: CLEARLINE, REUSELASTLINE

### ⚠️ 已实现但有差异
1. **图形绘制**: 我们新增了CIRCLE/GRADIENT等，原项目没有
2. **参数解析**: 我们支持逗号分隔，原项目可能只支持空格

### ❌ 原项目有但我们缺失
1. **PRINT_IMG, PRINT_RECT, PRINT_SPACE** - 简单图形打印
2. **G系列函数** - 图形对象操作 (GCREATE, GDRAWSPRITE等)
3. **K/D模式打印命令** - PRINTK, PRINTD系列
4. **字体样式命令** - FONTSTYLE, SETFONT
5. **CLEARTEXTBOX** - 清除文本框
6. **HTML命令** - HTML_PRINT, HTML_TAGSPLIT
7. **TOOLTIP命令** - TOOLTIP_SETCOLOR等
8. **调试命令** - DEBUGPRINT, ASSERT, THROW
9. **字符/字符串打印** - PRINTSINGLE系列
10. **按钮打印** - PRINTBUTTON系列
11. **键盘状态函数** - GETKEY, GETKEYTRIGGERED
12. **鼠标坐标函数** - MOUSEX, MOUSEY (分开)

### ❌ 我们新增但原项目没有
1. **音频命令** - PLAYBGM, PLAYSE等
2. **高级图形** - DRAWCIRCLE, FILLCIRCLE, DRAWGRADIENT
3. **清屏命令** - CLEARSCREEN
4. **背景颜色命令** - SETBACKGROUNDCOLOR

---

## 🎯 建议的下一步行动

### 优先级 1: 补齐原项目功能
1. **添加PRINT_IMG, PRINT_RECT, PRINT_SPACE** - 原项目有
2. **添加K/D模式打印命令** - PRINTK, PRINTD系列
3. **添加字体样式命令** - FONTSTYLE, SETFONT
4. **添加CLEARTEXTBOX** - 原项目有
5. **添加调试命令** - DEBUGPRINT, ASSERT

### 优先级 2: 调整现有实现
1. **拆分MOUSEPOS为MOUSEX/MOUSEY** - 匹配原项目
2. **添加键盘状态函数** - GETKEY, GETKEYTRIGGERED
3. **添加HTML命令** - HTML_PRINT等

### 优先级 3: 保持扩展功能
1. **保留音频命令** - 这是好的扩展
2. **保留高级图形** - CIRCLE/GRADIENT很有用
3. **保留清屏和背景颜色** - 实用功能

### 优先级 4: 未来功能
1. **G系列图形对象** - 复杂但有用
2. **PRINTBUTTON** - 交互式按钮
3. **PRINTSINGLE** - 单行打印
4. **TOOLTIP** - 工具提示

---

## 📝 结论

### 当前状态
- **完成度**: 约60% (对比原项目)
- **核心功能**: 基本完整
- **扩展功能**: 音频、高级图形

### 需要添加的原项目功能
1. PRINT_IMG/RECT/SPACE (3个)
2. K/D模式打印 (约15个)
3. 字体样式 (4个)
4. 调试命令 (5个)
5. 键盘函数 (2个)
6. HTML命令 (4个)
7. 其他小命令 (10+个)

**总计**: 约40个命令/函数需要添加

### 建议
1. **先补齐原项目功能** - 保持兼容性
2. **再扩展新功能** - 音频、高级图形
3. **文档化差异** - 明确哪些是扩展

---

**文档版本**: v1.0
**创建日期**: 2025-12-26
**状态**: 分析完成
