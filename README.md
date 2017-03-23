# Imagen Docker para los proyectos de Aplicaciones Web y Sistemas Web

Esta imagen de Docker incluye una pila LAMP ya configurada y lista para usar, junto con phpMyAdmin y acceso SSH como root (con contraseña). Está construida a partir del Dockerfile de tutum/lamp y adaptada para su uso en la Facultad de Informática de la FDI.

El servidor está basado en Ubuntu 16.04 (LTS), y todo el software se instala a partir de los repositorios de Ubuntu.

La imagen únicamente expone los puertos 80 y 22 (para acceder a otros puertos, se pueden establecer túneles SSH).


## Instrucciones para lanzar el contenedor

Al lanzar el contenedor sin instrucciones adicionales se configuran todos los servicios, incluyendo un password aleatorio para MySQL y un password por defecto (root:default) para acceso vía SSH.

Ambas contraseñas se pueden modificar al crear el contenedor:

* -e MYSQL_PASS=X
* -e SSH_PASS=X

Ejemplo:

```
docker run -d --name=MiContenedor -e MYSQL_PASS=mysqlp -e SSH_PASS=sshp informaticaucm/docker-aw-sw
```

## Instrucciones de uso

En el momento de lanzar el contenedor, se activan los siguientes servicios y funciones:

* Servidor SSH: Se puede acceder directamente como `root` usando el password generado al ejecutar el contenedor.
* Servidor Apache: Configurado por defecto con `/var/www/html` como directorio raíz. También incluye una instalación de PHPMyAdmin lista para utilizar
* Servidor MySQL: Se puede acceder a través de PHPMyAdmin con usuario `admin` y la contraseña generada al ejecutar el contenedor. Desde consola también se puede acceder como `root` sin contraseña.
* Subida de archivos: para subir archivos al servidor, se puede utilizar el protocolo SFTP sobre el servidor SSH.

Habitualmente al subir los archivos a través de SFTP y/o modificarlos en el contenedor se modifican los propietarios o los permisos de los archivos y/o carpetas, de tal modo que Apache no tiene permisos para utilizarlos. Para evitar estos problemas, una vez subas los archivos a `/var/www/html` ejecuta el comando `/usr/local/bin/fix-acl.sh` que asignará los permisos y propietarios oportunos a las carpetas y los archivos para que no haya problemas.

## Licencia

Esta imagen se distribuye bajo Licencia Apache 2.0. 

La imagen está construida a partir del Dockerfile y archivos de configuración de la imagen tutum/lamp (https://github.com/tutumcloud/lamp) y adaptada para su uso en la Facultad de Informática de la FDI.

> Original credits: tutum/lamp - by Fernando Mayo <fernando@tutum.co>, Feng Honglin <hfeng@tutum.co>

[![](https://images.microbadger.com/badges/image/informaticaucm/docker-aw-sw.svg)](https://microbadger.com/images/informaticaucm/docker-aw-sw "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/informaticaucm/docker-aw-sw.svg)](https://microbadger.com/images/informaticaucm/docker-aw-sw "Get your own version badge on microbadger.com")
