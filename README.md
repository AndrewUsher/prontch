# Prontch

A macOS native teleprompter app designed for recording videos while maintaining eye contact with your MacBook's camera. Prontch displays your script in the notch area (centered at the top of the screen) and uses voice activity detection to automatically scroll the text as you speak.

## Features

### Core Functionality
- **Notch-Positioned Display**: Script appears centered at the top of the screen, directly below the MacBook camera
- **Voice-Synced Auto-Scrolling**: Automatically scrolls text when you speak, pauses when you stop
- **Screen Capture Invisible**: Window is excluded from screen recordings (invisible in Zoom, Google Meet, Teams, etc.)
- **Menu Bar App**: Clean interface accessible from the macOS menu bar

### Smart Controls
- **Keyboard Shortcuts**: Full control without touching the mouse
- **Adjustable Scroll Speed**: Change speed on-the-fly during recording
- **Manual Override**: Scroll manually with arrow keys when needed
- **Pause/Resume**: Toggle scrolling at any time

### Script Management
- **Text Input**: Type or paste scripts directly
- **File Import**: Drag & drop or select .txt files
- **Paragraph Formatting**: Visual separation between paragraphs for easy reading

## System Requirements

- macOS 13.0 (Ventura) or later
- MacBook Pro with notch (14" or 16" models)
- Microphone access (for voice detection)

## Installation

1. Open `Prontch.xcodeproj` in Xcode
2. Build and run the project (⌘R)
3. The app will appear in your menu bar

## How to Use

### First Time Setup

1. **Launch Prontch** - The app icon will appear in your menu bar
2. **Click the menu bar icon** and select "Show Home"
3. **Grant microphone permission** when prompted (required for voice detection)
4. **Configure settings** (optional) - Adjust voice sensitivity and scroll speed

### Creating a Teleprompter Session

1. **Enter your script**:
   - Type/paste directly into the text editor, OR
   - Click "Import from File" to select a .txt file, OR
   - Drag and drop a .txt file onto the text editor

2. **Review your settings**:
   - Click "Settings" to adjust voice sensitivity and scroll speed
   - Test your microphone to ensure voice detection works

3. **Start teleprompter mode**:
   - Click "Start Teleprompter"
   - The script window will appear at the top of your screen below the notch
   - Start speaking - the text will automatically scroll as you talk

4. **Control during recording**:
   - Use keyboard shortcuts for manual control (see below)
   - Press `Esc` to exit teleprompter mode

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Space` | Pause/Resume scrolling |
| `↑` / `↓` | Manual scroll up/down |
| `⌘↑` / `⌘↓` | Increase/Decrease scroll speed |
| `Esc` | Exit teleprompter mode |

**Tip**: All shortcuts are also listed in the app menu under "Keyboard Shortcuts"

## Settings

### Voice Sensitivity
- **Low (0%)**: Requires loud, clear voice to trigger scrolling
- **Medium (50%)**: Default - works for normal speaking volume
- **High (100%)**: Sensitive - triggers on quieter speech

**Recommendation**: Start at 50% and adjust based on your microphone and speaking volume

### Scroll Speed
- **Slow**: 30 pixels/second - comfortable for detailed content
- **Medium**: 60 pixels/second - default setting
- **Fast**: 90 pixels/second - for experienced users

**Tip**: You can change speed during recording using `⌘↑`/`⌘↓`

## Technical Details

### Voice Activity Detection (VAD)
Prontch uses local audio processing to detect when you're speaking:
- Analyzes audio buffer in real-time using RMS (root mean square) calculation
- Converts amplitude to decibels and compares against threshold
- Includes 300ms debouncing to prevent flickering on brief pauses
- **All processing happens locally** - no cloud services or network required

### Screen Capture Exclusion
The teleprompter window uses `sharingType = .none` to exclude itself from:
- Screen recordings
- Video conferencing (Zoom, Google Meet, Microsoft Teams, etc.)
- Screenshot utilities
- Any screen capture APIs

### Window Positioning
- Uses `NSScreen.safeAreaInsets` to detect the notch area
- Positions window centered horizontally, 10px below the notch
- Window size: 800x120 pixels (optimized for readability)
- Floating window level ensures it stays on top

## Project Structure

```
Prontch/
├── Prontch.xcodeproj          # Xcode project file
├── Prontch/
│   ├── ProntchApp.swift       # Main app with menu bar integration
│   ├── Info.plist             # App configuration & permissions
│   ├── Models/
│   │   ├── Script.swift       # Script data model
│   │   ├── Settings.swift     # User settings & preferences
│   │   └── VoiceActivityState.swift  # VAD state enum
│   ├── Views/
│   │   ├── HomeView.swift     # Main script input screen
│   │   ├── TeleprompterView.swift    # Floating display view
│   │   └── SettingsView.swift        # Settings configuration
│   ├── Managers/
│   │   ├── AudioManager.swift        # Voice activity detection
│   │   ├── WindowManager.swift       # Notch-aware positioning
│   │   └── ScrollManager.swift       # Auto-scroll logic
│   ├── Utils/
│   │   ├── KeyboardShortcuts.swift   # Shortcut handling
│   │   └── FileImporter.swift        # Text file import
│   └── Assets.xcassets        # App icons & assets
└── README.md                  # This file
```

## Architecture

### Key Components

**AudioManager**
- Manages AVAudioEngine for microphone input
- Processes audio buffers to detect speech
- Publishes voice activity state changes

**ScrollManager**
- Subscribes to voice activity updates
- Uses CVDisplayLink for smooth 60fps scrolling
- Calculates scroll position based on time and speed

**WindowManager**
- Creates borderless, floating window
- Calculates position based on screen safe area
- Configures screen capture exclusion

**KeyboardShortcutHandler**
- Monitors keyboard events using NSEvent
- Maps key codes to actions (pause, scroll, speed adjust)
- Prevents event propagation for captured shortcuts

## Troubleshooting

### Microphone Not Working
1. Open **System Settings** > **Privacy & Security** > **Microphone**
2. Ensure **Prontch** is enabled
3. Restart the app
4. Test microphone in Settings

### Auto-Scroll Not Triggering
1. Check voice sensitivity setting (try increasing it)
2. Ensure you're speaking at normal volume
3. Test microphone in Settings to verify voice detection
4. Check that teleprompter isn't paused (press `Space`)

### Window Not Positioned Correctly
- The app is designed for MacBook Pro 14" and 16" with notches
- On models without notches, the window will appear at the top center
- Position is calculated based on screen safe area insets

### Text Too Small/Large
- Font size is optimized for viewing at arm's length from laptop screen
- Currently fixed at 18pt (modify `TeleprompterView.swift` line 45 to customize)

## Development

### Building from Source

```bash
# Clone or navigate to the project directory
cd /path/to/prontch/Prontch

# Open in Xcode
open Prontch.xcodeproj

# Build and run (⌘R)
```

### Requirements
- Xcode 15.0 or later
- Swift 5.9 or later
- macOS 13.0+ SDK

### Code Style
- SwiftUI for all views
- Combine for reactive state management
- MVVM architecture pattern
- ObservableObject for shared state

## Privacy & Security

- **Microphone Access**: Required for voice activity detection
- **Local Processing**: All audio processing happens on-device
- **No Network**: App does not make any network requests
- **No Data Collection**: No analytics, telemetry, or data collection
- **No Storage**: Scripts are not saved (session-only)

## License

This project is created as a production-ready macOS application. Feel free to modify and distribute as needed.

## Support

For issues, feature requests, or questions:
1. Check the Troubleshooting section above
2. Review keyboard shortcuts in the app menu
3. Adjust settings (voice sensitivity, scroll speed)

## Acknowledgments

Built with:
- SwiftUI for modern macOS UI
- AVFoundation for audio processing
- AppKit for window management
- Combine for reactive programming
