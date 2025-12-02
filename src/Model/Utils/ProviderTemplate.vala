/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public abstract class EmA.ProviderTemplate : Provider {
    private ListStore all_warnings;
    public override ListModel warnings { get { return all_warnings; } }

    public string name { get; protected set; }
    public bool supports_fill_for_point { get; protected set; }

    private bool refreshing = false;

    construct {
        all_warnings = new ListStore (typeof (Warning));
    }

    public override async void refresh (Coordinate[]? locations) {
        if (refreshing || !NetworkMonitor.get_default ().network_available) {
            debug ("Skipping refresh for provider %s - already refreshing or no network", name);
            return;
        }

        refreshing = true;

        var updated_warnings = new Gee.HashSet<Warning> ();

        if (locations != null && supports_fill_for_point) {
            foreach (var coord in locations.copy ()) {
                try {
                    yield fill_for_point (coord, updated_warnings);
                } catch (Error e) {
                    Log.report_gerror (name, e, _("Failed to fill warnings for point: "));
                }
            }
        } else {
            try {
                yield fill_for_all (updated_warnings);
            } catch (Error e) {
                Log.report_gerror (name, e, _("Failed to fill warnings: "));
            }
        }

        for (uint i = 0; i < all_warnings.get_n_items (); i++) {
            var warn = (Warning) all_warnings.get_item (i);
            if (!updated_warnings.contains (warn)) {
                all_warnings.remove (i);
            }
        }

        refreshing = false;
    }

    protected abstract async void fill_for_point (Coordinate coord, Gee.HashSet<Warning> updated_warnings) throws Error;
    protected abstract async void fill_for_all (Gee.HashSet<Warning> updated_warnings) throws Error;

    protected async void load_warning (string id, Object data, Gee.HashSet<Warning> updated_warnings) {
        var warning = Warning.get_by_id (id);

        if (warning != null) {
            updated_warnings.add (warning);
            return;
        }

        try {
            var area = yield get_warning_area (id, data);

            warning = new Warning (id, area);
            yield fill_warning (warning, data);

            updated_warnings.add (warning);
            all_warnings.append (warning);
        } catch (Error e) {
            Log.report_gerror (name, e, _("Failed to load warning %s: ").printf (id));
        }
    }

    protected abstract async MultiPolygon get_warning_area (string id, Object data) throws Error;

    protected abstract async void fill_warning (Warning warning, Object data) throws Error;
}
