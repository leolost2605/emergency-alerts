sources = [
    'Application.vala',
    'DashboardPage.vala',
    'LocationRow.vala',
    'LocationSearchPage.vala',
    'SubscriptionBox.vala',
    'WarningPage.vala',
    'Window.vala',
    'Model' / 'Client.vala',
    'Model' / 'Location.vala',
    'Model' / 'LocationSearch.vala',
    'Model' / 'RefreshManager.vala',
    'Model' / 'Provider' / 'Provider.vala',
    'Model' / 'Provider' / 'ProviderManager.vala',
    'Model' / 'Provider' / 'Warning.vala',
    'Model' / 'Provider' / 'Implementations' / 'Germany.vala',
    'Model' / 'Subscription' / 'Database.vala',
    'Model' / 'Subscription' / 'Subscription.vala',
    'Model' / 'Subscription' / 'SubscriptionManager.vala',
    'Model' / 'Utils' / 'IconCache.vala',
    'Model' / 'Utils' / 'Utils.vala',
]

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    meson.project_name(),
    gresource,
    sources,
    dependencies: ema_deps,
    install: true
)
