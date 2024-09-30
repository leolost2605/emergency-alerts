# project name and programming language
project('io.github.leolost2605.ema', 'vala', 'c')

# Include the translations module
i18n = import('i18n')

# Set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

adw_dep = dependency('libadwaita-1')
granite_dep = dependency('granite-7')
gtk_dep = dependency('gtk4')
json_dep = dependency('json-glib-1.0')
soup_dep = dependency('libsoup-3.0')

ema_deps = [
    adw_dep,
    granite_dep,
    gtk_dep,
    json_dep,
    soup_dep
]

subdir('data')
subdir('po')
subdir('src')
