L'administration du noyau Linux implique plusieurs commandes et outils permettant d'afficher, charger, décharger et configurer le noyau et ses modules. Voici une liste des commandes principales :

---

### 1. **Informations sur le noyau**
#### ➜ Afficher la version du noyau :
```bash
uname -r
```
#### ➜ Afficher des informations complètes sur le système :
```bash
uname -a
```
#### ➜ Afficher la version de distribution du système :
```bash
cat /etc/os-release
```
ou
```bash
lsb_release -a
```

---

### 2. **Gestion des modules du noyau**
#### ➜ Lister les modules chargés :
```bash
lsmod
```
#### ➜ Charger un module :
```bash
modprobe <nom_du_module>
```
ou
```bash
insmod <nom_du_module>.ko
```
(`insmod` nécessite le chemin absolu du module)

#### ➜ Décharger un module :
```bash
modprobe -r <nom_du_module>
```
ou
```bash
rmmod <nom_du_module>
```

#### ➜ Vérifier les informations d’un module :
```bash
modinfo <nom_du_module>
```

---

### 3. **Configuration et paramètres du noyau**
#### ➜ Lire les paramètres en cours :
```bash
sysctl -a
```
#### ➜ Modifier un paramètre du noyau temporairement :
```bash
sysctl -w net.ipv4.ip_forward=1
```
#### ➜ Appliquer une configuration de manière permanente (modification du fichier) :
```bash
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p  # Appliquer les changements
```

---

### 4. **Gestion des fichiers du noyau**
#### ➜ Afficher les logs du noyau :
```bash
dmesg | less
```
ou en temps réel :
```bash
dmesg -w
```

#### ➜ Afficher les fichiers de configuration :
```bash
ls /boot/
```

#### ➜ Vérifier les fichiers de configuration de GRUB :
```bash
cat /etc/default/grub
```

---

### 5. **Mettre à jour ou recompiler un noyau**
#### ➜ Installer une mise à jour du noyau :
(Dépend de la distribution)
- **Debian/Ubuntu** :
  ```bash
  sudo apt update && sudo apt upgrade linux-image-$(uname -r)
  ```
- **Red Hat/CentOS** :
  ```bash
  sudo yum update kernel
  ```
- **Arch Linux** :
  ```bash
  sudo pacman -Syu linux
  ```

#### ➜ Compiler un noyau depuis les sources :
1. Récupérer les sources :
   ```bash
   wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.6.tar.xz
   ```
2. Extraire :
   ```bash
   tar -xvf linux-6.6.tar.xz && cd linux-6.6
   ```
3. Configurer :
   ```bash
   make menuconfig
   ```
4. Compiler :
   ```bash
   make -j$(nproc)
   ```
5. Installer :
   ```bash
   sudo make modules_install
   sudo make install
   ```

---

### 6. **Gestion de GRUB (Bootloader)**
#### ➜ Mettre à jour GRUB après modification :
```bash
sudo update-grub  # Debian/Ubuntu
sudo grub2-mkconfig -o /boot/grub2/grub.cfg  # Red Hat/CentOS
```

#### ➜ Modifier les options du noyau au démarrage :
Éditer le fichier `/etc/default/grub` puis appliquer :
```bash
sudo update-grub
```

---

### 7. **Vérification des performances et ressources noyau**
#### ➜ Vérifier les processus en mode noyau :
```bash
ps -eo pid,comm,stat | grep "^ *[0-9]* [^ ]* D"
```
(`D` signifie qu’un processus est bloqué en attente d’I/O)

#### ➜ Surveiller l’activité des appels systèmes :
```bash
strace -p <PID>
```

#### ➜ Vérifier l’utilisation du processeur et de la mémoire en lien avec le noyau :
```bash
top
```
ou
```bash
htop
```

---

### **Conclusion**
Ces commandes permettent d’administrer le noyau Linux de manière efficace. Pour une administration avancée, il est aussi possible d'explorer :
- La compilation de noyau avec `make menuconfig`
- L’optimisation des modules pour les performances et la sécurité
- La gestion avancée du boot avec GRUB

Si tu veux une démonstration sur un cas particulier, dis-moi ! 🚀