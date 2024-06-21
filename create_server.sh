#!/bin/bash -xe

[ -z $HOST ] && echo "HOST not defined" && exit 1

if [ -f .config ]; then source .config; fi
gcloud compute instances create $HOST \
	--project=survey-tools \
	--zone=europe-west3-a \
	--machine-type=e2-medium \
	--network-interface=address=$HOST,network=default,network-tier=PREMIUM,stack-type=IPV4_ONLY \
	--maintenance-policy=MIGRATE \
	--provisioning-model=STANDARD \
	--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
	--tags=http-server,https-server \
	--create-disk=auto-delete=yes,boot=yes,image=projects/debian-cloud/global/images/debian-12-bookworm-v20240515,mode=rw,size=20,type=projects/survey-tools/zones/europe-west3-a/diskTypes/pd-balanced \
	--disk=auto-delete=no,boot=no,device-name=$HOST-data,name=$HOST-data \
	--no-shielded-secure-boot \
	--shielded-vtpm \
	--shielded-integrity-monitoring \
	--labels=goog-ec-src=vm_add-gcloud \
	--reservation-affinity=any

# wait for server to boot
sleep 15
until gcloud compute ssh $HOST --command="echo server online."
do
	sleep 5
done
export HOST=$HOST
envsubst '$HOST' < prep_server_step1.sh | gcloud compute ssh $HOST --command="bash -xe"
