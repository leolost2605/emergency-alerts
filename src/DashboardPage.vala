public class EmA.DashboardPage : Adw.NavigationPage {
    public signal void show_details (Warning warning);

    public Client client { get; construct; }
    public Gtk.SizeGroup header_bar_size_group { get; construct; }

    private Gtk.Box location_boxes;

    public DashboardPage (Client client, Gtk.SizeGroup header_bar_size_group) {
        Object (client: client, header_bar_size_group: header_bar_size_group);
    }

    construct {
        var menu = new Menu ();
        menu.append (_("Add new location"), "win.add-location");

        var menu_button = new Gtk.MenuButton () {
#if ADWAITA
            icon_name = "open-menu-symbolic",
#else
            icon_name = "open-menu",
#endif
            menu_model = menu
        };
#if !ADWAITA
        menu_button.add_css_class (Granite.STYLE_CLASS_LARGE_ICONS);
#endif

        var header_bar = new Adw.HeaderBar ();
        header_bar.pack_end (menu_button);
        header_bar.add_css_class (Granite.STYLE_CLASS_FLAT);

        header_bar_size_group.add_widget (header_bar);

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
        title = _("Dashboard");

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
