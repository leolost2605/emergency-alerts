/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.Germany : ProviderTemplate {
    private const string AREA_URL_TEMPLATE = "https://warnung.bund.de/api31/warnings/%s.geojson";
    private const string WARNING_URL_TEMPLATE = "https://warnung.bund.de/api31/warnings/%s.json";

    private const string[] MAP_DATA_URLS = {
        "https://warnung.bund.de/api31/mowas/mapData.json",
        "https://warnung.bund.de/api31/dwd/mapData.json",
        "https://warnung.bund.de/api31/lhp/mapData.json",
        // These are probably not relevant:
        // "https://warnung.bund.de/api31/katwarn/mapData.json",
        // "https://warnung.bund.de/api31/biwapp/mapData.json",
        // "https://warnung.bund.de/api31/police/mapData.json",
    };

    construct {
        name = _("Germany");
        add_supported_country_code (DE);

        // The API does not support location-based queries (at least not based on coordinates)
        supports_fill_for_point = false;
    }

    public override async void fill_for_all (Gee.HashSet<Warning> updated_warnings) throws Error {
        foreach (var url in MAP_DATA_URLS) {
            try {
                yield fill_for_end_point (updated_warnings, url);
            } catch (Error e) {
                Log.report_gerror (name, e, _("Failed to get warnings from %s").printf (url));
            }
        }
    }

    private async void fill_for_end_point (Gee.HashSet<Warning> updated_warnings, string url) throws Error {
        var root = yield Utils.get_json (url);

        var array = root.get_array ();
        for (uint i = 0; i < array.get_length (); i++) {
            var obj = array.get_object_element (i);
            var id = obj.get_string_member ("id");

            yield load_warning (id, null, updated_warnings);
        }
    }

    protected async override MultiPolygon get_warning_area (string id, Object? data) throws Error {
        var root = yield Utils.get_json (AREA_URL_TEMPLATE.printf (id));
        return yield Utils.parse_and_merge_to_multipolygon (root.get_object ());
    }

    protected async override void fill_warning (Warning warn, Object? data) throws Error {
        var root = yield Utils.get_json (WARNING_URL_TEMPLATE.printf (warn.id));

        CAP.fill_warning_details_from_alert (warn, root.get_object ());

        var info = root.get_object ().get_array_member ("info").get_object_element (0);

        if (info == null) {
            Log.report_error (_("Germany Warning %s".printf (warn.id)), _("Failed to get additional info"));
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
    }

    private async void get_icon (Warning warn, string event_code) {
        var uri = "https://warnung.bund.de/api31/appdata/gsb/eventCodes/%s.png".printf (event_code);
        warn.icon = yield IconCache.get_instance ().get_remote_icon (uri);
    }
}
