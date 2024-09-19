# project name and programming language
project('io.github.leolost2605.ema', 'vala', 'c')

# Include the translations module
i18n = import('i18n')

# Set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

#Translate and install our .desktop file
i18n.merge_file(
    input: 'data' / 'myapp.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: meson.project_source_root() / 'po',
    type: 'desktop',
    install: true,
    install_dir: get_option('datadir') / 'applications'
)

#Translate and install our .appdata file
i18n.merge_file(
    input: 'data' / 'myapp.metainfo.xml.in',
    output: meson.project_name() + '.metainfo.xml',
    po_dir: meson.project_source_root() / 'po',
    install: true,
    install_dir: get_option('datadir') / 'metainfo'
)

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

subdir('po')
subdir('src')
