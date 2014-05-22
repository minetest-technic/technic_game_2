#!/bin/sh
rm *.png

cp static/meselamp_base.png meselamp_white.png
convert static/meselamp_base.png -brightness-contrast -40 meselamp_grey.png
convert static/meselamp_base.png -brightness-contrast -65 meselamp_dark_grey.png
convert static/meselamp_base.png -brightness-contrast -80 meselamp_black.png
convert static/meselamp_base.png -brightness-contrast -60 -fill "#FF0000" -tint 90 meselamp_red.png
convert static/meselamp_base.png -brightness-contrast -37 -fill "#FF7F00" -tint 95 meselamp_orange.png
convert static/meselamp_base.png -brightness-contrast -15 -fill "#FFFF00" -tint 100 meselamp_yellow.png
convert static/meselamp_base.png -brightness-contrast -20 -fill "#3FFF00" -tint 100 meselamp_green.png
convert static/meselamp_base.png -brightness-contrast -70 -fill "#00FF00" -tint 100 meselamp_dark_green.png
convert static/meselamp_base.png -brightness-contrast -70 -fill "#00FFFF" -tint 100 meselamp_cyan.png
convert static/meselamp_base.png -brightness-contrast -60 -fill "#003FFF" -tint 80 meselamp_blue.png
convert static/meselamp_base.png -brightness-contrast -70 -fill "#8000FF" -tint 80 meselamp_violet.png
convert static/meselamp_base.png -brightness-contrast -70 -fill "#FF00FF" -tint 90 meselamp_magenta.png
convert static/meselamp_base.png -brightness-contrast -50x10 -fill "#FF0080" -tint 80 meselamp_pink.png

convert static/meselamp_base.png -brightness-contrast -55 -fill "#804000" -tint 80 meselamp_brown.png

# Generate dark versions
for i in *.png; do
	filename=$(basename "$i")
	filename="${filename%.*}"
	filename+="_dark.png"
	convert $i -brightness-contrast -28x-40 $filename
done

# Optimize
for i in *.png; do
	pngout -y $i $i
	optipng -o7 -zm1-9 $i
done

cp static/*.png ../textures
cp *.png ../textures
rm ../textures/meselamp_base.png

