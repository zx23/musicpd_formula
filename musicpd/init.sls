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
    - group: {{ musicpd.wheel_group }}
    - mode: '0644'
    - require:
      - pkg: musicpd
  cmd.wait:
    - name: 'service {{ musicpd.service }} restart'
    - user: root
    - watch:
      - pkg: musicpd
      - file: musicpd
  user.present:
    - name: {{ musicpd.user }}
    - shell: {{ musicpd.shell }}
    - fullname: {{ musicpd.fullname }}
    - require:
      - group: musicpd
      - pkg: musicpd
  group.present:
    - name: {{ musicpd.group }}

music_directory:
  file.directory:
    - name: {{ musicpd.global_config.music_directory }}
    - makedirs: True

playlist_directory:
  file.directory:
    - name: {{ musicpd.global_config.playlist_directory }}
    - makedirs: True

pid_directory:
  file.directory:
    - name: /var/mpd
    - makedirs: True
    - user: {{ musicpd.user }}
    - group: {{ musicpd.group }}
    - mode: '0755'
