---
marp: true
title: Linux Advanced
theme: utopios
paginate: true
author: Mohamed Aijjou
header: "![h:70px](https://utopios-marp-assets.s3.eu-west-3.amazonaws.com/logo_blanc.svg)"
footer: "Utopios® Tous droits réservés"
---

<!-- _class: lead -->
<!-- _paginate: false -->

# Linux Advanced

---

## Sommaire

<div style="font-size:21px">

1. Architecture système Linux
2. Noyau Linux
3. Loadable Kernel Modules (LKM)
4. "/proc" et "/sys"
5. Dépannage matériel
6. Logicial Volume Manager (LVM)
7. BTRFS
8. Séquence d'amorçage
9. Gestion de l'activité
10. Maintenance du système
11. Gestion d'urgence en cas de crash
12. Maintenance de la configuration réseau
13. Contrôler et améliorer les performances
14. La sécurité

</div>

---

<!-- _class: lead -->
<!-- _paginate: false -->

## Architecture système Linux

---

## Architecture système Linux

#### Introduction

<br/>

<div style="font-size:35px">

- Le système Linux est structuré selon une architecture modulaire en couches distinctes, comprenant du matériel, un noyau, et des couches logicielles qui interagissent via des interfaces standardisées. 
- Cette architecture garantit sécurité, stabilité et modularité.

---

## Architecture système Linux

#### Vue d'ensemble de l'architecture Linux

<br/>

<div style="font-size:25px">

L'architecture générale de Linux est constituée de :

- **Matériel (Hardware)** : CPU, mémoire, périphériques d'entrée/sortie, disques durs, etc.
- **Noyau Linux (Kernel)** : couche centrale responsable de la gestion des ressources matérielles.
- **Modules du noyau (LKM)** : extensions dynamiques du noyau.
- **Shell et utilitaires système** : permettant à l'utilisateur d'interagir avec le système.
- **Bibliothèques système (glibc, libm, libpthread, etc.)** : assurent l'abstraction matérielle.
- **Applications utilisateur** : logiciels exécutés par les utilisateurs.



---

## Architecture système Linux

#### Vue d'ensemble de l'architecture Linux

<br/>

<div style="font-size:25px">

Schéma simplifié :

```
+-----------------------------------+
| Applications utilisateur          | Ring 3
+-----------------------------------+
| Bibliothèques système (glibc...)  | Ring 3
+-----------------------------------+
| Appels système (syscalls)         |
+-----------------------------------+
| Noyau Linux (Kernel + LKM)        | Ring 0
+-----------------------------------+
| Matériel (CPU, RAM, Disques...)   | Ring -1 (Hyperviseur/firmware)
+-----------------------------------+
```

</div>

---


## Architecture système Linux

#### Vue d'ensemble de l'architecture Linux


<div style="font-size:25px">

- Le système Linux est structuré en couches : 
   - en bas, le **matériel** (processeur, mémoire, périphériques) ; 
   - au-dessus, le **noyau** du système (le kernel) qui s’exécute en mode privilégié ; 
   - et tout en haut, l’**espace utilisateur** où tournent les applications et processus utilisateur. 
- Cette séparation entre espace noyau et espace utilisateur est fondamentale pour la stabilité et la sécurité : le noyau dispose d’un accès direct au matériel et gère les ressources, tandis que les programmes utilisateurs doivent passer par des appels contrôlés (appels système) pour solliciter ses services. 
- Cela offre une protection mémoire et empêche qu’un programme en espace utilisateur ne corrompe directement le noyau ou les autres processus

</div>

---

## Architecture système Linux

#### Vue d'ensemble de l'architecture Linux



<div style="font-size:28px">

- En pratique, lorsqu’une application veut accéder au disque, à la réseau ou à tout périphérique, elle effectue un appel système pour demander au noyau d’exécuter cette opération privilégiée. 
- Le noyau joue donc le rôle d’intermédiaire entre le matériel et les logiciels : 
   - il gère la **mémoire**, 
   - planifie les **processus**, 
   - fournit des abstractions comme les **systèmes de fichiers** et les **interfaces réseau**, 
   - et expose ces fonctionnalités aux applications via une interface bien définie.

</div>

---

## Architecture système Linux

#### Anneaux de protection (-1, 0, 3)

<div style="font-size:22px">

Linux tire parti des anneaux de protection pour assurer une isolation efficace entre les processus et le noyau :

| Anneau | Niveau           | Description                                                                                  |
|--------|------------------|----------------------------------------------------------------------------------------------|
| **-1** | Hyperviseur      | Virtualisation matérielle et firmware (BIOS/UEFI)                                            |
| **0**  | Mode noyau       | Accès total au matériel, opérations critiques, gestion des processus et du matériel          |
| **1**  | Non utilisé      | Non utilisé par Linux pour simplifier l'architecture                                         |
| **2**  | Non utilisé      | Non utilisé par Linux pour simplifier l'architecture                                         |
| **3**  | Mode utilisateur | Exécution des applications et bibliothèques. Accès limité et contrôlé au matériel via appels système |

Ainsi, les applications utilisateur n'ont pas d'accès direct au matériel, ce qui garantit sécurité et stabilité.

</div>

---

## Architecture système Linux

#### Anneaux de protection (-1, 0, 3)

<br>

<div style="font-size:22px">

<center>
<img src="assets\linux1.png" width="550px">
</center>


</div>

---

## Architecture système Linux

#### Anneaux de protection (-1, 0, 3)


<div style="font-size:24px">

- Sur les processeurs x86, le mode de protection par **anneaux** définit plusieurs niveaux de privilège matériel. 
- L’anneau le plus privilégié est le **ring 0**, utilisé par le noyau (mode superviseur), et l’anneau le moins privilégié est généralement le **ring 3**, utilisé par les applications en espace utilisateur (mode utilisateur). 
- En théorie, x86 offre 4 anneaux (0 à 3), mais la plupart des OS (Unix, Windows…) n’en utilisent que deux : ring 0 pour le noyau et ring 3 pour l’espace utilisateur.
- Linux suit ce modèle, laissant les anneaux intermédiaires inutilisés. 
- Cette séparation garantit qu’un programme en ring 3 ne peut pas exécuter d’instructions sensibles ni accéder directement au matériel sans passer par le ring 0 – toute tentative illégitime déclencherait une faute de protection générale interceptée par le noyau.


</div>

---

## Architecture système Linux

#### Anneaux de protection (-1, 0, 3)

<br>

<div style="font-size:30px">

- Linux suit ce modèle, laissant les anneaux intermédiaires inutilisés. 
- Cette séparation garantit qu’un programme en ring 3 ne peut pas exécuter d’instructions sensibles ni accéder directement au matériel sans passer par le ring 0 – toute tentative illégitime déclencherait une faute de protection générale interceptée par le noyau 


</div>

---

## Architecture système Linux

#### Anneaux de protection (-1, 0, 3)

<div style="font-size:20px">

- Les **hyperviseurs** (virtualisation) exploitent un niveau de privilège encore supérieur, parfois qualifié d’**anneau -1**. 
- En effet, les extensions de virtualisation matérielle (Intel VT-x, AMD-V) introduisent un mode d’exécution spécial pour l’hyperviseur, plus privilégié que le noyau lui-même.
- Dans ce mode, l’hyperviseur (comme KVM ou Xen) s’exécute en *ring -1* et peut contrôler entièrement la machine, tandis que chaque système d’exploitation invité tourne en ring 0 virtuel sous son contrôle. 
- Avant l’apparition de ces extensions, un hyperviseur devait ruser : par exemple, Xen exécutait les noyaux invités en ring 1 et interceptait via un mécanisme *trap-and-emulate* toutes les instructions privilégiées non autorisées.
- Désormais, grâce au *“mode root”* VT-x, l’hyperviseur dispose d’un niveau dédié (ring -1) pour arbitrer les accès, et les OS invités peuvent fonctionner en ring 0 sans compromettre l’isolement.
- En résumé, l’anneau 0 correspond au noyau Linux (et drivers) s’exécutant en mode superviseur, l’anneau 3 correspond aux programmes utilisateurs en mode non privilégié, et l’anneau -1 désigne le mode hyperviseur offert par la virtualisation matérielle pour héberger des machines virtuelles avec un niveau de privilège supérieur au noyau hôte.


</div>

---

## Architecture système Linux

#### Plateformes matérielles supportées par Linux

<br>

<div style="font-size:35px">

- Une grande force du noyau Linux est sa **portabilité** : il a été porté sur un très large éventail d’architectures matérielles. 
- Historiquement né sur PC Intel 80386, Linux prend aujourd’hui en charge des **douzaines d’architectures** différentes 


</div>

---

## Architecture système Linux

#### Plateformes matérielles supportées par Linux

<div style="font-size:20px">

- **x86 32 bits (IA-32)** et **x86 64 bits (x86_64/AMD64)** – architectures PC grand public, serveurs et laptops.
- **ARM** (32 bits ARMv7 et 64 bits ARMv8/AArch64) – omniprésent dans l’embarqué, les smartphones, tablettes et micro-ordinateurs (Raspberry Pi, etc.).
- **RISC-V** – une architecture RISC ouverte et modulaire, dont le support a été intégré au noyau Linux en 2022 ([RISC-V - Wikipedia](https://en.wikipedia.org/wiki/RISC-V#:~:text=Mainline%20support%20for%20RISC,15)).
- **PowerPC/POWER** – architecture RISC d’IBM utilisée sur des stations de travail, serveurs et anciens Mac (Linux tourne sur des systèmes IBM Power et sur d’anciennes consoles de jeu, par ex. la PS3, basées sur PowerPC).
- **MIPS** – architecture RISC autrefois répandue dans les systèmes embarqués et stations SGI, supportée par Linux.
- **SPARC** – architecture RISC de Sun/Oracle (stations Unix), également supportée par Linux.
- **IBM S/390 (s390x)** – l’architecture des grands mainframes IBM, que Linux supporte nativement depuis les années 2000.
- Autres plateformes : **Microblaze**, **MIPS64**, **SuperH**, **Alpha**, **PA-RISC**, **Itanium**, **ARC**, etc.


</div>

---

## Architecture système Linux

#### Plateformes matérielles supportées par Linux

<div style="font-size:25px">

- Par exemple, une distribution comme **Ubuntu** fournit des images officielles pour x86_64, ARM64, PowerPC64 et IBM System z , ce qui illustre la diversité du matériel pris en charge. 
- Linux peut ainsi fonctionner aussi bien sur un **microcontrôleur** de quelques MHz avec peu de mémoire que sur un **supercalculateur** massif – ce qui témoigne de son extrême adaptabilité. 
- Cette portabilité est rendue possible par l’abstraction que fait le noyau du matériel : une grande partie du code est indépendante de l’architecture, et seules quelques couches (gestion du CPU, interruptions, etc.) sont spécifiques à chaque architecture, souvent isolées dans des sous-répertoires du code source (par ex. `arch/x86`, `arch/arm`…). 
- Le support d’une nouvelle architecture consiste à implémenter ces couches d’adaptation. 


</div>

---

## Architecture système Linux

#### Noyau Linux et LKM (Loadable Kernel Modules)

<div style="font-size:25px">


### Noyau Linux (Kernel Linux)

- Le noyau Linux adopte une architecture dite **monolithique modulaire**. **Monolithique** signifie que le noyau constitue un seul bloc de code s’exécutant en espace noyau (par opposition à un micronoyau qui éclaterait les services en plusieurs processus séparés). 
- **Modulaire** signifie que ce noyau peut être étendu à chaud via des **modules chargeables**. 
- En effet, Linux est conçu de manière modulaire, permettant d’intégrer des composants du noyau sous forme de modules logiciels qu’on peut charger ou décharger dynamiquement selon les besoins.
- À la compilation du noyau, de nombreux drivers et fonctionnalités peuvent être sélectionnés soit comme faisant partie intégrante du noyau, soit comme modules séparés (.ko). 

</div>

---


## Architecture système Linux

#### Noyau Linux et LKM (Loadable Kernel Modules)

<div style="font-size:24px">

### Noyau Linux (Kernel Linux)

Le noyau est le cœur du système Linux, responsable :

- De la **gestion des ressources matérielles** (CPU, RAM, I/O, périphériques…).
- Du **multi-tâche et ordonnancement** (scheduler).
- De la **gestion mémoire** (allocation, pagination, mémoire virtuelle…).
- Du **système de fichiers** et du stockage (FS).
- De la **gestion des périphériques**.
- De la **sécurité et contrôle d’accès** (permissions, isolation, sécurité).
- Des **communications inter-processus** (IPC).
- Du **réseau et protocoles associés**. 


</div>

---

## Architecture système Linux

#### Noyau Linux et LKM (Loadable Kernel Modules)

<div style="font-size:26px">

<br>

### LKM (Loadable Kernel Modules)

Les modules du noyau Linux (LKM - Linux Kernel Modules) sont des composants logiciels qui peuvent être chargés ou déchargés dynamiquement pour :

- Étendre les fonctionnalités du noyau sans redémarrage (pilotes matériels, protocoles réseau, systèmes de fichiers).
- Faciliter la maintenance du système (correction de bugs, sécurité renforcée).
- Optimiser les ressources système en chargeant uniquement les modules nécessaires.


</div>

---


## Architecture système Linux

#### Noyau Linux et LKM (Loadable Kernel Modules)

<div style="font-size:24px">

### LKM (Loadable Kernel Modules)

- Les **LKM (Loadable Kernel Modules)** sont ces modules du noyau que l’on peut insérer ou retirer à l’exécution. Ils offrent plusieurs avantages : 
   - ajouter un **module** permet d’activer une nouvelle fonctionnalité (par exemple le support d’un nouveau système de fichiers ou d’un périphérique) sans recompiler ni redémarrer le noyau ; 
   - retirer un module libère les ressources associées si le matériel n’est plus utilisé. 
   Cela contribue à réduire la taille du noyau en mémoire (on ne charge que les composants nécessaires) et facilite les mises à jour (on peut remplacer un module par une nouvelle version sans interrompre tout le système). 
 - Par exemple, les pilotes de certaines cartes réseau, imprimantes ou systèmes de fichiers (ex: **ext4**, **XFS**, **NTFS**…) sont souvent fournis sous forme de modules que l’on insère au besoin. 


</div>

---


## Architecture système Linux

#### Noyau Linux et LKM (Loadable Kernel Modules)

<div style="font-size:20px">

### LKM (Loadable Kernel Modules)

- Un **module** est un morceau de code compilé séparément (fichier .ko) qui peut s’insérer dans l’espace noyau. 
- Le **noyau** garde une table des symboles exportés auxquels les modules peuvent faire référence. Lorsqu’on charge un module (avec `insmod` ou `modprobe`), le kernel réalise un lien à chaud : il résout les dépendances du module envers les symboles du noyau ou d’autres modules déjà chargés, alloue de la mémoire kernel pour ce module et y transfère l’exécution. 
- Une fois chargé, le **module** s’exécute avec les mêmes privilèges que le noyau lui-même. 
- Linux fournit des APIs internes pour écrire des **modules**, par exemple pour enregistrer un nouveau pilote, un protocole réseau, etc., via des fonctions d’initialisation qui sont appelées au chargement. 
- Inversement, lorsqu’on enlève un module (`rmmod`), le kernel appelle la routine de nettoyage du **module** puis libère ses ressources. 
- Notons qu’un **module** mal programmé (buggé) peut potentiellement planter le système autant qu’un bug dans le noyau monolithique, puisqu’il tourne au même niveau de privilège.


</div>

---

## Architecture système Linux

#### Noyau Linux et LKM (Loadable Kernel Modules)

<div style="font-size:25px">

### En résumé

***Linux combine le meilleur des deux approches :*** 

- un **noyau monolithique** performant où tout le code tourne en mode superviseur, et une **extensibilité modulaire** permettant une grande flexibilité d’utilisation. 
- La plupart des distributions livrent un noyau générique comportant un minimum de fonctionnalités en dur, et tout le reste en modules (fichiers situés sous `/lib/modules/` correspondant à la version du noyau). 
- Au démarrage, seul le noyau de base est chargé ;
- puis les modules nécessaires (pilotes, etc.) sont insérés à la volée (souvent automatiquement via udev ou *scripts* de démarrage) en fonction du matériel détecté ou des besoins du système 


</div>

---

## Architecture système Linux

#### Noyau Linux et LKM (Loadable Kernel Modules)

<br>
<div style="font-size:30px">

Commandes clés pour la gestion des modules :

```shell
lsmod             # Affiche les modules actuellement chargés
modprobe <module> # Charge un module spécifique
rmmod <module>    # Décharge un module
insmod <module>   # Charge directement un module (.ko)
modinfo <module>  # Affiche les informations sur un module
```

Exemple de gestion de module réseau :

```shell
sudo modprobe e1000e       # charger module pour carte réseau Intel
sudo rmmod e1000e          # décharger module
```

</div>

---

## Architecture système Linux

### Le système de fichiers racine (Root Filesystem `/`)

<div style="font-size:35px">

<br>

- Sous Linux, l’ensemble du système de fichiers s’organise autour d’une racine unique notée `/` (le *root filesystem*). 
- Cette arborescence respecte la norme **FHS (Filesystem Hierarchy Standard)**, un standard qui définit de manière cohérente les emplacements des fichiers et répertoires dans les systèmes de type Unix 

<div>

---


## Architecture système Linux

### Le système de fichiers racine (Root Filesystem `/`)

<div style="font-size:25px">

Le système de fichiers racine est la base hiérarchique d'un système Linux, à partir de laquelle tous les autres systèmes de fichiers sont montés.

#### Structure typique :

```
/
├── /bin      (binaires essentiels)
|── /boot    (fichiers liés au boot)
├── /etc       (configurations système)
├── /home       (répertoires utilisateurs)
├── /var       (fichiers variables, logs, bases de données)
├── /lib       (bibliothèques partagées essentielles)
├── /usr       (applications, bibliothèques, ressources)
├── /bin, /sbin (commandes essentielles du système)
├── /tmp       (fichiers temporaires)
└── /dev       (périphériques matériels)
```



---


## Architecture système Linux

### Le système de fichiers racine (Root Filesystem `/`)

<div style="font-size:25px">

- Cette organisation standardisée (définie par FHS) permet aux administrateurs et utilisateurs de s’y retrouver facilement, et aux logiciels de savoir où placer ou chercher leurs fichiers. 
- Ainsi, un programme pourra supposer que les configurations système sont dans `/etc`, que les logs vont dans `/var/log`, que les exécutables sont dans `/usr/bin` ou `/usr/local/bin` selon qu’ils sont distribués ou locaux, etc. 
- La plupart des distributions Linux respectent scrupuleusement FHS, avec parfois quelques légères variantes ou liens symboliques (ex : certaines distributions unifient `/bin` et `/usr/bin` en faisant de l’un un lien vers l’autre pour simplifier l’arborescence). 
- Mais globalement, un utilisateur passant d’une distribution à l’autre retrouvera la même structure de base, héritée de Unix.




---


## Architecture système Linux

### Pilotes de périphériques



<div style="font-size:29px">

- Les **pilotes de périphériques** (device drivers) sont des composants du noyau chargés de la communication avec le matériel ou avec des périphériques virtuels. 
- Leur rôle est de fournir une interface standard aux programmes pour utiliser un matériel donné, en se chargeant de tous les détails bas-niveau spécifiques à ce matériel.
- Sous Linux, quasiment tout est piloté par des drivers : les disques, les clés USB, les cartes réseau, les cartes graphiques, le son, mais aussi des éléments plus virtuels comme le système de fichiers pseudo `proc` ou les terminaux virtuels.

</div>

---

### Architecture système Linux

#### Pilotes de périphériques

<div style="font-size:22px">

Du point de vue du noyau, un driver s’enregistre généralement comme un certain **type de périphérique** :

- **Pilotes de caractère** (**char drivers**) – ils gèrent des périphériques accessibles comme un flux de bytes, octet par octet. Typiquement, ce sont les ports série, les terminaux, les périphériques d’entrée (clavier) ou encore `/dev/tty`, `/dev/random`, etc. Les opérations se font via des appels système comme `read()`/`write()` qui transfèrent des octets en séquence.
- **Pilotes de bloc** – ils gèrent des périphériques organisés en blocs adressables (typiquement 512 octets ou plus). Ce sont principalement les **disques** et autres supports de stockage (SSD, CD-ROM). Le noyau les utilise via le cache de blocs et les appels comme `read()/write()` en bloc, et ils permettent notamment de monter des systèmes de fichiers.
- **Pilotes réseau** – ils ne s’exposent pas comme des fichiers dans `/dev` mais dans la pile réseau du noyau. Leur interface est plus complexe : ils échangent des **trames** (frames) ou paquets réseau plutôt que de simples octets ou blocs. Exemples : driver d’interface Ethernet, Wi-Fi (émission/réception de paquets), interface loopback. L’accès se fait via l’API socket/Berkeley du côté user, qui s’appuie en interne sur ces drivers réseau.

</div>

---

### Architecture système Linux

#### Pilotes de périphériques

<div style="font-size:22px">


- En pratique, les drivers Linux peuvent être soit **intégrés statiquement** au noyau, soit compilés en **modules** chargeables (LKM) comme vu plus haut. 
- La plupart des distributions choisissent de livrer la majorité des drivers sous forme de modules, afin qu’ils ne soient chargés que si le matériel correspondant est présent. 
- Lorsque le système détecte un nouveau matériel (par exemple insertion d’une clé USB), un mécanisme comme **udev** va éventuellement charger le module kernel approprié pour le gérer. 
- Inversement, un module de pilote inutilisé peut être déchargé pour libérer de la mémoire. 
- On peut lister les drivers (modules) actuellement chargés avec la commande **`lsmod`**, qui affiche la liste des modules du noyau en mémoire. 
- Par exemple, on y verra des entrées comme `usb_storage`, `i915` (driver GPU Intel), etc., avec leur taille et combien de fois ils sont utilisés.
- Techniquement, `lsmod` ne fait qu’afficher le contenu de `/proc/modules` de façon formatée.

</div>

---

### Architecture système Linux

#### Pilotes de périphériques

<div style="font-size:28px">

##### En résumé : 

- Les pilotes de périphériques sont le code du noyau qui fait le lien avec le matériel. 
- Ils exposent souvent une abstraction (par ex. un fichier dans `/dev` ou une interface réseau) que les programmes peuvent utiliser via les appels système standard. 
- Grâce aux drivers, les applications n’ont pas besoin de connaître les détails du fonctionnement d’une carte réseau ou d’un disque : elles utilisent des appels génériques (`open`, `ioctl`, `read`, `write`…), et c’est le driver qui, en coulisse, traduira ces requêtes en opérations concrètes sur le matériel. 

</div>

---

### Architecture système Linux

#### Pilotes de périphériques

<div style="font-size:24px">

##### En résumé : 

- La qualité et la richesse de la logithèque de drivers font la force de Linux : aujourd’hui, le noyau supporte une quantité immense de matériels différents. 
- Des commandes utiles pour interagir avec les drivers sont par exemple :
  - `lsmod` – lister les modules chargés (donc les drivers actifs).
  - `modinfo <module>` – afficher des informations sur un module (version, description, licence, alias de matériel pris en charge).
  - `lspci`, `lsusb` – lister les périphériques PCI/USB connectés (pour savoir quels matériels sont présents et quels modules peuvent être associés).
  - Fichiers dans `/proc` ou `/sys` – ex : `/proc/interrupts` pour voir quels drivers utilisent quelles IRQ, `/sys/bus/usb/devices/.../driver` pour voir quel driver gère un périphérique USB spécifique, etc.

</div>

---

### Architecture système Linux

#### Bibliothèques partagées et statiques 

<div style="font-size:24px">

Les **bibliothèques** sont des collections de fonctions/utilitaires partagées par plusieurs programmes. Sous Linux (et Unix en général), il existe deux modes principaux de liaison aux bibliothèques : la liaison **statique** et la liaison **dynamique** (*partagée*). 

</div>

---

