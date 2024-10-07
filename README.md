# ZJUSCT 可观测性系统

[可观测性 - ZJUSCT OpenDocs](https://zjusct.pages.zjusct.io/ops/opendocs/operation/observability/)

本仓库是 ZJUSCT 可观测性系统配置文件。

为了方便运维，所有服务 Docker 设计为无状态的，状态应当在本地存储或数据库中。我们对服务产生的各项数据进行分类：

- 配置文件：能够使用 Git 管理的配置文件，通常是简单的文本，存储在本仓库中。依靠这些配置文件，我们只需要克隆仓库并 `docker compose up` 就能够快速部署整个系统，开箱即用。

    部分服务将配置保存到数据库中，比如 Grafana，它使用内置的 SQLite 3 存储配置、用户、仪表盘等数据。即使如此，它也提供了 [Provisioning](https://grafana.com/docs/grafana/latest/administration/provisioning/) 功能，可以通过配置文件初始化数据库。

    下面是两个例子

    | 服务 | 配置文件 |
    | --- | --- |
    | OTel Collector | `/etc/otelcol-contrib/config.yaml` |
    | Grafana | `/etc/grafana/provisioning/` |

- 数据库：有些服务的数据库需要持久化，Docker 建议使用 Volume 来存储数据库这类写入密集型的数据。

    > Use volumes for write-heavy workloads: Volumes provide the best and most predictable performance for write-heavy workloads. This is because they bypass the storage driver and do not incur any of the potential overheads introduced by thin provisioning and copy-on-write. Volumes have other benefits, such as allowing you to share data among containers and persisting even when no running container is using them.

    为了做到开箱即用，`compose.yml` 中的 Volume 均使用相对路径，Git 仓库保留 `database` 的空文件夹结构。

    下面是两个例子：

    | 服务 | 数据库 |
    | --- | --- |
    | Elasticsearch | `/usr/share/elasticsearch/data` |

    每个服务自己的数据库直接写在 `services.<service>.volumes` 中，需要共享的文件（比如通用的证书）在顶层 `volumes` 中声明。

系统内部的服务连接受到 Docker 保护，可以信任，无需认证。暴露在外的服务均需要认证，否则可能遭受攻击。目前，暴露在外的服务有：

- OpenTelemetry Collector：使用 TLS 加密 + Bearer Token 认证
- Grafana：使用 TLS 加密 + 用户名密码认证

这些用户名、密码和 Token 存储在集群 VaultWarden 中。在 `compose.yml` 中设置为环境变量，通过 `get_credential.sh` 脚本生成 `.env` 文件，由 Docker Compose 读取。`.env` 文件不应当提交到 Git 仓库中。

## Public Ports

| Service | Port | Protocol |
| --- | --- | --- |
| Grafana | host:3000 | HTTP(external TLS) |
| otel | host:4319 | HTTP(external TLS) |
| otel-syslog | host:514 | UDP |
| otel-snmp | host:161 | UDP |
