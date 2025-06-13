class_name RenderResult

var diffuse_frames: Array[Image]
var normal_frames: Array[Image]

var render_duration_ms: int

func _init(diffuse: Array[Image], normal: Array[Image]):
	self.diffuse_frames = diffuse
	self.normal_frames = normal
