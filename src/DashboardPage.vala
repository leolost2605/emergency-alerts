public class EmA.DashboardPage : Adw.NavigationPage {
    public signal void show_details (Warning warning);

    public Client client { get; construct; }
    public Gtk.SizeGroup header_bar_size_group { get; construct; }

    private Gtk.Box location_boxes;
    private Gtk.Stack stack;

    public DashboardPage (Client client, Gtk.SizeGroup header_bar_size_group) {
        Object (client: client, header_bar_size_group: header_bar_size_group);
    }

    construct {
        var menu = new Menu ();
        menu.append (_("Add new location…"), "win.add-location");

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
            margin_bottom = 12,
            margin_end = 18,
            margin_start = 18
        };

        var clamp = new Adw.Clamp () {
            child = location_boxes,
            maximum_size = 700,
            tightening_threshold = 500
        };

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = clamp,
            vexpand = true,
            hscrollbar_policy = NEVER
        };

        var placeholder_text = new Gtk.Label (
            _("<big><b>No locations added yet</b></big>\nAdd a location to start receiving alerts.")
        ) {
            margin_top = 12,
            margin_bottom = 12,
            use_markup = true,
            xalign = 0.5f,
            yalign = 0.5f,
            justify = CENTER,
        };

        var button = new Gtk.Button.with_label (_("Add location…")) {
            action_name = "win.add-location"
        };
        button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);
        button.add_css_class ("pill");

        var placeholder_box = new Gtk.Box (VERTICAL, 12) {
            margin_bottom = 18,
            margin_end = 18,
            margin_start = 18,
            halign = CENTER,
            valign = CENTER,
        };
        placeholder_box.append (placeholder_text);
        placeholder_box.append (button);

        stack = new Gtk.Stack ();
        stack.add_named (scrolled_window, "locations");
        stack.add_named (placeholder_box, "placeholder");

        var box = new Gtk.Box (VERTICAL, 0);
        box.append (header_bar);
        box.append (stack);

        child = box;
        title = _("Dashboard");

        repopulate_location_box ();
        client.locations.items_changed.connect (repopulate_location_box);
    }

    private void repopulate_location_box () {
        for (
            var first_child = location_boxes.get_first_child ();
            first_child != null;
            first_child = location_boxes.get_first_child ()
        ) {
            location_boxes.remove (first_child);
        }

        stack.visible_child_name = client.locations.n_items > 0 ? "locations" : "placeholder";

        for (int i = 0; i < client.locations.n_items; i++) {
            var location_box = new LocationBox ((Location) client.locations.get_item (i));
            location_box.show_details.connect ((w) => show_details (w));
            location_boxes.append (location_box);
        }
    }
}
