### **🛠️ Démonstration complète sur LVM (Logical Volume Manager) et Device Mapper sous Linux**
Nous allons voir **pas à pas** comment configurer **LVM** sur ta **VM Vagrant sous VirtualBox**.  
Cela inclut :
1. **Présentation de LVM et Device Mapper**
2. **Création et gestion des Physical Volumes (PV), Volume Groups (VG), et Logical Volumes (LV)**
3. **Gestion avancée : Redimensionnement, Snapshot, Suppression**

---

## **📌 1. Présentation de LVM et Device Mapper**
### **🔹 Qu’est-ce que LVM ?**
LVM (**Logical Volume Manager**) est un système de gestion flexible des volumes de stockage.  
Il permet de :
- **Redimensionner dynamiquement** les partitions.
- **Créer des snapshots** (sauvegardes instantanées).
- **Ajouter ou supprimer** des disques facilement.

### **🔹 Qu’est-ce que le Device Mapper ?**
Device Mapper est un framework du noyau Linux qui permet de **mapper des périphériques de stockage** à d’autres devices.  
**LVM utilise Device Mapper** pour gérer ses volumes logiques.

---

## **📌 2. Installation de LVM**
Vérifie d’abord si LVM est installé :
```bash
sudo apt update
sudo apt install -y lvm2
```
Vérifie que LVM est bien activé :
```bash
sudo systemctl enable --now lvm2-lvmetad
```
Et affiche la version :
```bash
lvm version
```

---

## **📌 3. Ajouter un disque à la VM Vagrant**
### **🔹 Étape 1 : Ajouter un disque sous VirtualBox**
1. **Éteins ta VM** :
   ```bash
   vagrant halt
   ```
2. **Ouvre VirtualBox**, sélectionne ta VM.
3. **Ajoute un disque virtuel** :
   - **Stockage** → **Contrôleur SATA** → **Ajouter un disque dur** → **Créer un nouveau disque**.
   - Taille : **5 Go**.
   - Type : **Dynamique** (VMDK, VDI ou autre).
4. **Démarre ta VM** :
   ```bash
   vagrant up
   ```

---

## **📌 4. Vérifier le nouveau disque**
Liste les disques :
```bash
lsblk
```
Tu devrais voir un **nouveau disque non partitionné**, par exemple `/dev/sdb`.

Vérifie qu’il n’a pas encore de partition :
```bash
sudo fdisk -l /dev/sdb
```

Si **`/dev/sdb`** est disponible, on peut l'utiliser pour LVM.

---

## **📌 5. Création des Physical Volumes (PV)**
Un **Physical Volume (PV)** est un disque ou une partition que LVM peut utiliser.

1️⃣ **Initialiser `/dev/sdb` comme un PV** :
```bash
sudo pvcreate /dev/sdb
```
Vérifie :
```bash
sudo pvdisplay
```
Ou :
```bash
sudo pvs
```

---

## **📌 6. Création du Volume Group (VG)**
Un **Volume Group (VG)** regroupe plusieurs **Physical Volumes (PV)**.

1️⃣ **Créer un VG nommé `vg_data`** :
```bash
sudo vgcreate vg_data /dev/sdb
```
Vérifie :
```bash
sudo vgdisplay
```
Ou :
```bash
sudo vgs
```

---

## **📌 7. Création des Logical Volumes (LV)**
Un **Logical Volume (LV)** est une "partition virtuelle" sur le **VG**.

1️⃣ **Créer un LV de 3 Go nommé `lv_data` dans `vg_data`** :
```bash
sudo lvcreate -L 3G -n lv_data vg_data
```
Vérifie :
```bash
sudo lvdisplay
```
Ou :
```bash
sudo lvs
```

---

## **📌 8. Formater et monter le volume**
1️⃣ **Formater en ext4** :
```bash
sudo mkfs.ext4 /dev/vg_data/lv_data
```
2️⃣ **Créer un point de montage** :
```bash
sudo mkdir -p /mnt/lvm_data
```
3️⃣ **Monter le LV** :
```bash
sudo mount /dev/vg_data/lv_data /mnt/lvm_data
```
4️⃣ **Vérifier avec `df`** :
```bash
df -h /mnt/lvm_data
```

---

## **📌 9. Monter le volume au démarrage**
Pour que LVM soit monté automatiquement au reboot :
```bash
echo "/dev/vg_data/lv_data /mnt/lvm_data ext4 defaults 0 2" | sudo tee -a /etc/fstab
```
Puis tester :
```bash
sudo mount -a
```

---

## **📌 10. Gestion avancée**
### **🔹 🔄 Redimensionner un volume logique**
1️⃣ **Augmenter `lv_data` de 1 Go** :
```bash
sudo lvextend -L+1G /dev/vg_data/lv_data
```
2️⃣ **Redimensionner le système de fichiers** :
```bash
sudo resize2fs /dev/vg_data/lv_data
```
3️⃣ **Vérifier** :
```bash
df -h /mnt/lvm_data
```

---

### **🔹 📸 Créer un snapshot**
1️⃣ **Créer un snapshot de `lv_data`** :
```bash
sudo lvcreate -L 1G -s -n snap_lv_data /dev/vg_data/lv_data
```
2️⃣ **Lister les snapshots** :
```bash
sudo lvs
```
3️⃣ **Restaurer le snapshot** :
```bash
sudo lvconvert --merge /dev/vg_data/snap_lv_data
```
Puis :
```bash
sudo reboot
```

---

### **🔹 ❌ Supprimer un Logical Volume**
1️⃣ **Démonter le LV** :
```bash
sudo umount /mnt/lvm_data
```
2️⃣ **Supprimer le LV** :
```bash
sudo lvremove /dev/vg_data/lv_data
```
3️⃣ **Vérifier** :
```bash
sudo lvs
```

---

### **🔹 🛑 Supprimer un Volume Group**
1️⃣ **Vérifier s’il reste des LVs dans le VG** :
```bash
sudo lvdisplay vg_data
```
S’il y a des LVs, **les supprimer d'abord** :
```bash
sudo lvremove vg_data
```
2️⃣ **Supprimer le VG** :
```bash
sudo vgremove vg_data
```

---

### **🔹 🚨 Supprimer un Physical Volume**
Après avoir supprimé les VG et LVs :
```bash
sudo pvremove /dev/sdb
```
Puis vérifier :
```bash
sudo pvs
```

---

## **🎯 Conclusion**
Tu sais maintenant :
✅ **Créer un LVM complet sur VirtualBox (PV, VG, LV)**  
✅ **Redimensionner dynamiquement un volume**  
✅ **Créer et restaurer des snapshots**  
✅ **Gérer et supprimer des volumes en toute sécurité**  

Tu peux utiliser ces commandes sur ta **VM Vagrant avec VirtualBox** pour tester **en conditions réelles**. 🚀

Dis-moi si tu veux approfondir un point ! 😊