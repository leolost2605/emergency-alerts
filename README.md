# Emergency Alerts

![Emergency Alerts Screenshot](data/Screenshots/Dashboard.png?raw=true)

## Building, Testing, and Installation

Run `flatpak-builder` to configure the build environment, download dependencies, build, and install.

For the Adwaita version run

```bash
    flatpak-builder build io.github.leolost2605.emergency-alerts-adwaita.yml --user --install --force-clean --install-deps-from=flathub
```

For the elementary OS version run

```bash
    flatpak-builder build io.github.leolost2605.emergency-alerts.yml --user --install --force-clean --install-deps-from=appcenter
```

Only one of the two versions can be installed at the same time. To execute it run

```bash
    flatpak run io.github.leolost2605.emergency-alerts
```
