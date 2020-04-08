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

cms = api.get_cloudera_manager().get_service()

cluster_services_stop_order = "spark2_on_yarn,hue,oozie,impala,hive,spark_on_yarn,yarn,ks_indexer,solr,kafka,hbase,hdfs,zookeeper,streamsets,kudu"

print "stopping Cloudera Manager Service"
cms.stop()

for s in cluster_services_stop_order.split(","):
  print "stopping roles for services ",s
  sys.stdout.flush()
  svc = cluster.get_service(s)
  for r in svc.get_all_roles():
    svc.stop_roles(r.name)

zookeeper_svc = cluster.get_service("zookeeper")
kafka_svc = cluster.get_service("kafka")
impala_svc = cluster.get_service("impala")
while ((len(zookeeper_svc.get_commands()) + len(kafka_svc.get_commands()) + len(impala_svc.get_commands())) > 0):
  print "waiting 10 seconds for services to shut down..."
  time.sleep(10)

# wait another 10 seconds for good measure
print "waiting 10 seconds for services to shut down..."
time.sleep(10)

for s in reversed(cluster_services_stop_order.split(",")):
  print "starting roles for services ",s
  sys.stdout.flush()
  svc = cluster.get_service(s)
  for r in svc.get_all_roles():
    svc.start_roles(r.name)

print "Starting Cloudera Manager Service"
cms.start()

print "Done restarting roles"
