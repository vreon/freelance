extends AudioStreamPlayer

var enabled = true

# TODO: loading all the tracks into memory kinda sucks maybe? is this fine?
var tracks = {
	# (P): Placeholder
	CHILL = load("res://music/Fearofdark - Drowning In Sleep (P).ogg"),
	BOSS = load("res://music/Petriform - Heliofluid (P).ogg"),
	GRASS = load("res://music/Coda - Scrumb (P).ogg"),
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
