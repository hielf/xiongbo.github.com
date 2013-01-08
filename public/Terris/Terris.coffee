MOVE_STEP = 20
BLOCK_WIDTH = 20
WALL_LEFT = 200

# 背景墙有多少列和多少行
WALL_WIDTH = 15
WALL_HEIGHT = 21

WALL_ROW = [2,2,0,0,0,0,0,0,0,0,0,0,0,0,2,2]
MOVE_LEFT = 'left'
MOVE_RIGHT = 'right'
MOVE_DOWN = 'down'
REMOVE_SCORE = 10

COVER_TYPE = {'TURN': 'TURN', 'MOVE': 'MOVE'}
BACKGROUND_TYPE = {'WALL': 2, 'BLOCK': 1, 'BLANK': 0}
BLOCK_TYPE = {'KBLOCK': [[0,0,0],[0,1,0],[1,1,1]],'LLBLOCK': [[1,0,0],[1,0,0],[1,1,0]],'ZLBLOCK': [[0,1,0],[1,1,0],[1,0,0]], 'ZRBLOCK': [[1,0,0],[1,1,0],[0,1,0]], 'LRBLOCK': [[1,0,0],[1,0,0],[1,1,0]],'OBLOCK': [[1,1],[1,1]], 'SBLOCK': [[0,1,0,0],[0,1,0,0],[0,1,0,0],[0,1,0,0]]}
BLOCK_TYPE_VALUE = ['SBLOCK', 'SBLOCK', 'OBLOCK', 'KBLOCK', 'LLBLOCK', 'ZLBLOCK', 'ZRBLOCK', 'LRBLOCK', 'SBLOCK']

# 背景墙，代表方块能够活动的区域
class Wall
  # 2代表外围的围墙，用于判断方块是否超出了边界
  constructor: (@game)->
    @wall = ((0 for y in [0..WALL_WIDTH]) for x in [0..WALL_HEIGHT])
    for x, i in @wall
      for y, j in x
        @wall[i][j] = BACKGROUND_TYPE.WALL if i is 0 or i is 1 or i is WALL_HEIGHT - 1 or i is WALL_HEIGHT or j is 0 or j is 1 or j is WALL_WIDTH - 1 or j is WALL_WIDTH
  
  wall_draw: ->
    $('#wall_content').html('')
    $('#wall_over').css('display', 'none')
    _wall = "<div id='wall' class='wall'><table cellpadding='0' cellspacing='0'>"
    for x, i in @wall
      _wall +="<tr>"
      for y, j in x
        if y is 1
          _wall += "<td class='wall_block'></td>"
        else if y is 2
          _wall += "<td class='wall_block_fence'></td>"
        else
          _wall += "<td class='wall_block_blank'></td>"
      _wall +="</tr>"
    _wall += "</table></div>"
    $('#wall_content').html(_wall)

  draw_over: ->
    $('#wall_over').css('display', 'block')

  erase: ->
    is_full = false
    remove_rows = 0

    for x, i in @wall
      if is_full is true
        # 移除并插入新行
        @wall.splice(i - 1, 1)
        @wall.splice(2, 0, WALL_ROW)
        is_full = false
        remove_rows += 1
      for y in x
        if (y is 0)
          is_full = false
          break
        else if (y is 2)
          continue
        else if y is 1
          is_full = true

    @game.score_count(remove_rows)

# 方块基类
class Block
  constructor: (@wall) ->
    @block_type = null
    @is_stick = true
    @block = null
    @block_content = $("<div id='block_content' block_type='block_content' class='block_content'></div>")
    @init()
  
  init: ->
    @left = 80
    @top = 40
    @block_type = @generate()
    @block_redraw()
    @block_content.html(@block)
    @block_content.css('left', @left)
    @block_content.css('top', @top)
    $('#wall_content').append(@block_content)
    if @is_cover(@wall.wall, 0, 0, COVER_TYPE.MOVE)
      $('.block_content td').toggleClass("fixed", true)
      @wall.game.game_over()
      return
  
  generate: ->
    block_type_value = BLOCK_TYPE_VALUE[parseInt(Math.random()*9)]
    if block_type_value is 'SBLOCK' then @is_stick = true else @is_stick = false
    BLOCK_TYPE[block_type_value]
  
  move_interval: =>
    setInterval(this.move_down.bind(this), 500)
  
  block_draw: ->
    @block_content.html(@block)
    @block_content

  block_redraw: ->
    @block = this.block_view()

  block_view: ->
    block = "<table cellpadding='0' cellspacing='0'>"
    for x, i in @block_type
      block +="<tr>"
      for y, j in x
        if y is 1 then block += '<td class="block" id="block_' + i + '_' + j + '"></td>' else block += "<td class='block_blank'></td>"
      block +="</tr>"
    block += "</table>"
    block
  
  move_left: ->
    if @bump_test(@wall, MOVE_LEFT)
      @block_content.css('left', @left - MOVE_STEP)
      @left = @left - MOVE_STEP
    
  move_right: ->
    if @bump_test(@wall, MOVE_RIGHT)
      @block_content.css('left', @left + MOVE_STEP)
      @left = @left + MOVE_STEP

  move_down: ->
    if @bump_test(@wall, MOVE_DOWN)
      @block_content.css('top', @top + MOVE_STEP)
      @top = @top + MOVE_STEP
    else
      # 无法往下的时候，则判定当前方块移动完毕，重绘背景，产生新的方块
      @set_wall_value(@wall)
      @wall.erase()
      @wall.wall_draw()
      @init()
      $('#wall_content').append(@block_content)

    
  # 遍历4*4的小方块，判断每个方块移动后所处位置对应的wall上的值是否为1
  # 如果为1，则无法移动
  bump_test: (wall, direction)->
    wall_value = wall.wall
    for x, i in @block_type
      for y, j in x
        if y is 1
          switch direction
            when MOVE_LEFT
              return false if @is_cover(wall_value, i, j - 1, COVER_TYPE.MOVE)
            when MOVE_RIGHT
              return false if @is_cover(wall_value, i, j + 1, COVER_TYPE.MOVE)
            when MOVE_DOWN
              return false if @is_cover(wall_value, i + 1, j, COVER_TYPE.MOVE)
    return true
  
  # 根据小方块当前所处的位置，将背景所对应的数组中的值设成1
  # 并重新绘制背景墙
  set_wall_value: (wall) ->
    wall_value = wall.wall
    for x, i in @block_type
      for y, j in x
        if y is 1
          wall_value[@block_content.position().top/BLOCK_WIDTH + i][@block_content.position().left/BLOCK_WIDTH + j] = 1
  
  # 旋转
  # 基本算法：x[i][j] = x[length - j -1][i]
  turn: (wall, block_content) ->
    if @is_stick then _block_type = [[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]] else _block_type = [[0,0,0],[0,0,0],[0,0,0]]

    ((_block_type[i][j] = @block_type[@block_type.length - 1 -j][i] for y, j in x) for x, i in @block_type)
    return block_content if @offset_value(wall, _block_type) is null

    if block_content.position().left/BLOCK_WIDTH < 8 then @set_offset(@offset_value(wall, _block_type)*MOVE_STEP, MOVE_RIGHT, block_content) else @set_offset(@offset_value(wall, _block_type)*MOVE_STEP, MOVE_LEFT, block_content)
    @block_type = _block_type
    block_content.html(@block_redraw())
  
  # 旋转测试：
  # 判断旋转后，在横坐标和纵坐标各超出了多位单位，并做相应的调整
  # **遗留问题：如果有多行的方块超出了范围，应该取最大的超出值，目前的方块类型还不存在该问题
  offset_value: (wall, block_type) ->
    wall_value = wall.wall
    offset = 0
    for x, i in block_type
      for y, j in x
        if y is 1
          if @is_cover(wall_value, i, j, COVER_TYPE.TURN) is BACKGROUND_TYPE.WALL
            offset += 1
          else if @is_cover(wall_value, i, j, COVER_TYPE.TURN) is BACKGROUND_TYPE.BLOCK
            return null
    return offset

  # 如果是普通的移动，则只需要判断是否重叠
  # 如果是旋转，则需要判断是否需要进行位移
  # 根据重叠的类型进行判断，如果是与墙重叠，则需要进行位移，如果是与砖块重叠，则无法旋转
  is_cover: (wall_value, offset_h, offset_v, cover_type) ->
    block_top = @block_content.position().top/BLOCK_WIDTH + offset_h
    block_left = @block_content.position().left/BLOCK_WIDTH + offset_v
    if cover_type is COVER_TYPE.MOVE
      return (wall_value[block_top][block_left] is 1) or (wall_value[block_top][block_left] is 2)
    else if cover_type is COVER_TYPE.TURN
      if wall_value[block_top][block_left] is BACKGROUND_TYPE.WALL
        return BACKGROUND_TYPE.WALL
      else if wall_value[block_top][block_left] is BACKGROUND_TYPE.BLOCK
        return BACKGROUND_TYPE.BLOCK

  set_offset: (offset, direction, block_content) ->
    switch direction
      when MOVE_RIGHT
        block_content.css('left', @left + offset)
        @left = @left + offset
      when MOVE_LEFT
        block_content.css('left', @left - offset)
        @left = @left - offset


class Game
  constructor:  ->
    @is_start = null
    @is_pause = false
    @score = 0
    @score_count(0)

    @wall = new Wall(this)
    @wall.wall_draw()
    @block = new Block(@wall)


  start_game: ->
    if @is_pause is true
      @keydown_bind()
      @is_start = @block.move_interval()
      $('#game_start').attr('disabled', 'disabled')
      $('#game_stop').removeAttr('disabled')
    unless @is_start
      @keydown_bind()
      @is_start = @block.move_interval()
      $('#game_start').attr('disabled', 'disabled')
      $('#game_stop').removeAttr('disabled')

  stop_game: ->
    if @is_start
      clearInterval(@is_start)
      @unbind_keydown()
      @is_pause = true
      $('#game_start').removeAttr('disabled')
      $('#game_stop').attr('disabled', 'disabled')

  reset_game: ->
    clearInterval(@is_start)
    @unbind_keydown()
    @is_start = null
    @is_pause = false
    @score = 0
    @score_count(0)

    @wall = new Wall(this)
    @wall.wall_draw()
    @block = new Block(@wall)
    @start_game()



  game_over: ->
    clearInterval(@is_start)
    @unbind_keydown()
    @wall.draw_over()
    $('#game_start').attr('disabled', 'disabled')
    $('#game_stop').attr('disabled', 'disabled')
    

  # 计分算法
  score_count: (remove_count) ->
    switch remove_count
      when 1
        @score += REMOVE_SCORE
      when 2
        @score += 3*REMOVE_SCORE
      when 3
        @score += 5*REMOVE_SCORE
      when 4
        @score += 10*REMOVE_SCORE
    $('#l_score').html(@score)
  
  keydown_bind:  ->
    that = this
    do ->
      $(window).keydown (event) ->
        switch event.keyCode
          when 38
            that.block.block_content = that.block.turn(that.wall, that.block.block_content)
          when 37
            that.block.move_left()
          when 39
            that.block.move_right()
          when 40
            that.block.move_down()

  unbind_keydown: ->
    $(window).unbind()

# 游戏开始啦~~~
jQuery ->

  # 游戏设置
  game = new Game()
  $('#game_start').click ->
    game.start_game()
  $('#game_stop').click ->
    game.stop_game()
  $('#game_restart').click ->
    game.reset_game()
