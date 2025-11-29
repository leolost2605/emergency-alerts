/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.ProviderManager : Object {
    private Gee.List<Provider> providers;

    construct {
        providers = new Gee.ArrayList<Provider> ();
        providers.add (new Germany ());
        providers.add (new Ukraine ());
        providers.add (new USWeather ());
    }

    public Provider[] list_all () {
        return providers.to_array ();
    }
}
