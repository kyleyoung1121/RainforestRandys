extends Node3D

var is_collected: bool = false
var item_name = "item"

@onready var interactable_component = $Interactable
@onready var light = $OmniLight3D

@export var light_brightness = 0.1


func _ready():
	self.visible = true


func configure_item_name(given_item_name):
	item_name = given_item_name
	interactable_component.item_name = given_item_name


func set_lighting(is_lit):
	if is_lit:
		light.light_energy = light_brightness
	else:
		light.light_energy = 0


func _on_interactable_interacted(interactor):
	if not is_collected:
		self.visible = false
		is_collected = true
		print(ItemData.stylize_text(item_name) + " Collected!")
		queue_free()


func _on_interactable_focused(interactor):
	pass


func _on_interactable_unfocused(interactor):
	pass
