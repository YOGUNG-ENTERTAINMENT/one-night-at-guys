extends Node3D

@export var camOpenAnim: AnimationPlayer
@export var transanim: AnimationPlayer
@export var dooranim: AnimationPlayer
@export var victoryanim: AnimationPlayer
@export var powerProgress: TextureProgressBar
@export var timerLabel: Label
@export var roomsUI: Control
@export var roomTexture: TextureRect
@export var transTexture: TextureRect
@export var transTextures: Array

var roomTextures = {
	"lvl0" = preload("res://assets/rooms/normal/lvl0.png"),
	"lvl6" = preload("res://assets/rooms/normal/lvl6.png"),
	"lvl21" = preload("res://assets/rooms/normal/lvl21.png"),
	"lvl69" = preload("res://assets/rooms/normal/lvl69.png"),
	"lvl998" = preload("res://assets/rooms/normal/lvl998.png"),
	"lvlhub" = preload("res://assets/rooms/normal/lvlhub.png")
}

var roomTexturesBoat = {
	"lvl0" = preload("res://assets/rooms/with_boat/lvl0.png"),
	"lvl6" = preload("res://assets/rooms/with_boat/lvl6.png"),
	"lvl998" = preload("res://assets/rooms/with_boat/lvl998.png"),
	"lvlhub" = preload("res://assets/rooms/with_boat/lvlhub.png")
}

var roomTexturesGuy = {
	"lvl0" = preload("res://assets/rooms/with_guy/lvl0.png"),
	"lvl6" = preload("res://assets/rooms/with_guy/lvl6.png"),
	"lvl21" = preload("res://assets/rooms/with_guy/lvl21.png"),
	"lvl69" = preload("res://assets/rooms/with_guy/lvl69.png"),
	"lvl998" = preload("res://assets/rooms/with_guy/lvl998.png"),
	"lvlhub" = preload("res://assets/rooms/with_guy/lvlhub.png")
}

var roomOrder = [
	"lvl69",
	"lvl0",
	"lvl21",
	"lvl6",
	"lvlhub",
	"lvl998",
]

var roomOrderBoat = [
	"lvl0",
	"lvlhub",
	"lvl6",
	"lvlhub",
	"lvl998",
]

var curRoomIndex = 0
var curRoomOn = 0
var curRoomOnID = "lvl69"

var curRoomIndexBoat = 0
var curRoomOnBoat = 0

var door_opened = false
var door_hover = false
var victoryD = false

var currentTime: int = 0

func room_id_to_index(room_id):
	return roomOrder.find(room_id)

func room_id_to_index_boat(room_id):
	return roomOrderBoat.find(room_id)

# Called when the node enters the scene tree for the first time.
func _ready():
	for btn in roomsUI.get_children():
		btn.connect("pressed", func(): swtich_room(btn.name))
	swtich_room("lvl69")
	$Control/OpenCam.visible = true

func swtich_room(room_id):
	curRoomOnID = room_id
	
	var rand = RandomNumberGenerator.new()
	transTexture.texture = transTextures[rand.randi_range(0,transTextures.size() - 1)]
	transanim.play("transition")
	
	curRoomOn = room_id_to_index(room_id)
	curRoomOnBoat = room_id_to_index_boat(room_id)
	
	$Ambatuak.stop()
	
	if room_id_to_index(room_id) == curRoomIndex:
		roomTexture.texture = roomTexturesGuy[room_id]
		
		if room_id == "lvl6":
			$Ambatuak.play()

	elif room_id_to_index_boat(room_id) == curRoomIndexBoat:
		roomTexture.texture = roomTexturesBoat[room_id]
		
		if room_id == "lvl6":
			$Ambatuak.play()
	else:
		roomTexture.texture = roomTextures[room_id]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_open_cam_pressed():
	camOpenAnim.play("open_cam")
	Globals.powerUsages += 2


func _on_close_btn_pressed():
	camOpenAnim.play("close_cam")
	$Ambatuak.stop()
	Globals.powerUsages -= 2


func _on_button_toggled(button_pressed):
	print(button_pressed)
	var tween = get_tree().create_tween()
	if button_pressed:
		tween.tween_property($Camara, "rotation_degrees", Vector3(360,180,360), 1).set_trans(Tween.TRANS_LINEAR)
		$Control/OpenCam.visible = false
		$Control/MakeEnergy.visible = false
	else:
		tween.tween_property($Camara, "rotation_degrees", Vector3(0,0,0), 1).set_trans(Tween.TRANS_LINEAR)
		$Control/OpenCam.visible = true
		$Control/MakeEnergy.visible = true


var usageMultiply = 2

func _on_timer_timeout():
	if victoryD:
		return
	
	Globals.power -= Globals.powerUsages * usageMultiply
	
	powerProgress.value = Globals.power
	
	if Globals.power <= 0:
		dead()


func _on_clock_time_timeout():
	currentTime += 1
	timerLabel.text = "00:" + str(currentTime) + " AM"
	
	if currentTime > 300:
		usageMultiply = 4
	
	if currentTime > 600 and victoryD == false:
		print("HONG KONG")
		victoryanim.play("victory")
		victoryD = true
		await get_tree().create_timer(7).timeout
		OS.crash("YOU WIN GG!!!")

func _on_room_move_timeout():
	if victoryD:
		return
		
	var oldCurRoom = curRoomIndex
	var oldCurRoomBoat = curRoomIndexBoat
	
	curRoomIndex += 1
	curRoomIndexBoat += 1
	
	if curRoomOn == oldCurRoom:
		print("cur room changed")
		swtich_room(curRoomOnID)
	
	if curRoomOnBoat == curRoomIndexBoat:
		print("cur room changed")
		swtich_room(curRoomOnID)
	
	if curRoomIndex > roomOrder.size():
		if door_opened == false:
			dead()
		else:
			$guy.visible = false
			curRoomIndex = 1
	elif curRoomIndex > roomOrder.size() - 1:
		$guy.visible = true

	if curRoomIndexBoat > roomOrderBoat.size():
		if door_opened == false:
			dead()
		else:
			$boat.visible = false
			curRoomIndexBoat = 1
	elif curRoomIndexBoat > roomOrderBoat.size() - 1:
		$boat.visible = true

func dead():
	$Control/JUMPSCAR.visible = true
	$Explosd.play()
	await get_tree().create_timer(2.5).timeout
	OS.crash("LMFAO!!!!!!")

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and door_hover:
			door_opened = not door_opened
			
			if door_opened:
				dooranim.play("open")
				Globals.powerUsages += 3
			else:
				dooranim.play("close")
				Globals.powerUsages -= 3


func _on_area_3d_mouse_entered():
	door_hover = true


func _on_area_3d_mouse_exited():
	door_hover = false


func _on_make_energy_pressed():
	if Globals.power >= 100:
		return
	
	Globals.power += usageMultiply
	
	powerProgress.value = Globals.power

	var rand = RandomNumberGenerator.new()
	
	var tween = get_tree().create_tween()
	
	var x = rand.randf_range(0, 1000)
	var y = rand.randf_range(0, 600)
	
	tween.tween_property($Control/MakeEnergy, "global_position", Vector2(x, y), 0.25).set_trans(Tween.TRANS_LINEAR)
