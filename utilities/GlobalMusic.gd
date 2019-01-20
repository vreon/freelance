extends AudioStreamPlayer

var enabled = true

# TODO: loading all the tracks into memory kinda sucks maybe? is this fine?
var tracks = null

func _ready():
	if OS.is_debug_build():
		tracks = {
			CHILL = load("res://music/Fearofdark - Drowning In Sleep (P).ogg"),
			BOSS = load("res://music/Petriform - Heliofluid (P).ogg"),
		}
	else:
		tracks = {
			# TODO: OK to distribute music in source-available build if properly attributed
			# TODO: NC means no selling on stores; reach out to artists for licensing
			CHILL = load("res://music/Fearofdark - Drowning In Sleep (P).ogg"),  # cc-by-nc-nd
			BOSS = load("res://music/Petriform - Heliofluid (P).ogg"),  # cc-by-nc-sa
		}

func play_track(track):
	if not enabled or not track:
		return
		
	# TODO: segue
	if stream != track:
		stream = track
		stream.loop = true
		
	if not is_playing():
		play()