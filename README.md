# Emergency Alerts

![Emergency Alerts Screenshot](data/Screenshots/dashboard.png?raw=true)

## Building, Testing, and Installation

Run `flatpak-builder` to configure the build environment, download dependencies, build, and install.

For the Adwaita version run

```bash
    flatpak-builder build io.github.leolost2605.emergency-alerts.yml --user --install --force-clean --install-deps-from=flathub
```

For the elementary OS version run

```bash
    flatpak-builder build io.github.leolost2605.emergency-alerts-elementary.yml --user --install --force-clean --install-deps-from=appcenter
```

Only one of the two versions can be installed at the same time. To execute it run

```bash
    flatpak run io.github.leolost2605.emergency-alerts
```
## Adding support for another provider

Contributions that add support for another provider are (like all other contributions as well) very welcome.
To do this you just have to add a YourProvider class that extends the Provider abstract class and implements its
methods as described by the comments. For reference you can take a look at `Germany.vala`.

The general flow is:
- Your provider provides an updating list of warnings. The warnings in the list will be automatically displayed in the map and matched to locations (that have been selected by the user) based on their area.
- The refresh method will be called on your provider in regular intervals with a list of coordinates that correspond to locations selected by the user
- You fetch the warnings for the given coordinates and update the warnings list. I.e. you remove outdated warnings, update existing ones and add new ones
- If your API doesn't support coordinate based queries or the given array is _null_ (not empty) you should populate the warnings list with all currently available warnings.

The code style used is the [elementary OS code style](https://docs.elementary.io/develop/writing-apps/code-style).
For vala documentation refer to the [elementary OS developer docs](https://docs.elementary.io/develop) and for API documentation to [valadoc](https://valadoc.org/).
