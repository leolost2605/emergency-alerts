/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.LocationSearch : Object {
    public ProviderManager providers { get; construct; }
    public ListModel locations { get; construct; }

    private string _query = "";
    public string query {
        get {
            return _query;
        }
        set {
            _query = value;
            filter.changed (DIFFERENT);
        }
    }

    private ListStore locations_store;

    private Gtk.Filter filter;

    public LocationSearch (ProviderManager providers) {
        Object (providers: providers);
    }

    construct {
        locations_store = new ListStore (typeof (Location));

        filter = new Gtk.CustomFilter (filter_func);

        var filter_model = new Gtk.FilterListModel (locations_store, filter) {
            incremental = true
        };

        var sorter = new Gtk.NumericSorter (new Gtk.PropertyExpression (typeof (Location), null, "current-relevancy")) {
            sort_order = DESCENDING
        };

        var sort_model = new Gtk.SortListModel (filter_model, sorter);

        locations = sort_model;
    }

    public async void load () {
        foreach (var provider in providers.list_all ()) {
            yield provider.list_all_locations (add_location);
        }
    }

    private void add_location (Provider provider, string location_id, string name) {
        var location = new Location (provider.id, location_id, name);
        locations_store.append (location);
    }

    public void cleanup () {
        locations_store.remove_all ();
        query = "";
    }

    private bool filter_func (Object obj) {
        var location = (Location) obj;
        return location.update_relevancy (query) > 0;
    }
}
