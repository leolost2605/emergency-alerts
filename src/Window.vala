

public class Ema.Window : Gtk.ApplicationWindow {
    private Client client;
    private Adw.NavigationView navigation_view;

    public Window (Application application) {
        Object (
            application: application,
            default_height: 300,
            default_width: 300,
            title: _("Emergency Alerts"),
            titlebar: new Gtk.Grid () { visible = false }
        );
    }

    construct {
        client = new Client ();

        var dashboard_page = new DashboardPage (client);

        navigation_view = new Adw.NavigationView ();
        navigation_view.add (dashboard_page);

        child = navigation_view;

        dashboard_page.show_details.connect ((warning) => {
            navigation_view.push (new WarningPage (warning));
        });

        dashboard_page.search_for_location.connect (() => {
            navigation_view.push (new LocationSearchPage (client));
        });

        var remove_location_action = new SimpleAction ("remove-location", VariantType.STRING);
        add_action (remove_location_action);

        remove_location_action.activate.connect ((v) => client.remove_location ((string) v));
    }
}
