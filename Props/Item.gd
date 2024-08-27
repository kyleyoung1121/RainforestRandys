extends Node3D

var is_collected: bool = false
var item_name = "item"

@onready var interactable_component = $Interactable


func _ready():
	self.visible = true


func configure_item_name(given_item_name):
	item_name = given_item_name
	interactable_component.item_name = given_item_name


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
