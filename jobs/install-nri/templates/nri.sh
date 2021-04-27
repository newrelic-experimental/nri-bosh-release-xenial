#!/bin/bash

export NRIA_LICENSE_KEY=<%= p('infra_agent.license_key') %>

echo "$(date '+%F %T') Pre-start Job for New Relic Infrastructure"

if [ -e /usr/bin/newrelic-infra ]
then
  echo "$(date '+%F %T') Infrastructure is already installed. Version: $(/usr/bin/newrelic-infra -version)"
fi

echo "$(date '+%F %T') Installing New Relic Infrastructure"

echo -e "license_key: ${NRIA_LICENSE_KEY}\n" | tee /etc/newrelic-infra.yml

echo -e "display_name: <%= spec.name + '-' + spec.id %>\n" |  tee -a /etc/newrelic-infra.yml

echo -e "log_file: /var/vcap/sys/log/install-nri/newrelic-infa.log\n" | tee -a /etc/newrelic-infra.yml


<% if_p('infra_agent.agent_props') do |settings| -%>
  <% settings.each do |key, value| -%>
echo -e "<%= key %>: <%= value %>" | tee -a /etc/newrelic-infra.yml
  <% end %>
echo -e | tee -a /etc/newrelic-infra.yml
<% end %>

echo -e "custom_attributes:" | tee -a /etc/newrelic-infra.yml
echo -e "  bosh.az: <%= spec.az %>" | tee -a /etc/newrelic-infra.yml
echo -e "  bosh.bootstrap: <%= spec.bootstrap %>" | tee -a /etc/newrelic-infra.yml
echo -e "  bosh.deployment: <%= spec.deployment %>" | tee -a /etc/newrelic-infra.yml
echo -e "  bosh.id: <%= spec.id %>" | tee -a /etc/newrelic-infra.yml
echo -e "  bosh.index: <%= spec.index %>" | tee -a /etc/newrelic-infra.yml
echo -e "  bosh.ip: <%= spec.ip %>" | tee -a /etc/newrelic-infra.yml
echo -e "  bosh.name: <%= spec.name %>" | tee -a /etc/newrelic-infra.yml
echo -e "  bosh.environment: <%= p('infra_agent.environment') %>" | tee -a /etc/newrelic-infra.yml

<% if_p('infra_agent.custom_attributes') do |cas| %>
  <% cas.each do |key, value| -%>
     <% unless value.empty? -%>
echo -e "  bosh.<%= key %>: <%= value %>" | tee -a /etc/newrelic-infra.yml
     <% end %>
  <% end %>
<% end %>

wait_for_dpkg_lock() {
  while :
  do
      if ! [[ `lsof /var/lib/dpkg/lock` ]]
      then
          break
      fi
      echo "sleeping 3 in wait_for_dpkg_lock"
      sleep 3
  done
}

while :
do
  (
      flock -x 200
      sudo dpkg --force-confdef -i /var/vcap/packages/nr-infra/newrelic-infra_1.16.5_amd64.deb
  ) 200>/var/vcap/data/dpkg.lock
  if [ $? -ne 0 ] ; then
    echo "Install failed. Calling wait_for_dpkg_lock"
    wait_for_dpkg_lock
  else
     break
  fi

done
