#!/bin/bash
podman build -t nginx_seguro:casopractico2 .
podman tag nginx_seguro:casopractico2 acrpracticoandres.azurecr.io/nginx_seguro:casopractico2
podman push acrpracticoandres.azurecr.io/nginx_seguro:casopractico2
