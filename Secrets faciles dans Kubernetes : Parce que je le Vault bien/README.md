# Secrets faciles dans Kubernetes : Parce que je le Vault bien

This directory contains resources and materials for the talk "Secrets faciles dans Kubernetes : Parce que je le Vault bien".

## Table of Contents

- [Secrets faciles dans Kubernetes : Parce que je le Vault bien](#secrets-faciles-dans-kubernetes--parce-que-je-le-vault-bien)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Abstract](#abstract)
  - [Demo](#demo)
    - [Prerequisites](#prerequisites)
    - [Commands](#commands)
    - [Manifests](#manifests)
  - [Presentation](#presentation)
  - [License](#license)

## Introduction

This talk covers how to manage secrets in Kubernetes using HashiCorp Vault Secrets Operator. It includes a demo showcasing the integration of the operator in Kubernetes.

## Abstract

La gestion des secrets peut rapidement devenir un casse-tête pour les développeurs et les administrateurs de systèmes. Heureusement, Vault Secrets Operator offre une solution puissante et simplifiée pour sécuriser vos applications Kubernetes.

Démystifions ensemble l’utilisation de Vault Secrets Operator et voyons comment il peut transformer la gestion des secrets en une tâche simple et efficace.

Ce talk est destiné aux développeurs, aux ingénieurs DevOps/Sre/Platform et à toute personne souhaitant renforcer la sécurité de leurs applications Kubernetes sans ajouter de complexité inutile.

## Demo

The demo directory contains scripts and manifests used in the presentation.

### Prerequisites

- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [helm](https://helm.sh/docs/intro/install/)
- [vault cli](https://developer.hashicorp.com/vault/tutorials/getting-started/getting-started-install#install-vault) (OPTIONAL)
- [minikube](https://minikube.sigs.k8s.io/docs/start) (OPTIONAL)

### Commands

The [commands.sh](demo/commands.sh) script contains the commands to set up and run the demo.

### Manifests

The `manifests` directory contains the Kubernetes manifests used in the demo:

- [myapp.yaml](demo/manifests/myapp.yaml)
- [policy.hcl](demo/manifests/policy.hcl)
- [vaultauth.yaml](demo/manifests/vaultauth.yaml)
- [vaultco.yaml](demo/manifests/vaultco.yaml)
- [vaultstaticsecret.yaml](demo/manifests/vaultstaticsecret.yaml)

## Presentation

The presentation files are available in PDF, ODP and PPTX formats:

- [Secrets faciles dans Kubernetes _ Parce que je le Vault bien.pdf](Secrets%20faciles%20dans%20Kubernetes%20_%20Parce%20que%20je%20le%20Vault%20bien.pdf)
- [Secrets faciles dans Kubernetes _ Parce que je le Vault bien.odp](Secrets%20faciles%20dans%20Kubernetes%20_%20Parce%20que%20je%20le%20Vault%20bien.odp)
- [Secrets faciles dans Kubernetes _ Parce que je le Vault bien.pptx](Secrets%20faciles%20dans%20Kubernetes%20_%20Parce%20que%20je%20le%20Vault%20bien.pptx)

## License

This repository is licensed under the terms specified in the [LICENSE](../LICENSE) file.

All the scripts, images, markdown text and presentation in this repository are licenced under CC BY-SA 4.0 (Creative Commons Attribution-ShareAlike 4.0 International) license. This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt, and build upon the material in any medium or format, even for commercial purposes. If others remix, adapt, or build upon the material, they must license the modified material under identical terms.
