resource "null_resource" "zabbix_install" {
  for_each = var.servers

  provisioner "remote-exec" {
    inline = [
      # 必要なパッケージのインストール
      "yum install -y wget",
      "yum install -y mysql-server",
      "yum install -y httpd",  # Apache2のインストール
      "yum install -y zabbix-server-mysql zabbix-agent zabbix-web",
      
      # MySQLの設定
      "systemctl start mysqld",
      "systemctl enable mysqld",
      
      # MySQLの初期設定を非対話的に実行
      # rootユーザーのパスワード設定
      "mysql -e \"UPDATE mysql.user SET authentication_string=PASSWORD('your_password') WHERE User='root';\"",
      "mysql -e \"DELETE FROM mysql.user WHERE User='';\"",
      "mysql -e \"DROP DATABASE IF EXISTS test;\"",
      "mysql -e \"FLUSH PRIVILEGES;\"",

      # VALIDATE PASSWORD COMPONENTを無効にする
      "mysql -e 'UNINSTALL PLUGIN validate_password;'",

      # Apache2の設定
      "systemctl start httpd",  # Apacheの起動
      "systemctl enable httpd",  # Apacheの自動起動設定
      
      # Zabbix Webインターフェースの設定確認
      "if [ ! -f /etc/httpd/conf.d/zabbix.conf ]; then echo 'IncludeOptional /usr/share/zabbix/conf/apache.conf' > /etc/httpd/conf.d/zabbix.conf; fi",  # zabbix.confが無い場合に作成

      # ファイアウォールの設定
      "firewall-cmd --zone=public --add-port=80/tcp --permanent",  # HTTPポートを開放
      "firewall-cmd --zone=public --add-port=443/tcp --permanent",  # HTTPSポートを開放
      "firewall-cmd --reload",  # ファイアウォール設定の再読み込み

      # Zabbixサーバの起動
      "systemctl start zabbix-server",
      "systemctl start zabbix-agent",
      
      # Zabbixサービスの自動起動設定
      "systemctl enable zabbix-server",
      "systemctl enable zabbix-agent"
    ]

    connection {
      type        = "ssh"
      host        = each.value["host"]
      user        = "root"
      private_key = file("~/.ssh/id_ed25519")
    }
  }
}

