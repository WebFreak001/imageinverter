import std.file;
import std.file : r = read, w = write;
import std.experimental.color;
import std.getopt;
import std.path;
import std.stdio;
import std.string;
import std.parallelism;
import imageformats;
import imageinverter;

private string colorToFilenameString(RGB8 color) pure nothrow @safe
{
	import std.conv : to;
	import std.string : rightJustify;

	return color.r.value.to!string(16).rightJustify(2,
			'0') ~ color.g.value.to!string(16).rightJustify(2,
			'0') ~ color.b.value.to!string(16).rightJustify(2, '0');
}

void main(string[] args)
{
	auto bgString = "#231F20";
	string suffix;
	auto result = args.getopt(config.passThrough, "b|background", &bgString, "s|suffix", &suffix);
	auto bg = colorFromString(bgString);
	auto bgLum = getBackgroundLuminosity(bg);
	if (!suffix.length)
		suffix = "." ~ colorToFilenameString(bg);

	string prog = args[0];
	args = args[1 .. $];

	if (args.length == 0 || result.helpWanted)
	{
		defaultGetoptPrinter("Icon converter for different theme lightnesses.\nUsage: " ~ prog ~ " [files...]",
				result.options);
		return;
	}

	foreach (file; args.parallel)
	{
		stderr.writeln("Transforming ", file);
		auto ext = file.extension.toLower;
		string renamed = file[0 .. $ - ext.length] ~ suffix ~ file[$ - ext.length .. $];
		try
		{
			if (ext == ".svg")
			{
				renamed.w(file.readText.transformTextual(bgLum));
			}
			else if (ext == ".png" || ext == ".tga" || ext == ".bmp" || ext == ".jpg" || ext == ".jpeg")
			{
				auto img = read_image(file);
				if (img.c < 3)
				{
					stderr.writeln("Skipping incompatible image ", file);
					continue;
				}
				for (size_t i = 0; i < img.w * img.h; i++)
				{
					RGB8 col = RGB8(img.pixels[i * img.c], img.pixels[i * img.c + 1], img.pixels[i * img.c + 2]);
					auto transformed = col.transformRGB(bgLum);
					img.pixels[i * img.c] = transformed.r.value;
					img.pixels[i * img.c + 1] = transformed.g.value;
					img.pixels[i * img.c + 2] = transformed.b.value;
				}
				write_image(renamed, img.w, img.h, img.pixels, img.c);
			}
			else
				stderr.writeln("Skipping unknown filetype for file ", file);
		}
		catch (Exception e)
		{
			stderr.writeln("Failed transforming: ", e.msg);
		}
	}
}
