class_name PaletteHelper

static func build_palette_image(palette: Array[Color]) -> Image:
	if len(palette) == 0:
		var null_palette := Image.create_empty(1, 1, false, Image.FORMAT_RGB8)
		null_palette.set_pixel(0, 0, Color.BLACK)
		return null_palette
	
	var palette_image := Image.create_empty(len(palette), 1, false, Image.FORMAT_RGB8)
	for i in range(len(palette)):
		palette_image.set_pixel(i, 0, palette[i])
	return palette_image

static func palette_from_image(image: Image) -> Array[Color]:
	var colors: Array[Color] = []
	for x in image.get_width():
		for y in image.get_height():
			var pixel_color := image.get_pixel(x, y)
			if pixel_color.a != 0.0:
				var opaque_color = Color(pixel_color.r, pixel_color.g, pixel_color.b, 1.0)
				if opaque_color not in colors:
					colors.append(opaque_color)
	
	if len(colors) > 1024:
		push_warning("Too many colors in loaded palette! Truncating at 1024...")
		colors = colors.slice(0, 1024)
	
	return colors

static func palette_from_image_path(path: String) -> Array[Color]:
	var img := Image.load_from_file(path)
	return palette_from_image(img)

static func save_palette_to_path(palette: Array[Color], path: String):
	var image = build_palette_image(palette)
	if not path.ends_with(".png"):
		path = path + ".png"
	image.save_png(path)
