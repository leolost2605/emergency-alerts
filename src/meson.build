sources = [
    'Application.vala',
    'DashboardPage.vala',
    'LocationBox.vala',
    'LocationSearchPage.vala',
    'WarningPage.vala',
    'Window.vala',
    'Model' / 'Client.vala',
    'Model' / 'Database.vala',
    'Model' / 'IconCache.vala',
    'Model' / 'Location.vala',
    'Model' / 'LocationSearch.vala',
    'Model' / 'LocationsManager.vala',
    'Model' / 'Provider.vala',
    'Model' / 'ProviderManager.vala',
    'Model' / 'RefreshManager.vala',
    'Model' / 'Utils.vala',
    'Model' / 'Warning.vala',
    'Model' / 'Providers' / 'Germany.vala',
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
