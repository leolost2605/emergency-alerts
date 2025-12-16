/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public abstract class EmA.Location : Object {
    /**
     * The id of the location.
     */
    public string id { get; construct; }

    /**
     * The coordinate of the location.
     */
    public Coordinate coordinate { get; construct; }

    /**
     * The human readable name of the location.
     */
    public string name { get; construct; }

    /**
     * A description to closer identify the location. Usually the name of the country is enough.
     * However this can also be something entirely different.
     */
    public string description { get; construct; }

    /**
     * The country code of the location.
     */
    public CountryCode country_code { get; construct; }

    public virtual string? get_notes () {
        return null;
    }
}
