extends Node

@export var GenerateMaps: bool = false
@export var SavePath: String = "../FoliageMapGenerator/Image"
@export var terrainSplatmap: Texture2D
@export var mapsToGenerate: int = 30
@export var startingGreenValue: float = 0.99
@export var loopDecrementValue: float = 0.01

var blockColor: Color = Color(0.0, 0.0, 0.5, 0.9);

func _ready():
	if GenerateMaps:
		print("Generating foliage maps, patience please...")
		var timer = Timer.new()
		add_child(timer)
		var himg = terrainSplatmap.get_image()

		var width  = himg.get_width()
		var height = himg.get_height()

		var _img = Image.create(width, height, false, 5)
		_img.fill(blockColor)
		var path = "{}/FoliageMap".format([SavePath], "{}")
		for loop in range(0, mapsToGenerate):
			var loopVal = startingGreenValue - loop * loopDecrementValue
			for i in range(0, width):
				for j in range(0, height):
					var _color = himg.get_pixel(i, j)
					if _color.r >= loopVal:
						_img.set_pixel(i,j,Color.RED)
					if _color.b >= loopVal:
						_img.set_pixel(i,j,Color.BLUE)
					if _color.a >= loopVal:
						_img.set_pixel(i,j,blockColor)
					if _color.g >= loopVal:
						_img.set_pixel(i,j,Color.GREEN)
			_img.save_png("{}-{}-{}.png".format([path, loop, loopVal], "{}"))

		print("Foliage maps generated! Thank you for your patience.")
		get_tree().quit()