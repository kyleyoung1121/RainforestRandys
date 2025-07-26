class_name ItemGlow
extends Area3D

const FULL_BRIGHTNESS := 0.35
const LIGHT_FADE_DURATION := 0.4
const HIGHLIGHT_MODIFIER := 3

@onready var omni_light_3d = $OmniLight3D

var is_disabled := false
var brightness_tween: Tween


func halt_tween(target_tween):
	if target_tween:
		target_tween.kill()


func adjust_brightness(target_brightness, duration):
	if is_disabled:
		return
	
	# If we are in the middle of another tween, stop it
	halt_tween(brightness_tween)
	
	# Start tweening the brightness, turning on the light
	if is_instance_valid(get_tree()):
		brightness_tween = get_tree().create_tween().set_loops(1)
		brightness_tween.tween_property(omni_light_3d, "light_energy", target_brightness, duration)


func make_extra_bright():
	adjust_brightness(FULL_BRIGHTNESS * HIGHLIGHT_MODIFIER, LIGHT_FADE_DURATION / HIGHLIGHT_MODIFIER)


func turn_on():
	adjust_brightness(FULL_BRIGHTNESS, LIGHT_FADE_DURATION)


func turn_off():
	adjust_brightness(0, LIGHT_FADE_DURATION)
