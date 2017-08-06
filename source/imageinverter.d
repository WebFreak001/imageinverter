module imageinverter;

import std.experimental.color;
import std.experimental.color.hsx;
import std.regex;

alias HSLf = HSL!float;

private string colorToString(RGB8 color) pure nothrow @safe
{
	import std.conv : to;
	import std.string : rightJustify;

	return '#' ~ color.r.value.to!string(16).rightJustify(2,
			'0') ~ color.g.value.to!string(16).rightJustify(2,
			'0') ~ color.b.value.to!string(16).rightJustify(2, '0');
}

/// Utility function to replace all text color occurences (#000000) with transformed colors.
string transformTextual(string svg, float bgLum)
{
	return svg.replaceAll!(m => m.hit.colorFromString.transformRGB(bgLum)
			.colorToString)(ctRegex!`#[0-9a-fA-F]{6}`);
}

/// Returns the luminosity of a background color. Transformed icons use this as base for color transformation. Try #231F20 as starting point.
float getBackgroundLuminosity(RGB8 bg) pure nothrow @nogc @safe
{
	return bg.convertColor!HSLf.l;
}

/// Converts a light color using bgLum to a dark color.
RGB8 transformRGB(RGB8 color, float bgLum) pure nothrow @nogc @safe
{
	auto ret = color.convertColor!HSLf;
	ret.l = transformLuminosity(ret.l, bgLum);
	return ret.convertColor!RGB8;
}

/// Converts a light luminosity using bgLum to a dark luminosity
float transformLuminosity(float lum, float bgLum) pure nothrow @nogc @safe
{
	float baseLuminosity = 0.965f;
	if (bgLum < 0.5)
	{
		baseLuminosity = 1 - baseLuminosity;
		lum = 1 - lum;
	}

	if (lum < baseLuminosity)
		return bgLum * lum / baseLuminosity;
	else
		return (1 - bgLum) * (lum - 1) / (1 - baseLuminosity) + 1;
}
