---
layout: post
title: "Google App Engine系列：准备"
categories: translate
tags: app-engine
---

（本文译自：<http://tutorialzine.com/2011/01/getting-started-with-google-app-engine/>） 

在第一节中，你将了解这个平台以及如何在平台上开发应用。通过这个系列，我们将通过Python和Jquery创建一个功能齐全的web应用，该应用能够监控你网站的性能，并且记录停机时间（downtime). 什么是Google App Engine App Engine是一个用来提供开发和运行环境的平台。这意味着快速、高可靠性、以及可扩展性。你只需要关心你的代码，并且确信google能够搞定其他的一切：） 并且这项服务还有一点好处，他提供了500万的pv，不过如果超出，你需要为此付一定的费用。 你可以采用java或者python来创建web应用。

在本系列中，我们将采用python2.5。App Engine提供了一些基于数据存储、缓存、进程等的api，你可以在你的项目中使用它们。App Engine 为这些服务提供的每日配额足够我们这个系列应用的使用。 以下的这些资源将帮助你更好的了解这个平台。在开发仪表板的时候，我始终开着它们： App Engine getting started guide App Engine documentation for Python Python tutorial for beginners Python 2.5.2 documentation 准备开始 

第一步：在Google App Engine上注册。如果你已经有帐号了，请登录。 
![p1](http://cdn.tutorialzine.com/wp-content/uploads/2011/01/getting-started-google-appengine.jpg)

第二步，请安装python2.5，并下载App Engine SDK。SDK包括一个和App Engine类似的开发环境，以及一个用于发布应用的程序（App Launcher）。这意味着你可以在你的本地环境中发布web应用，并在适合的时候部署到App Engine。 

![p2](http://cdn.tutorialzine.com/wp-content/uploads/2011/01/app-engine-launcher.jpg)

使用App Launcher你可以随时启动/停止，以及发布你的应用程序。并通过localhost进行访问。 

点击“Run”将启动web服务器，它提供了和App Engine相同的运行环境。

点击“Browse“将在你的默认浏览器中打开你的项目。

“SDK Console”提供数据库的综合管理（即我们的“仪表板”将要存储数据的位置）。

“Deploy”将在Appspot.com上发布并建立你的web应用。 

建立你自己的仪表版 我当然不想直到系列结束你们都一直这样干看着，所以你现在应该马上建立你自己的版本，并且亲身感受一下。以下是你需要做的： 

打开appengine.google.com，创建新的应用。第一次创建的时候，你需要短信确认。然后，你可以为你的应用命名。 下载“仪表版”的源码，并进行解压。 打开“App Launcher，通过“File>Add Existing Application“导入这个应用。 

完成以上的步骤，请用编辑器打开“app.yaml"文件，修改应用标识符（your-application-identifier） application: your-application-identifier version: 1 runtime: python api_version: 接下来，打开"config/config.py"，修改你的应用名称，域名和搜索字符。 scriptTitle = "Your Application Title" fetchURL = "http://domain-to-be-checked.com/" searchString = "WordInThePageText" 搜索字符串必须是你的主页中存在的。比如在“仪表版”的例子中，我使用了“Tutorialzine“，这串字符的存在将告知你的 脚本：页面已经成功获取。（这段话有点不太懂是什么意思） 最后，你点击“Deploy”，就可以将你的应用部署到你的appspot.com的域名下。你可以对你的应用绑定其他的域名。

现在你已经拥有了一个正常运行的“仪表版”，接下来我们将开始实战了！
