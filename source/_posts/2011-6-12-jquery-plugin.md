---
layout: post
title: "如何编写jquery插件"
category: translate
tags: plugin
---

译自（<http://tutorialzine.com/2011/02/converting-jquery-code-plugin/>） 

demo见这里（<http://demo.tutorialzine.com/2011/02/converting-jquery-code-plugin/>） 

下载见这里（<http://demo.tutorialzine.com/2011/02/converting-jquery-code-plugin/jquery.tzSelect.zip>） 

当谈到有效的组织jquery代码，最好的选择是将其中的核心部分转换成插件。这样做有很多的益处：你的代码变得更容易修改和跟踪，重复性的任务也更容易处理。通过插件的形式组织代码重用能提高你的开发速度。 这就是为什么我们今天要来展示如何包装一个jQuery插件的原因。我们将使用使用jquery和css3美化的你的下拉菜单中的代码，并将它包装成一个随时可用的jQuery插件。 

###想法 

写一个jquery一点也不难。你需要通过自己的函数扩展$.fn对象。不管如何，难点是采用正确的方法去组织你的代码，以便你的插件能够容易的嵌入和使用。 

下面就是我们在转换代码为插件的过程中需要解决的问题： 
* 1.我们需要让用户能够控制下拉菜单中生成什么样的标记。比如例子中的代码就很大程度上依赖数据属性（包含html标记）的存在。这对于插件而言太具体，所以在实施的过程中，我们要将其排除。 
* 2.因为插件被调用的方式，我们需要重写代码，通过使用“this”对象替换选择器硬编码方式。这也能够使它一次转换多个select元素。 
* 3.我们需要将从插件中提取出javascript和css代码分解成文件，以便容易的嵌入和发布。 代码 不知你还记不记得，在上一篇课程中，jQuery代码遍历了下拉菜单的所有选项，并创建了一个无序列表。同时，也通过option的data属性，得到图片的url和描述，并插入到列表中。 

不过这些对于插件来说还是太具体了。我们需要给用户提供重写这个功能的能力。为了解决这个问题，我们可以允许用户通过传参数的方式将方法传递给插件，用来替代生成的标记。如果这个“方法参数”无法使用，我们将采取默认的方法——只是将option的文字提取出来，插入到列表中。 让我们看看代码如何实现：

	(function($){

	$.fn.tzSelect = function(options){
		options = $.extend({
			render : function(option){
				return $('<li>',{
					html : option.text()
				});
			},
			className : ''
		},options);

	// More code will be added here.

	}
	})(jQuery);

render方法获取一个option参数，返回一个li元素，并直接包含在下拉列表中。这便可以解决上面的第一个问题。关于extend的详细用法可以参考这里。

![p1](http://cdn.tutorialzine.com/wp-content/uploads/2011/02/jquery-css3-select-replacement-plugin.jpg)

在我们准备解决第2个问题前，让我们看看插件如何调用：

	$(document).ready(function(){  $('select').tzSelect(); });

从上面的示例中可以发现，我们为页面上的每一个select元素都调用了插件。我们可以使用“this”关键字来使用这些元素。

	return this.each(function(){

		// The "this" points to the current select element:

		var select = $(this);

		var selectBoxContainer = $('<div>',{
			width		: select.outerWidth(),
			className	: 'tzSelect',
			html		: '<div class="selectBox"></div>'
		});

		var dropDown = $('<ul>',{className:'dropDown'});
		var selectBox = selectBoxContainer.find('.selectBox');

		// Looping though the options of the original select element

		if(options.className){
			dropDown.addClass(options.className);
		}

		select.find('option').each(function(i){
			var option = $(this);

			if(i==select.attr('selectedIndex')){
				selectBox.html(option.text());
			}

			// As of jQuery 1.4.3 we can access HTML5
			// data attributes with the data() method.

			if(option.data('skip')){
				return true;
			}

			// Creating a dropdown item according to the
			// data-icon and data-html-text HTML5 attributes:

			var li = options.render(option);

			li.click(function(){

				selectBox.html(option.text());
				dropDown.trigger('hide');

				// When a click occurs, we are also reflecting
				// the change on the original select element:
				select.val(option.val());

				return false;
			});

			dropDown.append(li);
		});

		selectBoxContainer.append(dropDown.hide());
		select.hide().after(selectBoxContainer);

		// Binding custom show and hide events on the dropDown:

		dropDown.bind('show',function(){

			if(dropDown.is(':animated')){
				return false;
			}

			selectBox.addClass('expanded');
			dropDown.slideDown();

		}).bind('hide',function(){

			if(dropDown.is(':animated')){
				return false;
			}

			selectBox.removeClass('expanded');
			dropDown.slideUp();

		}).bind('toggle',function(){
			if(selectBox.hasClass('expanded')){
				dropDown.trigger('hide');
			}
			else dropDown.trigger('show');
		});

		selectBox.click(function(){
			dropDown.trigger('toggle');
			return false;
		});

		// If we click anywhere on the page, while the
		// dropdown is shown, it is going to be hidden:

		$(document).click(function(){
			dropDown.trigger('hide');
		});

	});
以上的代码基本就是今天需要转换的内容了~

其中一个重要的改变就是我们将`$(this)`赋给了select变量，而不是像过去一样使用硬编码`（$('select.makeMeFancy')）`的方式，那样会限制代码的使用范围。 

其他的改变就是我们采用传参的方式调用render方法来生成下来菜单的内容。将上面的代码联合起来，就是插件的完整内容了。 将这个插件代码放在一个单独的文件中用于解决第三个问题。但是，就像我前面提到的，我有意的将获取data属性值的代码移除了，以便使我们的插件更加轻便。对应的，我们必须在调用插件的时候，传递一个定制的输出函数。

	$(document).ready(function(){

	$('select.makeMeFancy').tzSelect({
		render : function(option){
			return $('<li>',{
				html:	'<img src="'+option.data('icon')+'" /><span>'+
						option.data('html-text')+'</span>'
			});
		},
		className : 'hasDetails'
	});

	// Calling the default version of the dropdown
	$('select.regularSelect').tzSelect();

	});
到这里，我们的jQuery插件就完成了。
