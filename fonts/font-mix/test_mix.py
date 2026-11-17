"""Self-check: builds tiny fonts, mixes them, checks the output names.

Run: .venv/bin/python test_mix.py
"""

import pathlib
import subprocess
import sys
import tempfile

from fontTools.fontBuilder import FontBuilder
from fontTools.pens.t2CharStringPen import T2CharStringPen
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.ttLib import TTFont

MIX = pathlib.Path(__file__).with_name("mix.py")


def make_font(path, family, style, weight, italic):
    cff = path.suffix == ".otf"
    fb = FontBuilder(1000, isTTF=not cff)
    fb.setupGlyphOrder([".notdef"])
    fb.setupCharacterMap({})
    ps = f"{family.replace(' ', '')}-{style.replace(' ', '')}"
    if cff:
        fb.setupCFF(ps, {"FullName": f"{family} {style}"}, {".notdef": T2CharStringPen(500, None).getCharString()}, {})
    else:
        fb.setupGlyf({".notdef": TTGlyphPen(None).glyph()})
    fb.setupHorizontalMetrics({".notdef": (500, 0)})
    fb.setupHorizontalHeader(ascent=800, descent=-200)
    fb.setupNameTable({"familyName": family, "styleName": style, "psName": ps,
                       "typographicFamily": family, "typographicSubfamily": style})
    fb.setupOS2(usWeightClass=weight, fsSelection=(1 if italic else 0x40))
    fb.updateHead(macStyle=(2 if italic else 0))
    fb.setupPost()
    fb.save(path)


def run(out, uprights, italics):
    return subprocess.run(
        [sys.executable, MIX, out, "--upright", *uprights, "--italic", *italics, "--name", "Test Mix"],
        capture_output=True, text=True,
    )


with tempfile.TemporaryDirectory() as tmp:
    tmp = pathlib.Path(tmp)
    up = [tmp / "Up-Light.ttf", tmp / "Up-Bold.ttf", tmp / "Up-LightItalic.ttf"]
    make_font(up[0], "Up", "Light", 300, False)
    make_font(up[1], "Up", "Bold", 700, False)
    make_font(up[2], "Up", "Light Italic", 300, True)  # wrong slant: must be skipped
    it = [tmp / "It-LightItalic.otf", tmp / "It-BoldItalic.otf"]
    make_font(it[0], "It", "Light Italic", 300, True)
    make_font(it[1], "It", "Bold Italic", 700, True)

    result = run(tmp / "out", up, it)
    assert result.returncode == 0, result.stderr
    outs = sorted(p.name for p in (tmp / "out").iterdir())
    assert outs == ["TestMix-Bold.ttf", "TestMix-BoldItalic.otf",
                    "TestMix-Light.ttf", "TestMix-LightItalic.otf"], outs

    expected = {  # file: (ID 1, ID 2, ID 16, ID 17)
        "TestMix-Light.ttf": ("Test Mix Light", "Regular", "Test Mix", "Light"),
        "TestMix-Bold.ttf": ("Test Mix", "Bold", "Test Mix", "Bold"),
        "TestMix-LightItalic.otf": ("Test Mix Light", "Italic", "Test Mix", "Light Italic"),
        "TestMix-BoldItalic.otf": ("Test Mix", "Bold Italic", "Test Mix", "Bold Italic"),
    }
    for filename, want in expected.items():
        font = TTFont(tmp / "out" / filename)
        got = tuple(font["name"].getDebugName(i) for i in (1, 2, 16, 17))
        assert got == want, (filename, got)
        assert font["name"].getDebugName(6) == filename.rsplit(".", 1)[0]
        if "CFF " in font:
            assert font["CFF "].cff.fontNames == [font["name"].getDebugName(6)]

    # Mismatched weights must fail without writing anything.
    result = run(tmp / "bad", up[:1], it)
    assert result.returncode != 0 and "Weights differ" in result.stderr, result.stderr
    assert not (tmp / "bad").exists()

print("ok")
