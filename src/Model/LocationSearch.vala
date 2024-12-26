public class EmA.LocationSearch : Object {
    public unowned Client client { get; construct; }
    public ListModel locations { get; construct; }

    private string _query = "";
    public string query {
        get {
            return _query;
        }
        set {
            _query = value;
            locations_lists.items_changed (0, locations_lists.n_items, locations_lists.n_items);
        }
    }

    private ListStore locations_lists;

    public LocationSearch (Client client) {
        Object (client: client);
    }

    construct {
        locations_lists = new ListStore (typeof (ListModel));

        var flatten_model = new Gtk.FlattenListModel (locations_lists);

        var filter_model = new Gtk.FilterListModel (flatten_model, new Gtk.CustomFilter (filter_func)) {
            incremental = true
        };

        var sorter = new Gtk.NumericSorter (new Gtk.PropertyExpression (typeof (Location), null, "current-relevancy")) {
            sort_order = DESCENDING
        };

        var sort_model = new Gtk.SortListModel (filter_model, sorter);

        locations = sort_model;
    }

    public async void load () {
        foreach (var provider in client.providers.get_values ()) {
            var model = yield provider.list_all_locations ();
            locations_lists.append (model);
        }
    }

    public void cleanup () {
        locations_lists.remove_all ();
    }

    private bool filter_func (Object obj) {
        var location = (Location) obj;
        return location.update_relevancy (query) > 0;
    }
}
