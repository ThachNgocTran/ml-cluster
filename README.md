# ml-cluster

Build Status:

[![Cluster-Ready-Test](https://github.com/ThachNgocTran/ml-cluster/actions/workflows/Cluster-Ready-Test.yml/badge.svg)](https://github.com/ThachNgocTran/ml-cluster/actions/workflows/Cluster-Ready-Test.yml)

## Intro

The cluster integrates **PostgreSQL, MLflow, Apache AirFlow**, and a **Flask** application. PostgreSQL serves as the centralized metadata repository for both MLflow and AirFlow. The machine learning lifecycle begins in a Jupyter Notebook, where training scripts log results and artifacts to MLflow. Once a Data Scientist manually registers a model version within the MLflow Registry, an AirFlow DAG periodically polls for updates. Upon detecting a new version, AirFlow triggers the Flask server to transition the updated model into the production environment. The Flask backend functions as both a web server for HTML content and a RESTful API for executing model updates and predictions.

## Demo Video

<p align="center">
  <a href="https://www.youtube.com/watch?v=DmDVRlGrkS0">
    <img src="https://img.youtube.com/vi/DmDVRlGrkS0/0.jpg" width="600">
  </a>
</p>

## Architecture

![Cluster Architecture](assets/diagram.png)

## Lessons learned

+ The `depends_on` meta-argument in Terraform is important in controlling the order of deloying resources in the cluster. Terraform tries to parallelize everything to speed up, which can lead to unintended consequences. It would be more predictable when manually controlling this process. See [here](terraform-helm/graph.svg).
+ In Terraform, in `helm.tf`, without using `timeout = 900`, it defaults to a standard 5-minute (300 seconds) wait, which may be too short. E.g. resource constraint. Terraform trusts the Kubernetes API for checking the Resources' Readiness. But when a Pod is ready, it doesn't mean the Application in the Pod is ready!
  + **Take-away**: explicitly use `timeout = 900` (or some number); additionally use `startupProbe` and `readinessProbe` in Helm Chart YAML file for e.g. `kind: Deployment`. Example: [here](terraform-helm/charts/airflow/templates/airflow.yaml).

## Reproducibility

TODO

## Development Environment

+ Windows 11 (WSL2 (Ubuntu 24.04)) x64
+ Python 3.12
+ k3d: v5.8.3 (based on k8/k3s: v1.31.5+k3s1)
+ Terraform: 1.14.6
+ Helm: 4.1.1
+ kubectl: v1.35.2
+ Postgres: 15-alpine (Docker Image)
