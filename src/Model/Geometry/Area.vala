/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public interface EmA.Area : Object {
    public abstract bool contains_point (Coordinate point);
    public abstract Gee.List<Gee.List<Coordinate>> get_border_rings ();
}
