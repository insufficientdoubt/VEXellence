#!/usr/bin/env python3
"""
generate-qrs.py - Quarto pre-render script
Generates QR codes for video-or-qr shortcodes before PDF/EPUB rendering.
"""

import os
import re
import hashlib
import urllib.parse
from pathlib import Path

import qrcode


def get_qr_codes_dir():
    """Get the QR codes directory path."""
    return Path("qr-codes")


def get_qr_filename(url):
    """Create a safe filename from URL."""
    hash_val = hashlib.md5(url.encode()).hexdigest()[:8]
    return f"qr-{hash_val}.png"


def generate_qr(url, output_path):
    """Generate a QR code for the given URL."""
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_M,
        box_size=10,
        border=4,
    )
    qr.add_data(url)
    qr.make(fit=True)

    img = qr.make_image(fill_color="black", back_color="white")
    img.save(output_path)
    return output_path


def scan_qmd_files():
    """Scan all .qmd files for video-or-qr shortcodes."""
    urls = set()

    for qmd_file in Path(".").rglob("*.qmd"):
        content = qmd_file.read_text()

        # Match video-or-qr shortcodes
        # {{< video-or-qr "url" "caption" >}}
        pattern = r'\{\{< video-or-qr ["\']([^"\']+)["\']'
        matches = re.findall(pattern, content)

        for url in matches:
            urls.add(url)

    return urls


def main():
    """Main entry point."""
    qr_dir = get_qr_codes_dir()
    qr_dir.mkdir(exist_ok=True)

    # Scan for URLs
    urls = scan_qmd_files()

    if not urls:
        print("No video-or-qr shortcodes found.")
        return

    print(f"Found {len(urls)} video URLs, generating QR codes...")

    for url in urls:
        filename = get_qr_filename(url)
        output_path = qr_dir / filename

        if output_path.exists():
            print(f"  Skipping existing: {filename}")
        else:
            print(f"  Generating: {filename}")
            generate_qr(url, output_path)

    print("QR code generation complete.")


if __name__ == "__main__":
    main()
