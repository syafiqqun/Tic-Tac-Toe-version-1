extends Node2D

var blue_shape = preload("res://scene_script/shape/Circle.tscn")
var red_shape = preload("res://scene_script/shape/Cross.tscn")

var grid_pos := []
var current_pos
var current_grid := 0

var inside_board := false

var player_turn := 1
var player_1_turn := [1, 3, 5, 7, 9]
var player_2_turn := [2, 4, 6, 8]

var game_state := 0
var game_over := 1
var game_draw := 2

var board_state := [0, 0, 0, 0, 0, 0, 0, 0, 0]
var blue := 1
var red  := 2

var player_won := ""

var stop := 0


func _ready():
	# generate position of the area
	var child  = get_node("Board/Area").get_children()
	for node in child:
		grid_pos.append(node.global_position)
	print(grid_pos)
	
	# set initial player indicator
	player_turn_indicator_change()
	
	# hide the game over pop up
	get_node("GameOverPopUp").hide()
	
	# hide win indicator
	get_node("WinIndicator").hide()

func _process(delta):
	# stop all the code execution in this function
	if stop == 1:
		return
	
	if game_state == game_over:
		game_over_pop_up()
		stop = 1
	
	# if none of the player won ,the result is a draw
	if player_turn > 9:
		game_state = game_draw
		player_won = "draw"
		# the game is finished
		if game_state == game_draw:
			game_state = game_over
	
	var current_mouse_pos = get_viewport().get_mouse_position()
	var pos_x = current_mouse_pos.x
	var pos_y = current_mouse_pos.y
	
	# disabled input when mouse pos out of board
	if pos_x < 352 or pos_x > 640 or pos_y < 142 or pos_y > 442:
		inside_board = false
	else:
		inside_board = true
	
	if Input.is_action_just_pressed("left_mouse_click") and inside_board:
		print("Current Grid:", current_grid)
		
		# check if the current grid are not empty
		# if not,can instance the shape
		if board_state[current_grid] == 0:
			instancing_shape()
			player_turn += 1
			player_turn_indicator_change()
		
		# check if there is any winning state for both players
		check_winning_state()


func _input(event):
	# reload the game if game is over
	if Input.is_action_just_pressed("ui_accept"):
		if game_state == game_over:
			get_tree().reload_current_scene()
func set_win_indicator(position_p, rotation_p):
	$WinIndicator.position = position_p
	$WinIndicator.rotation_degrees = rotation_p
	$WinIndicator.show()


func win_indicator_show(pos_type):
	var h_f = grid_pos[1]
	var h_s = grid_pos[4]
	var h_t = grid_pos[7]
	
	var v_f = grid_pos[3]
	var v_s = grid_pos[4]
	var v_t = grid_pos[5]
	
	# horizontal pos
	if pos_type == 1:
		set_win_indicator(h_f, 0)
	if pos_type == 2:
		set_win_indicator(h_s, 0)
	if pos_type == 3:
		set_win_indicator(h_t, 0)
	
	# vertical pos
	if pos_type == 4:
		set_win_indicator(v_f, 90)
	if pos_type == 5:
		set_win_indicator(v_s, 90)
	if pos_type == 6:
		set_win_indicator(v_t, 90)
	
	# diagonal pos
	if pos_type == 7:
		set_win_indicator(h_s, 45)
	if pos_type == 8:
		set_win_indicator(h_s, -45)


func board_state_row(index_state, shape, player_winner, indicator_p):
	if board_state[index_state[0]] == shape and board_state[index_state[1]] == shape and board_state[index_state[2]] == shape:
		player_won = player_winner
		game_state = game_over
		win_indicator_show(indicator_p)


func check_winning_state():
	# board represetation with index value
	# 0, 1, 2
	# 3, 4, 5
	# 6, 7, 8
	
	# horizontal
	var h_grid_1 = [0, 1, 2]
	var h_grid_2 = [3, 4, 5]
	var h_grid_3 = [6, 7, 8]
	
	# vertical
	var v_grid_1 = [0, 3, 6]
	var v_grid_2 = [1, 4, 7]
	var v_grid_3 = [2, 5, 8]
	
	# diagonal
	var d_1 = [0, 4, 8]
	var d_2 = [6, 4, 2]
	
	# player 1 blue color
	board_state_row(h_grid_1, blue, "Player_1", 1)
	board_state_row(h_grid_2, blue, "Player_1", 2)
	board_state_row(h_grid_3, blue, "Player_1", 3)
	
	board_state_row(v_grid_1, blue, "Player_1", 4)
	board_state_row(v_grid_2, blue, "Player_1", 5)
	board_state_row(v_grid_3, blue, "Player_1", 6)
	
	board_state_row(d_1, blue, "Player_1", 7)
	board_state_row(d_2, blue, "Player_1", 8)
	
	# player 2 red color
	board_state_row(h_grid_1, red, "Player_2", 1)
	board_state_row(h_grid_2, red, "Player_2", 2)
	board_state_row(h_grid_3, red, "Player_2", 3)
	
	board_state_row(v_grid_1, red, "Player_2", 4)
	board_state_row(v_grid_2, red, "Player_2", 5)
	board_state_row(v_grid_3, red, "Player_2", 6)
	
	board_state_row(d_1, red, "Player_2", 7)
	board_state_row(d_2, red, "Player_2", 8)


func player_turn_indicator_change():
	for x in player_1_turn:
		if x == player_turn:
			get_node("Indicator/Player_1").color = Color(0, 0, 1, 1)
			get_node("Indicator/Player_2").color = Color(0.24, 0.24, 0.24, 1)
#			print("Player 1 turn")
	for x in player_2_turn:
		if x == player_turn:
			get_node("Indicator/Player_2").color = Color(1, 0, 0, 1)
			get_node("Indicator/Player_1").color = Color(0.24, 0.24, 0.24, 1)
#			print("Player 2 turn")


func add_shape(shape):
	var new_shape = shape.instance()
	new_shape.position = grid_pos[current_grid]
	get_node("ShapeInstances").add_child(new_shape)


func instancing_shape():
	for x in player_1_turn:
		if x == player_turn:
			# add new shape to the board
			add_shape(blue_shape)
			
			# change the board state to represent the shape taking the spot
			board_state[current_grid] = blue
			
#			print("Instanced shape circle")
	
	for x in player_2_turn:
		if x == player_turn:
			# add new shape to the board
			add_shape(red_shape)
			
			# change the board state to represent the shape taking the spot
			board_state[current_grid] = red
			
#			print("Instanced shape cross")


func game_over_pop_up():
	$GameOverPopUp.show()
	$GameOverPopUp/AnimationPlayer.play("text_blink")
	if player_won == "draw":
		$GameOverPopUp/GameWon.text = "Draw"
	if player_won == "Player_1":
		$GameOverPopUp/GameWon.text = "Player 1 [Blue] Won!!!"
	if player_won == "Player_2":
		$GameOverPopUp/GameWon.text = "Player 2 [Red] Won!!!"


# area for checking the position of the mouse
func _on_Area_1_mouse_entered():
	current_pos = grid_pos[0]
	current_grid = 0

func _on_Area_2_mouse_entered():
	current_pos = grid_pos[1]
	current_grid = 1

func _on_Area_3_mouse_entered():
	current_pos = grid_pos[2]
	current_grid = 2

func _on_Area_4_mouse_entered():
	current_pos = grid_pos[3]
	current_grid = 3

func _on_Area_5_mouse_entered():
	current_pos = grid_pos[4]
	current_grid = 4

func _on_Area_6_mouse_entered():
	current_pos = grid_pos[5]
	current_grid = 5

func _on_Area_7_mouse_entered():
	current_pos = grid_pos[6]
	current_grid = 6

func _on_Area_8_mouse_entered():
	current_pos = grid_pos[7]
	current_grid = 7

func _on_Area_9_mouse_entered():
	current_pos = grid_pos[8]
	current_grid = 8
