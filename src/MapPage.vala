/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.MapPage : Adw.Bin {
    public Client client { get; construct; }

    private Shumate.SimpleMap simple_map;

    private Gee.List<WarningLayer> layers;

    public MapPage (Client client) {
        Object (client: client);
    }

    construct {
        layers = new Gee.LinkedList<WarningLayer> ();

        var source = new Shumate.RasterRenderer.from_url ("https://tile.openstreetmap.org/{z}/{x}/{y}.png");

        simple_map = new Shumate.SimpleMap () {
            map_source = source
        };

        child = simple_map;

        client.warnings.items_changed.connect (on_warnings_changed);
        on_warnings_changed (0, 0, (uint) client.warnings.get_n_items ());
    }

    private void on_warnings_changed (uint pos, uint removed, uint added) {
        for (uint i = pos; i < pos + removed; i++) {
            layers.remove_at ((int) pos);
        }

        for (uint i = pos; i < pos + added; i++) {
            var warning = (Warning) client.warnings.get_item (i);
            var layer = new WarningLayer (simple_map, warning);
            layers.insert ((int) i, layer);
        }
    }
}
