public class Ema.LocationSearchPage : Adw.NavigationPage {
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

        var filter_list_model = new Gtk.FilterListModel (client.location_search.locations, new Gtk.CustomFilter (match_func)) {
            incremental = true
        };

        var selection_model = new Gtk.NoSelection (filter_list_model);

        var list_view = new Gtk.ListView (selection_model, factory) {
            single_click_activate = true
        };
        list_view.add_css_class (Granite.STYLE_CLASS_RICH_LIST);

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = list_view,
            vexpand = true,
            hexpand = true
        };

        var box = new Gtk.Box (VERTICAL, 6);
        box.append (header_bar);
        box.append (entry);
        box.append (scrolled_window);

        child = box;
        title = _("Location Search");

        entry.search_changed.connect (() => client.location_search.locations.items_changed (0, client.location_search.locations.get_n_items (), client.location_search.locations.get_n_items ()));

        list_view.activate.connect ((view, index) => {
            client.add_location ((Location) view.model.get_item (index));
            var navigation_view = (Adw.NavigationView) get_ancestor (typeof (Adw.NavigationView));
            navigation_view.pop ();
        });
    }

    private bool match_func (Object? obj) {
        var location = (Location) obj;
        return location.name.contains (entry.text);
    }
}
