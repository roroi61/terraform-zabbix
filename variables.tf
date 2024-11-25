variable "servers" {
  description = "List of servers to install Zabbix"
  type = map(object({
    host = string
  }))
  default = {
    server1 = {
      host = "ip"
    },
    server2 = {
      host = "ip"
    }
  }
}
