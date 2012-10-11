---
layout: post
title: "Google App Engine系列：组织你的项目"
category: translate
tags: app-engine
---

在这个系列的第二部分，我们将展示项目的目录结构并创建必须的配置文件。 

目录结构 每一个App Engine应用根目录都必须存在一些配置文件。在我们的例子中是app.yame、index.yaml和cron.yaml。其他的目录结构随意。 清晰起见，“仪表版”应用的目录结构如下：

![p1](http://cdn.tutorialzine.com/wp-content/uploads/2011/02/directory-structure-app-engine-application.jpg)

一些文件夹的用途如下： “assets”包括图片、样式表以及脚本文件； “config”包括一个含有基本配置选项的python文件，内容包括需要获取的url地址、应用的名称等。这个文件是独立于App Engine的yaml文件的； “model”、“view”、“controller”文件夹是按照mvc架构创建的python源文件； 当有新的request请求时，main.py文件是首先被访问的。通过它将各个不同的请求发送到相应的控制器，我们将在下一部分进行讲解。 配置文件 就像你在上一篇中看到的，当发布你自己的“运行时间仪表版”的时候，需要编辑一些文件。这些是App Engine的配置文件，用于定义你的应用语言，标识符以及版本信息。 这些配置信息采用yaml文件格式。这种格式的设计是用来处理一些简单数据的序列化，以及用来表示一些程序语言中通常的数据格式，例如：数字、数组、字符串、数值等等，以便更适合存储配置数据。 

	app.yaml
	application: tutorialzine-dashboard 
	version: 1 
	runtime: python 
	api_version: 1  
	builtins: - 
	datastore_admin: on  
	handlers:  - url: /assets   
	static_dir: assets  - url: /favicon.ico   
	static_files: assets/img/favicon.ico   
	upload: assets/img/favicon.ico  - url: /crons/.*   
	script: main.py   login: admin  - url: /generate-test-data/   
	script: main.py   login: admin  - url: .*   script: main.py

app.yaml是你应用程序主要的配置文件。当你创建新的应用的时候，app engine launcher会自动帮你创建这个文件。你可以从这里了解更多。 头两行包含了应用的标识符和版本。标识符用来指向你在appengine.google.com上创建的应用。App Engine通过版本属性管理应用的多个版本。通过控制面板，你能够随时发布或者很容易的回滚到以前的版本。 builtins指令可以使你在App Engine控制面板中启用数据存储管理，方便检测和删除数据。 最后是handlers，可以通过正则表达式映射到对应的脚本处理程序。你需要通过“static_files”或者“static_dir”指定你的静态文件地址。在上面的代码中可以看到我指定了所有访问dashboard.tutorialzine.com/assets的请求都指向到了assets目录。 你也可以选择性的指定某些地址只有应用管理员能够访问。在上面我使用这个选项指定/ crons / URL只有这个应用程序管理员和cron服务能够访问,以防止有人触发cron脚本。

![p2](http://cdn.tutorialzine.com/wp-content/uploads/2011/02/uptime-dashboard-app-engine.jpg)

	crons.yaml
	- description: Five minute ping   url: /crons/5min/   schedule: every 5 minutes 
	- description: Daily averages   url: /crons/1day/   schedule: every day 00:00

crons.yaml配置了cron服务。上面的代码告知服务每隔5分钟执行一次/crons/5min，每天午夜执行一次/crons/1day/。这些地址通过正则表达式精确的匹配http请求，这意味着即使执行特定地址你也不需要任何特殊的准备（meaning that you do not need any special preparations to execute a certain address from cron）。 index.yaml是由app launcher自动创建的，你可以在里面定义数据存储所需要使用的索引。索引非常重要，因为它可以加快你应用的查询速度，这也是为什么简单查询也会自动创建他们。所幸我们的应用非常简单，不需要修改index.yaml。 这样我们就成功的配置了新的app engine应用了。
