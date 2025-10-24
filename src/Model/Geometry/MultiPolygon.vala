/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.MultiPolygon : Object {
    public int size { get { return polygons.size; } }

    private Gee.List<Polygon> polygons;

    public MultiPolygon.from_polygons (Polygon[] polygons) {
        this.polygons.add_all_array (polygons);
    }

    construct {
        polygons = new Gee.ArrayList<Polygon> ();
    }

    public void merge (MultiPolygon other) {
        polygons.add_all (other.polygons);
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
}
