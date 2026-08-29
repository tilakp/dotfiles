# NANO Emacs Theme for Doom Emacs

This is an implementation of Nicolas P. Rougier's minimal NANO theme for Doom Emacs. The nano theme offers a clean, minimalist interface with carefully chosen typography and color scheme.

## Features

- Minimal and distraction-free interface
- Enhanced typography with proper line spacing
- Clean frames with larger border margins
- Consistent semantic faces across different modes
- Improved readability with carefully chosen colors

## Components

1. **nano-theme.el** - The core theme implementation with face definitions and styling
2. **nano-agenda.el** - A minimalist calendar and agenda view

## Typography Settings

The theme uses:
- **Roboto Mono** as the default font at size 14pt with light weight
- Line spacing of 0.15 for better readability
- A lighter weight for bold text to maintain visual harmony

## Frame Layout

- Frames are set to 44 rows × 81 columns
- Zero-width fringes for a cleaner look
- 32-pixel internal borders for breathing room
- No vertical scroll bars or dividers

## Semantic Colors

The NANO theme revolves around these semantic face roles:

- **default**: Normal text 
- **highlight**: Highlighted areas
- **subtle**: Less emphasized elements
- **faded**: Background information
- **salient**: Important elements to draw attention
- **popout**: Elements that should stand out
- **strong**: For extra emphasis
- **critical**: For errors and warnings

Each face has an inverted version (e.g., `nano-default-i`) for use on dark backgrounds.

## Integration with Doom Emacs

The NANO theme implementation works alongside Doom's existing theme system and complements the previously added nano-agenda functionality.

## Usage

The theme is automatically loaded by your config.el file. If you want to further customize it:

1. Edit the face definitions in `nano-theme.el`
2. Adjust typography settings as needed
3. Run `doom/reload` to apply changes

## Credits

Based on Nicolas P. Rougier's NANO Emacs implementation:
https://github.com/rougier/nano-emacs
