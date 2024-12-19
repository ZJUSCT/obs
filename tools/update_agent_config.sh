#!/bin/bash

# curl https://gh-proxy.com/https://raw.githubusercontent.com/ZJUSCT/clusters.zju.edu.cn/refs/heads/main/tools/update_agent_config.sh | sudo bash

wget https://gh-proxy.com/https://raw.githubusercontent.com/ZJUSCT/clusters.zju.edu.cn/refs/heads/main/config/otelcol/agent.yaml -O /etc/otelcol-contrib/config.yaml || exit 1

# restart systemd service
cat <<EOF
Once you finish editing the configuration file,
please run the following commands to restart the systemd service:
sudo systemctl daemon-reload && sudo systemctl restart otelcol-contrib
EOF
