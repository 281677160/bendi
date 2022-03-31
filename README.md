## 本地Ubuntu一键编译脚本,全程无脑操作,只要梯子质量过关就好了

- ### 说明：
- 《Telegram聊天吹水群》- 《Telegram中文设置方法》
- 此一键编译脚本基本同步我的《云编译脚本》，包含常用插件
- github已筑墙,所以国内用户编译全程都需要梯子,请准备好梯子,使用大陆白名单或全局模式
- 推荐使用 Ubuntu 20.04 LTS （支持windons子系统ubuntu和普通ubuntu）
- 使用非root用户登录您的ubuntu系统,执行以下代码即可:

- 为防止个别系统没安装curl，使用一键编译命令之前选执行一次安装curl命令:
```sh
sudo apt-get update && sudo apt-get install -y curl
```
---
- ubuntu 和 WSL的ubuntu 通用一键编译openwrt命令
```sh
bash <(curl -fsSL git.io/local.sh)
```
