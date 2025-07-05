/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.Ukraine : Provider {
    public const string ID = "ukraine";

    public override string id { get { return ID; } }

    private Json.Parser? parser = null;

    private async void reload_json () {
        if (parser != null) {
            return;
        }

        parser = new Json.Parser ();

        var message = new Soup.Message ("GET", "https://ubilling.net.ua/aerialalerts/");

        try {
            var input_stream = yield Utils.get_session ().send_async (message, Priority.DEFAULT, null);

            yield parser.load_from_stream_async (input_stream);

            if (parser.get_root () == null) {
                warning ("failed to reload JSON: parsing failed");
            }
        } catch (Error e) {
            warning ("FAILED TO GET INFO FROM SERVER: %s", e.message);
        }

        Timeout.add_seconds_once (3, () => parser = null); // The info is cached for three seconds on the server side anyway
    }

    public async override void refresh_location (Location location) {
        yield reload_json ();

        //todo block while another is reloading json

        if (parser.get_root () == null) {
            warning ("Failed to refresh location %s: parsing failed", location.name);
            return;
        }

        var obj = parser.get_root ().get_object ().get_object_member ("states");

        if (!obj.has_member (location.name)) {
            warning ("Failed to refresh location %s: no data for this location", location.name);
            return;
        }

        var warning_obj = obj.get_object_member (location.name);

        Warning[] updated_warnings = {};

        if (warning_obj.get_boolean_member ("alertnow")) {
            var warn = new Warning (
                Uuid.string_random (),
                location,
                _("Air raid alert in %s").printf (location.name)
            );
            updated_warnings += warn;
        }

        location.update_warnings (updated_warnings);
    }

    public async override ListModel list_all_locations () {
        yield reload_json ();

        var list_store = new ListStore (typeof (Location));

        if (parser.get_root () == null) {
            warning ("Failed to list locations, parsing failed");
            return list_store;
        }

        var obj = parser.get_root ().get_object ().get_object_member ("states");
        obj.foreach_member ((obj, member_name, node) => {
            list_store.append (new Location (ID, member_name, member_name));
        });

        return list_store;
    }
}
