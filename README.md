# MRJL Robotics Handbook

A comprehensive textbook for the Mingwan Junior League (MRJL) competitive robotics program. Built with [Quarto](https://quarto.org/) for multi-format publishing.

## Overview

This handbook covers everything from team fundamentals to advanced competition strategies for VEX IQ robotics. It produces:

- **Web version**: Published on GitHub Pages
- **Print-ready PDF**: For physical copies
- **EPUB**: For e-readers and tablets

## Quick Start

### Preview Locally

```bash
# Install Quarto (if needed)
brew install quarto  # macOS
# or download from https://quarto.org/docs/get-started/

# Preview the book
quarto preview

# Build all formats
quarto render
```

### Build Specific Formats

```bash
# HTML only
quarto render --to html

# PDF only (requires LaTeX)
quarto render --to pdf

# EPUB only
quarto render --to epub
```

## Project Structure

```
├── _quarto.yml           # Book configuration
├── _extensions/          # Custom shortcode extensions
│   ├── video-or-qr/     # Video→QR shortcode
│   └── h5p/             # H5P with print fallback
├── sections/            # Chapter files
│   ├── 01-welcome.qmd
│   ├── 02-engineering.qmd
│   ├── 03-coding.qmd
│   ├── 04-strategy.qmd
│   ├── 05-driving.qmd
│   ├── 06-team-management.qmd
│   ├── 07-checklists.qmd
│   └── 08-glossary.qmd
├── scripts/             # Build scripts
│   └── generate-qrs.py # QR code generator
├── styles/              # Custom CSS
└── references.bib       # Bibliography
```

## Custom Shortcodes

### Video → QR Code

```markdown
{{< video-or-qr "https://example.com/video.mp4" "Watch the demonstration" >}}
```

- **HTML**: Embedded video player
- **PDF/EPUB**: QR code linking to the video

### H5P Interactive Content

```markdown
{{< h5p url="https://..." type="quiz" 
  question="What is a motor?" 
  options="Motor|Provides rotation"
  answer="Provides rotation" 
  hint="Think about movement" >}}
```

- **HTML**: Embedded H5P iframe
- **PDF**: Styled box with upside-down answer
- **EPUB**: Plain text with visible answer

## Development

### Prerequisites

- Quarto 1.2+
- Python 3.8+ (for QR generation)
- LaTeX (for PDF output, e.g., MacTeX)

### Running Pre-render Scripts

QR codes are auto-generated before PDF/EPUB builds via `scripts/generate-qrs.py`.

```bash
# Run manually
python3 scripts/generate-qrs.py
```

## License

This handbook is for MRJL team use. Contact leadership for permissions.

## Contributing

Found an error or want to improve the content?

1. Create an issue describing the problem
2. Submit a pull request with your changes
3. Test with `quarto preview`

---

Built with ❤️ by MRJL Team
