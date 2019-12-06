extends Spatial

class_name HealthBar

func _ready() -> void:
	self.rotation_degrees = Vector3(0, -90, 0)
	self.set_scale(Vector3(0.5, 0.5, 0.5))

func set_bar(value:float) -> void:
	$Bar.set_scale(Vector3(1.0, 1.0, value))

func set_material(color_material) -> void:
	$Bar.set_material_override(color_material)