{% if 'BSD' in salt['grains.get']('os') %}
{% set group = 'wheel' %}
{% else %}
{% set group = 'root' %}
{% endif %}
{% from "musicpd/map.jinja" import musicpd with context %}

musicpd:
  pkg.installed:
    - name: {{ musicpd.package }}
  service.running:
    - name: {{ musicpd.service }}
    - enable: True
    - require:
      - pkg: musicpd
      - file: musicpd
      - file: music_directory
      - file: playlist_directory
      - user: musicpd
      - group: musicpd
  file.managed:
    - name: {{ musicpd.config }}
    - source: salt://musicpd/files/musicpd.conf.jinja
    - context:
        settings: {{ musicpd }}
    - template: jinja
    - user: root
    - group: {{ group }}
    - mode: '0644'
    - require:
      - pkg: musicpd
  cmd.wait:
    - name: 'service musicpd restart'
    - user: root
    - watch:
      - pkg: musicpd
      - file: musicpd
  user.present:
    - name: {{ musicpd.user }}
    - uid: {{ musicpd.uid }}
    - shell: {{ musicpd.shell }}
    - fullname: {{ musicpd.fullname }}
    - require:
      - group: musicpd
      - pkg: musicpd
  group.present:
    - name: {{ musicpd.group }}
    - gid: {{ musicpd.gid }}

music_directory:
  file.directory:
    - name: {{ musicpd.lookup.music_directory }}

playlist_directory:
  file.directory:
    - name: {{ musicpd.lookup.playlist_directory }}