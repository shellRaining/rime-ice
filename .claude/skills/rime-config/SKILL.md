---
name: rime-config
description: Rime 输入法配置管理经验总结。当询问 Rime 配置文件、修改建议、维护方式时使用。
allowed-tools: Read, Grep, Glob, mcp__acp__Read
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

## 清理脚本说明

`clean-after-merge.sh` 用于合并上游后删除不需要的文件：
- Windows 配置（weasel.yaml、go.work）
- iOS 平台配置（others/iRime、others/Hamster）
- 开发工具（others/script、others/recipes）
- GitHub 相关（.github/）
- 文档图片（others/demo.webp、others/sponsor.webp）

每次合并上游后必须运行此脚本
