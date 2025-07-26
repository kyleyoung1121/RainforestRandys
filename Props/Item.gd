extends Node3D

var is_collected: bool = false
var item_name = "item"
var on_list := false

@onready var interactable_component = $Interactable
@onready var item_glow_component = $ItemGlow



func _ready():
	self.visible = true


func set_item_name(given_item_name):
	item_name = given_item_name
	interactable_component.item_name = given_item_name


func set_required(state):
	on_list = state
	item_glow_component.is_disabled = !(state)


func _on_interactable_interacted(_interactor):
	if not is_collected and on_list:
		self.visible = false
		is_collected = true
		print(ItemData.stylize_text(item_name) + " Collected!")
		item_glow_component.brightness_tween.kill()
		queue_free()


func _on_interactable_focused(_interactor):
	item_glow_component.make_extra_bright()


func _on_interactable_unfocused(_interactor):
	if is_collected:
		item_glow_component.turn_off()
	else:
		item_glow_component.turn_on()
