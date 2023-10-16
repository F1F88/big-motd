# 更大的 MOTD

**文档 :**  [English](./readme.md) | [中文](./readme_CN.md)

**本项目同时托管在 :**  [GitHub](https://github.com/f1f88/big-motd) | [Gitee](https://gitee.com/f1f88/big-motd)

### 作用

当 Motd 仅显示文本文字时，允许显示更多的字数。

### 详细描述

默认情况下，Motd 只能显示 2048 个字符。

此插件能够修改 Motd 的最大字符限制，从而显示更多的字符。

你可以通过修改插件提供的参数 convar - 'sm_big_motd_size' 来修改 Motd 的最大字符数。

![image](./img/Img_231016_211008.png)

注意: 我只在 NMRIH 游戏中测试了可用性，但其他游戏应该也能使用

## 依赖

- [SourceMod 1.11](https://www.sourcemod.net/downloads.php?branch=stable) 或更高

## Installation
- 从 releases 中下载最新的发行压缩包
- 解压下载的压缩包到 `addons/sourcemod` 文件夹中
- 在服务器控制台输入 `sm plugins load big-motd` 加载插件（或者重启服务器）
