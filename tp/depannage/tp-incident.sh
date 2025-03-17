#!/bin/bash

(
# Incident réseau (DNS invalide)
echo "nameserver 10.123.123.123" | sudo tee /etc/resolv.conf >/dev/null
echo "[Incident] DNS configuré vers 10.123.123.123 (invalide)" >> /tmp/incidents.log

# Incident matériel (remplissage complet disque dur)
fallocate -l $(df --output=avail / | tail -1 | awk '{print $1}')K /tmp/fichier_rempli.img 2>/dev/null || \
dd if=/dev/zero of=/tmp/fichier_rempli.img bs=1M status=none
echo "[Incident] Disque rempli à 100% via /tmp/fichier_rempli.img" >> /tmp/incidents.log

# Incident surcharge CPU (processus consommant fortement le CPU)
( while :; do :; done ) &
echo "[Incident] Processus surcharge CPU lancé (PID: $!)" >> /tmp/incidents.log

# Fin de la génération d'incidents, auto-suppression du script
rm -f "$(readlink -f "$0")"
) &