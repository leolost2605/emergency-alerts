/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

public class EmA.Ukraine : Provider {
    public const string INSTRUCTION = // Source: https://unity.gov.ua/en/2024/07/08/what-to-do-if-you-hear-an-air-raid-warning/
_("""<b>On the street:</b>
- Find the closest shelter (underpass, subway station, parking lot, or bomb shelter) and get there as quickly as you can.
- Avoid buildings that are important for the country’s defense or other critical infrastructure.
<b>At home:</b>
- Make sure you turn off all electrical appliances, turn off the gas, and, if you can, put out any open sources of fire (stoves, fireplaces, etc.).
- Leave the premises as quickly as possible and head to the nearest shelter.
- Don’t use the elevators during an air raid. Just go down the stairs instead.
- If there’s no safe place to go in your building, stay inside and find a spot away from windows.""");

    private ListStore store;
    public override GLib.ListModel warnings { get { return store; } }

    private HashTable<string, MultiPolygon> areas;

    private bool refreshing = false;
    private DateTime? last_refresh_time;

    construct {
        store = new ListStore (typeof (Warning));

        refresh.begin (null);
    }

    public override bool is_location_supported (Location location) {
        return location.country_code == UA || location.country_code == UNKNOWN;
    }

    public async override void refresh (Gee.Collection<Location>? locations) {
        if (refreshing || !NetworkMonitor.get_default ().network_available || (last_refresh_time != null &&
            new DateTime.now_utc ().difference (last_refresh_time) < TimeSpan.SECOND * 10
        )) {
            return;
        }

        if (locations != null && locations.is_empty) {
            store.remove_all ();
            return;
        }

        refreshing = true;

        yield ensure_areas ();

        var message = new Soup.Message ("GET", "https://ubilling.net.ua/aerialalerts/");

        try {
            var input_stream = yield Utils.get_session ().send_async (message, Priority.DEFAULT, null);

            var parser = new Json.Parser ();
            yield parser.load_from_stream_async (input_stream);

            if (parser.get_root ()?.get_object () != null && parser.get_root ().get_object ().has_member ("states")) {
                var states = parser.get_root ().get_object ().get_object_member ("states");
                states.foreach_member (foreach_state);
            } else {
                Log.report_error (_("Ukraine"), _("Failed to refresh: parsing failed"));
            }
        } catch (Error e) {
            Log.report_gerror (_("Ukraine"), e);
        }

        last_refresh_time = new DateTime.now_utc ();
        refreshing = false;
    }

    private void foreach_state (Json.Object obj, string state_name, Json.Node node) requires (
        node.get_object () != null && node.get_object ().has_member ("alertnow")
    ) {
        var is_alert = node.get_object ().get_boolean_member ("alertnow");

        update_warning_for_state (state_name, is_alert);
    }

    private void update_warning_for_state (string state_name, bool is_alert) {
        // TODO: Include timestamp
        var id = "ua.gov.%s-alert".printf (state_name);

        var warning = Warning.get_by_id (id);

        if (is_alert && warning == null) {
            if (!(state_name in areas)) {
                Log.report_error (_("Ukraine"), _("No area data for state %s").printf (state_name));
                return;
            }

            warning = new Warning (id, areas[state_name]) {
                severity = EXTREME,
                title = _("Air Raid Alert"),
                description = _("An air raid alert is currently active in %s. Please take appropriate safety measures.").printf (state_name),
                event = _("Air Raid"),
                web = "<a href=\"https://visitukraine.today/de/blog/5628/how-to-act-during-air-raids-and-shelling-instructions-for-foreigners\">visitukraine.today</a>",
                instruction = INSTRUCTION
            };

            set_icon.begin (warning);

            store.append (warning);
        } else if (!is_alert && warning != null) {
            uint pos;
            if (store.find (warning, out pos)) {
                store.remove (pos);
            }
        }
    }

    private async void set_icon (Warning warn) {
        var uri = "https://warnung.bund.de/api31/appdata/gsb/eventCodes/BBK-EVC-052.png";
        warn.icon = yield IconCache.get_instance ().get_remote_icon (uri);
    }

    private async void ensure_areas () {
        if (areas != null) {
            return;
        }

        areas = new HashTable<string, MultiPolygon> (str_hash, str_equal);

        var mapping = get_geojson_mapping_table ();
        foreach (var key in mapping.get_keys ()) {
            const string base_uri = "https://raw.githubusercontent.com/EugeneBorshch/ukraine_geojson/refs/heads/master/%s.geojson";
            var file = yield Utils.get_file (base_uri.printf (mapping[key]));

            var parser = new Json.Parser ();

            try {
                yield parser.load_from_stream_async (yield file.read_async ());

                areas[key] = yield Utils.parse_and_merge_to_multipolygon (parser.get_root ().get_object ());
            } catch (Error e) {
                Log.report_gerror (mapping[key], e, _("Failed to load geo json: "));
            }
        }
    }

    private static HashTable<string, string> get_geojson_mapping_table () {
        var table = new HashTable<string, string> (str_hash, str_equal);
        table["Вінницька область"] = "UA_05_Vinnytska";
        table["Волинська область"] = "UA_07_Volynska";
        table["Луганська область"] = "UA_09_Luhanska";
        table["Дніпропетровська область"] = "UA_12_Dnipropetrovska";
        table["Донецька область"] = "UA_14_Donetska";
        table["Житомирська область"] = "UA_18_Zhytomyrska";
        table["Закарпатська область"] = "UA_21_Zakarpatska";
        table["Запорізька область"] = "UA_23_Zaporizka";
        table["Івано-Франківська область"] = "UA_26_Ivano_Frankivska";
        table["Київська область"] = "UA_32_Kyivska";
        table["Кіровоградська область"] = "UA_35_Kirovohradska";
        table["Автономна Республіка Крим"] = "UA_43_Avtonomna_Respublika_Krym";
        table["Львівська область"] = "UA_46_Lvivska";
        table["Миколаївська область"] = "UA_48_Mykolaivska";
        table["Одеська область"] = "UA_51_Odeska";
        table["Полтавська область"] = "UA_53_Poltavska";
        table["Рівненська область"] = "UA_56_Rivnenska";
        table["Сумська область"] = "UA_59_Sumska";
        table["Тернопільська область"] = "UA_61_Ternopilska";
        table["Харківська область"] = "UA_63_Kharkivska";
        table["Херсонська область"] = "UA_65_Khersonska";
        table["Хмельницька область"] = "UA_68_Khmelnytska";
        table["Черкаська область"] = "UA_71_Cherkaska";
        table["Чернігівська область"] = "UA_74_Chernihivska";
        table["Чернівецька область"] = "UA_77_Chernivetska";
        //  We don't have a separate geojson for Kyiv city, so we use the Kyiv oblast one
        table["м. Київ"] = "UA_32_Kyivska";
        return table;
    }
}
