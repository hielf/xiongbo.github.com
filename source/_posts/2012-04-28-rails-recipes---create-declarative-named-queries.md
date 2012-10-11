---
layout: post
title: "Rails Recipes --创建自我表达的命名查询"
description: "创建自我表达的命名查询"
categories: [reading-notes,Rails-Recipes]
tags: rails-recipes
---


### 问题
对于需要筛选数据的情况，经常会出现在控制器中定义查询方法的方式，代码如下：

	class WombatsController < ApplicationController
		def search
			@wombats = Wombat.where( "bio like ?", "%#{params[:q]} %").
				order(:age)
			render :index
		end
	end

但是这种方式是不好的，因为它将业务逻辑放在了控制器中，增加了耦合度，而我们往往应该在模型中对业务进行封装，那么有什么好的方法呢？

### 解决方法
先看一般的解决方式：

	class Wombat < ActiveRecord::Base
		def self.with_bio_containing(query)
			where( "bio like ?", "%#{query} %").
			order(:age)
		end
	end

通过将对数据的访问逻辑放在模型中，那么我们可以采用`@wombats=Wombat.with_bio_containing(params[:q])`这种调用类方法方式返回需要的数据，而不用了解具体的实现机制。

接下来，我们可以采用'scope'方法进行更好的封装，先看个简单的例子：

	class Person < ActiveRecord::Base
		scope :teenagers, where( "age < 20 AND age > 12" )
		scope :by_name, order(:name)
	end

这里我们通过_scope_对查询和排序条件进行了命名，于是可以采用`Person.teenagers.count`的方式返回查询条件内的数量，更进一步，可以采用`Person.teenagers.by_name.map &:name`这种链式调用的方式返回按名字排序的人员数组。

最后，回看第一个列子，如何在这种方式中使用动态查询呢？代码如下：

	class Wombat < ActiveRecord::Base
		scope :with_bio_containing, lambda {|query| where( "bio like ?", "% #{query} %").order(:age) }
	end

我们在scope中引入了lambda对象，这样，我们就能通过代码块的方式动态的获取查询条件了。值得一提的是：`Person.teenagers`返回的并不是一组序列，而是返回的_ActiveRecord::Relation_的实例，这可以通过`Person.teenagers.to_sql`返回的是一段sql查询代码看出来，具体的查询代码如下：

	select "people".* from "people" where (age<20 and age>12)
