# Manifiestos Kubernetes - Caso Práctico 2

Este directorio contiene los archivos necesarios para desplegar la aplicación en un clúster de AKS:

- `deployment.yaml`: despliegue del pod basado en la imagen del ACR.
- `service.yaml`: servicio tipo LoadBalancer para exposición pública.
- `persistentVolumeClaim.yaml`: configuración del almacenamiento persistente.
- `index.html`: contenido web que será expuesto por la aplicación.

## Despliegue

```bash
kubectl apply -f persistentVolumeClaim.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```