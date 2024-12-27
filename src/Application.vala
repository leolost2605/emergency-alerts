/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2023 Your Organization (https://yourwebsite.com)
 */

public class EmA.Application : Gtk.Application {
    private const OptionEntry[] OPTIONS = {
        { "background", 'b', NONE, NONE, out background }
    };

    private static bool background = false;

    private Client client;

    construct {
        application_id = "io.github.leolost2605.emergencyalerts";
        flags = HANDLES_COMMAND_LINE;

        add_main_option_entries (OPTIONS);
    }

    protected override void startup () {
        base.startup ();

#if ADWAITA
        Adw.init ();

        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/io/github/leolost2605/emergencyalerts/Application.css");
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
#else
        Granite.init ();
#endif

        hold ();

        client = new Client ();
    }

    protected override int command_line (ApplicationCommandLine commandline) {
        activate ();
        return 0;
    }

    protected override void activate () {
        if (background) {
            background = false;
            return;
        }

        var main_window = new Window (this, client);
        main_window.present ();
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }
}
