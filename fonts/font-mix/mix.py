"""Mix one font's uprights with another font's italics into one installable family.

Usage: python mix.py <out_dir> --upright <files...> --italic <files...> --name <family name>

Fonts are paired by weight class, so both sides must have the same set of weights.
Files of the wrong slant are skipped, so passing a whole family to either side is fine.
Originals are only read; renamed copies are written to out_dir.
"""

import argparse
import pathlib
import sys

from fontTools.ttLib import TTFont

# Mac compatible full name, WWS family/subfamily, variations PostScript prefix.
# These would still carry the old family name, so drop them.
DROPPED_NAME_IDS = (18, 21, 22, 25)


def is_italic(font: TTFont) -> bool:
    return bool(font["OS/2"].fsSelection & 1 or font["head"].macStyle & 2)


def load(
    paths: list[pathlib.Path], italic: bool
) -> dict[int, tuple[pathlib.Path, TTFont]]:
    """Map weight class -> (path, font) for the fonts with the given slant."""
    fonts = {}
    for path in paths:
        if path.suffix.lower() not in (".otf", ".ttf"):
            sys.exit(f"{path}: only .otf and .ttf files are supported")
        font = TTFont(path)
        if "fvar" in font:
            sys.exit(f"{path}: variable fonts aren't supported")
        if is_italic(font) != italic:
            continue
        weight = font["OS/2"].usWeightClass
        if weight in fonts:
            sys.exit(
                f"{path} and {fonts[weight][0]} both have weight {weight}; pass only one"
            )
        fonts[weight] = (path, font)
    return fonts


def names(family: str, style: str, italic: bool) -> dict[int, str]:
    """Name table entries for one member of the new family, keyed by name ID."""
    weight = style.replace("Italic", "").strip() or "Regular"
    # Legacy (ID 1/2) names only allow Regular/Bold per family, so other
    # weights get their own legacy family, e.g. "My Mix Light" + "Italic".
    base = weight if weight in ("Regular", "Bold") else "Regular"
    legacy_family = family if base == weight else f"{family} {weight}"
    legacy_style = (
        {"Regular": "Italic", "Bold": "Bold Italic"}[base] if italic else base
    )
    ps_name = f"{family.replace(' ', '')}-{style.replace(' ', '')}"
    return {
        1: legacy_family,
        2: legacy_style,
        3: ps_name,
        4: f"{family} {style}",
        6: ps_name,
        16: family,
        17: style,
    }


def rename(font: TTFont, family: str, italic: bool) -> str:
    """Rewrite the font's names into the new family; returns its PostScript name."""
    table = font["name"]
    style = table.getDebugName(17) or table.getDebugName(2) or "Regular"
    new = names(family, style, italic)
    for name_id in (*DROPPED_NAME_IDS, *new):
        table.removeNames(nameID=name_id)
    for name_id, value in new.items():
        table.setName(
            value, name_id, 3, 1, 0x409
        )  # Windows Unicode English; macOS reads these

    # The CFF table carries its own PostScript name, which must match name ID 6.
    if "CFF " in font:
        cff = font["CFF "].cff
        cff.fontNames = [new[6]]
        top = cff.topDictIndex[0]
        top.FullName = new[4]
        top.FamilyName = new[1]
    return new[6]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("out_dir", type=pathlib.Path)
    parser.add_argument(
        "--upright",
        nargs="+",
        type=pathlib.Path,
        required=True,
        help="font files to take the uprights from",
    )
    parser.add_argument(
        "--italic",
        nargs="+",
        type=pathlib.Path,
        required=True,
        help="font files to take the italics from",
    )
    parser.add_argument(
        "--name", required=True, help='new family name, e.g. "Monaspice Mix"'
    )
    args = parser.parse_args()

    uprights = load(args.upright, italic=False)
    italics = load(args.italic, italic=True)
    if not uprights:
        sys.exit("No upright fonts among the --upright files")
    if not italics:
        sys.exit("No italic fonts among the --italic files")
    if uprights.keys() != italics.keys():
        sys.exit(
            f"Weights differ: upright {sorted(uprights)}, italic {sorted(italics)}"
        )

    args.out_dir.mkdir(parents=True, exist_ok=True)
    for fonts, italic in ((uprights, False), (italics, True)):
        for _, (path, font) in sorted(fonts.items()):
            ps_name = rename(font, args.name, italic)
            dest = args.out_dir / f"{ps_name}{path.suffix.lower()}"
            font.save(dest)
            print(f"{path.name:42} -> {dest.name}")


if __name__ == "__main__":
    main()
