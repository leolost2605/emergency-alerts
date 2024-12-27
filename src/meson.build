sources = [
    'Application.vala',
    'DashboardPage.vala',
    'LocationBox.vala',
    'LocationSearchPage.vala',
    'WarningPage.vala',
    'Window.vala',
    'Model' / 'Client.vala',
    'Model' / 'IconCache.vala',
    'Model' / 'Location.vala',
    'Model' / 'LocationSearch.vala',
    'Model' / 'Provider.vala',
    'Model' / 'Warning.vala',
    'Model' / 'Providers' / 'Germany.vala'
]

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    meson.project_name(),
    gresource,
    sources,
    dependencies: ema_deps,
    install: true
)
