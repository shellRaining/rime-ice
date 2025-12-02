---
name: rime-config
description: Rime 输入法配置管理经验总结。当询问 Rime 配置文件、修改建议、维护方式时使用。
---

# Rime 配置管理经验总结

## 核心原则

1. 使用 .custom.yaml 补丁文件，不直接修改原始配置
2. Fork 上游仓库但只保留需要的方案文件
3. 定期同步上游词库更新
4. 用 Git 管理个人配置，忽略运行时数据

## 文件分类

### 可修改（个人配置）

- `*.custom.yaml` - 补丁文件，覆盖原始配置
- `custom_phrase.txt` - 自定义短语（Tab 分隔，非空格）

### 不可修改（上游维护）

- `cn_dicts/`、`en_dicts/` - 词库目录（201MB）
- `*.dict.yaml` - 词典索引
- `*.schema.yaml` - 原始方案定义
- `default.yaml`、`squirrel.yaml` - 原始配置
- `lua/`、`opencc/` - 扩展功能和简繁转换

### 可删除（自动生成）

- `build/` - 编译产物
- `*.userdb/` - 用户词典
- `user.yaml`、`installation.yaml` - 运行时数据

## 补丁文件语法

**default.custom.yaml 示例**：

```yaml
patch:
  schema_list:
    - schema: rime_ice

  "menu/page_size": 7

  "key_binder/bindings/+":
    - { when: paging, accept: comma, send: Page_Up }
```

**squirrel.custom.yaml 示例**：

```yaml
patch:
  app_options:
    com.neovide.neovide:
      ascii_mode: true

  "preset_color_schemes/purity_of_form_custom/font_face": "LXGW WenKai Mono"
  "preset_color_schemes/purity_of_form_custom/alpha": 0.95
```

**rime_ice.custom.yaml 示例**（优化词库和纠错）：

```yaml
patch:
  # 自定义短语：启用补全功能
  custom_phrase/enable_completion: true # 启用前缀匹配补全

  # 拼写纠错：启用 ia/ai 和 ian/ain 纠错
  # 让 xai/jai/qai 可以纠错为 xia/jia/qia，这样 yixai 可以得到"一下"
  # 让 xain/jain/qain 可以纠错为 xian/jian/qian，这样 wofaxain 可以得到"我发现"
  speller/algebra/+:
    - derive/([qjx])ia$/$1ai/ # qai → qia, xai → xia, jai → jia
    - derive/([qtpdjlxbnm])ian$/$1ain/ # xain → xian, jain → jian, qain → qian 等
```

## 维护流程

### 同步上游更新

**完整流程**：

```bash
cd ~/Library/Rime
git fetch upstream
git merge upstream/main
./clean-after-merge.sh  # 清理重新引入的文件
git add -A
git commit -m "chore: 清理不需要的文件"
# 重新部署 Rime
```

**重要**：合并上游时会重新引入已删除的文件（weasel.yaml、.github/、others/iRime 等），必须运行清理脚本

### 部署配置

- 菜单栏：输入法图标 → 部署
- 快捷键：Control+Option+`

### Git 管理策略

**.gitignore 配置**：

```
build/
*.userdb/
user.yaml
installation.yaml
# 注释掉以管理个人配置：
# *.custom.yaml
```

**提交内容**：

- 包含：\*.custom.yaml、custom_phrase.txt、删除的方案文件
- 忽略：build/、\*.userdb/、运行时数据

## 常见问题解决

### 配置不生效

1. 检查 YAML 缩进（空格，非 Tab）
2. 重新部署
3. 查看 build/\*.log

### 合并冲突

- .custom.yaml 文件不会冲突
- 如直接修改原始文件，需手动解决冲突

### 词库更新

- 不修改 cn_dicts/、en_dicts/ 内容
- 直接 git merge 即可获取更新

## Fork vs 自建维护

### 选择 Fork 的理由

1. 词库维护成本极高（50+ 万词条，持续更新）
2. 词库与方案解耦（全拼双拼共用词库）
3. 删除方案文件不影响词库质量
4. 可选择性同步（只同步词库，不同步方案）

### 精简策略

- 删除：不需要的 \*.schema.yaml 文件
- 保留：cn_dicts/、en_dicts/、opencc/、lua/
- 自定义：通过 \*.custom.yaml 管理

## 最佳实践

1. 新建 .custom.yaml 而非直接修改原文件
2. custom_phrase.txt 使用 Tab 分隔（非空格）
3. 定期同步上游词库（每月一次）
4. 修改后必须重新部署
5. 备份 \*.custom.yaml 和 custom_phrase.txt

## 文件优先级

1. \*.custom.yaml（最高）
2. 用户目录的 \*.yaml
3. 共享目录的默认配置

## Instructions

当用户询问 Rime 配置时：

1. 优先推荐使用 .custom.yaml 方式
2. 说明哪些文件不应修改及原因
3. 提供具体的补丁语法示例
4. 提醒重新部署以生效
5. 如用户已直接修改原文件，建议转换为 .custom.yaml

## 经验教训总结

1. .custom.yaml 被 .gitignore 忽略 - 需要注释掉 \*.custom.yaml 规则
2. Git 合并冲突产生临时文件 - 定期清理 _*BACKUP*_、\*.orig 等
3. 词库文件有合并标记 - 说明之前手动编辑过，应避免
4. 直接修改原文件导致更新冲突 - 使用补丁方式避免
5. 文件必须在根目录 - Rime 不支持子目录配置
6. 重新部署是必需的 - 修改配置后不会自动生效
7. 合并上游会重新引入已删除文件 - Git 无法阻止，必须用脚本清理

### 词库管理经验

8. **custom_phrase.txt 去重** - 不要添加已在英文词库中存在的单词
   - 检查方法：`grep "^单词" en_dicts/*.dict.yaml`
   - 英文词库已包含常用单词（go、code、main、Amazon、NASA、Hugo 等）
   - custom_phrase.txt 只应包含：专有名词、中英混合词、特殊缩写、个人信息
   - 如果只是想置顶某个词，应使用 `pin_cand_filter` 而非 custom_phrase.txt

9. **启用补全功能** - custom_phrase 默认不支持前缀匹配
   - 问题：输入 `navi` 无法补全 `navidrome`，必须输入完整才出现
   - 解决：在 rime_ice.custom.yaml 中添加 `custom_phrase/enable_completion: true`
   - 效果：输入前缀即可看到候选（navi/navid/navidr → Navidrome）

10. **拼写纠错规则** - rime_ice.schema.yaml 中部分纠错规则默认被注释
    - 问题 1：输入 `yixai` 想得到"一下"，却出现"胰腺癌"
      - 原因："一下"拼音是 `yi xia`，`xai` 需要纠错为 `xia`
      - 解决：启用 `derive/([qjx])ia$/$1ai/` 规则
    - 问题 2：输入 `wofaxain` 想得到"我发现"，却出现"我发现爱你"
      - 原因："发现"拼音是 `fa xian`，`xain` 需要纠错为 `xian`
      - 解决：启用 `derive/([qtpdjlxbnm])ian$/$1ain/` 规则
    - 配置位置：rime_ice.custom.yaml 的 `speller/algebra/+` 节点
    - 副作用：可能影响全拼简拼混输（如 `x'ai` 喜爱 → `xia` 下），但通常不影响

11. **单字符禁用英文联想** - 单字符输入时过滤英文补全
    - 问题：enable_completion 启用后，输入单字符触发英文联想
    - 错误方案：
      - 设置 min_phrase_length: 2 - 参数不存在
      - 修改 custom_phrase.txt 编码为缩写 - 破坏可读性
      - 禁用 enable_completion - 失去前缀补全
    - 正确方案：Lua 过滤器
      1. 创建调试过滤器，记录候选项类型到 /tmp/rime_debug.log
      2. 分析日志：英文补全类型为 completion，中文为 phrase/user_phrase
      3. 创建 single_char_filter.lua，单字符时过滤 completion 类型
      4. 配置：engine/filters/+: - lua_filter@\*single_char_filter
    - 经验：
      - 先调试验证，不盲目猜测参数
      - Lua 过滤器必须返回含 init() 和 func() 的模块 M
      - 候选项类型通过 cand.type 获取
      - 使用日志文件调试比猜测高效

12. **derive 规则方向理解错误** - 拼写派生规则的正确方向
    - 问题：输入 `itanjia` 想得到"添加"（tianjia），首次尝试写成 `derive/^itan$/tian/` 未生效
    - 原因：**误解了 derive 规则的方向**
      - derive 的语法：`derive/原始拼音/派生拼音/`
      - 含义：允许用户使用"派生拼音"来输入"原始拼音"对应的词
      - 词库中的词条标注的是**原始拼音**（如"添加"标注为 tianjia）
    - 正确理解：
      - `derive/^tian$/itan/` 意思是：将词库中标注为 `tian` 的词，派生出 `itan` 拼写
      - 效果：用户输入 `itanjia` 时，可以匹配到词库中 `tianjia`（添加）的词条
    - 错误理解：
      - `derive/^itan$/tian/` 意思是：将词库中标注为 `itan` 的词，派生出 `tian` 拼写
      - 问题：词库中根本没有标注为 `itan` 的词（因为 itan 不是合法拼音），所以无法派生
    - 验证方法：检查是否为合法拼音组合
      - `itan` 不是合法汉语拼音，词库中不会有这样的标注
      - `tian` 是合法拼音，词库中有大量词条（天、添、田、甜等）
      - 因此应该从 `tian`（存在）派生到 `itan`（不存在但允许输入）
    - 经验总结：
      - derive 规则：`derive/词库中存在的拼音/允许用户输入的拼音/`
      - 方向：从正确 → 错误，从规范 → 容错
      - 其他示例：
        - `derive/^([zcs])h/$1/`：zh/ch/sh（正确）→ z/c/s（容错）
        - `derive/([qjx])ia$/$1ai/`：qia/jia/xia（正确）→ qai/jai/xai（容错）
        - `derive/^tian$/itan/`：tian（正确）→ itan（容错）

## 清理脚本说明

`clean-after-merge.sh` 用于合并上游后删除不需要的文件：

- Windows 配置（weasel.yaml、go.work）
- iOS 平台配置（others/iRime、others/Hamster）
- 开发工具（others/script、others/recipes）
- GitHub 相关（.github/）
- 文档图片（others/demo.webp、others/sponsor.webp）

每次合并上游后必须运行此脚本
