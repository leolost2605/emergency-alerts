/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Leonhard (leo.kargl@proton.me)
 */

namespace EmA.CAP {
    public void fill_warning_details_from_alert (Warning warn, Json.Object alert) {
        if (alert.has_member ("id")) {
            if (warn.id != alert.get_string_member ("id")) {
                warning ("Warning ID mismatch between CAP alert and Warning object");
            }
        }

        if (alert.has_member ("sender")) {
            warn.sender_id = alert.get_string_member ("sender");
        }

        if (alert.has_member ("sent")) {
            var sent_str = alert.get_string_member ("sent");
            warn.sent = new DateTime.from_iso8601 (sent_str, null);
        }

        if (alert.has_member ("status") && alert.get_string_member ("status") != "Actual") {
            warning ("Only 'actual' status should be presented to the user");
        }

        if (alert.has_member ("msgType")) {
            // TODO: Do we want to use this information?
        }

        if (alert.has_member ("scope") && alert.get_string_member ("scope") != "Public") {
            warning ("Non-public CAP alerts should not be presented to the user");
        }

        if (alert.has_member ("info")) {
            var info = alert.get_array_member ("info").get_object_element (0);
            fill_warning_details_from_info (warn, info);
        }
    }

    public void fill_warning_details_from_info (Warning warn, Json.Object info) {
        if (info.has_member ("category")) {
            var category_array = info.get_array_member ("category");
            var categories = new Warning.Category[category_array.get_length ()];
            for (uint i = 0; i < category_array.get_length (); i++) {
                switch (category_array.get_string_element (i)) {
                    case "Geo":
                        categories[i] = Warning.Category.GEO;
                        break;
                    case "Met":
                        categories[i] = Warning.Category.MET;
                        break;
                    case "Safety":
                        categories[i] = Warning.Category.SAFETY;
                        break;
                    case "Security":
                        categories[i] = Warning.Category.SECURITY;
                        break;
                    case "Rescue":
                        categories[i] = Warning.Category.RESCUE;
                        break;
                    case "Fire":
                        categories[i] = Warning.Category.FIRE;
                        break;
                    case "Health":
                        categories[i] = Warning.Category.HEALTH;
                        break;
                    case "Env":
                        categories[i] = Warning.Category.ENVIRONMENT;
                        break;
                    case "Transport":
                        categories[i] = Warning.Category.TRANSPORT;
                        break;
                    case "Infra":
                        categories[i] = Warning.Category.INFRASTRUCTURE;
                        break;
                    case "CBRNE":
                        categories[i] = Warning.Category.CBRNE;
                        break;
                    case "Other":
                        categories[i] = Warning.Category.OTHER;
                        break;
                    default:
                        warning ("Unknown category in CAP info: %s".printf (category_array.get_string_element (i)));
                        break;
                }
            }
            warn.categories = new Gee.ArrayList<Warning.Category>.wrap (categories);
        }

        if (info.has_member ("event")) {
            warn.event = info.get_string_member ("event");
        }

        if (info.has_member ("responseType")) {
            // parse response types
        }

        if (info.has_member ("urgency")) {
            switch (info.get_string_member ("urgency")) {
                case "Immediate":
                    warn.urgency = IMMEDIATE;
                    break;
                case "Expected":
                    warn.urgency = EXPECTED;
                    break;
                case "Future":
                    warn.urgency = FUTURE;
                    break;
                case "Past":
                    warn.urgency = PAST;
                    break;
                case "Unknown":
                    warn.urgency = UNKNOWN;
                    break;
                default:
                    warning ("Unknown urgency in CAP info: %s".printf (info.get_string_member ("urgency")));
                    break;
            }
        }

        if (info.has_member ("severity")) {
            switch (info.get_string_member ("severity")) {
                case "Extreme":
                    warn.severity = EXTREME;
                    break;
                case "Severe":
                    warn.severity = SEVERE;
                    break;
                case "Moderate":
                    warn.severity = MODERATE;
                    break;
                case "Minor":
                    warn.severity = MINOR;
                    break;
                case "Unknown":
                    warn.severity = UNKNOWN;
                    break;
                default:
                    warning ("Unknown severity in CAP info: %s".printf (info.get_string_member ("severity")));
                    break;
            }
        }

        if (info.has_member ("certainty")) {
            switch (info.get_string_member ("certainty")) {
                case "Observed":
                    warn.certainty = OBSERVED;
                    break;
                case "Likely":
                    warn.certainty = LIKELY;
                    break;
                case "Possible":
                    warn.certainty = POSSIBLE;
                    break;
                case "Unlikely":
                    warn.certainty = UNLIKELY;
                    break;
                case "Unknown":
                    warn.certainty = UNKNOWN;
                    break;
                default:
                    warning ("Unknown certainty in CAP info: %s".printf (info.get_string_member ("certainty")));
                    break;
            }
        }

        if (info.has_member ("effective")) {
            var effective_str = info.get_string_member ("effective");
            warn.effective = new DateTime.from_iso8601 (effective_str, null);
        } else {
            // Per docs: If this item is not included, the effective time SHALL be assumed to be the same as in <sent>
            warn.effective = warn.sent;
        }

        if (info.has_member ("onset")) {
            var onset_str = info.get_string_member ("onset");
            warn.onset = new DateTime.from_iso8601 (onset_str, null);
        }

        if (info.has_member ("end")) {
            var end_str = info.get_string_member ("end");
            warn.end = new DateTime.from_iso8601 (end_str, null);
        }

        if (info.has_member ("expires")) {
            var expires_str = info.get_string_member ("expires");
            warn.expires = new DateTime.from_iso8601 (expires_str, null);
        }

        if (info.has_member ("senderName")) {
            warn.sender_name = info.get_string_member ("senderName");
        }

        if (info.has_member ("headline")) {
            warn.title = info.get_string_member ("headline");
        }

        if (info.has_member ("description")) {
            warn.description = info.get_string_member ("description");
        }

        if (info.has_member ("instruction")) {
            warn.instruction = info.get_string_member ("instruction");
        }

        if (info.has_member ("web")) {
            var url = info.get_string_member ("web");

            try {
                var base_uri = Uri.parse ("https://", NONE);
                var uri = Uri.parse_relative (base_uri, url, NONE);

                warn.web = "<a href=\"%s\">%s</a>".printf (uri.to_string (), url);
            } catch (Error e) {
                warning ("Failed to parse URL: %s", e.message);
                warn.web = url;
            }
        }
    }
}
