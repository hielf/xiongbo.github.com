---
layout: post
title: "Rails Recipes --创建有意义的多对多对象关系"
categories: [reading-notes,Rails-Recipes]
tags: rails-recipes
---

### 问题
有时候对于领域内的一些对象间关系，往往比一般的多对多关系要丰富的多。比如*杂志*和*读者*之间：除了象我们通常所想的一本杂志可以有多个读者以及一个读者可以阅读多本杂志这种关系外，还经常存在某些业务规则，比如读者可以包括普通购买读者，订阅读者等，而杂志的订阅又可能包含全年制、半年制、季度等。那么，如何在两个对象间描述这种业务关系呢？

### 解决办法

* 普通情况下，我们可以通过表名的约定来定义多对多的管理，例如：

	create_table :magazines do |t|
		t.string :title
	end

	create_table :readers do |t|
		t.string :name
	end

	create_table :magazines_readers, id: false do |t|
		t.integer :magazine_id
		t.integer :reader_id
	end

如此，我们就可以通过如下方式进行对象间的访问：

	magazine = Magazine.create(title: "the ruby language journal")
	matz = Reader.find_by_name("Matz")
	magazine.readers << matz
	matz.magazines.size # => 1

然而，当我们需要描述订阅者这种对象关系时，以上的方式就不是那么适合了。我们可以采用下面的方式：

* 将读者与杂志间的关系抽象成一个模型，并用该模型链接读者与杂志

	def self.up
		drop_table :magazines_readers
		create_table :subscriptions do |t|
		t.column :reader_id, :integer
		t.column :magazine_id, :integer
		t.column :last_renewal_on, :date
		t.column :length_in_issues, :integer
		end
	end

然后，手动的在各模型间添加对应关系：

	class Subscription < ActiveRecord::Base
		belongs_to :reader
		belongs_to :magazine
	end
	
	class Reader < ActiveRecord::Base
		has_many :subscriptions
		has_many :magazines, :through => :subscription
	end
	
	class Magazine < ActiveRecord::Base
		has_many :subscriptions
		has_many :readers, :through => :subscriptions
	end

这样，我们就可以通过和上面一样的方式在两者间进行访问。而当我们需要描述订阅规则的时候，我们可以采用如下的方式：

	class Magazine < ActiveRecord::Base
		has_many :subscriptions
		has_many :readers, :through => :subscriptions
		has_many :semiannual_subscribers,
		:through => :subscriptions,
		:source => :reader, # 通过source属性约定对象的类型
		:conditions => ['length_in_issues = 6'] # 通过conditions约定对象的生成规则
	end

而当我们需要访问的时候，我们就可以通过`Magazine.first.semiannual_subscribers`的方式进行访问了。
