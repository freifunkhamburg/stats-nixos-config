hamburg.freifunk.net Statistik
===============================

Initiales Setup
-----
1. System starten
2. Passwörter liegen nach dem Start des ersten Dienstes jeweils unter `/var/lib/*/*.pw`
3. Nginx konfigurieren um ACME zu benutzen
4. services.influxdb.extraConfig.http.auth-enabled auf true setzen
5. Config für Collector anpassen in collector.nix
6. Grafana konfigurieren


Development
-----
Starten des Systems:
    QEMU_NET_OPTS="hostfwd=tcp:127.0.0.1:2222-:22,hostfwd=tcp:127.0.0.1:8080-:80" nixos-shell
Zugriff dann per SSH über 127.0.0.1:2222 und HTTP über 127.0.0.1:8080.
