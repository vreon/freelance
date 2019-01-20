extends StaticBody2D

export(String, "none", "attacked", "deflected", "touched") var attack_result = "none"
export(String, "none", "hurt", "burned", "shocked") var touch_result = "none"

func attacked():
	return attack_result

func touched():
	return touch_result