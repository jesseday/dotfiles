# Font Mix

Builds one installable font family from one font's uprights and another font's
italics. Zed can't set a separate italic font, so giving both one family name
works around that.

## Inputs

Static `.otf` or `.ttf` files (not variable fonts). Fonts are paired by weight,
so both sides need the same set of weights. Files with the wrong slant are
skipped, so you can pass a whole family to either side. The originals are only
read.

## Setup and run

```bash
uv run mix.py ./out --upright "<family name>" <files... >--italic <files... >--name
```

For example, Monaspace Neon uprights with Radon italics:

```bash
uv run mix.py ./out \
	--upright ~/Documents/fonts/Monaspace/MonaspiceNeNerdFont-*.otf \
	--italic ~/Documents/fonts/Monaspace/MonaspiceRnNerdFont-*.otf \
	--name "Monaspice Mix"
```

To check the script after changing it, run `uv run test_mix.py`.

## Install

`open out/*`, then click Install in Font Book. To rebuild, remove the old family
in Font Book first, then restart Zed.

## Use

Set `"buffer_font_family"` to the `--name` value in the Zed settings, e.g.
`"buffer_font_family": "Monaspice Mix"`.

## Changing the pairing

Pass different files to `--upright` and `--italic`, and pick a new `--name`.
