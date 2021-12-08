
## 本地Ubuntu一键编译脚本,全程无脑操作,只要梯子质量过关就好了

- ### 说明：
- 《[Telegram聊天吹水群](https://t.me/heiheiheio)》- 《[Telegram中文设置方法](https://github.com/danshui-git/shuoming/blob/master/tele.md)》
- 此一键编译脚本基本同步我的《[云编译脚本](https://github.com/281677160/build-actions)》，包含常用插件
- github已筑墙,所以国内用户编译全程都需要梯子,请自备好梯子,使用大陆白名单或全局模式
- 请使用 Ubuntu 18.04 LTS 或 Ubuntu 20.04 LTS
- 编译openwrt两个常用的工具下载地址《[PuTTY(SSH)工具](https://github.com/danshui-git/shuoming/blob/master/Putty%E5%B7%A5%E5%85%B7%E4%B8%8B%E8%BD%BD.md)》《[WinSCP文件管理](https://github.com/danshui-git/shuoming/blob/master/WinSCP.md)》
- 使用非root用户登录您的ubuntu系统,执行以下代码即可:

---
- 为防止个别系统没安装curl，使用一键编译命令之前选执行一次安装curl命令:
```sh
sudo apt-get update && sudo apt-get install -y curl
```

---
- 一键编译openwrt命令:
```sh
bash <(curl -fsSL git.io/local.sh)
```
---

- windons子系统专用一键编译openwrt命令:
```
bash <(curl -fsSL git.io/wsl.sh)
```
---

问：进入一键本地编译系统后叫我选择编译源码，我该任何选择？<br />
答：我[这里](https://github.com/danshui-git/shuoming/blob/master/%E7%AE%80%E5%8D%95%E4%BB%8B%E7%BB%8D%E6%96%B0%E8%84%9A%E6%9C%AC.md)作了简单介绍，当然本地编译是不支持自建文件夹来增加机型的，云编译你们拉取了我仓库后可以随便自建。<br />
#

问：“请在/home/dan/OP_DIY/xxx_source里面设置好自定义文件”是什么意思？<br />
答：OP_DIY文件跟openwrt文件是同一个目录里面的，根据提示进入xxx_source源码文件夹里面设置好里面的自定义文件跟配置文件，以后每次编译都读取里面的文件内容为主的，包括配置文件，如果你编译的时候有更改配置的话，编译完成后记得根据提示去更新配置文件。<br />
#

问：询问我是否需要选择机型和增删插件，是什么意思？<br />
答：在我设置里面每个源码默认编译都是x86-64的机型固件，不适合所有人的，这个就是进入设置界面，如果你有设置需要就输入‘大小写的Y都可以，按回车确认’，等脚本运行到此步骤就自动弹出窗口（SSH窗口不能太小，太小的话会弹不出设置窗口，以截图分辨率来计算吧，起码要达到650*400），如果不需要就直接按回车就跳过了，《[youtube大神的固件配置视频教程](https://www.youtube.com/watch?v=jEE_J6-4E3Y)》视频跟不上源码的节奏的，你也不能按视频操作，就看看在那里修改机型，那里增加减少插件，增加主题就好了。
#

问：询问我是否把定时更新插件编译进固件，是什么意思？<br />
答：这个在本地编译增加就是个娱乐的，因为我云编译程序是会自动把固件传送到指定位置，安装好固件后就能检测了，本地编译想用的话，只能编译好又手动传到指定位置，就给闲的蛋痛的人玩的，怎么在本地编译又能自动传github的指定位置，这个我不会啊，有懂的可以把代码贡献一下的，谢谢！
#

问：再次编译的时候询问我是否更换源码，是什么意思？<br />
答：就字面上的意思，比如你首次编译的时候选择的是Lede_source源码，你玩腻了，想换其他源码编译就可以换呗。
#

问：使用什么梯子编译比较好？<br />
答：这个我真没啥好建议啊，我就说说我测试用的几个机场为例吧。<br />

<1> 第一个机场18元一个月，此机场看4K，打开网页都杠杠的，速度很快，但是用来编译的时候只有50%概率能成功，因为下载DL步骤很经常下载不完整，在这个步骤下载不完整就不需要进行编译了，DL下载不完整会自动退出编译程序。<br />

<2> 第二个机场9元一个月的，这个机场100%编译不成功，下载源码都经常下载不了，别说下载DL的时候了，100%下载不完整。<br />

<3> 第三个机场6.66元买的一个月，这个机场可以编译成功，就是下载DL的时候需要30分钟时间，太久了，下载源码也慢，所以我去买了第四个机场，这个机场第三天回来看看的时候居然跑路了，握草。<br />

<4> 第四个机场2.99元买的一个月，这个机场99%编译成功，下载速度快，用着舒服，虽然限速150M，量也才50G，我用这机场测试了3天，量就用完了，所以本地编译也需要很大成本滴。<br />

<5> 第四个机场4.99元买的一个月，这个机场很诡异的，下载源码的时候经常少文件夹的，比如源码里面一起是10个文件夹它经常就下到5-6个，下载我插件包的时候也是这样，下载不完整，不是少这就是少那的，用这个机场来搞本地编译你会疯的，因为我做了判断下载错误就停止，但是这个机场节点下载文件是少了，判断又判断他是成功下载了，所以你会误认为你机场节点很好，但是一编译就100%错误的，呵呵。<br />

<6> 还有一些机场节点有问题，显示编译成功，但是又没固件的。<br />

<7> 本人前后差不多用了10个机场来测试本地编译，真正可以舒服编译的只有2个，所以我真不推荐本地编译，云编译多省事。<br />
#
#
#
---
#
- <img src="https://github.com/danshui-git/shuoming/blob/master/doc/bendi5.png" />
#
- <img src="https://github.com/danshui-git/shuoming/blob/master/doc/bendi1.png" />
#
- <img src="https://github.com/danshui-git/shuoming/blob/master/doc/bendi2.png" />
#
- <img src="https://github.com/danshui-git/shuoming/blob/master/doc/bendi3.png" />
#
- <img src="https://github.com/danshui-git/shuoming/blob/master/doc/bendi4.png" />
---
#
- # 捐赠
- 如果你觉得此项目对你有帮助，请请我喝一杯82年的凉白开，感谢！

-微信-
# <img src="https://github.com/danshui-git/shuoming/blob/master/doc/weixin4.png" />
