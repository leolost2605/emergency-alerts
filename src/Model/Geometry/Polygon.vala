/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.Polygon : Object, Area {
    public int size { get { return border.size; } }

    private Gee.List<Coordinate> border;

    public Polygon.from_coordinates (Coordinate[] coordinates) {
        border.add_all_array (coordinates);
    }

    construct {
        border = new Gee.ArrayList<Coordinate> ();
    }

    public void add_point (Coordinate point) {
        border.add (point);
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

    public Gee.List<Gee.List<Coordinate>> get_border_rings () {
        var rings = new Gee.ArrayList<Gee.List<Coordinate>> ();
        rings.add (border);
        return rings;
    }
}
