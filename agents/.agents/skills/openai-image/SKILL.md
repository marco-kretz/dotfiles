---
name: openai-image
description: "Generate or edit images with OpenAI's GPT-Image-2.5 models (flare and sunburst) via a stdlib-only Python CLI. Use when the user asks to create, generate, edit, inpaint, or restyle an image with OpenAI / GPT-Image / DALL-E."
---

# OpenAI Image Generation

`gen_image.py` calls `v1/images/generations` and `v1/images/edits` directly (stdlib
only, no `openai` SDK needed). Requires `OPENAI_API_KEY` in the environment.

## Model choice

| Model | Flag | Use for |
|---|---|---|
| `gpt-image-2.5-flare` | `-m flare` (default) | fast, high-quality everyday generation |
| `gpt-image-2.5-sunburst` | `-m sunburst` | precise editing and top quality; slower, pricier |

Pick flare unless the task is a detailed edit or the user asks for maximum quality.

## Usage

```bash
# generate
python3 ~/.claude/skills/openai-image/gen_image.py "a red fox in fog" -o fox.png

# high quality, portrait, transparent background, webp
... "logo of an owl" -m sunburst -q high -s 1024x1536 -b transparent -f webp -o owl.webp

# edit (up to 16 reference images, repeat -e)
... "put the product on a marble table" -m sunburst -e product.png -o shot.png

# inpaint: mask PNG, transparent area = the region to replace
... "replace the sky with a sunset" -e photo.png --mask sky-mask.png -o out.png
```

## Options

- `-q low|medium|high|xhigh|max|auto` — `max` can take minutes; raise `--timeout` (default 600s).
- `-s` — `1024x1024`, `1536x1024`, `1024x1536`, `auto`, or any `WxH` in multiples of 16.
- `-f png|jpeg|webp` with `--compression 0-100` for jpeg/webp.
- `-b transparent` only works with png/webp.
- `-n 3` writes `out-1.png`, `out-2.png`, `out-3.png`.

Self-check: `python3 test_gen_image.py` in the skill directory.
