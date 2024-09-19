public class Ema.DashboardPage : Adw.NavigationPage {
    public signal void show_details (Warning warning);

    public Client client { get; construct; }

    public DashboardPage (Client client) {
        Object (client: client);
    }

    construct {
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

        var header_bar = new Gtk.HeaderBar ();
        header_bar.add_css_class (Granite.STYLE_CLASS_FLAT);

        var box = new Gtk.Box (VERTICAL, 0);
        box.append (header_bar);
        box.append (scrolled_window);

        child = box;

        list_box.bind_model (client.warnings, create_widget_func);

        list_box.row_activated.connect ((row) => {
            show_details ((Warning) client.warnings.get_item (row.get_index ()));
        });
    }

    private Gtk.Widget create_widget_func (Object obj) {
        var warning = (Warning) obj;

        var header_label = new Granite.HeaderLabel (warning.title) {
            secondary_text = warning.sender
        };

        return header_label;
    }
}
