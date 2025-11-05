/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.Log : Object {
    private static GLib.Once<Log> instance;
    public static Log get_instance () {
        return instance.once (() => new Log ());
    }

    public signal void error_reported (string affected_locations, string error_message) {
        warning ("An error was reported for %s: %s".printf (affected_locations, error_message));
    }

    public static void report_error (string affected_locations, string error_message) {
        Log.get_instance ().error_reported (affected_locations, error_message);
    }

    public static void report_gerror (string affected_locations, Error error, string prefix = "") {
        report_error (affected_locations, prefix + error.message);
    }
}
