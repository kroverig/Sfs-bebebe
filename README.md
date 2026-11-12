# SFS Bebebe — Android single-player prototype

This repository currently contains an offline single-player rocket game prototype. Multiplayer is intentionally postponed until requested.

## Current features
- Rocket assembly by adding fuel tanks and engines.
- Launch, hold-to-thrust, steering buttons.
- Fuel, altitude and speed indicators.
- Basic gravity and atmospheric drag.
- Reset and rebuild.

## Build APK
1. Open the Actions tab.
2. Select the Build Android APK workflow.
3. Press Run workflow (or push a commit to main).
4. Open the completed workflow run.
5. Download the artifact named SFS-Bebebe-Android-APK.
6. Extract the downloaded artifact ZIP, then install the APK inside it.

The APK is a debug build for testing. The repository stores source files; GitHub Actions produces the APK artifact.

## Controls
- START — begin flight.
- Hold THRUST — engine thrust while pressed.
- Left / Right — steer.
- Add Tank / Add Engine — add parts before launch.
- Reset — return to the hangar.

Multiplayer/network code is not included in this version.
