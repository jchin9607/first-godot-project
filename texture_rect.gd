extends TextureRect

var color = Color.WHITE
	
func _draw():
	draw_circle(Vector2(0,0), 5, color)

func change_color(col: Color):
	color = col
	
	queue_redraw()
