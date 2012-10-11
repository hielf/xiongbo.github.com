---
layout: post
title: "基于mongodb的自定义表单实现思考"
categories: project
tags: [mongodb,mongoid]
---


#### 如何通过mongoid构建表单的数据结构

通过mongoid提供的继承行为，可以有效的表现表单的字段，我的想法如下，这样各类字段不仅能作为XboForm的嵌入文档，同时也可以满足不同字段的个性化信息，如果不使用继承，就只能在模型中包括所有可能的字段属性

{% codeblock lang:ruby %} 
class XboField
  include Mongoid::Document
  include Mongoid::Timestamps 
  field :name
  field :label
  field :help_text
  field :required, type: Boolean
  field :type
  validates_presence_of :name 
  embedded_in :xbo_form 
end

class XboString < XboField
  field :max_length, type: Integer
end

class XboEmail < XboField
end

class XboSelect < XboField
end

class XboTextarea < XboField
  field :word_limit, type: Integer
end
{% endcodeblock %}

#### 编辑表单字段的时候，如何表示不同的表单字段呢？

可以通过rails中的fields_for在同一个提交表单中表现不同的字段项，需要注意的是由于各个字段作为内嵌文档是以数组的形式保存的，不能采用形如rails guide中的a_from.b_fields.text_field形式，而是要先通过build方法生成实例，再进行使用，以email字段为例：

{% codeblock lang:ruby %}    
<% xbo_email = @xbo_form.xbo_fields.build({},XboEmail) %>
<%= form_for @xbo_form, url: xbo_forms_path do |f| %>
  <%= f.label '名称' %>
  <%= f.text_field :name %>

  <%= fields_for xbo_email do |xbo_email| %>
    <%= xbo_email.label '字段名称：' %>
    <%= xbo_email.text_field :name %>
    <%= xbo_email.label '字段标签：' %>
    <%= xbo_email.text_field :label %>
  <% end %> 
<% end %>
{% endcodeblock %}

这样，当提交表单的时候，就会产生形如以下的参数形式：

{% codeblock lang:json %}
{
  id:xxxxxxx,
  name:"zzzz",
  XboEmail:{
      _type: "XboEmail",
      name: "xxxxx"
      label: "yyyyyy"
    }  
}
{% endcodeblock %}

当对表单项进行保存的时候，可以通过\_type属性，判断当前的字段类别，从而进行保存。

但是这种设计其实是有问题的，不能因为字段在物理形式上是通过内嵌文档的方式保存在表单的集合中，就把对字段属性的修改也放在了表单的控制逻辑中。正确的方式应该是采用xbo_fields的控制器进行处理。可以采用如下的方式对field设置更明确的控制器。

{% codeblock lang:ruby %}
resources :xbo_forms do
  resources :xbo_fields, controller: "xbo_form_xbo_fields"
end
{% endcodeblock %}

***************

*2012-7-12更新*

#### 表单模板 

因为在进行表单设计的时候，表单项往往是动态生成的。并且，每个表单字段所包含的属性都不尽相同。所以应该针对不同的字段，设计不同的表单模板，以下拉菜单为例:

{% codeblock lang:ruby %}
------—_xbo_dropdown.html.erb----------

<h4>下拉菜单字段类型</h4>

<%= form_for field, url: xbo_form_xbo_field_path(xbo_form, field), remote: true, method: "put" do |xbo_dropdown| %>
  <%= xbo_dropdown.label '字段名称：' %>
  <%= xbo_dropdown.text_field :name %>
  <%= xbo_dropdown.label '字段标签：' %>
  <%= xbo_dropdown.text_field :label %>
  <%= xbo_dropdown.label '提示文字：' %>
  <%= xbo_dropdown.text_field :help_text %>
  <%= xbo_dropdown.label '下拉参数列表' %>

  <%= select_tag :item_list_temp, options_for_select(field.item_list), prompt: '-----请选择----', id: "select_items" %>
  <%= xbo_dropdown.hidden_field :item_list %>

  <%= link_to '编辑参数', "#", id: "edit_dropdown_arg", title: "点击编辑下拉菜单参数" %>

  <%= xbo_dropdown.submit "保存", class: "btn btn-primary", disable_with: "保存中..." %>
  <%= link_to '删除', xbo_form_xbo_field_path(xbo_form, field), confirm: '确定删除该表单字段吗？', method: :delete, remote: true %>
<% end %> 
//下拉菜单参数操作
<div class="modal hide" id="arg_add">
  <div class="modal-header">
    <button type="button" class="close" data-dismiss="modal">×</button>
    <h3>定义下拉菜单选项参数</h3>
  </div>

  <div class="modal-body">
  <div>
    <input type="text" id="dropdown_text" class="input-small" placeholder="参数文字"></input>
    <input type="text" id="dropdown_value" class="input-small" placeholder="参数值"></input>
    <input type="button" id="add_arg" class="btn btn-info" value="添加"></input>
  </div> 
  <div>
    <table id="arg_list" class="table table-striped">
      <tr class="nodrop nodrag"><th>参数名称</th><th>参数值</th><th>编辑</th><th>删除</th></tr>
    </table>

  </div>
  <div class="modal-footer">
    <a href="#" class="btn" data-dismiss="modal">关闭</a>
    <a href="#" id="add_to_dropdown" class="btn btn-primary" data-dismiss="modal">保存参数</a>
  </div>
</div>

<script type="text/javascript" charset="utf-8">

$('#edit_dropdown_arg').tooltip({delay: {show: 500, hide: 100}}).click(function(){ 
    $('#arg_add').modal({
      backdrop: true
    });
    $('#arg_list').tableDnD();
    $('#add_to_dropdown').click(function(){
      insert_into_select_items();
    });
  });

$('#add_arg').click(function(){
  var item_text = $('#dropdown_text').val()
  var item_value = $('#dropdown_value').val()
  $('#arg_list').append("<tr class='arg'><td>" + item_text + "</td><td>" + item_value + "</td><td><a href='#'>编辑</a></td><td><a href='#'>删除</a></td></tr>");
  $('#arg_list').tableDnD(); 

  });

function insert_into_select_items()
{
  var item_list = [];
  var item_arrays = [];

  $('#arg_list tr[class=arg]').each(function(){
        //item_list.push([$(this).children().eq(0).html(),$(this).children().eq(1).html()]);
      var _item = {"text": $(this).children().eq(0).html(), "value": $(this).children().eq(1).html()};
      item_list.push(_item);
      });

  $.each(item_list,function(num,item){
      $("#select_items").append("<option value='" + item['value'] + "'>" + item['text'] + "</option>");
      //var _item_array = new Array(item['text'], item['value'] + ";");
      item_arrays.push(item['text'] + "_" + item['value']);
      })

  $("#xbo_dropdown_item_list").val(item_arrays);
}

</script>
{% endcodeblock %}

我们在表单项的模板中，不仅可以设计表单的特有样式，还可以嵌入表单项的特有属性的操作，当需要增加新的类型的表单项的时候，只需要设计新的表单项模板即可。

#### 填写表单

由于每一类的表单字段都是动态的，因此不可能针对每类表单就生成对应的数据表。我采用的方式是将所有的表单数据都放在表单数据集合中(xbo_submissions)，根据不同的表单ID，读取不同的表单数据。而每一条表单数据的内容是以Hash的形式保存的。如下所示：

{% codeblock lang:ruby %}
class XboSubmission
  include Mongoid::Document
  
  field :name, type: String
  field :content, type: Hash

  belongs_to :xbo_form
end
{% endcodeblock %}

因为mongodb本身就是文档型的数据库，所以保存在单一的文档中应该不是问题。同时，通过对"xbo_form_id"进行索引，也应该能有效的解决查询的问题。以下是提交数据的表单：

{% codeblock lang:ruby %}
<%= form_for @xbo_submission, url: xbo_form_xbo_submissions_path(@xbo_form) do |f| %>
  <%= f.hidden_field :name, placeholder: @xbo_form.name %>
  <%= f.fields_for :content do |con| %>
    <% @xbo_form.xbo_fields.each do |field| %>
      <% case field._type %>
      <% when "XboString" %>
        <%= con.label field.label %>
        <%= con.text_field field.name %>
      <% when "XboDropdown" %>
        <%= con.label field.label %>
        <%= con.select field.name, options_for_select(field.item_list), prompt: "---请选择---" %>
      <% when "XboEmail" %>
        <%= con.label field.label %> 
        <div class='input-prepend'><span class='add-on'><i class='icon-envelope'></i></span><%= con.text_field field.name %></div> 
      <% end %>
    <% end %>
  <% end %>

  <div>
    <%= f.submit '提交', class: "btn btn-primary" %>
    <%= link_to '返回', xbo_form_xbo_submissions_path(@xbo_form) %>
  </div>
<% end %>
{% endcodeblock %}

