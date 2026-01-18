sources = [
    'Application.vala',
    'Model' / 'Client.vala',
    'Model' / 'RefreshManager.vala',
    'Model' / 'Geometry' / 'Coordinate.vala',
    'Model' / 'Geometry' / 'MultiPolygon.vala',
    'Model' / 'Geometry' / 'Polygon.vala',
    'Model' / 'Location' / 'CurrentLocation.vala',
    'Model' / 'Location' / 'Database.vala',
    'Model' / 'Location' / 'FixedLocation.vala',
    'Model' / 'Location' / 'Location.vala',
    'Model' / 'Location' / 'LocationManager.vala',
    'Model' / 'Location' / 'LocationSearch.vala',
    'Model' / 'Provider' / 'Provider.vala',
    'Model' / 'Provider' / 'ProviderManager.vala',
    'Model' / 'Provider' / 'Warning.vala',
    'Model' / 'Provider' / 'Implementations' / 'Germany.vala',
    'Model' / 'Provider' / 'Implementations' / 'Ukraine.vala',
    'Model' / 'Provider' / 'Implementations' / 'USWeather.vala',
    'Model' / 'Subscription' / 'LocationFilter.vala',
    'Model' / 'Subscription' / 'Subscription.vala',
    'Model' / 'Subscription' / 'SubscriptionManager.vala',
    'Model' / 'Utils' / 'CAP.vala',
    'Model' / 'Utils' / 'CountryCode.vala',
    'Model' / 'Utils' / 'GeoJSON.vala',
    'Model' / 'Utils' / 'IconCache.vala',
    'Model' / 'Utils' / 'Log.vala',
    'Model' / 'Utils' / 'ProviderTemplate.vala',
    'Model' / 'Utils' / 'Utils.vala',
    'Model' / 'Warning' / 'WarningAggregator.vala',
    'UI' / 'WarningChooserDialog.vala',
    'UI' / 'WarningPage.vala',
    'UI' / 'Window.vala',
    'UI' / 'AddLocationDialog' / 'AddLocationDialog.vala',
    'UI' / 'AddLocationDialog' / 'LocationRow.vala',
    'UI' / 'AddLocationDialog' / 'LocationSearchPage.vala',
    'UI' / 'HomePage' / 'HomePage.vala',
    'UI' / 'HomePage' / 'DashboardPage' / 'DashboardPage.vala',
    'UI' / 'HomePage' / 'DashboardPage' / 'SubscriptionBox.vala',
    'UI' / 'HomePage' / 'MapPage' / 'MapPage.vala',
    'UI' / 'HomePage' / 'MapPage' / 'WarningLayer.vala',
    'UI' / 'Widgets' / 'ErrorDialog.vala',
    'UI' / 'Widgets' / 'WarningRow.vala',
]

config_data = configuration_data()
config_data.set_quoted('VERSION', meson.project_version())
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_file = configure_file(
    input: 'Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    meson.project_name(),
    gresource,
    config_file,
    sources,
    dependencies: ema_deps,
    install: true
)
