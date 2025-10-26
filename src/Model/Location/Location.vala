/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.Location : Object {
    /**
     * The id of the location.
     */
    public string id { get; construct; }

    public Coordinate coordinate { get; construct; }

    /**
     * The human readable name of the location.
     */
    public string name { get; construct; }

    /**
     * The country this location is in.
     */
    public string country { get; construct; }

    public string country_code { get; construct; }

    internal Location (Coordinate coordinate, string name, string country, string country_code) {
        Object (coordinate: coordinate, name: name, country: country, country_code: country_code);
    }

    internal Location.from_variant (Variant variant) throws Error {
        double lat = 0, lon = 0;
        string name = "", country = "", country_code = "";

        if (variant.get_type_string () == "(ddsss)") {
            lat = variant.get_child_value (0).get_double ();
            lon = variant.get_child_value (1).get_double ();
            name = variant.get_child_value (2).get_string ();
            country = variant.get_child_value (3).get_string ();
            country_code = variant.get_child_value (4).get_string ();

            if (name == "") {
                throw new IOError.INVALID_ARGUMENT ("No name set for location");
            }
        } else {
            critical ("Tried to get location from invalid variant");
            throw new IOError.INVALID_ARGUMENT ("Invalid variant type for Location");
        }

        Object (coordinate: new Coordinate (lat, lon), name: name, country: country, country_code: country_code);
    }

    construct {
        id = "%f, %f".printf (coordinate.latitude, coordinate.longitude);
    }

    public Variant to_variant () {
        return new Variant.tuple ({
            new Variant.double (coordinate.latitude),
            new Variant.double (coordinate.longitude),
            new Variant.string (name),
            new Variant.string (country),
            new Variant.string (country_code)
        });
    }

    public string? get_notes () {
        // TODO: Don't hardcode this?
        switch (country_code) {
            case "??": return _("Country code unknown, alerts might not be supported");
            case "DE": return null;
            case "UA": return _("Only air raid alerts are currently supported");
            default: return _("Currently not supported");
        }
    }
}
