/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.Polygon : Object {
    public int size { get { return border.size; } }

    private Gee.List<Coordinate> border;

    private Polygon? bounding_rect_cache = null;

    public Polygon.from_coordinates (Coordinate[] coordinates) {
        border.add_all_array (coordinates);
    }

    construct {
        border = new Gee.ArrayList<Coordinate> ();
    }

    public new Coordinate @get (int index) {
        return border[index];
    }

    public bool contains_point (Coordinate point) {
        var inside = false;

        var lat = point.latitude;
        var lon = point.longitude;

        var p1 = this[0];
        var p2 = new Coordinate (0, 0);

        for (int i = 1; i < size; i++) {
            p2 = this[i % size];

            if (lat > double.min (p1.latitude, p2.latitude)) {

                if (lat <= double.max (p1.latitude, p2.latitude)) {

                    if (lon <= double.max (p1.longitude, p2.longitude)) {
                        var lon_intersection = (lat - p1.latitude) * (p2.longitude - p1.longitude) / (p2.latitude - p1.latitude) + p1.longitude;

                        if (p1.longitude == p2.longitude || lon <= lon_intersection) {
                            inside = !inside;
                        }
                    }
                }
            }

            p1 = p2;
        }

        return inside;
    }

    /**
     * Returns the bounding rectangle of this. This aims to be fast so the bounding rect might be bigger
     * than necessary. It will also be cached after the first call.
     */
    public Polygon get_bounding_rect () {
        if (bounding_rect_cache == null) {
            bounding_rect_cache = compute_bounding_rect ();
        }

        return bounding_rect_cache;
    }

    private Polygon compute_bounding_rect () {
        double min_lat = 90;
        double max_lat = -90;
        double min_lon = 180;
        double max_lon = -180;

        foreach (var point in this) {
            if (point.latitude < min_lat) {
                min_lat = point.latitude;
            }
            if (point.latitude > max_lat) {
                max_lat = point.latitude;
            }
            if (point.longitude < min_lon) {
                min_lon = point.longitude;
            }
            if (point.longitude > max_lon) {
                max_lon = point.longitude;
            }
        }

        var corners = new Coordinate[] {
            new Coordinate (min_lat, min_lon),
            new Coordinate (min_lat, max_lon),
            new Coordinate (max_lat, max_lon),
            new Coordinate (max_lat, min_lon),
        };

        return new Polygon.from_coordinates (corners);
    }
}
