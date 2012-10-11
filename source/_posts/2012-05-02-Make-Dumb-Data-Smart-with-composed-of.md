---
layout: post
title: "Rails Recipes --通过composed_of构建结构化数据"
description: "通过composed_of方法构建结构化数据"
categories: [reading-notes,Rails-Recipes]
tags: rails-recipes
---

### 问题

如何对数据进行结构化封装，从而可以使用面向对象的方式进行访问呢？采用compose_of()方法可以解决这个问题！

### 解决方法

假设现在有一个课程分数模型CourseRecord，其中有一个表示该课程分数的字段：letter_grade，该模型的表示如下：

	class CourseRecord < ActiveRecord::Base
		composed_of :grade,
				class_name: 'Grade', 
				mapping: %w(letter_grade letter_grade)
	end

这里的grade表示封装的属性名称，并通过mapping属性将letter_grade字段与稍后提到的Grade模型中的letter_grade字段进行映射。这里的class_name属性是可选的，它表示对应的封装模型名称，如果不指定，则默认为属性封装名称，即grade。下面是Grade的模型表示：

	class Grade
		include Comparable
		attr_accessor :letter_grade
		SORT_ORDER = ["f" , "d" , "c" , "b" , "a" ].inject({}) {|h, letter| 
		h.update "#{letter}-" => h.size
		h.update letter => h.size
		h.update "#{letter}+" => h.size
		}
		def initialize(letter_grade)
			@letter_grade = letter_grade
		end
		def <=>(other)
			SORT_ORDER[letter_grade.downcase] <=>
			SORT_ORDER[other.letter_grade.downcase]
		end
	end

通过这种方式，我们就可以对属性进行个性化的封装。然后我们就能采用如下的方式进行比较：

	>> Grade.new("a-") < Grade.new("a+") # => true

其中Comparable mixin用于类中的对象间的排序。并且，这个类必须定义<=>操作符，用于确定对象间如何进行比较，根据是否小于，等于 或大于这个其它对象来决定返回值-1、0、1。

值得一提的是想要通过`course.grade.letter_grade = "f"; course.save`的方式对对象的值进行修改的话，是行不通的。而必须采用`course.grade = Grade.new("f"); course.save`的方式才行。

特别有用的是，不仅仅是单一的字段，还可以对多个字段进行封装，比如在逻辑上应该属于一类的字段*street, city, state, country*，可以通过如下的方式封装到address对象中。

	class Person < ActiveRecord::Base
		composed_of :address, :mapping => [ %w(address_street street),
			%w(address_city city),
			%w(address_state state) ,
			%w(address_country country) ]
	end 
