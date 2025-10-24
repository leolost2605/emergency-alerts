/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.Germany : Provider {
    public const string ID = "germany";

    private ListStore all_warnings;
    public override ListModel warnings { get { return all_warnings; } }

    private bool refreshing = false;

    construct {
        all_warnings = new ListStore (typeof (Warning));
    }

    public override async void refresh (Coordinate[]? locations) {
        // We ignore locations for now, as the API does not support location-based queries
        // (at least not based on coordinates)
        if (refreshing) {
            return;
        }

        refreshing = true;

        var message = new Soup.Message ("GET", "https://warnung.bund.de/api31/mowas/mapData.json");

        try {
            var input_stream = yield Utils.get_session ().send_async (message, Priority.DEFAULT, null);

            var parser = new Json.Parser ();
            yield parser.load_from_stream_async (input_stream);

            if (parser.get_root () == null) {
                warning ("Failed to refresh all locations: parsing failed");
                return;
            }

            var updated_warnings = new Gee.HashSet<Warning> ();

            var array = parser.get_root ().get_array ();
            for (uint i = 0; i < array.get_length (); i++) {
                var obj = array.get_object_element (i);
                var id = obj.get_string_member ("id");

                var warning = Warning.get_by_id (id);
                if (warning != null) {
                    updated_warnings.add (warning);
                    continue;
                }

                var area = yield get_warning_area (id);

                if (area == null) {
                    GLib.warning ("Failed to get warning area for id %s", id);
                    continue;
                }

                warning = new Warning (id, area);
                updated_warnings.add (warning);

                load_warning.begin (warning);
            }

            for (int i = (int) all_warnings.n_items - 1; i >= 0; i--) {
                var warn = (Warning) all_warnings.get_item (i);

                if (!updated_warnings.contains (warn)) {
                    all_warnings.remove (i);
                }
            }
        } catch (Error e) {
            warning ("Failed to get info from nina api: %s", e.message);
        }

        refreshing = false;
    }

    private async Area? get_warning_area (string id) {
        var message = new Soup.Message ("GET", "https://warnung.bund.de/api31/warnings/%s.geojson".printf (id));

        try {
            var input_stream = yield Utils.get_session ().send_async (message, Priority.DEFAULT, null);

            var parser = new Json.Parser ();
            yield parser.load_from_stream_async (input_stream);

            return yield Utils.get_area_from_geojson (parser.get_root ().get_object ());
        } catch (Error e) {
            warning ("Failed to refresh warning location: %s", e.message);
            return null;
        }
    }

    private async void load_warning (Warning warn) {
        var message = new Soup.Message ("GET", "https://warnung.bund.de/api31/warnings/%s.json".printf (warn.id));

        try {
            var input_stream = yield Utils.get_session ().send_async (message, Priority.DEFAULT, null);

            var parser = new Json.Parser ();
            yield parser.load_from_stream_async (input_stream);

            CAP.fill_warning_details_from_alert (warn, parser.get_root ().get_object ());

            var info = parser.get_root ().get_object ().get_array_member ("info").get_object_element (0);

            if (info == null) {
                warning ("Failed to get additional info");
                all_warnings.append (warn);
                return;
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

            string event_code = "BBK-EVC-001";

            var is_weather = warn.id.has_prefix ("dwd");
            var is_flood = warn.id.has_prefix ("lhp");

            if (is_weather) {
                event_code = "BBK-EVC-031";
            } else if (is_flood) {
                event_code = "BBK-EVC-038";
            }

            if (info.has_member ("eventCode")) {
                info.get_array_member ("eventCode").foreach_element ((array, index, node) => {
                    if (node.get_object ().has_member ("value")
                        && node.get_object ().get_string_member ("value").contains ("EVC")
                    ) {
                        event_code = node.get_object ().get_string_member ("value");
                    }
                });
            }

            get_icon.begin (warn, event_code);

            all_warnings.append (warn);
        } catch (Error e) {
            warning ("FAILED TO GET INFO FROM SERVER: %s", e.message);
        }
    }

    private async void get_icon (Warning warn, string event_code) {
        var uri = "https://warnung.bund.de/api31/appdata/gsb/eventCodes/%s.png".printf (event_code);
        warn.icon = yield IconCache.get_instance ().register_remote_icon (event_code, uri);
    }
}
