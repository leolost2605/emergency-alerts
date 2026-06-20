/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.ProviderManager : Object {
    private ListStore _providers;
    public ListModel providers { get { return _providers; } }

    construct {
        _providers = new ListStore (typeof (Provider));
        _providers.append (new Germany ());
        _providers.append (new Ukraine ());
        _providers.append (new USWeather ());
    }
}
