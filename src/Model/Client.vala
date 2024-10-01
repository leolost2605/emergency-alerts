public class Ema.Client : Object {
    private static Settings settings = new Settings ("io.github.leolost2605.emergencyalerts");

    public ListStore locations { get; construct; }

    public LocationSearch location_search { get; construct; }

    private Soup.Session session;
    private HashTable<string, Warning> warnings_by_id;

    construct {
        warnings_by_id = new HashTable<string, Warning> (str_hash, str_equal);
        locations = new ListStore (typeof (Location));

        session = new Soup.Session ();

        location_search = new LocationSearch (session);

        var locs = settings.get_strv ("locations");
        foreach (var loc in locs) {
            locations.append (new Location.from_string (loc));
        }

        refresh ();
    }

    public void add_location (Location location) {
        locations.append (location);

        refresh_location.begin (location);

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
            refresh_location.begin ((Location) locations.get_item (i));
        }
    }

    private async void refresh_location (Location location) {
        var ars_normalized = location.id.splice (5, 12, "0000000");
        var message = new Soup.Message ("GET", "https://warnung.bund.de/api31/dashboard/%s.json".printf (ars_normalized));

        try {
            var input_stream = yield session.send_async (message, Priority.DEFAULT, null);

            var parser = new Json.Parser ();
            yield parser.load_from_stream_async (input_stream);

            var array = parser.get_root ().get_array ();
            array.foreach_element ((array, index, node) => {
                var obj = node.get_object ();

                var id = obj.get_string_member ("id");
                var translated_title_obj = obj.get_object_member ("i18nTitle");

                var locale = GLib.Intl.setlocale (ALL, null);

                string? title = null;
                if (translated_title_obj.has_member (locale)) {
                    title = translated_title_obj.get_string_member (locale);
                }

                var data_obj = obj.get_object_member ("payload").get_object_member ("data");

                if (title == null) {
                    title = data_obj.get_string_member ("headline");
                }

                /*
                 * For a certain warning we only want one object so that all get refreshed at the same time.
                 */
                Warning warning;
                if (id in warnings_by_id) {
                    warning = warnings_by_id[id];
                } else {
                    warning = new Warning (id, location, title);
                    warnings_by_id[id] = warning;
                }

                /*
                 * However the same warning may apply to multiple locations so each location tracks
                 * duplicates itself.
                 */
                location.append (warning);

                refresh_warning.begin (warning);
            });
        } catch (Error e) {
            warning ("FAILED TO GET INFO FROM SERVER: %s", e.message);
        }
    }

    private async void refresh_warning (Warning warn) {
        var message = new Soup.Message ("GET", "https://warnung.bund.de/api31/warnings/%s.json".printf (warn.id));

        try {
            var input_stream = yield session.send_async (message, Priority.DEFAULT, null);

            var parser = new Json.Parser ();
            yield parser.load_from_stream_async (input_stream);

            var info = parser.get_root ().get_object ().get_array_member ("info").get_object_element (0);

            if (info == null) {
                warning ("Failed to get additional info");
                return;
            }

            warn.description = info.has_member ("description") ? info.get_string_member ("description") : null;
            warn.sender = info.has_member ("senderName") ? info.get_string_member ("senderName") : null;
            warn.web = info.has_member ("web") ? info.get_string_member ("web") : null;
            warn.event_kind = info.has_member ("event") ? info.get_string_member ("event") : null;
            warn.severity = info.has_member ("severity") ? info.get_string_member ("severity") : null;
            warn.onset = info.has_member ("onset") ? new DateTime.from_iso8601 (info.get_string_member ("onset"), null) : null;
            warn.expires = info.has_member ("expires") ? new DateTime.from_iso8601 (info.get_string_member ("expires"), null) : null;
            warn.instruction = info.has_member ("instruction") ? info.get_string_member ("instruction") : null;

            if (info.has_member ("area")) {
                string areas = "";
                info.get_array_member ("area").foreach_element ((array, index, node) => {
                    if (node.get_object ().has_member ("areaDesc")) {
                        areas += node.get_object ().get_string_member ("areaDesc") + "\n";
                    }
                });
                warn.areas = areas.strip ();
            } else {
                warn.areas = null;
            }

        } catch (Error e) {
            warning ("FAILED TO GET INFO FROM SERVER: %s", e.message);
        }
    }
}
