import sys
import time
from cm_api.api_client import ApiResource

cm_host = "172.18.0.2"
cm_port = "7180"
cm_login = "admin"
cm_password = "admin"
cluster_name = "cluster"
cm_api_version = "19"

api = ApiResource(server_host=cm_host, server_port=cm_port, username=cm_login, password=cm_password, version=cm_api_version)

for attempt in range(1,30):
    try:
        print "Getting cluster on attempt no. ",attempt
        cluster = api.get_cluster(cluster_name)
        print "Got cluster!"
        break;
    except Exception as e:
        print "Waiting 10 seconds. Will try up to 30 times"
        sys.stdout.flush()
        time.sleep(10)
        pass

hosts = cluster.list_hosts()

for s in cluster.get_all_services():
  print "Restarting roles for services ",s.name
  sys.stdout.flush()
  for r in s.get_all_roles():
    s.restart_roles(r.name)

print "Done restarting roles"
