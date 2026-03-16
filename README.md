# ml-cluster

Build Status:

[![Cluster-Ready-Test](https://github.com/ThachNgocTran/ml-cluster/actions/workflows/Cluster-Ready-Test.yml/badge.svg)](https://github.com/ThachNgocTran/ml-cluster/actions/workflows/Cluster-Ready-Test.yml)

## Intro

The Cluster consists of Postgres, Mlflow, AirFlow and Flask server. Postgres is where Mlflow and AirFlow store the data. Within a Jupyter Notebook, a Model training script submits the result, e.g. artifacts, to Mlflow. Within Mlflow, the Data Scientist personally registers a Model. AirFlow periodically checks if there is a new version of a specific Model; if so, it signals the Flask to update the Model. The Flask server serve not only html page, but also the API call (prediction, model update).

## Demo Video

<p align="center">
  <a href="https://www.youtube.com/watch?v=DmDVRlGrkS0">
    <img src="https://img.youtube.com/vi/DmDVRlGrkS0/0.jpg" width="600">
  </a>
</p>

## Architecture

TODO

## Lessons learned

TODO

## Development Environment

+ Windows 11 (WSL2 (Ubuntu 24.04)) x64
+ Python 3.12
+ k3d: v5.8.3 (based on k8/k3s: v1.31.5+k3s1)
+ Terraform: 1.14.6
+ Helm: 4.1.1
+ kubectl: v1.35.2
