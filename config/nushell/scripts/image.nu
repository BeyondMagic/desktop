#to_gif() {
#
#	palette="/tmp/palette.png"
#	filters="fps=25,scale=500:-1:flags=lanczos"
#
#	ffmpeg -i "$1" -vf "$filters,palettegen" -y $palette
#	ffmpeg -i "$1" -i $palette -lavfi "$filters [x]; [x][1:v] paletteuse" -y "$1".gif
#
#}
