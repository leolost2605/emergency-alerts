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
    public ListModel providers { private get; construct; }

    private Gtk.FlattenListModel _warnings;
    public ListModel warnings { get { return _warnings; } }

    public WarningAggregator (ListModel providers) {
        Object (providers: providers);
    }

    construct {
        var warnings_lists = new Gtk.MapListModel (providers, map_func);

        _warnings = new Gtk.FlattenListModel (warnings_lists);
    }

    private static Object map_func (owned Object obj) {
        var provider = (Provider) obj;
        return provider.warnings;
    }
}
