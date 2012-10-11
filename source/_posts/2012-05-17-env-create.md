---
layout: post
title: "linux虚拟机上的rails环境配置"
categories: Project
tags: [coffeescript,npm,rvm]
---


下载LMDE xcfe版的linux，并通过vmware创建虚拟机。

在终端下执行以下命令安装rvm：

	bash < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer )

将以下脚本追加到当前用户主目录下的.bashrc文件:

	[[ -s "$HOME/.rvm/scripts/rvrm" ]] && . "$HOME/.rvm/scripts/rvm"

通过`rvm 1.9.3`安装ruby

安装过程中遇到无法读取zlib和openssl的问题，可以通过以下方式解决：

	rvm pkg install zlib
	rvm pkg install openssl
	rvm remove 1.9.3
	rvm install 1.9.3 -C --with-openssl-dir=$HOME/.rvm/usr,--with-iconv-dir=$HOME/.rvm/usr

通过`gem install rails -v 3.2.3`安装rails

接着又遇到了无法安装sqlite3的问题，可以通过如下的方式解决`apt-get install libsqlite3-dev`

通过以下页面安装node.js<https://gist.github.com/579814>

期间遇到了`Checking for library dl  : not found`的问题，可以通过 `sudo apt-get install libcurl4-openssl-dev`进行解决

通过`node -v`和`npm -v`检查是否安装正确

通过`npm install coffee-script`安装coffeescript
