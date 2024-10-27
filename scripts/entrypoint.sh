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
