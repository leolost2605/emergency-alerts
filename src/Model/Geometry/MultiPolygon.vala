/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.MultiPolygon : Object, Area {
    public int size { get {return polygons.size; } }

    public Gee.List<Polygon> polygons { get; set; }

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
