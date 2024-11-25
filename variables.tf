variable "servers" {
  description = "List of servers to install Zabbix"
  type = map(object({
    host = string
  }))
  default = {
    server1 = {
      host = "133.125.85.181"
    },
    server2 = {
      host = "153.120.92.141"
    }
  }
}
