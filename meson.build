# project name and programming language
project('io.github.leolost2605.emergency-alerts', 'vala', 'c')

i18n = import('i18n')
gnome = import('gnome')

# Set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

if get_option('adwaita')
  add_project_arguments('--define', 'ADWAITA', language: 'vala')
endif

adw_dep = dependency('libadwaita-1')
granite_dep = dependency('granite-7')
gtk_dep = dependency('gtk4')
json_dep = dependency('json-glib-1.0')
portal_dep = dependency('libportal')
soup_dep = dependency('libsoup-3.0')

ema_deps = [
    adw_dep,
    granite_dep,
    gtk_dep,
    json_dep,
    portal_dep,
    soup_dep
]

subdir('data')
subdir('po')
subdir('src')

gnome.post_install(
  glib_compile_schemas: true,
  gtk_update_icon_cache: true,
  update_desktop_database: true,
)
