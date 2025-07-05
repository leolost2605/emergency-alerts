/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.LocationSearch : Object {
    public unowned LocationsManager locations_manager { get; construct; }
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

    private Gtk.Filter filter;

    public LocationSearch (LocationsManager locations_manager) {
        Object (locations_manager: locations_manager);
    }

    construct {
        filter = new Gtk.CustomFilter (filter_func);

        var filter_model = new Gtk.FilterListModel (locations_manager.locations, filter) {
            incremental = true
        };

        var sorter = new Gtk.NumericSorter (new Gtk.PropertyExpression (typeof (Location), null, "current-relevancy")) {
            sort_order = DESCENDING
        };

        var sort_model = new Gtk.SortListModel (filter_model, sorter);

        locations = sort_model;
    }

    public async void load () {
        yield locations_manager.load_all ();
    }

    public void cleanup () {
        locations_manager.unload_all ();
        query = "";
    }

    private bool filter_func (Object obj) {
        var location = (Location) obj;
        return location.update_relevancy (query) > 0;
    }
}
