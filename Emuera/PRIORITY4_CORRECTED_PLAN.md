# Priority 4 修正开发计划 - 基于原项目对比

## 📊 重要发现

通过对比原项目（C#版Emuera），发现以下关键差异：

### 原项目没有的功能（我们新增的）
- ❌ 音频命令 (PLAYBGM, PLAYSE等) - **纯新增**
- ❌ 高级图形 (DRAWCIRCLE, FILLCIRCLE, DRAWGRADIENT) - **纯新增**
- ❌ 清屏命令 (CLEARSCREEN) - **纯新增**
- ❌ 背景颜色命令 (SETBACKGROUNDCOLOR) - **纯新增**

### 原项目有但我们缺失的功能
- ⚠️ PRINT_IMG, PRINT_RECT, PRINT_SPACE - **需要添加**
- ⚠️ K/D模式打印命令 - **需要添加**
- ⚠️ 字体样式命令 - **需要添加**
- ⚠️ 调试命令 (DEBUGPRINT, ASSERT) - **需要添加**
- ⚠️ HTML命令 - **需要添加**
- ⚠️ 键盘状态函数 - **需要添加**

---

## 🎯 修正后的开发优先级

### 阶段 1: 补齐原项目核心功能 (Week 1-2)

#### 1.1 打印命令扩展
| 命令 | 原项目 | 优先级 | 状态 |
|------|--------|--------|------|
| PRINT_IMG | ✅ 有 | 高 | 待实现 |
| PRINT_RECT | ✅ 有 | 高 | 待实现 |
| PRINT_SPACE | ✅ 有 | 高 | 待实现 |
| PRINTC | ✅ 有 | 中 | 待实现 |
| PRINTLC | ✅ 有 | 中 | 待实现 |
| PRINTCR | ✅ 有 | 中 | 待实现 |
| PRINTFORMC | ✅ 有 | 中 | 待实现 |
| PRINTFORMLC | ✅ 有 | 中 | 待实现 |

#### 1.2 K/D模式打印 (15个命令)
```
K模式 (Kanji/Character模式):
- PRINTK, PRINTKL, PRINTKW
- PRINTVK, PRINTVKL, PRINTVKW
- PRINTSK, PRINTSKL, PRINTSKW
- PRINTFORMK, PRINTFORMKL, PRINTFORMKW
- PRINTFORMSK, PRINTFORMSKL, PRINTFORMSKW
- PRINTCK, PRINTLCK, PRINTFORMCK, PRINTFORMLCK

D模式 (Debug模式):
- PRINTD, PRINTDL, PRINTDW
- PRINTVD, PRINTVDL, PRINTVDW
- PRINTSD, PRINTSDL, PRINTSDW
- PRINTFORMD, PRINTFORMDL, PRINTFORMDW
- PRINTFORMSD, PRINTFORMSDL, PRINTFORMSDW
- PRINTCD, PRINTLCD, PRINTFORMCD, PRINTFORMLCD
```

#### 1.3 字体和样式命令
| 命令 | 原项目 | 优先级 | 状态 |
|------|--------|--------|------|
| SETFONT | ✅ 有 | 高 | 待实现 |
| FONTBOLD | ✅ 有 | 高 | 待实现 |
| FONTITALIC | ✅ 有 | 高 | 待实现 |
| FONTREGULAR | ✅ 有 | 高 | 待实现 |
| FONTSTYLE | ✅ 有 | 中 | 待实现 |
| ALIGNMENT | ✅ 有 | 高 | 待实现 |

#### 1.4 其他重要命令
| 命令 | 原项目 | 优先级 | 状态 |
|------|--------|--------|------|
| CLEARTEXTBOX | ✅ 有 | 中 | 待实现 |
| CUSTOMDRAWLINE | ✅ 有 | 中 | 待实现 |
| DRAWLINEFORM | ✅ 有 | 中 | 待实现 |
| TIMES | ✅ 有 | 中 | 待实现 |

---

### 阶段 2: 补齐系统函数 (Week 3)

#### 2.1 键盘状态函数
| 函数 | 原项目 | 优先级 | 状态 |
|------|--------|--------|------|
| GETKEY | ✅ 有 | 高 | 待实现 |
| GETKEYTRIGGERED | ✅ 有 | 高 | 待实现 |

#### 2.2 鼠标坐标函数 (调整)
| 函数 | 原项目 | 优先级 | 状态 |
|------|--------|--------|------|
| MOUSEX | ✅ 有 | 高 | 待实现 |
| MOUSEY | ✅ 有 | 高 | 待实现 |
| MOUSEPOS | ❌ 新增 | 中 | 已计划 |

**调整**: 将MOUSEPOS拆分为MOUSEX/MOUSEY以匹配原项目

#### 2.3 系统状态函数
| 函数 | 原项目 | 优先级 | 状态 |
|------|--------|--------|------|
| GETCOLOR | ✅ 有 | 高 | ✅ 已实现 |
| GETBGCOLOR | ✅ 有 | 高 | 待实现 |
| GETDEFCOLOR | ✅ 有 | 中 | 待实现 |
| GETDEFBGCOLOR | ✅ 有 | 中 | 待实现 |
| GETSTYLE | ✅ 有 | 中 | 待实现 |
| GETFONT | ✅ 有 | 中 | 待实现 |
| CURRENTALIGN | ✅ 有 | 中 | 待实现 |
| CURRENTREDRAW | ✅ 有 | 中 | 待实现 |
| CLIENTWIDTH | ✅ 有 | 中 | 待实现 |
| CLIENTHEIGHT | ✅ 有 | 中 | 待实现 |
| ISACTIVE | ✅ 有 | 中 | 待实现 |

#### 2.4 HTML和工具提示
| 命令 | 原项目 | 优先级 | 状态 |
|------|--------|--------|------|
| HTML_PRINT | ✅ 有 | 中 | 待实现 |
| HTML_TAGSPLIT | ✅ 有 | 中 | 待实现 |
| HTML_GETPRINTEDSTR | ✅ 有 | 低 | 待实现 |
| HTML_POPPRINTINGSTR | ✅ 有 | 低 | 待实现 |
| HTML_TOPLAINTEXT | ✅ 有 | 低 | 待实现 |
| HTML_ESCAPE | ✅ 有 | 低 | 待实现 |
| TOOLTIP_SETCOLOR | ✅ 有 | 低 | 待实现 |
| TOOLTIP_SETDELAY | ✅ 有 | 低 | 待实现 |
| TOOLTIP_SETDURATION | ✅ 有 | 低 | 待实现 |

#### 2.5 调试命令
| 命令 | 原项目 | 优先级 | 状态 |
|------|--------|--------|------|
| DEBUGPRINT | ✅ 有 | 中 | 待实现 |
| DEBUGPRINTL | ✅ 有 | 中 | 待实现 |
| DEBUGPRINTFORM | ✅ 有 | 中 | 待实现 |
| DEBUGPRINTFORML | ✅ 有 | 中 | 待实现 |
| DEBUGCLEAR | ✅ 有 | 中 | 待实现 |
| ASSERT | ✅ 有 | 中 | 待实现 |
| THROW | ✅ 有 | 中 | 待实现 |

---

### 阶段 3: 补齐高级打印命令 (Week 4)

#### 3.1 字符/字符串单行打印
| 命令 | 原项目 | 优先级 | 状态 |
|------|--------|--------|------|
| PRINTSINGLE | ✅ 有 | 中 | 待实现 |
| PRINTSINGLEV | ✅ 有 | 中 | 待实现 |
| PRINTSINGLES | ✅ 有 | 中 | 待实现 |
| PRINTSINGLEFORM | ✅ 有 | 中 | 待实现 |
| PRINTSINGLEFORMS | ✅ 有 | 中 | 待实现 |
| PRINTSINGLEK | ✅ 有 | 低 | 待实现 |
| PRINTSINGLEVK | ✅ 有 | 低 | 待实现 |
| PRINTSINGLESK | ✅ 有 | 低 | 待实现 |
| PRINTSINGLEFORMK | ✅ 有 | 低 | 待实现 |
| PRINTSINGLEFORMSK | ✅ 有 | 低 | 待实现 |
| PRINTSINGLED | ✅ 有 | 低 | 待实现 |
| PRINTSINGLEVD | ✅ 有 | 低 | 待实现 |
| PRINTSINGLESD | ✅ 有 | 低 | 待实现 |
| PRINTSINGLEFORMD | ✅ 有 | 低 | 待实现 |
| PRINTSINGLEFORMSD | ✅ 有 | 低 | 待实现 |

#### 3.2 按钮打印命令
| 命令 | 原项目 | 优先级 | 状态 |
|------|--------|--------|------|
| PRINTBUTTON | ✅ 有 | 中 | 待实现 |
| PRINTBUTTONC | ✅ 有 | 中 | 待实现 |
| PRINTBUTTONLC | ✅ 有 | 中 | 待实现 |

#### 3.3 普通文本打印
| 命令 | 原项目 | 优先级 | 状态 |
|------|--------|--------|------|
| PRINTPLAIN | ✅ 有 | 中 | 待实现 |
| PRINTPLAINFORM | ✅ 有 | 中 | 待实现 |

---

### 阶段 4: 图形对象系统 (Week 5) - 可选

#### 4.1 G系列函数 (图形对象)
| 函数 | 原项目 | 优先级 | 状态 |
|------|--------|--------|------|
| GCREATE | ✅ 有 | 低 | 待实现 |
| GCREATEFROMFILE | ✅ 有 | 低 | 待实现 |
| GDISPOSE | ✅ 有 | 低 | 待实现 |
| GCLEAR | ✅ 有 | 低 | 待实现 |
| GFILLRECTANGLE | ✅ 有 | 低 | 待实现 |
| GDRAWSPRITE | ✅ 有 | 低 | 待实现 |
| GSETCOLOR | ✅ 有 | 低 | 待实现 |
| GSETBRUSH | ✅ 有 | 低 | 待实现 |
| GSETPEN | ✅ 有 | 低 | 待实现 |
| GCREATED | ✅ 有 | 低 | 待实现 |
| GWIDTH | ✅ 有 | 低 | 待实现 |
| GHEIGHT | ✅ 有 | 低 | 待实现 |
| GGETCOLOR | ✅ 有 | 低 | 待实现 |

#### 4.2 Sprite对象函数
| 函数 | 原项目 | 优先级 | 状态 |
|------|--------|--------|------|
| SPRITECREATE | ✅ 有 | 低 | 待实现 |
| SPRITEDISPOSE | ✅ 有 | 低 | 待实现 |
| SPRITECREATED | ✅ 有 | 低 | 待实现 |
| SPRITEWIDTH | ✅ 有 | 低 | 待实现 |
| SPRITEHEIGHT | ✅ 有 | 低 | 待实现 |
| SPRITEMOVE | ✅ 有 | 低 | 待实现 |
| SPRITESETPOS | ✅ 有 | 低 | 待实现 |
| SPRITEPOSX | ✅ 有 | 低 | 待实现 |
| SPRITEPOSY | ✅ 有 | 低 | 待实现 |
| SPRITEGETCOLOR | ✅ 有 | 低 | 待实现 |

#### 4.3 CBG系列函数 (画布操作)
| 函数 | 原项目 | 优先级 | 状态 |
|------|--------|--------|------|
| CBGSETG | ✅ 有 | 低 | 待实现 |
| CBGSETSPRITE | ✅ 有 | 低 | 待实现 |
| CBGCLEAR | ✅ 有 | 低 | 待实现 |
| CBGCLEARBUTTON | ✅ 有 | 低 | 待实现 |
| CBGREMOVERANGE | ✅ 有 | 低 | 待实现 |
| CBGREMOVEBMAP | ✅ 有 | 低 | 待实现 |
| CBGSETBMAPG | ✅ 有 | 低 | 待实现 |
| CBGSETBUTTONSPRITE | ✅ 有 | 低 | 待实现 |

#### 4.4 动画和高级图形
| 函数 | 原项目 | 优先级 | 状态 |
|------|--------|--------|------|
| GDRAWG | ✅ 有 | 低 | 待实现 |
| GDRAWGWITHMASK | ✅ 有 | 低 | 待实现 |
| GSAVE | ✅ 有 | 低 | 待实现 |
| GLOAD | ✅ 有 | 低 | 待实现 |
| SPRITEANIMECREATE | ✅ 有 | 低 | 待实现 |
| SPRITEANIMEADDFRAME | ✅ 有 | 低 | 待实现 |
| SETANIMETIMER | ✅ 有 | 低 | 待实现 |

---

### 阶段 5: 我们的扩展功能 (Week 6)

#### 5.1 音频系统 (新增)
| 命令 | 描述 | 优先级 | 状态 |
|------|------|--------|------|
| PLAYBGM | 播放背景音乐 | 高 | 计划中 |
| STOPBGM | 停止背景音乐 | 高 | 计划中 |
| PLAYSE | 播放音效 | 高 | 计划中 |
| STOPSE | 停止音效 | 高 | 计划中 |
| PLAYVOICE | 播放语音 | 中 | 计划中 |
| VOLUME | 音量控制 | 中 | 计划中 |
| FADEBGM | 淡入淡出 | 低 | 计划中 |

#### 5.2 高级图形 (新增)
| 命令 | 描述 | 优先级 | 状态 |
|------|------|--------|------|
| DRAWSPRITE | 绘制精灵 | 高 | ✅ 已完成 |
| DRAWRECT | 绘制矩形 | 高 | ✅ 已完成 |
| FILLRECT | 填充矩形 | 高 | ✅ 已完成 |
| DRAWCIRCLE | 绘制圆形 | 中 | ✅ 已完成 |
| FILLCIRCLE | 填充圆形 | 中 | ✅ 已完成 |
| DRAWLINEEX | 高级线条 | 中 | ✅ 已完成 |
| DRAWGRADIENT | 渐变填充 | 低 | ✅ 已完成 |
| SETBRUSH | 设置画笔 | 中 | ✅ 已完成 |
| CLEARSCREEN | 清屏 | 高 | ✅ 已完成 |
| SETBACKGROUNDCOLOR | 背景颜色 | 高 | ✅ 已完成 |

---

## 📈 统计和进度

### 原项目功能统计
- **总命令**: 266个
- **已实现**: ~100个
- **缺失**: ~166个
- **完成度**: ~38%

### 修正后的Priority 4计划
- **阶段1**: 补齐打印命令 (~25个) - Week 1-2
- **阶段2**: 补齐系统函数 (~20个) - Week 3
- **阶段3**: 高级打印命令 (~30个) - Week 4
- **阶段4**: 图形对象系统 (~30个) - Week 5 (可选)
- **阶段5**: 我们的扩展 (17个) - 已完成/计划中

### 优先级建议
1. **必须完成** (Week 1-3): 阶段1 + 阶段2
   - 约45个命令/函数
   - 覆盖原项目核心功能

2. **推荐完成** (Week 4): 阶段3
   - 约30个命令/函数
   - 增强打印功能

3. **可选完成** (Week 5+): 阶段4
   - 约30个命令/函数
   - 图形对象系统（复杂但强大）

4. **保持扩展** (已完成): 阶段5
   - 音频和高级图形
   - 这是我们的特色功能

---

## 🎯 最终建议

### 立即行动 (Week 1-2)
1. **添加PRINT_IMG, PRINT_RECT, PRINT_SPACE** - 原项目有
2. **添加K/D模式打印基础** - PRINTK, PRINTD
3. **添加字体命令** - SETFONT, FONTBOLD等
4. **添加CLEARTEXTBOX** - 原项目有

### 短期计划 (Week 3-4)
5. **完善K/D模式** - 所有变体
6. **添加系统函数** - GETKEY, MOUSEX/MOUSEY等
7. **添加调试命令** - DEBUGPRINT, ASSERT

### 中期计划 (Week 5+)
8. **添加HTML命令** - HTML_PRINT等
9. **添加高级打印** - PRINTSINGLE, PRINTBUTTON
10. **图形对象系统** - G系列函数（可选）

### 保持功能
- ✅ 音频系统 (我们的扩展)
- ✅ 高级图形 (我们的扩展)

---

## 📝 总结

**当前状态**:
- Priority 4 图形部分: 20% 完成
- 对比原项目: 38% 完成
- 需要新增: ~166个命令/函数

**修正后的计划**:
- 优先补齐原项目功能 (保持兼容性)
- 保留我们的扩展 (音频、高级图形)
- 分阶段实施，避免过度开发

**预计时间**:
- 核心补齐: 3-4周
- 完整实现: 6-8周

---

**文档版本**: v2.0 (修正版)
**创建日期**: 2025-12-26
**基于**: 原项目对比分析
