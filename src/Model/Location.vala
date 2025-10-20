/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.Location : Object {
    /**
     * The id of the location.
     */
    public string id { get; construct; }

    /**
     * The id of the provider that this location belongs to
     */
    public string provider_id { get; construct; }

    /**
     * The _provider given_  id for this location
     */
    public string location_id { get; construct; }

    /**
     * The human readable name of the location.
     */
    public string name { get; construct; }

    /**
     * The country this location is in.
     */
    public string country { get; construct; }

    /**
     * Internal argument used for searching.
     */
    public uint current_relevancy { get; private set; default = 1; }

    private string[] name_tokens;

    internal Location (string provider_id, string location_id, string name, string country) {
        Object (provider_id: provider_id, location_id: location_id, name: name, country: country);
    }

    internal Location.from_variant (Variant variant) {
        string provider_id = "", location_id = "", name = "", country = "";

        if (variant.get_type_string () == "(ssss)") {
            provider_id = variant.get_child_value (0).get_string ();
            location_id = variant.get_child_value (1).get_string ();
            name = variant.get_child_value (2).get_string ();
            country = variant.get_child_value (3).get_string ();
        } else {
            critical ("Tried to get location from invalid variant");
        }

        Object (provider_id: provider_id, location_id: location_id, name: name, country: country);
    }

    construct {
        id = provider_id + "-" + location_id;

        string[] ascii_alternatives;
        string[] tokens = name.tokenize_and_fold ("", out ascii_alternatives);

        name_tokens = new string[tokens.length + ascii_alternatives.length];

        for (int i = 0; i < name_tokens.length; i++) {
            if (i < tokens.length) {
                name_tokens[i] = tokens[i];
            } else {
                name_tokens[i] = ascii_alternatives[i - tokens.length];
            }
        }
    }

    internal uint update_relevancy (string query) {
        if (query.strip () == "") {
            current_relevancy = 1;
            return current_relevancy;
        }

        int score = 0;
        string[] query_words = query.tokenize_and_fold ("", null);

        // TODO: Make better
        foreach (var query_word in query_words) {
            for (int i = 0; i < name_tokens.length; i++) {
                if (name_tokens[i].has_prefix (query_word)) {
                    if (i == 0) {
                        score += 30;
                    } else {
                        score += 20;
                    }
                    continue;
                }

                if (name_tokens[i].contains (query_word)) {
                    if (i == 0) {
                        score += 10;
                    } else {
                        score += 5;
                    }
                }
            }
        }

        current_relevancy = score;

        return current_relevancy;
    }

    public Variant to_variant () {
        return new Variant.tuple ({
            new Variant.string (provider_id),
            new Variant.string (location_id),
            new Variant.string (name),
            new Variant.string (country)
        });
    }
}
