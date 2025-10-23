/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

/**
 * This class aggregates all warnings from all available providers.
 * By default providers can decide which warnings to expose at any time.
 * Some might always provide all warnings, some might provide no warnings, some only certain warnings.
 * The consumer can give hints however:
 * - Via the (un)pin_location methods the consumer can tell the providers to try to load warnings
 * for the given locations and keep them updated.
 * - Via the load_all_warnings and unload_all_warnings methods the consumer can tell the providers
 * to try to load as many warnings as possible.
 */
public class EmA.WarningAggregator : Object {
    public ProviderManager providers { get; construct; }

    private Gtk.FlattenListModel _warnings;
    public ListModel warnings { get { return _warnings; } }

    public WarningAggregator (ProviderManager providers) {
        Object (providers: providers);
    }

    construct {
        var warnings_lists = new ListStore (typeof (ListModel));

        foreach (var provider in providers.list_all ()) {
            warnings_lists.append (provider.warnings);
        }

        _warnings = new Gtk.FlattenListModel (warnings_lists);
    }

    // TODO: Do we want to go coordinates only or do we want to keep the custom location system?
    public void pin_location (Coordinate location) {

    }

    public void unpin_location (Coordinate location) {

    }

    public void load_all_warnings () {

    }

    public void unload_all_warnings () {

    }

    // This is also still to think about since areas are quite expensive to get and compute:
    public void require_area () {
        // Would require the area field to be set for warnings
    }

    public void unrequire_area () {

    }
}
