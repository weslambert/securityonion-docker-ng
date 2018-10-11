#!/bin/bash

/usr/local/bin/kibana-docker &

KIBANA_VERSION=6.4.1
MAX_WAIT=240

# Check to see if Kibana is available
wait_step=0
  until curl -s -XGET http://localhost:5601 > /dev/null ; do
  wait_step=$(( ${wait_step} + 1 ))
  echo "Waiting on Kibana...Attempt #$wait_step"
	  if [ ${wait_step} -gt ${MAX_WAIT} ]; then
			  echo "ERROR: Kibana not available for more than ${MAX_WAIT} seconds."
			  exit 5
	  fi
		  sleep 1s;
  done

  # Apply Kibana config
  echo
  echo "Applying Kibana config..."
  curl -s -XPOST http://localhost:5601/api/saved_objects/config/$KIBANA_VERSION \
      -H "Content-Type: application/json" \
      -H "kbn-xsrf: $KIBANA_VERSION" \
      -d@/usr/share/kibana/config/config.json
  echo

# Apply all the dashboards
# Load dashboards, visualizations, index pattern(s), etc.
for i in /usr/share/kibana/dashboards/*.json; do
	curl -XPOST localhost:5601/api/kibana/dashboards/import?force=true -H 'kbn-xsrf:true' -H 'Content-type:application/json' -d @$i >> /var/log/kibana/dashboards.log 2>&1 &
	echo -n "."
done
# Add Custom dashboards
for i in /usr/share/kibana/custdashboards/*.json; do
	curl -XPOST localhost:5601/api/kibana/dashboards/import?force=true -H 'kbn-xsrf:true' -H 'Content-type:application/json' -d @$i >> /var/log/kibana/dashboards.log 2>&1 &
	echo -n "."
done

sleep infinity
