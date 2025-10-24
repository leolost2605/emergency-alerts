/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.GeoJSON.Feature : Object {
    public Object geometry { get; construct; }
    public Json.Object? properties { get; construct; }

    public Feature (Object geometry, Json.Object? properties) {
        Object (geometry: geometry, properties: properties);
    }
}

namespace EmA.GeoJSON {
    public async G parse_object_as_type<G> (Json.Object object) throws Error {
        var parsed_object = yield parse_object (object);

        if (!(parsed_object is G)) {
            throw new IOError.INVALID_ARGUMENT ("Parsed GeoJSON object is not of the expected type");
        }

        return (G) parsed_object;
    }

    public async Object parse_object (Json.Object object) throws Error {
        if (!object.has_member ("type")) {
            throw new IOError.FAILED ("Invalid GeoJSON object");
        }

        switch (object.get_string_member ("type")) {
            case "FeatureCollection":
                if (!object.has_member ("features")) {
                    throw new IOError.FAILED ("Invalid GeoJSON FeatureCollection: missing features");
                }

                var features = object.get_array_member ("features");
                var parsed_features = new Gee.ArrayList<Feature> ();

                for (uint i = 0; i < features.get_length (); i++) {
                    var feature_obj = features.get_object_element (i);
                    var parsed_feature = yield parse_object_as_type<Feature> (feature_obj);
                    parsed_features.add (parsed_feature);
                }

                return parsed_features;

            case "Feature":
                if (!object.has_member ("geometry")) {
                    throw new IOError.FAILED ("Invalid GeoJSON Feature: missing geometry");
                }

                var geometry = yield parse_object (object.get_object_member ("geometry"));
                return new Feature (
                    geometry, object.has_member ("properties") ? object.get_object_member ("properties") : null
                );

            case "MultiPolygon":
                if (!object.has_member ("coordinates")) {
                    throw new IOError.FAILED ("Invalid GeoJSON MultiPolygon: missing coordinates");
                }
                return yield parse_multi_polygon (object.get_array_member ("coordinates"));

            case "Polygon":
                if (!object.has_member ("coordinates")) {
                    throw new IOError.FAILED ("Invalid GeoJSON Polygon: missing coordinates");
                }
                return yield parse_polygon (object.get_array_member ("coordinates"));

            default:
                throw new IOError.FAILED ("Unsupported GeoJSON object type: %s".printf (object.get_string_member ("type")));
        }
    }

    public async MultiPolygon parse_multi_polygon (Json.Array multi_polygon) throws Error {
        var polygons = new Polygon[multi_polygon.get_length ()];
        for (uint i = 0; i < multi_polygon.get_length (); i++) {
            var polygon_array = multi_polygon.get_array_element (i);
            var polygon = yield parse_polygon (polygon_array);
            polygons[i] = polygon;
        }

        return new MultiPolygon.from_polygons (polygons);
    }

    public async Polygon parse_polygon (Json.Array polygon) throws Error {
        if (polygon.get_length () == 0) {
            throw new IOError.FAILED ("Invalid GeoJSON Polygon");
        }

        // We ignore holes since if an alert applies to an area surrounding an area it
        // probably applies to the surrounded area as well
        var border_ring = polygon.get_array_element (0);

        var coordinates = parse_line_string (border_ring);

        return new Polygon.from_coordinates (coordinates);
    }

    public Coordinate[] parse_line_string (Json.Array line_string) throws Error {
        var coordinates = new Coordinate[line_string.get_length ()];

        for (uint i = 0; i < line_string.get_length (); i++) {
            var position = line_string.get_array_element (i);
            coordinates[i] = parse_position (position);
        }

        return coordinates;
    }

    public Coordinate parse_position (Json.Array position) throws Error {
        if (position.get_length () < 2) {
            throw new IOError.FAILED ("Invalid GeoJSON position");
        }

        var longitude = position.get_double_element (0);
        var latitude = position.get_double_element (1);

        // We ignore altitude if present

        return new Coordinate (latitude, longitude);
    }
}
