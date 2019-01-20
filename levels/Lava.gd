extends TileMap

func attacked():
	return "touched"

func touched():
	return "burned"