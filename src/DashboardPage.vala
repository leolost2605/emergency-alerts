public class EmA.DashboardPage : Adw.NavigationPage {
    public signal void show_details (Warning warning);
    public signal void search_for_location ();

    public Client client { get; construct; }

    private Gtk.Box location_boxes;

    public DashboardPage (Client client) {
        Object (client: client);
    }

    construct {
        var location_button = new Gtk.Button.from_icon_name ("location-active");

        var header_bar = new Gtk.HeaderBar ();
        header_bar.pack_end (location_button);
        header_bar.add_css_class (Granite.STYLE_CLASS_FLAT);

        location_boxes = new Gtk.Box (VERTICAL, 18) {
            margin_top = 12,
            margin_bottom = 12
        };

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = location_boxes,
            vexpand = true
        };

        var box = new Gtk.Box (VERTICAL, 0);
        box.append (header_bar);
        box.append (scrolled_window);

        child = box;

        location_button.clicked.connect (() => search_for_location ());

        repopulate_location_box ();
        client.locations.items_changed.connect (repopulate_location_box);
    }

    private void repopulate_location_box () {
        Gtk.Widget? first_child = location_boxes.get_first_child ();
        while (first_child != null) {
            location_boxes.remove (first_child);
            first_child = location_boxes.get_first_child ();
        }

        for (int i = 0; i < client.locations.n_items; i++) {
            var location_box = new LocationBox ((Location) client.locations.get_item (i));
            location_box.show_details.connect ((w) => show_details (w));
            location_boxes.append (location_box);
        }
    }
}
