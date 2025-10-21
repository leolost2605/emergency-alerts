/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Leonhard (leo.kargl@proton.me)
 */

public class EmA.IconCache : Object {
    private static IconCache? _instance = null;
    public static IconCache get_instance () {
        if (_instance == null) {
            _instance = new IconCache ();
        }

        return _instance;
    }

    public signal void icon_loaded (string uri);

    private HashTable<string, FileIcon?> icons = new HashTable<string, FileIcon> (str_hash, str_equal);

    public async Icon get_remote_icon (string uri) {
        if (uri in icons) {
            if (icons[uri] != null) {
                return icons[uri];
            }

            // We did already register but haven't loaded yet

            ulong icon_loaded_id = icon_loaded.connect ((loaded_uri) => {
                if (loaded_uri == uri) {
                    Idle.add (() => {
                        get_remote_icon.callback ();
                        return Source.REMOVE;
                    });
                }
            });

            yield;

            disconnect (icon_loaded_id);

            return icons[uri];
        }

        // Prevent multiple registers for the same icon while we're loading it
        icons[uri] = null;

        var file = yield Utils.get_file (uri);

        icons[uri] = new FileIcon (file);

        icon_loaded (uri);

        return icons[uri];
    }
}
