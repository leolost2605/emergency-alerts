/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.FixedLocation : Location {
    private const string LOCATION_VARIANT_TYPE_STRING = "(dda{sv})";

    public string country_code { get; construct; }

    internal FixedLocation (Coordinate coordinate, string name, string country, string country_code) {
        Object (
            id: "%f, %f".printf (coordinate.latitude, coordinate.longitude),
            coordinate: coordinate, name: name, description: country, country_code: country_code
        );
    }

    internal FixedLocation.from_variant (Variant variant) throws Error {
        if (!variant.is_of_type (new VariantType (LOCATION_VARIANT_TYPE_STRING))) {
            critical ("Tried to get location from invalid variant");
            throw new IOError.INVALID_ARGUMENT ("Invalid variant type for Location");
        }

        var lat = variant.get_child_value (0).get_double ();
        var lon = variant.get_child_value (1).get_double ();

        var info = (HashTable<string, Variant>) variant.get_child_value (2);
        var name = (string) info["name"] ?? "";
        var country = (string) info["country"] ?? "";
        var country_code = (string) info["country_code"] ?? "";

        if (name == "") {
            throw new IOError.INVALID_ARGUMENT ("No name set for location");
        }

        Object (
            id: "%f, %f".printf (lat, lon),
            coordinate: new Coordinate (lat, lon), name: name, description: country, country_code: country_code
        );
    }

    public Variant to_variant () {
        var info = new HashTable<string, Variant> (str_hash, str_equal);
        info["name"] = new Variant.string (name);
        info["country"] = new Variant.string (description);
        info["country_code"] = new Variant.string (country_code);

        var variant = new Variant.tuple ({
            new Variant.double (coordinate.latitude),
            new Variant.double (coordinate.longitude),
            info
        });
        assert (variant.is_of_type (new VariantType (LOCATION_VARIANT_TYPE_STRING)));
        return variant;
    }

    public override string? get_notes () {
        // TODO: Don't hardcode this?
        switch (country_code) {
            case "??": return _("Country code unknown, alerts might not be supported");
            case "DE": return null;
            case "UA": return _("Only air raid alerts are currently supported");
            case "US": return _("Only weather alerts are currently supported");
            default: return _("Currently not supported");
        }
    }
}
