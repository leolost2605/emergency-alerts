sources = [
    'Application.vala',
    'DashboardPage.vala',
    'LocationBox.vala',
    'LocationSearchPage.vala',
    'WarningPage.vala',
    'Window.vala',
    'Model' / 'Client.vala',
    'Model' / 'LocationSearch.vala',
    'Model' / 'RefreshManager.vala',
    'Model' / 'Location' / 'Database.vala',
    'Model' / 'Location' / 'Location.vala',
    'Model' / 'Location' / 'LocationsManager.vala',
    'Model' / 'Provider' / 'Provider.vala',
    'Model' / 'Provider' / 'ProviderManager.vala',
    'Model' / 'Provider' / 'Warning.vala',
    'Model' / 'Provider' / 'Implementations' / 'Germany.vala',
    'Model' / 'Utils' / 'IconCache.vala',
    'Model' / 'Utils' / 'Utils.vala',

    # 'Model' / 'Providers' / 'Ukraine.vala'
]

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    meson.project_name(),
    gresource,
    sources,
    dependencies: ema_deps,
    install: true
)
