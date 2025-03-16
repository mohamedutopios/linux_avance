Voici une démonstration complète, claire et détaillée sur **les systèmes de fichiers virtuels `/proc` et `/sys` sous Linux**, leurs rôles, leurs usages, ainsi que la manipulation via `sysctl`.

---

# 🗂️ **1. Présentation du système de fichiers `/proc`**

Le dossier `/proc` est un système de fichiers virtuel fournissant une interface vers les données du noyau Linux en temps réel.

> **Caractéristiques :**
> - N'existe qu'en mémoire vive (pas réellement sur disque).
> - Fournit des informations dynamiques sur les processus, matériel et état du noyau.

---

## 📌 **Structure de `/proc`**

Quelques fichiers clés dans `/proc` :

- **Informations générales :**
  - `/proc/cpuinfo` : Informations sur le processeur.
  - `/proc/meminfo` : Utilisation de la mémoire vive.
  - `/proc/version` : Version exacte du noyau.
  - `/proc/uptime` : Durée depuis le démarrage.

- **Gestion des processus :**
  - `/proc/[PID]` : Dossier contenant les informations sur le processus avec PID donné.

- **Informations système :**
  - `/proc/modules` : Modules chargés.
  - `/proc/devices` : Périphériques connus du noyau.

---

## 🔧 **Exemples concrets avec `/proc` :**

### ▶️ Afficher les informations sur le CPU :

```bash
cat /proc/cpuinfo
```

### ▶️ Afficher les informations sur la mémoire :

```bash
cat /proc/meminfo
```

### ▶️ Liste des modules chargés :

```bash
cat /proc/modules
```

### ▶️ Visualiser l'état d’un processus :

Par exemple, pour le processus ayant le PID 1 (`systemd`) :

```bash
cat /proc/1/status
```

### ▶️ État des interruptions matérielles :

```bash
cat /proc/interrupts
```

---

# 🗂️ **2. `/sys` : le système virtuel « sysfs »**

`/sys` est un système de fichiers virtuel qui permet d'interagir directement avec le noyau et le matériel (périphériques) par des attributs.

- Utilisé principalement pour configurer dynamiquement des périphériques et interagir avec l’espace noyau.

---

## 📌 **Structure de `/sys`**

- `/sys/devices` : Hiérarchie complète du matériel détecté.
- `/sys/class` : Périphériques classés par catégorie (ex: réseau, stockage, etc.).
- `/sys/module` : Paramètres configurables des modules du noyau.
- `/sys/bus` : Informations sur les bus système (PCI, USB, etc.).
- `/sys/kernel` : Paramètres internes du noyau.

---

## 🔧 **Exemples concrets avec `/sys` :**

### ▶️ Identifier les périphériques réseau disponibles :

```bash
ls /sys/class/net/
```

### ▶️ Lire une adresse MAC d'une interface :

```bash
cat /sys/class/net/eth0/address
```

### ▶️ Lister les modules chargés :

```bash
ls /sys/module/
```

### ▶️ Voir les paramètres disponibles pour un module précis :

Par exemple pour le module `ipv6` :

```bash
ls /sys/module/ipv6/parameters/
```

---

# 🚩 **3. Gestion avancée avec `sysctl`**

`sysctl` permet de gérer dynamiquement les paramètres du noyau.

### 📌 **Structure des paramètres :**
Les paramètres sont généralement disponibles dans :
- `/proc/sys/`

Par exemple :
- `/proc/sys/net/ipv4/ip_forward` : active/désactive le routage IP.

### 🔧 **Exemple concret avec `sysctl` :**

**Vérifier l'état du routage IP :**
```bash
sudo sysctl net.ipv4.ip_forward
# ou
cat /proc/sys/net/ipv4/ip_forward
# ou
/sbin/sysctl net.ipv4.ip_forward
```

**Activer le routage IP temporairement :**
```bash
sudo sysctl -w net.ipv4.ip_forward=1
```

ou via le fichier :

```bash
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
```

**Vérification :**
```bash
sysctl net.ipv4.ip_forward
```

---

# ⚙️ **3. Gestion permanente avec sysctl.conf**

Les modifications effectuées directement via `sysctl` sont temporaires.  
Pour rendre un paramétrage persistant, utilise `/etc/sysctl.conf` ou `/etc/sysctl.d/*.conf`.

**Exemple de configuration persistante :**

Modifier `/etc/sysctl.conf` :
```bash
sudo nano /etc/sysctl.conf
```

Ajouter à la fin :
```ini
# Activer routage IP
net.ipv4.ip_forward=1

# Durcir la sécurité réseau
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.all.accept_redirects=0
```

### Recharger la configuration sans redémarrer :
```bash
sudo sysctl -p
```

---

# 🔍 **4. Utilitaire : sysTool**

`sysTool` est un utilitaire permettant de visualiser et de diagnostiquer facilement les périphériques et modules dans `/sys`.

### ▶️ **Installation :**
```bash
sudo apt install systool
```

### ▶️ **Utilisation concrète :**

Lister tous les périphériques PCI :
```bash
sudo systool -c pci
```

Lister les modules noyau chargés et leurs paramètres :
```bash
sudo systool -v -m <nom_du_module>
```

**Exemple :**
```bash
sudo systool -v -m ipv6
```

---

# 📚 **5. TP indicatif : Paramétrage avec sysctl**

Voici un TP simple que tu peux réaliser :

### 🔹 **Objectifs :**
- Activer le routage IP.
- Augmenter le nombre maximal de connexions TCP simultanées.
- Vérifier le paramétrage et le rendre persistant.

### ▶️ **Étape 1 : Activer le routage IP**
```bash
sudo sysctl -w net.ipv4.ip_forward=1
```

### ▶️ **Étape 2 : Augmenter les connexions TCP simultanées**
```bash
sudo sysctl -w net.core.somaxconn=4096
```

### ▶️ **Étape 3 : Rendre les modifications persistantes**
Édite `/etc/sysctl.d/99-tuning.conf` :
```bash
sudo nano /etc/sysctl.d/99-tuning.conf
```

Ajouter ces lignes :
```ini
net.ipv4.ip_forward=1
net.core.somaxconn=4096
```

Recharger :
```bash
sudo sysctl -p /etc/sysctl.d/99-tuning.conf
```

Vérifier la prise en compte des paramètres :
```bash
sysctl net.ipv4.ip_forward
sysctl net.core.somaxconn
```

---

# 🎯 **Résumé des commandes utiles**

| Commande                          | Description                                   |
|-----------------------------------|-----------------------------------------------|
| `cat /proc/cpuinfo`               | Infos CPU                                     |
| `cat /proc/meminfo`               | Infos Mémoire                                 |
| `ls /sys/class`                   | Lister classes périphériques                  |
| `sysctl -a`                       | Lister tous les paramètres noyau              |
| `sysctl -w clé=valeur`            | Modifier un paramètre temporairement          |
| `sysctl -p`                       | Charger configuration persistante             |
| `sudo systool -v -m module`       | Informations complètes sur un module          |

---

✅ **Conclusion :**

Tu as désormais une démonstration détaillée, réaliste et complète des systèmes virtuels `/proc` et `/sys`, leur gestion avec `sysctl` ainsi qu'un exemple pratique d'utilisation et d’automatisation des réglages.

Je reste disponible pour toute autre précision ou approfondissement !