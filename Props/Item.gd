extends Node3D

@export var item_name: String = "item"
@export var location: String = "general"

var is_collected: bool = false


func _ready():
	self.visible = true


func _on_interactable_interacted(interactor):
	if not is_collected:
		self.visible = false
		is_collected = true
		print("Item Collected!")
		queue_free()


func _on_interactable_focused(interactor):
	pass


func _on_interactable_unfocused(interactor):
	pass
