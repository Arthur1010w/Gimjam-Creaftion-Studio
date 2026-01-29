extends Control

# Referensi Node sesuai struktur file .tscn Anda 
@onready var music = $HBoxContainer/MarginContainer/MarginContainer/VBoxContainer/MarginContainer/Musik/music as Label
@onready var angka_musik = $HBoxContainer/MarginContainer/MarginContainer/VBoxContainer/MarginContainer/Musik/angka_musik as Label
@onready var h_slider_musik = $HBoxContainer/MarginContainer/MarginContainer/VBoxContainer/MarginContainer/Musik/HSlider_musik as HSlider
@onready var h_slider_audio = $HBoxContainer/MarginContainer/MarginContainer/VBoxContainer/MarginContainer/Audio/HSlider as HSlider
@onready var angka_audio = $HBoxContainer/MarginContainer/MarginContainer/VBoxContainer/MarginContainer/Audio/Angka as Label
@onready var action_button = $Action_keybind/action_button as Button
@onready var h_slider_bright = $HBoxContainer/MarginContainer/MarginContainer/VBoxContainer/MarginContainer/Brightness/HSlider_bright as HSlider
@onready var angka_bright = $HBoxContainer/MarginContainer/MarginContainer/VBoxContainer/MarginContainer/Brightness/Angka as Label
# Pilihan Bus menggunakan nama yang tepat 
@export_enum("Master", "SFX") var bus_name : String = "Master"

var master_index : int
var sfx_index : int
var is_rebinding = false 
var action_to_rebind = "ui_accept"

func _ready() -> void:
	# Mengambil index bus audio 
	master_index = AudioServer.get_bus_index("Master")
	sfx_index = AudioServer.get_bus_index("SFX")
	
	# Menghubungkan sinyal slider ke fungsi 
	h_slider_musik.value_changed.connect(_on_musik_value_changed)
	h_slider_audio.value_changed.connect(_on_audio_value_changed)
	h_slider_bright.value_changed.connect(_on_h_slider_bright_value_changed)

		
	if has_node("/root/GlobalBrightness"):
		var saved_val = get_node("/root/GlobalBrightness").current_brightness
		h_slider_bright.value = saved_val
		_update_brightness_ui(saved_val)
	else:
		h_slider_bright.value = 1.0
		_on_h_slider_bright_value_changed(1.0)
		
	_update_ui_display()
	
	_update_button_text()
# Tambahkan fungsi pembantu untuk update UI
func _update_brightness_ui(value: float) -> void:
	angka_bright.text = str(int(round(value * 100))) + "%"

func _on_h_slider_bright_value_changed(value: float) -> void:
	# Update teks angka
	_update_brightness_ui(value)
	
	# Simpan dan terapkan ke Autoload
	if has_node("/root/GlobalBrightness"):
		get_node("/root/GlobalBrightness").set_brightness(value)
	
func _update_button_text():
	# Mengambil nama tombol yang terdaftar saat ini
	var events = InputMap.action_get_events(action_to_rebind)
	if events.size() > 0:
		action_button.text = events[0].as_text().trim_suffix(" (Physical)")
		
func _on_action_button_pressed():
	is_rebinding = true
	action_button.text = "Waiting for Input..."
	
func _input(event):
	if is_rebinding and event is InputEventKey and event.is_pressed():
		# 1. Hapus input lama
		InputMap.action_erase_events(action_to_rebind)
		# 2. Masukkan input baru yang ditekan user
		InputMap.action_add_event(action_to_rebind, event)
		
		is_rebinding = false
		_update_button_text()
		# Mencegah input 'tembus' ke fungsi lain
		get_viewport().set_input_as_handled()
		
		
func _update_ui_display() -> void:
	# Update Slider Musik 
	var vol_musik = db_to_linear(AudioServer.get_bus_volume_db(master_index))
	h_slider_musik.value = vol_musik
	angka_musik.text = str(int(round(vol_musik * 100))) + "%"
	
	# Update Slider Audio 
	var vol_audio = db_to_linear(AudioServer.get_bus_volume_db(sfx_index))
	h_slider_audio.value = vol_audio
	# Tambahkan int() di sini juga
	angka_audio.text = str(int(round(vol_audio * 100))) + "%"

func _on_musik_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_index, linear_to_db(value)) 
	var nilai_bulat = int(round(value * 100))
	angka_musik.text = str(nilai_bulat) + "%"

func _on_audio_value_changed(value: float) -> void:
	# Pastikan Bus SFX sudah dibuat di Audio Mixer
	AudioServer.set_bus_volume_db(sfx_index, linear_to_db(value))
	var nilai_bulat = int(round(value * 100))
	angka_audio.text = str(nilai_bulat) + "%"

func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://Main_Menu.tscn")
