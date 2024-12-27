public class EmA.Germany : Provider {
    public const string ID = "germany";

    private HashTable<string, Warning> warnings_by_id; //Todo: Remove warnings also from here once they are outdated.

    construct {
        warnings_by_id = new HashTable<string, Warning> (str_hash, str_equal);
    }

    public async override void refresh_location (Location location) {
        var ars_normalized = location.id.splice (5, 12, "0000000"); // API Documentation tells us to replace the last seven digits with 0 and this is a 12 digit key.

        var file = File.new_for_uri ("https://warnung.bund.de/api31/dashboard/%s.json".printf (ars_normalized));

        try {
            var input_stream = yield file.read_async ();

            var parser = new Json.Parser ();
            yield parser.load_from_stream_async (input_stream);

            Warning[] updated_warnings = {};

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
                 * For a unique warning we only want one object so that all get refreshed at the same time.
                 */
                Warning warning;
                if (id in warnings_by_id) {
                    warning = warnings_by_id[id];
                } else {
                    warning = new Warning (id, location, title);
                    warnings_by_id[id] = warning;
                }

                updated_warnings += warning;

                refresh_warning.begin (warning);
            });

            location.update_warnings (updated_warnings);
        } catch (Error e) {
            warning ("FAILED TO GET INFO FROM SERVER: %s", e.message);
        }
    }

    private async void refresh_warning (Warning warn) {
        var file = File.new_for_uri ("https://warnung.bund.de/api31/warnings/%s.json".printf (warn.id));

        try {
            var input_stream = yield file.read_async ();

            var parser = new Json.Parser ();
            yield parser.load_from_stream_async (input_stream);

            var info = parser.get_root ().get_object ().get_array_member ("info").get_object_element (0);

            if (info == null) {
                warning ("Failed to get additional info");
                return;
            }

            warn.description = info.has_member ("description") ? info.get_string_member ("description") : null;
            warn.sender = info.has_member ("senderName") ? info.get_string_member ("senderName") : null;
            warn.event_kind = info.has_member ("event") ? info.get_string_member ("event") : null;
            warn.severity = info.has_member ("severity") ? info.get_string_member ("severity") : null;
            warn.onset = info.has_member ("onset") ? new DateTime.from_iso8601 (info.get_string_member ("onset"), null) : null;
            warn.expires = info.has_member ("expires") ? new DateTime.from_iso8601 (info.get_string_member ("expires"), null) : null;
            warn.instruction = info.has_member ("instruction") ? info.get_string_member ("instruction") : null;

            if (info.has_member ("web")) {
                var url = info.get_string_member ("web");

                try {
                    var base_uri = Uri.parse ("https://", NONE);
                    var uri = Uri.parse_relative (base_uri, url, NONE);

                    warn.web = "<a href=\"%s\">%s</a>".printf (uri.to_string (), url);
                } catch (Error e) {
                    warning ("Failed to parse URL: %s", e.message);
                    warn.web = url;
                }
            } else {
                warn.web = null;
            }

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

            if (warn.icon_name == null) {
                string event_code = "BBK-EVC-001";

                if (info.has_member ("eventCode")) {
                    info.get_array_member ("eventCode").foreach_element ((array, index, node) => {
                        if (node.get_object ().has_member ("value")) {
                            event_code = node.get_object ().get_string_member ("value");
                        }
                    });
                }

                get_icon.begin (warn, event_code);
            }

        } catch (Error e) {
            warning ("FAILED TO GET INFO FROM SERVER: %s", e.message);
        }
    }

    private async void get_icon (Warning warn, string event_code) {
        var uri = "https://warnung.bund.de/api31/appdata/gsb/eventCodes/%s.png".printf (event_code);
        IconCache.get_instance ().register_remote_icon.begin (event_code, uri);

        warn.icon_name = event_code;
    }

    public async override ListModel list_all_locations () {
        var list_store = new ListStore (typeof (Location));

        // Caching this costs us some performance the first time but makes subsequent loads nearly instantanious.
        var file = yield Utils.get_cached_file ("https://www.xrepository.de/api/xrepository/urn:de:bund:destatis:bevoelkerungsstatistik:schluessel:rs_2021-07-31/download/Regionalschl_ssel_2021-07-31.json");

        try {
            var input_stream = yield file.read_async ();

            var parser = new Json.Parser ();
            yield parser.load_from_stream_async (input_stream);

            var array = parser.get_root ().get_object ().get_array_member ("daten");
            array.foreach_element ((array, index, node) => {
                var inner_array = node.get_array ();
                var id = inner_array.get_string_element (0);
                var name = inner_array.get_string_element (1);
                list_store.append (new Location (ID, id, name));
            });
        } catch (Error e) {
            warning ("Failed to load locations: %s", e.message);
        }

        return list_store;
    }
}
