/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.Coordinate : Object {
    public double latitude { get; construct; } // Y aka North South
    public double longitude { get; construct; } // X aka East West

    public Coordinate (double latitude, double longitude) {
        Object (latitude: latitude, longitude: longitude);
    }
}
