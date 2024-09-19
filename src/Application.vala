/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2023 Your Organization (https://yourwebsite.com)
 */

public class Ema.Application : Gtk.Application {
    public Application () {
        Object (
            application_id: "io.github.myteam.myapp",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void startup () {
        base.startup ();

        Granite.init ();
    }

    protected override void activate () {
        var main_window = new Window (this);
        main_window.present ();
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }
}
