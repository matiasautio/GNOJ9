extends Node


var index = 4


# Called when the node enters the scene tree for the first time.
func _ready():
	#pass
	display_text()


func display_text():
	$"../BackgroundColor/ScaleHelper/guide_text".bbcode_text = ""
	$"../BackgroundColor/ScaleHelper/guide_text".rect_scale = Vector2(0,0)
	index += 1
	$delay.start()
	match index:
		-1:
			pass
		0:
			$"../BackgroundColor/ScaleHelper/guide_text/AnimationPlayer".play("increase_scale")
			$"../BackgroundColor/ScaleHelper/guide_text".bbcode_text = "[center][wave]Get a job!"
		1:
			$"../BackgroundColor/ScaleHelper/guide_text/AnimationPlayer".play("increase_scale")
			$"../BackgroundColor/ScaleHelper/guide_text".bbcode_text = "[center][wave]Merge trees!"
		2:
			$"../BackgroundColor/ScaleHelper/guide_text/AnimationPlayer".play("increase_scale")
			$"../BackgroundColor/ScaleHelper/guide_text".bbcode_text = "[center][wave]Destroy carbon \nsinks!"
		3:
			$"../BackgroundColor/ScaleHelper/guide_text/AnimationPlayer".play("increase_scale")
			$"../BackgroundColor/ScaleHelper/guide_text".bbcode_text = "[center][wave]Or help save \nthe forests!"
		4:
			$"../BackgroundColor/ScaleHelper/guide_text/AnimationPlayer".play("increase_scale")
			$"../BackgroundColor/ScaleHelper/guide_text".bbcode_text = "[center][wave]Choose your side!"
		5:
			$"../BackgroundColor/ScaleHelper/guide_text/AnimationPlayer".play("increase_scale")
			$"../BackgroundColor/ScaleHelper/guide_text".bbcode_text = "[center][wave]Fight back!"
			$delay.wait_time = 999 # :-)
		6:
			$"../BackgroundColor/ScaleHelper/guide_text/Logo".visible = true
			$"../BackgroundColor/ScaleHelper/guide_text2".visible = true
			$"../BackgroundColor/ScaleHelper/guide_text/AnimationPlayer".play("increase_scale")


func _on_delay_timeout():
	display_text()
