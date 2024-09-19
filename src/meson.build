sources = [
    'Application.vala',
    'DashboardPage.vala',
    'WarningPage.vala',
    'Window.vala',
    'Model' / 'Client.vala',
    'Model' / 'Warning.vala'
]

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    meson.project_name(),
    sources,
    dependencies: ema_deps,
    install: true
)
