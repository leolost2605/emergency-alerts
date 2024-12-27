

public class EmA.Window : Gtk.ApplicationWindow {
    public Client client { get; construct; }

    private Adw.NavigationView navigation_view;
    private Gtk.SizeGroup header_bar_size_group;

    public Window (Application application, Client client) {
        Object (
            application: application,
            client: client,
            default_height: 300,
            default_width: 300,
            title: _("Emergency Alerts"),
            titlebar: new Gtk.Grid () { visible = false }
        );
    }

    construct {
        header_bar_size_group = new Gtk.SizeGroup (VERTICAL);

        var dashboard_page = new DashboardPage (client, header_bar_size_group);

        navigation_view = new Adw.NavigationView ();
        navigation_view.add (dashboard_page);

        child = navigation_view;

        dashboard_page.show_details.connect ((warning) =>
            navigation_view.push (new WarningPage (warning, header_bar_size_group))
        );

        var add_location_action = new SimpleAction ("add-location", null);
        add_action (add_location_action);

        add_location_action.activate.connect (() => navigation_view.push (new LocationSearchPage (client, header_bar_size_group)));

        var remove_location_action = new SimpleAction ("remove-location", VariantType.STRING);
        add_action (remove_location_action);

        remove_location_action.activate.connect ((v) => client.remove_location ((string) v));

        close_request.connect (() => {
            request_background_permission.begin ();
            return true;
        });

        client.refresh ();
    }

    private async void request_background_permission () {
        var portal = new Xdp.Portal ();

        var commandline = new GenericArray<weak string> ();
        commandline.add ("io.github.leolost2605.emergencyalerts");
        commandline.add ("--background");

        try {
            yield portal.request_background (
                null,
                _("Emergency Alerts has to run in background in order to send notifications about incoming alerts."),
                commandline,
                AUTOSTART,
                null
            );
        } catch (Error e) {
            warning ("Failed to request background permission: %s", e.message);
        }

        destroy ();
    }
}
