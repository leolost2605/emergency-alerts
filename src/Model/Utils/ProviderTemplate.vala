/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public abstract class EmA.ProviderTemplate : Provider {
    private ListStore all_warnings;
    public override ListModel warnings { get { return all_warnings; } }

    public string name { get; protected set; }
    public bool supports_fill_for_point { get; protected set; }

    private Gee.HashSet<CountryCode> supported_country_codes;
    private bool refreshing = false;

    construct {
        all_warnings = new ListStore (typeof (Warning));
        supported_country_codes = new Gee.HashSet<CountryCode> ();
    }

    protected void add_supported_country_code (CountryCode code) {
        supported_country_codes.add (code);
    }

    public override bool is_location_supported (Location location) {
        return location.country_code == UNKNOWN || location.country_code in supported_country_codes;
    }

    public override async void refresh (Gee.Collection<Location>? locations) {
        if (refreshing || !NetworkMonitor.get_default ().network_available) {
            debug ("Skipping refresh for provider %s - already refreshing or no network", name);
            return;
        }

        if (locations != null && locations.is_empty) {
            debug ("Skipping refresh for provider %s - no locations given", name);
            all_warnings.remove_all ();
            return;
        }

        refreshing = true;

        var updated_warnings = new Gee.HashSet<Warning> ();

        if (locations != null && supports_fill_for_point) {
            foreach (var location in locations) {
                try {
                    yield fill_for_point (location.coordinate, updated_warnings);
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

    protected virtual async void fill_for_point (Coordinate coord, Gee.HashSet<Warning> updated_warnings) throws Error {
        critical ("Fill for point called on provider %s which does not support it. Did you set supports_fill_for_point to true?", name);
    }

    protected abstract async void fill_for_all (Gee.HashSet<Warning> updated_warnings) throws Error;

    protected async void load_warning (string id, Object? data, Gee.HashSet<Warning> updated_warnings) {
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

    protected abstract async MultiPolygon get_warning_area (string id, Object? data) throws Error;

    protected abstract async void fill_warning (Warning warning, Object? data) throws Error;
}
