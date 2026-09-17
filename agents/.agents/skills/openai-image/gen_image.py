#!/usr/bin/env python3
"""Generate or edit images with OpenAI's GPT-Image-2.5 models. Stdlib only."""

import argparse
import base64
import json
import mimetypes
import os
import sys
import urllib.error
import urllib.request
import uuid
from pathlib import Path

API = "https://api.openai.com/v1/images"
MODELS = {"flare": "gpt-image-2.5-flare", "sunburst": "gpt-image-2.5-sunburst"}


def multipart(fields, files):
    """fields: list of (name, str). files: list of (name, Path)."""
    boundary = uuid.uuid4().hex
    body = bytearray()
    for name, value in fields:
        body += f'--{boundary}\r\nContent-Disposition: form-data; name="{name}"\r\n\r\n{value}\r\n'.encode()
    for name, path in files:
        ctype = mimetypes.guess_type(path.name)[0] or "application/octet-stream"
        body += (
            f'--{boundary}\r\nContent-Disposition: form-data; name="{name}"; '
            f'filename="{path.name}"\r\nContent-Type: {ctype}\r\n\r\n'
        ).encode()
        body += path.read_bytes() + b"\r\n"
    body += f"--{boundary}--\r\n".encode()
    return bytes(body), f"multipart/form-data; boundary={boundary}"


def post(url, data, ctype, key, timeout):
    req = urllib.request.Request(
        url, data=data,
        headers={"Authorization": f"Bearer {key}", "Content-Type": ctype},
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return json.load(r)
    except urllib.error.HTTPError as e:
        detail = e.read().decode("utf-8", "replace")
        sys.exit(f"OpenAI API error {e.code}: {detail}")
    except urllib.error.URLError as e:
        sys.exit(f"Network error: {e.reason}")


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("prompt")
    p.add_argument("-m", "--model", default="flare", choices=MODELS,
                   help="flare = fast everyday generation (default), sunburst = precise editing/quality")
    p.add_argument("-o", "--out", default="image.png", help="output path; multiple images get -1, -2 suffixes")
    p.add_argument("-e", "--edit", action="append", type=Path, default=[],
                   help="input image to edit (repeat, up to 16 references)")
    p.add_argument("--mask", type=Path, help="inpainting mask (PNG with transparent area to replace)")
    p.add_argument("-s", "--size", default="auto",
                   help="1024x1024 | 1536x1024 | 1024x1536 | WIDTHxHEIGHT (multiples of 16) | auto")
    p.add_argument("-q", "--quality", default="auto",
                   choices=["low", "medium", "high", "xhigh", "max", "auto"])
    p.add_argument("-f", "--format", dest="fmt", default="png", choices=["png", "jpeg", "webp"])
    p.add_argument("--compression", type=int, help="0-100, jpeg/webp only")
    p.add_argument("-b", "--background", default="auto", choices=["transparent", "opaque", "auto"])
    p.add_argument("-n", type=int, default=1, help="number of images")
    p.add_argument("--timeout", type=int, default=600, help="seconds (max quality can be slow)")
    a = p.parse_args()

    key = os.environ.get("OPENAI_API_KEY")
    if not key:
        sys.exit("OPENAI_API_KEY is not set.")
    for f in a.edit + ([a.mask] if a.mask else []):
        if not f.is_file():
            sys.exit(f"No such file: {f}")
    if a.mask and not a.edit:
        sys.exit("--mask requires --edit.")

    fields = [
        ("model", MODELS[a.model]), ("prompt", a.prompt), ("n", str(a.n)),
        ("size", a.size), ("quality", a.quality), ("output_format", a.fmt),
        ("background", a.background),
    ]
    if a.compression is not None:
        fields.append(("output_compression", str(a.compression)))

    if a.edit:
        files = [("image[]", f) for f in a.edit]
        if a.mask:
            files.append(("mask", a.mask))
        body, ctype = multipart(fields, files)
        url = f"{API}/edits"
    else:
        payload = dict(fields)
        payload["n"] = a.n
        if a.compression is not None:
            payload["output_compression"] = a.compression
        body, ctype = json.dumps(payload).encode(), "application/json"
        url = f"{API}/generations"

    res = post(url, body, ctype, key, a.timeout)
    out = Path(a.out)
    for i, item in enumerate(res["data"], 1):
        path = out if len(res["data"]) == 1 else out.with_name(f"{out.stem}-{i}{out.suffix}")
        path.write_bytes(base64.b64decode(item["b64_json"]))
        print(path)


if __name__ == "__main__":
    main()
