# Imagen Docker para los proyectos de Aplicaciones Web y Sistemas Web

Esta imagen de Docker se basa en la imagen oficial [php:7.3-apache-buster](https://hub.docker.com/_/php) añadiendo acceso por SSH y adaptada para su uso en la Facultad de Informática de la FDI.

> El servidor de SSH está pensado para subir los archivos por SFTP y para realizar tareas básicas administrativas o revisión de los ficheros de log cuando el contenedor se ejecuta en un servidor remoto.

La imagen únicamente expone los puertos 80 y 22 (para acceder a otros puertos, se pueden establecer túneles SSH).

## Instrucciones para lanzar el contenedor

Al lanzar el contenedor sin instrucciones adicionales se configuran todos los servicios, incluyendo un password para la cuenta del usuario `root` (por defecto `default`) para el acceso vía SSH.

La contraseña se pueden modificar al crear el contenedor:

* -e SSH_PASS=X

Ejemplos:

```
# Ejecución básica
docker run -d \
  --name=MiContenedor \
  -e SSH_PASS=sshp \
  informaticaucm/docker-aw-sw

# Ejecución cambiando los puertos de escucha de Apache y SSH
docker run -d \
  --name=MiContenedor \
  -e SSH_PASS=sshp \
  -p 80:8080 \
  -p 22:2222 \
  informaticaucm/docker-aw-sw

# Ejecución cambiando los puertos de escucha de Apache y SSH asociándolos sólo a la interfaz local
docker run -d \
  --name=MiContenedor \
  -e SSH_PASS=sshp \
  -p 127.0.0.1:80:8080 \
  -p 127.0.0.1:22:2222 \
  informaticaucm/docker-aw-sw
```

## Instrucciones de uso

Este contenedor es de poca utilidad por sí solo ya normalmente se necesita un servidor de base de datos y es recomendable tener una interfaz administrativa para dicho servidor de base de datos.

Para simplificar su uso, en el repositorio se proporciona un archivo `docker-compose.yml` que puede utilizarse para lanzar un stack LAMP completo utilizando la herramienta [docker-compose](https://docs.docker.com/compose/). Este archivo lanza 1 instancia de los siguientes contenedores:

* [Apache + PHP + SSH](https://hub.docker.com/r/informaticaucm/docker-aw-sw).
* [MariaDB](https://hub.docker.com/_/php)
* [phpMyAdmin](https://hub.docker.com/_/phpmyadmin)

Por defecto los diferentes servicios escuchan en los siguientes puertos (se puede editar el fichero `docker-compose.yml` para modificarlos):

* Puerto `8080`: Apache
* Puerto `8081`: phpMyAdmin
* Puerto `8022`: SSH

Para lanzar la pila completa debes ejecutar desde el directorio donde se encuentre `docker-compose.yml`:

```
# Ejecución en primer plano (puedes terminar la ejecución pulsando Ctrl+C)
docker-compose

# Ejecución en segundo plano
# docker-compose up

# Para parar la ejecución de la pila en segundo plano
# docker-compose down
```

Por comodidad, se han mapeado varios directorios dentro del contenedor a directorios del anfitrión donde se ejecuta docker:

* `servidor/apache2 -> /etc/apache2`:  Aquí puedes modificar los archivos de configuración de apache.
* `servidor/php -> /usr/local/etc/php`: Aquí puedes modificar los archivos de configuración de PHP.
* `servidor/www -> /var/www`: dentro se creará el directorio `html` donde podrás alojar tu aplicación.
* `servidor/log -> /var/www`: dentro se crearán los directorios `apache2` y `php` donde se alojarán los ficheros de log de Apache y PHP respectivamente.

Habitualmente al subir los archivos a través de SFTP y / o modificarlos en el contenedor se modifican los propietarios o los permisos de los archivos y/o carpetas, de tal modo que Apache no tiene permisos para utilizarlos. Para evitar estos problemas, una vez subas o modifiques archivos en `/var/www/html` ejecuta el comando `fix-www-acl` que asignará la propiedad y los permisos oportunos a los directorios y los archivos para que no haya problemas.

## Licencia

Esta imagen se distribuye bajo Licencia Apache 2.0. 

[![](https://images.microbadger.com/badges/image/informaticaucm/docker-aw-sw:201920.4.1.svg)](https://microbadger.com/images/informaticaucm/docker-aw-sw:201920.4.1 "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/informaticaucm/docker-aw-sw:201920.4.1.svg)](https://microbadger.com/images/informaticaucm/docker-aw-sw:201920.4.1 "Get your own version badge on microbadger.com")
