/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

/**
 * This class aggregates all warnings from all available providers.
 * By default providers can decide which warnings to expose at any time.
 * Some might always provide all warnings, some might provide no warnings, some only certain warnings.
 * See {@link RefreshManager} for how to give hints on what warnings should be provided.
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
}
