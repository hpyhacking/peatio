# Deploying Peatio on [Kubernetes](https://kubernetes.io/)

## Overview

1. [Dependencies](#dependencies)
2. [Configuration](#configuration)
3. [Installing the chart](#installing-the-chart)
3. [Getting help](#getting-help)

## Dependencies

Peatio has 3 main dependencies:

- [MySQL](https://www.mysql.com/)
- [Redis](https://redis.io/)
- [RabbitMQ](https://www.rabbitmq.com/)

If you don't have them installed yet, you can check our [helm charts repo](https://charts.peatio.tech/).

## Configuration

All the configuration goes in `config/charts/peatio/values.yaml`. It has many helpful comments, but in this section we have more details about each config option.

| Name                      | Default Value                  | Description                   |
| ------------------------- | ------------------------------ | ----------------------------- |
| `replicaCount`            | `1`                            | Number of pod's replicas      |
| `image.repository`        | `"rubykube/peatio"`            | Image repo                    |
| `image.tag`               | `"0.2.2"`                      | Image version                 |
| `image.pullPolicy`        | `"IfNotPresent"`               | Image pull polucy             |
| `service.name`            | `"peatio"`                     | Service name                  |
| `service.type`            | `"ClusterIP"`                  | Service type                  |
| `service.externalPort`    | `8080`                         | Service external port         |
| `service.internalPort`    | `8080`                         | Service internal port         |
| `ingress.enabled`         | `false`                        | Enable or disable the ingress |
| `ingress.hosts`           | `["peatio.local"]`             | The virtual hosts names       |
| `ingress.annotations`     | see `values.yaml`              | Ingress annotations           |
| `ingress.tls.secretName`  | `"peatio-tls"`                 | TLS secret name               |
| `ingress.tls.hosts`       | `["peatio.local"]`             | TLS virtual hosts names       |
| `resources.limits.cpu`    | `"100m"`                       | CPU resource requests         |
| `resources.limits.memory` | `"128Mi"`                      | Memory resource limits        |
| `resources.limits.cpu`    | `"100m"`                       | CPU resource requests         |
| `resources.limits.memory` | `"128Mi"`                      | Memory resource requests      |
| `peatio.env`              | see `application.yml`          | Peatio environment config     |
| `db.host`                 | `"%current-release%-db"`       | Your MySQL host               |
| `db.user`                 | `"root"`                       | MySQL user                    |
| `db.password`             | `nil`                          | MySQL password                |
| `redis.host`              | `"%current-release%-redis"`    | Your Redis host               |
| `redis.password`          | `nil`                          | Redis password                |
| `rabbitmq.host`           | `"%current-release%-rabbitmq"` | Your RabbitMQ host            |
| `rabbitmq.port`           | `5672`                         | RabbitMQ port                 |
| `rabbitmq.username`       | `nil`                          | RabbitMQ username             |
| `rabbitmq.password`       | `nil`                          | RabbitMQ password             |

## Installing the chart

This one is simple:

```shell
helm install config/peatio/charts
```

If you want use `helm package` and external values file, try this:

```shell
$ helm package
Successfully packaged chart and saved it to: peatio-0.1.0.tgz
$ helm install peatio-0.1.0.tgz -f path/to/your/values.yaml
NAME: random-name
...
```

That's all you need to deploy peatio on kubernetes.

## Getting help

If you got any trouble with this deployment, please [open an issue](https://github.com/rubykube/peatio/issues/new). If you want external devops support with peatio, contact hello@peatio.tech.