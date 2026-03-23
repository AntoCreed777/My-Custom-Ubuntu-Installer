# Ubuntu Server Autoinstall — Setup Personal

Este repositorio contiene una ISO personalizada de **Ubuntu Server LTS** configurada para instalación automática mediante `autoinstall` (Subiquity + Cloud-Init NoCloud).

---

## Objetivo

Automatizar completamente la instalación del sistema en mi PC personal. Como formateo con frecuencia, esta ISO permite:

* Reducir drásticamente el tiempo de reinstalación.
* Evitar tareas manuales repetitivas.
* Mantener un entorno consistente.

---

# Qué hace esta ISO

Al arrancar desde la ISO personalizada, el proceso:

* Instala Ubuntu automáticamente.
* Configura usuario, red y particionado según `autoinstall.yaml`.
* Instala mis herramientas habituales.
* Aplica configuraciones base del sistema.
* Finaliza sin intervención manual.

---

# Postinstalación (scripts)

Este repositorio incluye scripts modulares en `scripts/` que se ejecutan desde `late-commands` de `autoinstall.yaml`.

Los scripts están separados en archivos `.sh` para dos modos de uso:

* Durante el autoinstall (ejecución automática).
* En sistemas ya instalados previamente (ejecución manual, sin reinstalar).

Se pueden reutilizar en cualquier máquina Ubuntu, desde cualquier ruta, definiendo el usuario objetivo con `--user` o con `TARGET_USER`.

Módulos disponibles:

* `systemd`
* `network`
* `ssh`
* `fastfetch`
* `python`
* `folders`
* `aliases`
* `fonts`
* `cleanup`

Script principal:

```bash
sudo /opt/my-installer/scripts/main.sh --user "${SUDO_USER:-$USER}" --only ssh,aliases,fonts --skip fonts
```

Flags:

* `--user <usuario>`: define el usuario objetivo para módulos que escriben en su home o configuración.
* `--only <mod1,mod2,...>`: ejecuta solo los módulos indicados.
* `--skip <mod1,mod2,...>`: excluye módulos del set final a ejecutar.

Precedencia:

* Si combinas `--only` y `--skip`, `--skip` manda al final (si un módulo está en ambos, se omite).

Ejemplo de ejecución manual en un sistema ya instalado:

```bash
git clone https://github.com/AntoCreed777/My-Custom-Ubuntu-Installer.git /tmp/my-installer
sudo /tmp/my-installer/scripts/main.sh --user "${SUDO_USER:-$USER}"
```

Alternativa con variable de entorno:

```bash
sudo TARGET_USER="${SUDO_USER:-$USER}" /tmp/my-installer/scripts/main.sh
```

Comportamiento actual del `main.sh`:

* Modo best-effort: si un módulo falla, continúa con los siguientes.
* Al final muestra resumen con módulos fallidos.
* El log puede guardarse con `tee`, por ejemplo en `/var/log/postinstall.log`.

---

# Requisitos

* ISO original de Ubuntu Server LTS.
* Archivo `autoinstall.yaml` adaptado a mi configuración.
* Herramientas necesarias:

```bash
sudo apt update
sudo apt install xorriso
```

---

# Construcción de la ISO Personalizada

## 1. Preparar entorno

```bash
mkdir -p ~/autoinstall-iso
cd ~/autoinstall-iso

sudo mkdir -p /mnt/iso
sudo mount -o loop ORIGINAL_ISO.iso /mnt/iso
```

---

## 2. Copiar contenido de la ISO

```bash
mkdir iso-work
cp -rT /mnt/iso iso-work
sudo umount /mnt/iso
```

---

## 3. Agregar configuración NoCloud

Crear estructura:

```bash
mkdir -p iso-work/nocloud
touch iso-work/nocloud/meta-data
touch iso-work/nocloud/user-data
```

Copiar el contenido de:

```
autoinstall.yaml
```

dentro de:

```
iso-work/nocloud/user-data
```

`meta-data` puede permanecer vacío.

---

## 4. Modificar GRUB para autoinstall

Editar:

```bash
vim iso-work/boot/grub/grub.cfg
```

Agregar o modificar la entrada:

```
set timeout=5

menuentry "Autoinstall Ubuntu Server" {
    set gfxpayload=keep
    linux   /casper/vmlinuz quiet autoinstall ds=nocloud\;s=/cdrom/nocloud/ ---
    initrd  /casper/initrd
}
```

Esto indica al kernel que active el modo `autoinstall` y utilice el datasource local `nocloud`.

---

## 5. Generar ISO personalizada

```bash
cd iso-work

xorriso -as mkisofs \
  -r \
  -V "UBUNTU_AUTOINSTALL" \
  -o ../custom_ubuntu.iso \
  -J -l \
  -iso-level 3 \
  -partition_offset 16 \
  -b boot/grub/i386-pc/eltorito.img \
  -c boot.catalog \
  -no-emul-boot \
  -boot-load-size 4 \
  -boot-info-table \
  -eltorito-alt-boot \
  -e EFI/boot/bootx64.efi \
  -no-emul-boot \
  -isohybrid-gpt-basdat \
  .

cd ..
```

Se generará:

```
custom_ubuntu.iso
```

---

# Instalación Rápida

## Opción 1 — Grabar en USB con `dd`

```bash
lsblk
sudo dd if=custom_ubuntu.iso of=/dev/sdX bs=4M status=progress && sync
```

> [!WARNING]
> ⚠️ Esto borra completamente el contenido del USB.

---

## Opción 2 — Usar Ventoy (recomendado en mi caso)

Yo utilizo **Ventoy**, lo que me permite mantener múltiples ISOs en un mismo USB sin reescribir el dispositivo cada vez.

En ese caso, simplemente copio `custom_ubuntu.iso` al USB preparado con Ventoy y arranco desde allí.

---

## Ejecución

1. Arrancar desde el USB.
2. Seleccionar **Autoinstall Ubuntu Server**.
3. Esperar a que termine automáticamente.

Al finalizar, el sistema queda listo con mis herramientas habituales.

---

# Flujo de Uso Habitual

1. Modifico `autoinstall.yaml` si agrego nuevas herramientas.
2. Regenero la ISO.
3. Formateo.
4. Instalo sin intervención manual.
