/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.LocationSearchPage : Adw.NavigationPage {
    public Client client { get; construct; }
    public Gtk.SizeGroup header_bar_size_group { get; construct; }

    private LocationSearch location_search;

    private Gtk.SearchEntry entry;
    private Gtk.NoSelection selection_model;
    private Gtk.ListView list_view;
    private Gtk.Stack stack;

    public LocationSearchPage (Client client, Gtk.SizeGroup header_bar_size_group) {
        Object (client: client, header_bar_size_group: header_bar_size_group);
    }

    construct {
        location_search = new LocationSearch ();

        var header_bar = new Adw.HeaderBar () {
            show_title = false
        };
        header_bar.add_css_class (Granite.STYLE_CLASS_FLAT);

        header_bar_size_group.add_widget (header_bar);

        entry = new Gtk.SearchEntry () {
            margin_start = 12,
            margin_end = 12
        };

        var placeholder = new Adw.StatusPage () {
            icon_name = "system-search-symbolic",
            title = _("Search for places"),
            description = _("Start typing to search…")
        };

        var factory = new Gtk.SignalListItemFactory ();
        factory.setup.connect (on_setup);
        factory.bind.connect (on_bind);

        selection_model = new Gtk.NoSelection (location_search.locations);

        list_view = new Gtk.ListView (selection_model, factory) {
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

        stack = new Gtk.Stack ();
        stack.add_named (placeholder, "placeholder");
        stack.add_named (scrolled_window, "scrolled");
        selection_model.bind_property (
            "n-items", stack, "visible-child-name", SYNC_CREATE, (binding, from_val, ref to_val) => {
                to_val.set_string (from_val.get_uint () > 0 ? "scrolled" : "placeholder");
                return true;
            }
        );

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

        entry.map.connect ((_entry) => _entry.grab_focus ());

        entry.search_changed.connect (on_search_changed);

        list_view.activate.connect (on_activate);

        selection_model.items_changed.connect_after (on_items_changed);
    }

    private void on_setup (Object obj) {
        var item = (Gtk.ListItem) obj;
        item.child = new LocationRow ();
    }

    private void on_bind (Object obj) {
        var item = (Gtk.ListItem) obj;
        var row = (LocationRow) item.child;
        row.bind ((Location) item.item);
    }

    private void on_search_changed () {
        location_search.search.begin (entry.text);
    }

    private void on_activate (Gtk.ListView view, uint index) {
        client.subscribe ((Location) view.model.get_item (index));
        activate_action_variant ("navigation.pop", null);
    }

    private void on_items_changed () {
        if (selection_model.n_items > 0) {
            list_view.scroll_to (0, NONE, null);
        }
    }
}
