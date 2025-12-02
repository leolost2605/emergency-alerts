/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.MultiPolygon : Object {
    public int size { get { return polygons.size; } }

    private Gee.List<Polygon> polygons;

    private Polygon? bounding_rect_cache = null;

    public MultiPolygon.from_polygons (Polygon[] polygons) {
        this.polygons.add_all_array (polygons);
    }

    construct {
        polygons = new Gee.ArrayList<Polygon> ();
    }

    public void merge (MultiPolygon other) {
        polygons.add_all (other.polygons);
        bounding_rect_cache = null;
    }

    public new Polygon @get (int index) {
        return polygons[index];
    }

    public bool contains_point (Coordinate point) {
        foreach (var polygon in this) {
            if (polygon.contains_point (point)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Returns the bounding rectangle of this. This aims to be fast so the bounding rect might be bigger
     * than necessary. It will also be cached after the first call. This means if the multipolygon or rather
     * one of its polygons is modified after the first call to this, this might return an incorrect result.
     * There currently is no way to invalidate the cache (only {@link merge} automatically invalidates it).
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

        foreach (var polygon in this) {
            foreach (var point in polygon) {
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
