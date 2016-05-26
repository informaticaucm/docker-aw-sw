**Imagen Docker para los proyectos de Aplicaciones Web y Sistemas Web**

Esta imagen de Docker incluye una pila LAMP ya configurada y lista para usar, junto con phpMyAdmin y acceso SSH como root (con contraseña). Está construida a partir del Dockerfile de tutum/lamp y adaptada para su uso en la Facultad de Informática de la FDI.

El servidor está basado en Ubuntu 14.04 (LTS), y todo el software se instala a partir de los repositorios de Ubuntu.

La imagen únicamente expone los puertos 80 y 22 (para acceder a otros puertos, se pueden establecer túneles SSH).


**Instrucciones para lanzar el contenedor**

Al lanzar el contenedor sin instrucciones adicionales se configuran todos los servicios, incluyendo un password aleatorio para MySQL y un password por defecto (root:default) para acceso vía SSH.

Ambas contraseñas se pueden modificar al crear el contenedor:

* -e MYSQL_PASS=X
* -e SSH_PASS=X

Ejemplo:

> docker run -d --name=MiContenedor -e MYSQL_PASS=mysqlp -e SSH_PASS=sshp informaticaucm/aw-sw

**Licencia**

Esta imagen se distribuye bajo Licencia Apache 2.0. 

La imagen está construida a partir del Dockerfile y archivos de configuración de la imagen tutum/lamp (https://github.com/tutumcloud/lamp) y adaptada para su uso en la Facultad de Informática de la FDI.

> Original credits: tutum/lamp - by Fernando Mayo <fernando@tutum.co>, Feng Honglin <hfeng@tutum.co>
