# FA

An iOS app that keeps your lock screen fresh: rotating quotes, a word of the day with its definition, and wallpapers that cycle on their own.

## How it works

iOS doesn't let apps change your wallpaper or lock screen directly, so FA uses the three things Apple does allow:

| Feature | How | Setup |
| --- | --- | --- |
| Quotes and words on the lock screen | WidgetKit lock screen widgets that pre-schedule a timeline, so they change without the app running | Add the widget once |
| Wallpaper cycling | A Shortcuts action, **Get Next Wallpaper**, that returns the next image (optionally with the current quote drawn on it). Shortcuts' built-in **Set Wallpaper** applies it | One personal automation |
| Shortcuts helpers | **Get Current Quote** and **Get Current Word** return the text the widgets are showing | Optional |

The app has four tabs: **Today** (current quote and word, browse everything), **Favorites** (and a switch to rotate only favorites), **Wallpapers** (8 bundled gradients plus your own photos) and **Setup** (rotation interval and step-by-step instructions).

## Building

You need a Mac with Xcode 16 or later. The Xcode project is generated from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen), so it never has merge conflicts:

```sh
brew install xcodegen
xcodegen
open FA.xcodeproj
```

Then in Xcode:

1. Select the **FA** project, and under **Signing & Capabilities** pick your team for both the **FA** and **FAWidget** targets (or set `DEVELOPMENT_TEAM` in `project.yml`).
2. If the bundle IDs `com.ichxse.fa` / `group.com.ichxse.fa` are taken or rejected, change them in `project.yml` and in `Shared/AppGroup.swift`, then run `xcodegen` again.
3. Plug in your iPhone, choose it as the run destination, and press Run.

If you sign with a free Apple ID and Xcode complains about App Groups, remove the `entitlements` blocks from `project.yml`. Everything still works, except favorites and the rotation interval won't reach the widgets.

## Project layout

```
App/        SwiftUI app, wallpaper library, quote-on-wallpaper renderer, App Intents
Widget/     WidgetKit extension (Quote and Word widgets)
Shared/     Models, bundled content (quotes.json, words.json), rotation logic, shared preferences
project.yml XcodeGen spec
```

Rotation is deterministic per time slot (`Shared/Rotation.swift`): the app, the widgets and the Shortcuts actions all compute the same "current" quote and word without syncing, and every item is shown once before anything repeats.

## Adding content

Edit `Shared/Resources/quotes.json` or `Shared/Resources/words.json`. Each entry needs a unique `id`. To add bundled wallpapers, drop portrait JPEGs (1290×2796 is ideal) into `App/Wallpapers/`.

## Ideas for later

- Pull new words from a dictionary API and wallpapers from Unsplash
- Live Activity for a longer-form daily card
- Interactive widget button to favorite the current quote
- Themed packs (stoic, poetry, science) and per-pack widgets
