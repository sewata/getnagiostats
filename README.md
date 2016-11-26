# zabbix template nagiostats

get nagios's statistics with nagiostats

（Nagios 3.x）

install

1. add zabbix user into nagios group to execute nagiostats.

2. deploy the script and Userparameter.

3. import the template.

enjoy

## UserParameter

UserParameter=get.nagiostats,/etc/zabbix/scripts/get-nagiostats.sh

## Script

get-nagiostats.sh

## Change Log

=20161126

Added Graphs and Screen in the template.
