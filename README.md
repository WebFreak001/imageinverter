# imageinverter

Converts light icons to dark icons like Visual Studio.

Code example:

```d
import imageinverter;

float bgLum = getBackgroundLuminosity(RGB8(0x23, 0x1F, 0x20));
foreach (ref RGB8 pixel; image)
	pixel = pixel.transformRGB(bgLum);
```

Using as application:

```sh
dub build --config=application
./imageinverter --suffix .dark --background "#231F20" *.svg *.png *.tga *.bmp *.jpg
# suffix defaults to ".backgroundcolor" (.231F20 in this case), background defaults to #231F20
# the suffix is appended like this: file.png -> filesuffix.png
```