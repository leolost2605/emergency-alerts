/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.ProviderManager : Object {
    private HashTable<string, Provider> providers;

    construct {
        providers = new HashTable<string, Provider> (str_hash, str_equal);
        providers[Germany.ID] = new Germany ();
    }

    public Provider[] list_all () {
        return providers.get_values_as_ptr_array ().data;
    }

    public new Provider? @get (string provider_id) {
        return providers[provider_id];
    }
}
