/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.Location : Object, ListModel {
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

    public bool subscribed { get { return warnings != null; } }

    /**
     * Internal argument used for searching.
     */
    public uint current_relevancy { get; private set; default = 1; }

    private ListModel? warnings;

    private string[] name_tokens;

    internal Location (string provider_id, string location_id, string name) {
        Object (provider_id: provider_id, location_id: location_id, name: name);
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

    internal void set_warnings (ListModel? model) {
        if (warnings != null) {
            warnings.items_changed.disconnect (on_items_changed);
        }

        warnings = model;

        if (warnings != null) {
            warnings.items_changed.connect (on_items_changed);
        }
    }

    private void on_items_changed (uint pos, uint removed, uint added) {
        items_changed (pos, removed, added);
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

    public Type get_item_type () {
        return typeof (Warning);
    }

    public uint get_n_items () {
        if (warnings == null) {
            return 0;
        }

        return warnings.get_n_items ();
    }

    public Object? get_item (uint position) {
        if (warnings == null) {
            return null;
        }

        return warnings.get_item (position);
    }
}
