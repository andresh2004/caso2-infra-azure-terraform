# Caso Práctico 2: Automatización de Despliegues en Azure

Este repositorio contiene la resolución del **Caso Práctico 2** de la asignatura *DevOps & Cloud* en la Universidad Internacional de La Rioja (UNIR).  
El objetivo es desplegar infraestructura en Azure de forma totalmente automatizada utilizando **Terraform** y **Ansible**, así como ejecutar dos aplicaciones distintas en **Podman** (VM) y **Kubernetes (AKS)**, con sus imágenes almacenadas en **Azure Container Registry (ACR)**.

---

## 📐 Arquitectura General

- **Terraform**: creación de recursos en Azure (ACR, VM, AKS).
- **Ansible**: configuración automática de los servicios (Podman, Kubernetes, apps).
- **Podman**: contenedor web ejecutado en una VM Linux.
- **AKS**: orquestación de contenedor con almacenamiento persistente.
- **ACR**: almacén privado de imágenes accesible por ambos entornos.
- Infraestructura 100% reproducible y accesible desde Internet.

---

## 📁 Estructura del Repositorio

```
caso2-infra-azure-terraform/
├── terraform/              # Código IaC con Terraform
├── ansible/                # Playbooks para automatización con Ansible
│   ├── inventory/
│   └── playbooks/
├── acr/                    # Imágenes containerizadas
│   ├── app-podman/
│   └── app-k8s/
├── k8s/                    # Manifests YAML para el despliegue en AKS
├── diagramas/              # Diagramas Draw.io
├── evidencias/             # Capturas del entorno o ejecución
├── informe/                # Informe final en formato PDF o DOCX
└── README.md               # Este documento
```

---

## ⚙️ Requisitos

- Azure CLI configurado
- Terraform ≥ 1.3
- Ansible ≥ 2.10
- Cuenta activa en Azure con permisos para crear recursos
- Docker o Podman para construir imágenes
- Kubernetes CLI (`kubectl`)

---

## 🚀 Instrucciones de Ejecución

### 1. Desplegar Infraestructura

```bash
cd terraform/
terraform init
terraform apply
```

Esto creará:
- Azure Container Registry
- Máquina virtual Linux
- Cluster AKS con 1 nodo

---

### 2. Construir y subir imágenes al ACR

```bash
cd acr/app-podman/
podman build -t acr_name.azurecr.io/app-podman:casopractico2 .
podman push acr_name.azurecr.io/app-podman:casopractico2

cd ../app-k8s/
podman build -t acr_name.azurecr.io/app-k8s:casopractico2 .
podman push acr_name.azurecr.io/app-k8s:casopractico2
```

---

### 3. Configurar VM y AKS con Ansible

```bash
cd ansible/
ansible-playbook -i inventory/hosts playbooks/deploy_vm.yml
ansible-playbook -i inventory/hosts playbooks/deploy_aks.yml
```

---

### 4. Desplegar aplicación en AKS

```bash
cd k8s/
kubectl apply -f .
```

---

## 📄 Documentación y Evidencias

- 🧾 Informe completo: [`/informe`](./informe)
- 📊 Diagramas de infraestructura y despliegue: [`/diagramas`](./diagramas)
- 📷 Evidencias de ejecución: [`/evidencias`](./evidencias)

---

## 🔐 Licencia

Este proyecto se entrega bajo la licencia MIT para fines académicos.  
El uso y reproducción queda restringido a contextos educativos. No se permite su redistribución comercial sin autorización.

---

## 👨‍💻 Autor

- Nombre: Carlos Andres Herrera Gonzalez
- Curso: DevOps & Cloud – UNIR
- Fecha: 26 de Julio 2025