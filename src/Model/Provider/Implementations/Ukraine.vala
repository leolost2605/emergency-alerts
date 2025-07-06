/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.Ukraine : Provider {
    public const string ID = "ukraine";

    public override string id { get { return ID; } }

    private HashTable<string, ListStore> lists_by_location_id = new HashTable<string, ListStore> (str_hash, str_equal);

    private uint refresh_timeout_id = 0;

    public override ListModel subscribe (string location_id) {
        if (location_id in lists_by_location_id) {
            return lists_by_location_id[location_id];
        }

        var list = new ListStore (typeof (Warning));
        lists_by_location_id[location_id] = list;
        return list;
    }

    public override void unsubscribe (string location_id) {
        lists_by_location_id.remove (location_id);
    }

    private void queue_refresh () {
        if (refresh_timeout_id != 0) {
            return;
        }

        refresh.begin ();

        refresh_timeout_id = Timeout.add_seconds (3, () => {
            refresh_timeout_id = 0;
            return Source.REMOVE;
        });
    }

    private async void refresh () {
        var parser = new Json.Parser ();

        var message = new Soup.Message ("GET", "https://ubilling.net.ua/aerialalerts/");

        try {
            var input_stream = yield Utils.get_session ().send_async (message, Priority.DEFAULT, null);

            yield parser.load_from_stream_async (input_stream);

            if (parser.get_root () == null) {
                warning ("failed to reload JSON: parsing failed");
                return;
            }

            var obj = parser.get_root ().get_object ().get_object_member ("states");

            foreach (var location in lists_by_location_id.get_keys ()) {
                if (!obj.has_member (location)) {
                    warning ("Failed to update location %s: no data", location);
                    continue;
                }

                var list = lists_by_location_id[location];

                var warning_obj = obj.get_object_member (location);

                if (warning_obj.get_boolean_member ("alertnow") && list.n_items == 0) {
                    var warn = new Warning (
                        Uuid.string_random (),
                        _("Air raid alert in %s").printf (location)
                    );
                    list.append (warn);
                    get_icon.begin (warn, "BBK-EVC-052");
                } else if (!warning_obj.get_boolean_member ("alertnow") && list.n_items > 0) {
                    list.remove_all ();
                }
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

    public async override void refresh_location (string id) {
        queue_refresh ();
    }

    public async override void list_all_locations (ForeachLocationFunc func) {
        var parser = new Json.Parser ();

        var message = new Soup.Message ("GET", "https://ubilling.net.ua/aerialalerts/");

        try {
            var input_stream = yield Utils.get_session ().send_async (message, Priority.DEFAULT, null);

            yield parser.load_from_stream_async (input_stream);
        } catch (Error e) {
            warning ("Failed to load locations: %s", e.message);
            return;
        }

        if (parser.get_root () == null) {
            warning ("Failed to list locations, parsing failed");
            return;
        }

        var obj = parser.get_root ().get_object ().get_object_member ("states");
        obj.foreach_member ((obj, member_name, node) => {
            func (this, member_name, member_name);
        });
    }
}
