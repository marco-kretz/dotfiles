#!/usr/bin/env python3
"""Self-check: python3 test_gen_image.py"""
from pathlib import Path
from tempfile import TemporaryDirectory

from gen_image import multipart

with TemporaryDirectory() as d:
    img = Path(d, "cat.png")
    img.write_bytes(b"\x89PNG-data")
    body, ctype = multipart([("model", "gpt-image-2.5-flare")], [("image[]", img)])
    boundary = ctype.split("boundary=")[1]
    assert body.startswith(f"--{boundary}\r\n".encode())
    assert body.endswith(f"--{boundary}--\r\n".encode())
    assert b'name="model"\r\n\r\ngpt-image-2.5-flare\r\n' in body
    assert b'name="image[]"; filename="cat.png"\r\nContent-Type: image/png' in body
    assert b"\x89PNG-data" in body
print("ok")
