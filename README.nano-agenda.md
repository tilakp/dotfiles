# Nano-Agenda for Doom Emacs

This is an implementation of the nano-agenda view based on Nicolas Rougier's work (https://github.com/rougier/nano-emacs).

## Features

- Minimalist calendar + agenda view
- Interactive navigation with keyboard and mouse
- Clean visual display with customizable faces

## Dependencies

The nano-agenda requires the following packages:
- ts (Time/Date manipulation library)
- org-agenda (Part of org-mode)

## Usage

Nano-agenda has been configured with the following keybindings:

- `SPC o a` - Open nano-agenda view
- Within nano-agenda:
  - Arrow keys - Navigate days/weeks
  - Shift+Arrow keys - Navigate months/years
  - `t` or `.` - Jump to today
  - `q` or `ESC` or `RET` - Close nano-agenda

## Installation

These files have already been installed in your Doom Emacs configuration:
1. `nano-agenda.el` - The main implementation
2. Added `ts` package to your `packages.el`
3. Updated `config.el` to load and configure nano-agenda

For the changes to take effect, you need to restart Emacs or run:
```
doom sync
M-x doom/reload
```

If you encounter any issues with the `ts` package not being found, you may need to:
1. Run `doom sync` again
2. Restart Emacs completely

## Customization

You can customize the appearance of nano-agenda by modifying the face definitions in `nano-agenda.el`.

The calendar has been configured with increased spacing between rows and agenda entries for better readability. If you want to adjust this spacing:

1. For calendar rows spacing: Look for `(setq result (concat result "\n\n"))` in the `nano-agenda-body-days` function
2. For agenda entries spacing: Look for `(insert "\n\n")` after inserting each agenda entry

## Troubleshooting

If you see an error about `ts` not being found, make sure:
1. You've run `doom sync` after saving all changes
2. The package is properly listed in `packages.el`

For other issues, check the *Messages* buffer for error details.
