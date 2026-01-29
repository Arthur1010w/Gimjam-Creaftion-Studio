# GlobalBrightness.gd (Autoload)
extends CanvasLayer

# Variabel ini akan bertahan meski scene berpindah-pindah
var current_brightness: float = 1.0

@onready var rect = $ColorRect

func _ready():
	# Gunakan nilai yang tersimpan saat pertama kali muncul
	set_brightness(current_brightness)

func set_brightness(value: float):
	current_brightness = value
	if rect:
		rect.color.a = 1.0 - value
