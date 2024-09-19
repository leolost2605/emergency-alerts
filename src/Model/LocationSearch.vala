public class Ema.LocationSearch : Object {
    public Soup.Session session { get; construct; }

    public ListModel locations { get; construct; }

    private ListStore list_store;

    public LocationSearch (Soup.Session session) {
        Object (session: session);
    }

    construct {
        list_store = new ListStore (typeof (Location));

        locations = list_store;

        refresh_map.begin ();
    }

    private async void refresh_map () {
        var message = new Soup.Message ("GET", "https://www.xrepository.de/api/xrepository/urn:de:bund:destatis:bevoelkerungsstatistik:schluessel:rs_2021-07-31/download/Regionalschl_ssel_2021-07-31.json");

        try {
            var input_stream = yield session.send_async (message, Priority.DEFAULT, null);

            var parser = new Json.Parser ();
            yield parser.load_from_stream_async (input_stream);

            var array = parser.get_root ().get_object ().get_array_member ("daten");
            array.foreach_element ((array, index, node) => {
                var inner_array = node.get_array ();
                var id = inner_array.get_string_element (0);
                var name = inner_array.get_string_element (1);
                list_store.append (new Location (id, name));
            });
        } catch (Error e) {
            warning ("Failed to load locations: %s", e.message);
        }
    }
}
