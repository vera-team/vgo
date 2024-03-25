#!/bin/bash
set -e


# if ! [[ $TAG =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]; then
#     echo "Invalid tag: $TAG, must be in the form of vMAJOR.MINOR.PATCH,example: v1.0.0"
#     exit 1
# fi

# 检查当前是否为main分支
if [ "$(git rev-parse --abbrev-ref HEAD)" != "master" ]; then
    echo "You must be on the master branch to release"
    exit 1
fi

# 检查是否有未提交的修改
if ! git diff-index --quiet HEAD --; then
    # 如果当前环境为github codespace，检测结果有误，跳过
    if [ -n "$CODESPACES" ]; then
        echo "skip uncommitted changes check in codespace"
    else
        echo "You have uncommitted changes, please commit or stash them"
        exit 1
    fi
fi
# 检查本地与远程是否有同步问题
if ! git diff-index --quiet --cached HEAD --; then
    echo "Your local repository is out of sync with remote, please sync first"
    exit 1
fi

## 获取第一个参数为tag
TAG=$1
if [ -z "$TAG" ]; then
    echo "Usage: $0 <tag>"
    exit 1
fi

# 判断是否是tag
if ! echo "$TAG" | grep -q '^v[0-9]\+\.[0-9]\+\.[0-9]\+$'; then
    echo "Invalid tag: $TAG, must be in the form of vMAJOR.MINOR.PATCH,example: v1.0.0"
    exit 1
fi

# 推送到main
git push origin master
# 创建tag
git tag $TAG
# 提交tag
git push origin $TAG
# 显示最新的tag
git describe --tags --abbrev=0
