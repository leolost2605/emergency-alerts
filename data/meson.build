install_data(
    'icons' / '128.svg',
    install_dir: get_option('datadir') / 'icons' / 'hicolor' / 'scalable' / 'apps',
    rename: meson.project_name() + '.svg'
)

install_data(
    'icons' / '128.svg',
    install_dir: get_option('datadir') / 'icons' / 'hicolor' / 'scalable@2' / 'apps',
    rename: meson.project_name() + '.svg'
)

install_data(
    'gschema.xml',
    install_dir: get_option('datadir') / 'glib-2.0' / 'schemas',
    rename: meson.project_name() + '.gschema.xml'
)

i18n.merge_file(
    input: meson.project_name() + '.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: meson.project_source_root() / 'po' / 'extra',
    type: 'desktop',
    install: true,
    install_dir: get_option('datadir') / 'applications'
)

metainfo_file = i18n.merge_file(
    input: meson.project_name() + '.metainfo.xml.in',
    output: meson.project_name() + '.metainfo.xml',
    po_dir: meson.project_source_root() / 'po' / 'extra',
    install: true,
    install_dir: get_option('datadir') / 'metainfo'
)

gresource = gnome.compile_resources(
    'gresource',
    'gresource.xml',
    source_dir: 'data',
    dependencies: metainfo_file
)
