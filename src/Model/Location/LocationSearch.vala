/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.LocationSearch : Object {
    private ListStore store;
    public ListModel locations { get { return store; } }

    private Cancellable? cancellable;

    construct {
        store = new ListStore (typeof (Location));
    }

    public async void search (string search_term) {
        if (cancellable != null) {
            cancellable.cancel ();
        }

        cancellable = new Cancellable ();

        var message = new Soup.Message ("GET", "https://photon.komoot.io/api/?q=%s&limit=%d".printf (Uri.escape_string (search_term), 10));

        try {
            var input_stream = yield Utils.get_session ().send_async (message, Priority.DEFAULT, cancellable);

            var parser = new Json.Parser ();
            yield parser.load_from_stream_async (input_stream, cancellable);

            store.remove_all ();

            parse_geo_json (parser.get_root ().get_object ());
        } catch (IOError.CANCELLED e) {
            // Ignore cancelled errors
        } catch (Error e) {
            warning ("Failed to search forward via geocode: %s", e.message);
        }
    }

    private void parse_geo_json (Json.Object root) {
        if (root.get_string_member ("type") != "FeatureCollection") {
            warning ("Invalid GeoJSON response");
            return;
        }

        var features = root.get_array_member ("features");
        features.foreach_element (parse_feature);
    }

    private void parse_feature (Json.Array array, uint index, Json.Node node) {
        var feature = node.get_object ();
        if (feature.get_string_member ("type") != "Feature") {
            return;
        }

        var geometry = feature.get_object_member ("geometry");
        if (geometry.get_string_member ("type") != "Point") {
            return;
        }

        var coordinates = geometry.get_array_member ("coordinates");
        if (coordinates.get_length () != 2) {
            return;
        }

        double lon = coordinates.get_double_element (0);
        double lat = coordinates.get_double_element (1);

        var properties = feature.get_object_member ("properties");
        var location = parse_location (lat, lon, properties);

        store.append (location);
    }

    private Location parse_location (double lat, double lon, Json.Object properties) {
        var name = parse_name (properties);

        var country = "";
        if (properties.has_member ("country")) {
            country = properties.get_string_member ("country");
        }

        return new Location (new Coordinate (lat, lon), name, country);
    }

    private string parse_name (Json.Object properties) {
        var name = properties.get_string_member ("name");
        if (name != null) {
            return name;
        }

        var housenumber = properties.get_string_member ("housenumber");
        var street = properties.get_string_member ("street");
        var city = properties.get_string_member ("city");
        var state = properties.get_string_member ("state");
        var country = properties.get_string_member ("country");

        var parts = new GenericArray<string> ();

        if (housenumber != null && street != null) {
            parts.add (housenumber + " " + street);
        } else if (street != null) {
            parts.add (street);
        }

        if (city != null) {
            parts.add (city);
        }

        if (state != null) {
            parts.add (state);
        }

        if (country != null) {
            parts.add (country);
        }

        return string.joinv (", ", parts.data);
    }
}
