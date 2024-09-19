public class Ema.DashboardPage : Adw.NavigationPage {
    public signal void show_details (Warning warning);
    public signal void search_for_location ();

    public Client client { get; construct; }

    public DashboardPage (Client client) {
        Object (client: client);
    }

    construct {
        var location_button = new Gtk.Button.from_icon_name ("location-active");

        var header_bar = new Gtk.HeaderBar ();
        header_bar.pack_end (location_button);
        header_bar.add_css_class (Granite.STYLE_CLASS_FLAT);

        var list_box = new Gtk.ListBox () {
            margin_top = 12,
            margin_bottom = 12,
            margin_end = 12,
            margin_start = 12,
            show_separators = true,
            hexpand = true,
            activate_on_single_click = true,
            valign = START
        };
        list_box.add_css_class ("boxed-list");
        list_box.add_css_class (Granite.STYLE_CLASS_RICH_LIST);

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = list_box,
            vexpand = true
        };

        var box = new Gtk.Box (VERTICAL, 0);
        box.append (header_bar);
        box.append (scrolled_window);

        child = box;

        list_box.bind_model (client.warnings, create_widget_func);

        list_box.row_activated.connect ((row) => {
            show_details ((Warning) client.warnings.get_item (row.get_index ()));
        });

        location_button.clicked.connect (() => search_for_location ());
    }

    private Gtk.Widget create_widget_func (Object obj) {
        var warning = (Warning) obj;

        var title_label = new Gtk.Label (warning.title) {
            wrap = true,
            xalign = 0
        };

        var description_label = new Gtk.Label (null) {
            wrap = true,
            xalign = 0
        };
        description_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);

        warning.bind_property ("time-formatted", description_label, "label", SYNC_CREATE);
        warning.notify["time-formatted"].connect (() => description_label.visible = warning.time_formatted != null);
        description_label.visible = warning.time_formatted != null;

        var box = new Gtk.Box (VERTICAL, 3);
        box.append (title_label);
        box.append (description_label);

        return box;
    }
}
