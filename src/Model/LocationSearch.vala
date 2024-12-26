public class EmA.LocationSearch : Object {
    public unowned Client client { get; construct; }
    public ListModel locations { get; construct; }

    private ListStore locations_lists;

    public LocationSearch (Client client) {
        Object (client: client);
    }

    construct {
        locations_lists = new ListStore (typeof (ListModel));

        var flatten_model = new Gtk.FlattenListModel (locations_lists);

        locations = flatten_model;
    }

    public async void load () {
        foreach (var provider in client.providers.get_values ()) {
            var model = yield provider.list_all_locations ();
            locations_lists.append (model);
        }
    }
}
