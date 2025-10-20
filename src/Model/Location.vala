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

    private Gee.ArrayList<string> search_tokens;

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

        string[] name_ascii_alternatives;
        string[] name_tokens = name.tokenize_and_fold ("", out name_ascii_alternatives);
        string[] country_ascii_alternatives;
        string[] country_tokens = country.tokenize_and_fold ("", out country_ascii_alternatives);

        search_tokens = new Gee.ArrayList<string> ();
        search_tokens.add_all_array (name_tokens);
        search_tokens.add_all_array (country_tokens);
        search_tokens.add_all_array (name_ascii_alternatives);
        search_tokens.add_all_array (country_ascii_alternatives);
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
            for (int i = 0; i < search_tokens.size; i++) {
                if (search_tokens[i].has_prefix (query_word)) {
                    if (i == 0) {
                        score += 30;
                    } else {
                        score += 20;
                    }
                    continue;
                }

                if (search_tokens[i].contains (query_word)) {
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
