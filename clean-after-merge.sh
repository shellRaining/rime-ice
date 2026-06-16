#!/bin/bash
# 合并上游后的清理脚本

cd "$(dirname "$0")"

echo "清理不需要的文件..."

# 删除 Windows 配置
rm -f weasel.yaml go.work

# 删除 iOS 平台配置
rm -rf others/iRime others/Hamster others/双拼补丁示例

# 删除不用的双拼方案
rm -f double_pinyin*.schema.yaml

# 删除开发工具和可选方案
rm -rf others/script others/recipes others/pages others/no_lua_schema

# 删除补丁示例和上游文档变更中不保留的文件
rm -rf others/patch_examples
rm -f others/docs/Changelog.md

# 删除 GitHub 相关
rm -rf .github

# 删除文档图片
rm -f others/demo.webp others/sponsor.webp others/CHANGELOG.md

echo "清理完成！"
echo "如有文件被删除，请运行："
echo "  git add -A"
echo "  git commit -m 'chore: 清理不需要的文件'"
