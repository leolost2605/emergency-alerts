public class EmA.Client : Object {
    private static Settings settings = new Settings ("io.github.leolost2605.emergency-alerts");

    public ListStore locations { get; construct; }
    public LocationSearch location_search { get; construct; }

    public HashTable<string, Provider> providers { get; construct; }

    construct {
        providers = new HashTable<string, Provider> (str_hash, str_equal);
        providers[Germany.ID] = new Germany ();

        location_search = new LocationSearch (this);

        locations = new ListStore (typeof (Location));

        var locs = settings.get_strv ("locations");
        foreach (var loc in locs) {
            locations.append (new Location.from_string (loc));
        }

        refresh ();
        Timeout.add_seconds (30, () => {
            refresh ();
            return Source.CONTINUE;
        });
    }

    public void add_location (Location location) {
        for (int i = 0; i < locations.n_items; i++) {
            if (((Location) locations.get_item (i)).id == location.id) {
                return;
            }
        }

        locations.append (location);

        refresh_location (location);

        var as_string = location.to_string ();
        var saved_locations = settings.get_strv ("locations");

        if (as_string in saved_locations) {
            return;
        }

        saved_locations += as_string;
        settings.set_strv ("locations", saved_locations);
    }

    public void remove_location (string id) {
        var locs = settings.get_strv ("locations");

        string[] new_locs = {};
        foreach (var loc in locs) {
            if (!(id in loc)) {
                new_locs += loc;
            }
        }

        settings.set_strv ("locations", new_locs);

        for (int i = 0; i < locations.n_items; i++) {
            var location = (Location) locations.get_item (i);
            if (location.id == id) {
                locations.remove (i);
                break;
            }
        }
    }

    public void refresh () {
        for (int i = 0; i < locations.n_items; i++) {
            refresh_location ((Location) locations.get_item (i));
        }
    }

    private void refresh_location (Location location) {
        providers[location.provider_id].refresh_location.begin (location);
    }
}
