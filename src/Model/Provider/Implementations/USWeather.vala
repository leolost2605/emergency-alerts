/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.USWeather : ProviderTemplate {
    private const string BASE_URL = "https://api.weather.gov/alerts/active";
    private const string BASE_URL_FOR_POINT = "https://api.weather.gov/alerts/active?point=%f,%f";

    construct {
        name = _("US Weather");
        supports_fill_for_point = true;
    }

    protected override async void fill_for_point (Coordinate coord, Gee.HashSet<Warning> updated_warnings) throws Error {
        var node = yield Utils.get_json (BASE_URL_FOR_POINT.printf (coord.latitude, coord.longitude));

        var object = node.get_object ();

        if (object.has_member ("type") &&
            object.get_string_member ("type") == "https://api.weather.gov/problems/InvalidParameter" &&
            object.has_member ("detail") &&
            object.get_string_member ("detail") == "Parameter \"point\" is invalid: out of bounds"
        ) {
            // The point is out of bounds of the US but this would throw a parsing error for the geojson
            // so check for that case and just ignore the point
            return;
        }

        var feature_collection = yield GeoJSON.parse_object_as_type<Gee.List<GeoJSON.Feature>> (node.get_object ());

        foreach (var feature in feature_collection) {
            var id = feature.properties.get_string_member ("id");
            yield load_warning (id, feature, updated_warnings);
        }
    }

    protected override async void fill_for_all (Gee.HashSet<Warning> updated_warnings) throws Error {
        var node = yield Utils.get_json (BASE_URL);

        var feature_collection = yield GeoJSON.parse_object_as_type<Gee.List<GeoJSON.Feature>> (node.get_object ());

        foreach (var feature in feature_collection) {
            var id = feature.properties.get_string_member ("id");
            yield load_warning (id, feature, updated_warnings);
        }
    }

    protected async override MultiPolygon get_warning_area (string id, Object? data) throws Error {
        var properties = ((GeoJSON.Feature) data).properties;

        if (!properties.has_member ("affectedZones") ||
            properties.get_member ("affectedZones").get_node_type () != ARRAY
        ) {
            throw new IOError.FAILED ("Invalid affectedZones in US Weather warning");
        }

        var affected_zones = properties.get_array_member ("affectedZones");

        var result = new MultiPolygon ();

        for (uint i = 0; i < affected_zones.get_length (); i++) {
            var zone_uri = affected_zones.get_string_element (i);

            var zone_file = yield Utils.get_file (zone_uri);

            var input_stream = yield zone_file.read_async ();

            var parser = new Json.Parser ();
            yield parser.load_from_stream_async (input_stream);

            var zone = parser.get_root ().get_object ();

            var polygon = yield Utils.parse_and_merge_to_multipolygon (zone);
            result.merge (polygon);
        }

        return result;
    }

    protected async override void fill_warning (Warning warning, Object? data) throws Error {
        var properties = ((GeoJSON.Feature) data).properties;

        // The API has info and alert fields mixed in the one properties object
        CAP.fill_warning_details_from_alert (warning, properties);
        CAP.fill_warning_details_from_info (warning, properties);
    }

    private async void get_icon (Warning warn, string event_code) {
        var uri = "https://warnung.bund.de/api31/appdata/gsb/eventCodes/%s.png".printf (event_code);
        warn.icon = yield IconCache.get_instance ().get_remote_icon (uri);
    }
}
