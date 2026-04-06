# Ubuntu Server Autoinstall — Setup Personal

Este repositorio contiene una ISO personalizada de **Ubuntu Server LTS** configurada para instalación automática mediante `autoinstall` (Subiquity + Cloud-Init NoCloud).

## Objetivo

Automatizar completamente la instalación del sistema en mi PC personal.

Formateo con frecuencia y normalmente instalo el mismo conjunto de herramientas y configuraciones. Esta ISO permite:

- Reducir drásticamente el tiempo de reinstalación.
- Evitar tareas manuales repetitivas.
- Mantener un entorno consistente.

## Qué hace esta ISO

Al arrancar desde la ISO personalizada:

- Instala Ubuntu automáticamente.
- Configura usuario, red y particionado según `autoinstall.yaml`.
- Instala las herramientas habituales.
- Aplica configuraciones base del sistema.
- Finaliza sin intervención manual.

No requiere interacción durante la instalación.

## Requisitos

- ISO original de Ubuntu Server LTS.
- Archivo `autoinstall.yaml` adaptado a la configuración deseada.
- Conexión a Internet por cable de red (Ethernet), activa y estable durante toda la instalación.
- Herramientas necesarias:

```sh
sudo apt update
sudo apt install xorriso
```

> [!IMPORTANT]
> Esta instalación ejecuta múltiples tareas que dependen de Internet.
> Es imprescindible iniciar el sistema con cable de red conectado y verificar que la conexión sea estable.
> Si la conexión se interrumpe durante el proceso, el instalador puede fallar.

## Construcción de la ISO personalizada

### 1. Preparar entorno

```sh
mkdir -p ~/autoinstall-iso
cd ~/autoinstall-iso

sudo mkdir -p /mnt/iso
sudo mount -o loop ORIGINAL_ISO.iso /mnt/iso
```

### 2. Copiar contenido de la ISO

```sh
mkdir iso-work
cp -rT /mnt/iso iso-work
sudo umount /mnt/iso
```

### 3. Agregar configuración NoCloud

Crear estructura:

```sh
mkdir -p iso-work/nocloud
touch iso-work/nocloud/meta-data
touch iso-work/nocloud/user-data
```

Copiar el contenido de:

```text
autoinstall.yaml
```

dentro de:

```text
iso-work/nocloud/user-data
```

`meta-data` puede permanecer vacío.

> [!IMPORTANT]
> Cambie la contraseña del usuario en `autoinstall.yaml`. Genere el hash con `mkpasswd -m sha-512` e ingréselo en la configuración.

### 4. Modificar GRUB para autoinstall

Editar:

```sh
vim iso-work/boot/grub/grub.cfg
```

Agregar o modificar la entrada:

```conf
set timeout=5

menuentry "Autoinstall Ubuntu Server" {
    set gfxpayload=keep
    linux   /casper/vmlinuz quiet autoinstall ds=nocloud\;s=/cdrom/nocloud/ ---
    initrd  /casper/initrd
}
```

Esto indica al kernel que active el modo `autoinstall` y utilice el datasource local `nocloud`.

### 5. Generar ISO personalizada

```sh
cd iso-work

xorriso -as mkisofs \
  -r \
  -V "Ubuntu 24.04 LTS amd64" \
  -o ../personal_custom_ubuntu.iso \
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

```text
personal_custom_ubuntu.iso
```

## Preparación del medio de instalación

### Opción 1 — Grabar en USB con `dd`

```sh
lsblk
sudo dd if=personal_custom_ubuntu.iso of=/dev/sdX bs=4M status=progress && sync
```

> [!WARNING]
> ⚠️ Esto borra completamente el contenido del USB.

### Opción 2 — Usar Ventoy (recomendado en mi caso)

Yo utilizo **Ventoy**, lo que me permite mantener múltiples ISOs en un mismo USB sin reescribir el dispositivo cada vez.

En ese caso, simplemente copio `personal_custom_ubuntu.iso` al USB preparado con Ventoy y arranco desde allí.

### Instalación

> [!WARNING]
> Antes de iniciar, confirme que el equipo está conectado por Ethernet y que la conexión a Internet es estable.
> Si la conexión se corta durante la instalación, el proceso puede fallar.

1. Arrancar desde el USB.
2. Seleccionar **Autoinstall Ubuntu Server**.
3. Esperar a que termine automáticamente.

Al finalizar, el sistema queda listo con mis herramientas habituales instaladas.

## Flujo de uso habitual

1. Modifico `autoinstall.yaml` si agrego nuevas herramientas.
2. Regenero la ISO.
3. Formateo.
4. Instalo sin intervención manual.
5. Sistema configurado y listo para uso inmediato.
