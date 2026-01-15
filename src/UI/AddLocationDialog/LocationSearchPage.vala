/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.LocationSearchPage : Adw.NavigationPage {
    public Client client { get; construct; }

    private LocationSearch location_search;

    private Gtk.SearchEntry entry;
    private Gtk.NoSelection selection_model;
    private Gtk.ListView list_view;

    public uint searching { get; private set; default = 0; }

    public LocationSearchPage (Client client) {
        Object (client: client);
    }

    construct {
        location_search = new LocationSearch ();

        var header_bar = new Adw.HeaderBar ();
        header_bar.add_css_class (Granite.STYLE_CLASS_FLAT);

        entry = new Gtk.SearchEntry () {
            margin_start = 12,
            margin_end = 12,
        };
        entry.stop_search.connect (() => activate_action_variant ("window.close", null));
        // We use text notify directly instead of search changed because we apply
        // the delay our selfves and we wan't to show the spinner as soon as the text changes
        entry.notify["text"].connect (on_search_changed);

        var placeholder = new Adw.StatusPage () {
            icon_name = "system-search-symbolic",
        };
        placeholder.add_css_class ("compact");
        entry.bind_property ("text", placeholder, "title", SYNC_CREATE, (binding, from_val, ref to_val) => {
            var text = from_val.get_string ();
            to_val.set_string (text.length > 0 ? _("No places found for %s").printf (text) : _("Search for places"));
            return true;
        });
        entry.bind_property ("text", placeholder, "description", SYNC_CREATE, (binding, from_val, ref to_val) => {
            var text = from_val.get_string ();
            to_val.set_string (text.length > 0 ? _("Try changing search terms") : _("Start typing to search…"));
            return true;
        });

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

        var content_stack = new Gtk.Stack ();
        content_stack.add_named (placeholder, "placeholder");
        content_stack.add_named (scrolled_window, "scrolled");
        selection_model.bind_property (
            "n-items", content_stack, "visible-child-name", SYNC_CREATE, (binding, from_val, ref to_val) => {
                to_val.set_string (from_val.get_uint () > 0 ? "scrolled" : "placeholder");
                return true;
            }
        );

        var searching_stack = new Gtk.Stack ();
        searching_stack.add_named (content_stack, "content");
#if ADWAITA
        searching_stack.add_named (new Adw.Spinner (), "spinner");
#else
        searching_stack.add_named (new Gtk.Spinner () { spinning = true }, "spinner");
#endif
        bind_property ("searching", searching_stack, "visible-child-name", SYNC_CREATE, (binding, from_val, ref to_val) => {
            to_val.set_string (from_val.get_uint () > 0 ? "spinner" : "content");
            return true;
        });

        var frame = new Gtk.Frame (null) {
            child = searching_stack,
            margin_start = 12,
            margin_end = 12,
            margin_bottom = 12
        };

        var box = new Gtk.Box (VERTICAL, 6);
        box.append (header_bar);
        box.append (entry);
        box.append (frame);

        child = box;
        title = _("Add Location");

        entry.map.connect ((_entry) => _entry.grab_focus ());

        list_view.activate.connect (on_activate);

        selection_model.items_changed.connect_after (on_items_changed);
    }

    private async void on_search_changed () {
        searching++;
        yield location_search.search (entry.text);
        searching--;
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

    private void on_activate (Gtk.ListView view, uint index) {
        client.subscribe ((Location) view.model.get_item (index));
        activate_action_variant ("window.close", null);
    }

    private void on_items_changed () {
        if (selection_model.n_items > 0) {
            list_view.scroll_to (0, NONE, null);
        }
    }
}
