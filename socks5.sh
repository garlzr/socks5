#!/bin/bash

# 更新系统并安装 dante-server
sudo apt update
sudo apt install -y dante-server

# 备份原始的配置文件
sudo mv /etc/danted.conf /etc/danted.conf.bak

# 创建新的配置文件
sudo bash -c 'cat <<EOL > /etc/danted.conf
logoutput: /var/log/danted.log   # 日志文件路径

internal: 0.0.0.0 port = 1080    # 监听所有接口的 1080 端口
external: eth0                   # 使用 VPS 的网卡接口，通常是 eth0，如果是其他名称需要修改

method: username                 # 使用用户名和密码进行验证

user.privileged: root            # 需要 root 权限
user.notprivileged: nobody       # 降权运行为 nobody 用户

# 客户端访问规则
client pass {
   from: 0.0.0.0/0 to: 0.0.0.0/0   # 允许任何客户端访问
   log: connect disconnect error
}

# 代理转发规则
pass {
   from: 0.0.0.0/0 to: 0.0.0.0/0   # 允许代理任何地址
   protocol: tcp udp               # 允许 TCP 和 UDP 协议
   method: username                # 要求用户名和密码
}
EOL'

# 配置防火墙允许 1080 端口
sudo ufw allow 1080/tcp

# 创建日志文件并设置权限
sudo touch /var/log/danted.log
sudo chown nobody:nogroup /var/log/danted.log

# 重启 dante 服务并设置开机启动
sudo systemctl restart danted
sudo systemctl enable danted

# 创建一个新的用户作为 SOCKS5 代理的用户
sudo adduser proxyuser

echo "Dante SOCKS5 代理已成功配置并启动。使用 proxyuser 作为代理用户名进行连接。"
echo "Socks5 代理信息为[直接复制]: $(hostname -I | awk '{print $1}'):1080:proxyuser:密码"
