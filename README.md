# Rime 个人配置

基于 [雾凇拼音](https://github.com/iDvel/rime-ice) 的精简配置，只保留全拼方案。

## 配置说明

### 个人配置文件

- `default.custom.yaml` - 全局配置（方案列表、快捷键）
- `squirrel.custom.yaml` - macOS 界面配置（字体、透明度、应用设置）
- `custom_phrase.txt` - 自定义短语

### 自定义内容

**快捷键**:
- 逗号句号翻页 (`,` `.`)
- Control+h 退格
- 禁用 Control+Shift+3/4

**界面**:
- 字体: LXGW WenKai Mono
- 透明度: 0.95
- 磨砂效果

**应用设置**:
- Neovide/Ghostty: 默认英文
- QQ: 默认中文

## 维护

### 同步上游词库更新

```bash
git fetch upstream
git merge upstream/main
# 重新部署 Rime
```

### 修改配置

编辑 `*.custom.yaml` 文件，重新部署即可生效。

### 部署

- 菜单栏: 输入法图标 → 部署
- 快捷键: Control+Option+`

## 文件结构

```
.
├── *.custom.yaml          # 个人配置
├── custom_phrase.txt      # 自定义短语
├── cn_dicts/              # 中文词库
├── en_dicts/              # 英文词库
├── lua/                   # Lua 扩展
└── opencc/                # 简繁转换
```

## 上游

- 原项目: [iDvel/rime-ice](https://github.com/iDvel/rime-ice)
- 许可证: GPL-3.0
