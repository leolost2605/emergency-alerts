/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.AddLocationDialog : Adw.Dialog {
    public Client client { get; construct; }

    public AddLocationDialog (Client client) {
        Object (client: client);
    }

    construct {
        var navigation_view = new Adw.NavigationView ();
        navigation_view.push (new LocationSearchPage (client));

        child = navigation_view;
        title = _("Add Location");
        content_width = 500;
    }
}
