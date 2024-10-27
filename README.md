# Tutorial Nginx Servers
## Estructura de directorios

- creamos el directorio `websites`

<img src="imagenes/dirWebsites.png">

- creamos el directorio `sites-available`

<img src="imagenes/dirSitesAvailable.png">

- creamos el directorio `scripts`

<img src="imagenes/dirScripts.png">

- creamos el directorio `htpasswd`

<img src="imagenes/dirHtpasswd.png">

- creamos el directorio `sslcerts`

<img src="imagenes/dirSSL.png">

- creamos el `docker-compose.yml`

<img src="imagenes/dirDockercompose.png">

## Configuración Nginx Server

- Lo primero que tenemos que hacer es crear un nuevo archivo en el directorio `sites-available` con el nombre deseado. En este caso `seguro.net.conf`.

una vez dentro del archivo, debemos agregar la siguiente información:

<img src="imagenes/vh80.png">

esto indica que cualquier petición que llegue al puerto 80 será redirigida al puerto 443 del contenedor.

- Ahora configuraremos el server para el puerto 443.

<img src="imagenes/vh443_1.png">

con este codigo indicamos con el DocumentRoot que la carpeta donde se encuentran los archivos del sitio web es `/var/www/html/seguro.net` y que tendra un nombre de host `seguro.net` y por ultimo tendrá un alias `www.seguro.net`.

- Seguiremos con el puerto 443 configurando las paginas de error.

<img src="imagenes/vh443_errores.png">

En esta parte le indicamos el error  y a continuacion la ruta donde se encuentran los archivos de error. es decir continuamos la ruta desde donde dejamos el **Root hasta la carpeta con los errores.**

- Ahora habilitaremos el `certificado SSL` que posteriormente generaremos con la herramienta **`OpenSSL`**.

<img src="imagenes/vh443_ssl.png">

Aqui definimos que que vamos a habilitar el SSL, donde se encuentra nuestro certificado y nuestra key y que protocolo SSL vamos a usar.

- Por ultimo, configuraremos el acceso restringido a nuestro sitio web.

<img src="imagenes/vh443_htpasswd.png">

1. Donde estamos definiendo el directorio que queremos protejer.
2. El mensajes que vamos a mostrar cuando salga el cuadro de identificacion
3. Que solo los usuarios que esten en el archivo de contraseñas puedan acceder al sitio web.
4. La ruta del archivo de contraseñas que vamos a usar.


   
## Generar certificado SSL y contraseña con OpenSSL

- Primero debemos instalar OpenSSL en nuestra maquina.

<img src="imagenes/openSSL.png">

- Ahora crearemos el certificado y la key con OpenSSL.

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout seguro.net.key -out seguro.net.crt
```
 pegaremos este comando en la **`Terminal propia de OpenSSL`** esto nos pedira que introduzcamos la información necesaria para crear el certificado y la key.

 <img src="imagenes/openSSLCommand.png">

 tendremos en cuenta que en el Campo "Common Name" introducimos el nombre de nuestro dominio. En este caso es `seguro.net`.

 los 2 archivos que hemos generado son `seguro.net.key` y `seguro.net.crt` y los pegaremos en el directorio `sslcert` para que los pueda usar Apache.

 - Para generar la contraseña, utilizaremos el siguiente comando:
 
 ```bash
 openssl passwd
 ```

 esto nos pedira que introduzcamos una contraseña y nos generara un odigo que hace referencia a nuestra contraseña.

 <img src="imagenes/htpasswdinside.png">

 dentro del archivo `htpasswd` escribiremos  `nombre del usuario : código generado por OpenSSL.`

 ## Script para habilitar y desabilitar los servidores

 >[!NOTE]
 >Esta parte es opcional ya que podriamos hacerlo en la terminal propia de Docker.

 En el directorio `scripts` creamos un script llamado `entrypoint.sh` y lo editamos con el siguiente codigo:

 ```bash
#!/bin/bash

#enlazamos los archivos de configuracion
if [ ! -L /etc/nginx/sites-enabled/alvaro.com.conf ]; then
  ln -s /etc/nginx/sites-available/alvaro.com.conf /etc/nginx/sites-enabled/
fi

if [ ! -L /etc/nginx/sites-enabled/herrero.com.conf ]; then
  ln -s /etc/nginx/sites-available/herrero.com.conf /etc/nginx/sites-enabled/
fi

if [ ! -L /etc/nginx/sites-enabled/seguro.net.conf ]; then
  ln -s /etc/nginx/sites-available/seguro.net.conf /etc/nginx/sites-enabled/
fi

#reiniciamos la configuracion nginx
nginx -s reload
#ejecutamos nginx 
nginx -g 'daemon off;'
```

1. habilitamos los servidores con `ln -s`
2. reiniciamos la configuracion nginx con `nginx -s reload`
3. ejecutamos apache con `nginx -g "daemon off"`

## Docker Compose

```yml
services:
  apache: 
    image: ubuntu/nginx:latest
    container_name: nginx
    ports:
      - 80:80
      - 443:443
    volumes:
      - ./websites:/var/www/html
      - ./sites-availabe:/etc/nginx/sites-available
     # - ./conf/nginx.conf:/etc/nginx/nginx.conf
      - ./sslcert:/etc/nginx/certs
      - ./htpasswd/.htpasswd:/etc/nginx/.htpasswd
      - ./scripts:/docker-entrypoint.d/
    restart: always
```

- Este es el `docker-compose.yml` que nos permite crear y administrar nuestro Nginx con Docker:
  - Se conecta a la imagen `ubuntu/nginx:latest`
  - El nombre del contenedor es `nginx`
  - Se exponen los puertos 80 y 443 para acceder a nuestra web
  - Se montan los directorios necesarios para Nginx:
   - `websites`: donde se encuentran los archivos del sitio web
   - `sites-available`: donde se encuentran los archivos de configuracion de los virtual hosts
   - `sslcert`: donde se encuentra el certificado y la key
   - `htpasswd`: donde se encuentra el archivo de contraseñas
   - `scripts`: donde se encuentra el script para habilitar y desabilitar los virtual hosts
  - El `entrypoint.sh` se copia en la ruta `docker-entrypoint.d` 

- Para levantar y tirar el docker compose, utilizamos los siguientes comandos:

```bash	
docker-compose up -d
docker-compose down
```

## Hosts File

>[!WARNING]
>Este archivos es delicado y se debe editar con cuidado ademas de hacer un backup del archivo original.

- Para que Apache pueda acceder a los virtual hosts, debemos agregar los nombres de nuestros dominios al archivo `C:\Windows\System32\drivers\etc\hosts`.

<img src="imagenes/mydns.png">

## Ejemplos de funcionamiento de la web

### Alvaro.com

- http://alvaro.com

<img src="imagenes/alvaro1.png">

- error 404: http://alvaro.com/asdasd

<img src="imagenes/alvaro2.png">

### Herrero.com

- http://www.herrero.com

<img src="imagenes/herrero1.png">

- error 404: http://www.herrero.com/asdasd

<img src="imagenes/herrero2.png">

### Seguro.net

- https://seguro.net

<img src="imagenes/seguro1.png">

- https://seguro.net/secreto

<img src="imagenes/seguro2.png">

- error 401: https://seguro.net/secreto
 - cuando salta el cuadro de identificacion lo cerramos

<img src="imagenes/seguro3.png">

- error 404: https://seguro.net/asdasd

<img src="imagenes/seguro4.png">

- error 403: https://seguro.net/secreto
- el nombre del archivo html dentro de seguro no es index-html

<img src="imagenes/seguro403.png">

- error 500: https://seguro.net/error500
- cuando en la configuracion le decimos que busque la utenticacion en archivo que no existe

 <img src="imagenes/seguro5.png">


# Autor

Realizado por [Álvaro Herrero Tamayo](https://github.com/alvarito304)
