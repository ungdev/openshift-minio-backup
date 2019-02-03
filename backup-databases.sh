#!/bin/sh

DATE=$(date +%Y-%m-%d_%H-%M-%S)
DIR=$(PWD)

#BACKUP_HOST=""
#BUCKET=""

putBackup ()
{
  file=$1
  resource="/${BUCKET}/${file}"
  content_type="application/octet-stream"
  date=$(date -R)

  curl -v -X PUT -T "${file}" \
	          -H "Host: $BACKUP_HOST" \
	          -H "Date: ${date}" \
	          -H "Content-Type: ${content_type}" \
	          http://$BACKUP_HOST${resource}
}

## Backup object per project for easy restore
#mkdir -p $DIR/projects
#cd $DIR/projects
#for i in `oc get projects --no-headers |grep Active |awk '{print $1}'`
#do
#  mkdir $i
#  cd $i
#  oc export namespace $i >ns.yml
#  oc export project   $i >project.yml
#  #for j in pods replicationcontrollers deploymentconfigs buildconfigs services routes pvc quota hpa secrets configmaps daemonsets deployments endpoints imagestreams ingress scheduledjobs jobs limitranges policies policybindings roles rolebindings resourcequotas replicasets serviceaccounts templates oauthclients petsets
#  for j in deploymentconfigs buildconfigs services routes pvc secrets configmaps endpoints imagestreams policies policybindings roles rolebindings serviceaccounts 
#  do
#    mkdir $j
#    cd $j
#    for k in `oc get $j -n $i --no-headers |awk '{print $1}'`
#    do
#      echo export $j $k '-n' $i
#      oc export $j $k -n $i >$k.yml
#    done
#    cd ..
#  done
#  cd ..
#done

for i in mysql postgresql mongodb
do
	oc get dc -l backup=$i --all-namespaces -o jsonpath='{range .items[?(@.status.availableReplicas > 0)]}{.metadata.name}{" "}{.metadata.namespace}{"\n"}{end}' \
  |while read DC_NAME PROJECT
  do
    POD=$(oc get pods -n $PROJECT -l deploymentconfig=$DC_NAME  -o jsonpath='{range .items[?(@.status.phase == "Running")]}{.metadata.name}{end}' | head -n 1)
    echo "$PROJECT $DC_NAME $POD"
    DBNAME=""
    case $i in
      mysql)
        DBNAME=$(oc -n $PROJECT exec $POD -- /usr/bin/sh -c 'echo $MYSQL_DATABASE')
        echo "Backup database $DBNAME..."
        oc -n $PROJECT exec $POD -- /bin/bash -c 'mysqldump -h 127.0.0.1 -u $MYSQL_USER --password=$MYSQL_PASSWORD $MYSQL_DATABASE' | gzip > $DIR/$PROJECT-$DBNAME-$DATE.sql.gz
        #putBackup $DIR/$PROJECT-$DBNAME-$DATE.sql.gz
        ;;
      postgresql)
        DBNAME=$(oc -n $PROJECT exec $POD -- /usr/bin/sh -c 'echo $POSTGRESQL_DATABASE')
        echo "Backup database $DBNAME..."
        oc -n $PROJECT exec $POD -- /bin/bash -c 'pg_dump -Fc $POSTGRESQL_DATABASE ' | gzip > $DIR/$PROJECT-$DBNAME-$DATE.pg.gz
        #putBackup $DIR/$PROJECT-$DBNAME-$DATE.pg.gz
        ;;
      mongodb)
        DBNAME=$(oc -n $PROJECT exec $POD -- /usr/bin/sh -c 'echo $MONGODB_DATABASE')
        echo "Backup database $DBNAME..."
        oc -n $PROJECT exec $POD -- /bin/bash -c 'mongodump -u $MONGODB_USER -p $MONGODB_PASSWORD -d $MONGODB_DATABASE --gzip --archive' > $DIR/$PROJECT-$DBNAME-$DATE.mongodump.gz
        #putBackup $DIR/$PROJECT-$DBNAME-$DATE.mongodump.gz
        ;;
      *)
        echo "ERROR: Unknown backup-method $i"
        ;;
    esac
  done
done
