public class EmA.LocationSearchPage : Adw.NavigationPage {
    public Client client { get; construct; }

    private Gtk.SearchEntry entry;

    public LocationSearchPage (Client client) {
        Object (client: client);
    }

    construct {
        var header_bar = new Adw.HeaderBar () {
            show_title = false
        };
        header_bar.add_css_class (Granite.STYLE_CLASS_FLAT);

        entry = new Gtk.SearchEntry () {
            margin_start = 12,
            margin_end = 12
        };

        var spinner = new Gtk.Spinner () {
            spinning = true
        };

        var loading_label = new Gtk.Label (_("Loading locations…"));

        var loading_placeholder = new Gtk.Box (VERTICAL, 6) {
            halign = CENTER,
            valign = CENTER
        };
        loading_placeholder.append (spinner);
        loading_placeholder.append (loading_label);

        var factory = new Gtk.SignalListItemFactory ();
        factory.setup.connect ((obj) => {
            var item = (Gtk.ListItem) obj;
            item.child = new Gtk.Label (null) {
                margin_start = 12,
                margin_end = 12,
                xalign = 0
            };
        });
        factory.bind.connect ((obj) => {
            var item = (Gtk.ListItem) obj;
            var location = (Location) item.item;
            var label = (Gtk.Label) item.child;
            label.label = location.name;
        });

        var selection_model = new Gtk.NoSelection (client.location_search.locations);

        var list_view = new Gtk.ListView (selection_model, factory) {
            single_click_activate = true,
            tab_behavior = ITEM
        };
        list_view.add_css_class (Granite.STYLE_CLASS_RICH_LIST);
        list_view.add_css_class (Granite.STYLE_CLASS_BACKGROUND);
        list_view.remove_css_class (Granite.STYLE_CLASS_VIEW);

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = list_view,
            vexpand = true,
            hexpand = true
        };

        var stack = new Gtk.Stack ();
        stack.add_child (loading_placeholder);
        stack.add_child (scrolled_window);

        var frame = new Gtk.Frame (null) {
            child = stack,
            margin_start = 12,
            margin_end = 12,
            margin_bottom = 12
        };

        var box = new Gtk.Box (VERTICAL, 6);
        box.append (header_bar);
        box.append (entry);
        box.append (frame);

        child = box;
        title = _("Location Search");

        entry.search_changed.connect (() => client.location_search.query = entry.text);

        list_view.activate.connect ((view, index) => {
            client.add_location ((Location) view.model.get_item (index));
            var navigation_view = (Adw.NavigationView) get_ancestor (typeof (Adw.NavigationView));
            navigation_view.pop ();
        });

        client.location_search.load.begin (() => stack.visible_child = scrolled_window);

        selection_model.items_changed.connect_after (() => {
            if (selection_model.n_items > 0) {
                list_view.scroll_to (0, NONE, null);
            }
        });
    }
}
