/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.Location : Object {
    /**
     * The id of the provider this location originates from.
     */
    public string provider_id { get; construct; }

    /**
     * The id of the location.
     */
    public string id { get; construct; }

    /**
     * The human readable name of the location.
     */
    public string name { get; construct; }

    /**
     * A list of warnings that are currently active for this location.
     */
    public ListStore warnings { get; construct; }

    /**
     * Internal argument used for searching.
     */
    public uint current_relevancy { get; private set; default = 1; }

    private string[] name_tokens;

    public Location.from_string (string str) {
        var split = str.split ("=");

        string id, name, provider_id;
        if (split.length == 3) {
            provider_id = split[0];
            id = split[1];
            name = split[2];
        } else {
            provider_id = "unknown";
            id = "invalid id";
            name =  "Unknown Location";
            critical ("Unknown location found: %s", str);
        }

        Object (provider_id: provider_id, id: id, name: name);
    }

    public Location (string provider_id, string id, string name) {
        Object (provider_id: provider_id, id: id, name: name);
    }

    construct {
        warnings = new ListStore (typeof (Warning));

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

    public void update_warnings (Warning[] updated_warnings) {
        warnings.splice (0, warnings.get_n_items (), updated_warnings);
    }

    public string to_string () {
        return "%s=%s=%s".printf (provider_id, id, name);
    }

    public uint update_relevancy (string query) {
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
}
