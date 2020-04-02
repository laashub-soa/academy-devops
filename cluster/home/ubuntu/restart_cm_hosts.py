import sys
from cm_api.api_client import ApiResource

cm_host = "node-1.cluster"
cm_port = "7180"
cm_login = "admin"
cm_password = "admin"
cluster_name = "cluster"
cm_api_version = "19"

api = ApiResource(server_host=cm_host, server_port=cm_port, username=cm_login, password=cm_password, version=cm_api_version)

cluster = api.get_cluster(cluster_name)
hosts = cluster.list_hosts()

for s in cluster.get_all_services():
  print "Restarting roles for services ",s.name
  for r in s.get_all_roles():
    s.restart_roles(r.name)

