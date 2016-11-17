#!/bin/bash

ZABBIXCONFIG=/etc/zabbix/zabbix_agentd.conf
ZABBIXSERVER=127.0.0.1
ZABBIXHOSTNAME=ZabbixServer
ZABBIXSENDFILE=/var/tmp/get-nagiostats.send
TIMESTAMP=`date +%s`

> $ZABBIXSENDFILE

NAGIOSTATS_CMD=`which nagiostats`
RC=$?
if [ $RC -ne 0 ]; then
  echo $RC
  exit 1
fi
NAGIOSTATS=`$NAGIOSTATS_CMD`
RC=$?
if [ $RC -ne 0 ]; then
  echo $RC
  exit 1
fi
ZABBIXSENDER_CMD=`which zabbix_sender`
RC=$?
if [ $RC -ne 0 ]; then
  echo $RC
  exit 1
fi

# Total
total_hsts=`echo "$NAGIOSTATS" | grep "^Total Hosts:" | awk '{print $3}'`
total_srvs=`echo "$NAGIOSTATS" | grep "^Total Services:" | awk '{print $3}'`

# Command Buffers
cmd_buffers_used=`echo "$NAGIOSTATS" | grep "^Used/High/Total Command Buffers:" \
                  | perl -pe "s|.*(\d+) / \d+ / \d+|\1|"`
cmd_buffers_high=`echo "$NAGIOSTATS" | grep "^Used/High/Total Command Buffers:" \
                  | perl -pe "s|.*\d+ / (\d+) / \d+|\1|"`
cmd_buffers_total=`echo "$NAGIOSTATS" | grep "^Used/High/Total Command Buffers:" \
                  | perl -pe "s|.*\d+ / \d+ / (\d+)|\1|"`

# External Commands
external_cmds_last_1min=`echo "$NAGIOSTATS" | grep "^External Commands Last 1/5/15 min:" \
                         | perl -pe "s|.*(\d+) / \d+ / \d+|\1|"`
external_cmds_last_5min=`echo "$NAGIOSTATS" | grep "^External Commands Last 1/5/15 min:" \
                         | perl -pe "s|.*\d+ / (\d+) / \d+|\1|"`
external_cmds_last_15min=`echo "$NAGIOSTATS" | grep "^External Commands Last 1/5/15 min:" \
                          | perl -pe "s|.*\d+ / \d+ / (\d+)|\1|"`

# Active Host
act_hsts_last_1min=`echo "$NAGIOSTATS" | grep "^Active Hosts Last 1/5/15/60 min:" \
                    | perl -pe "s|.*(\d+) / \d+ / \d+ / \d+|\1|"`
act_hsts_last_5min=`echo "$NAGIOSTATS" | grep "^Active Hosts Last 1/5/15/60 min:" \
                    | perl -pe "s|.*\d+ / (\d+) / \d+ / \d+|\1|"`
act_hsts_last_15min=`echo "$NAGIOSTATS" | grep "^Active Hosts Last 1/5/15/60 min:" \
                     | perl -pe "s|.*\d+ / \d+ / (\d+) / \d+|\1|"`
act_hsts_last_60min=`echo "$NAGIOSTATS" | grep "^Active Hosts Last 1/5/15/60 min:" \
                     | perl -pe "s|.*\d+ / \d+ / \d+ / (\d+)|\1|"`

# Passive Host
psv_hsts_last_1min=`echo "$NAGIOSTATS" | grep "^Passive Hosts Last 1/5/15/60 min:" \
                    | perl -pe "s|.*(\d+) / \d+ / \d+ / \d+|\1|"`
psv_hsts_last_5min=`echo "$NAGIOSTATS" | grep "^Passive Hosts Last 1/5/15/60 min:" \
                    | perl -pe "s|.*\d+ / (\d+) / \d+ / \d+|\1|"`
psv_hsts_last_15min=`echo "$NAGIOSTATS" | grep "^Passive Hosts Last 1/5/15/60 min:" \
                     | perl -pe "s|.*\d+ / \d+ / (\d+) / \d+|\1|"`
psv_hsts_last_60min=`echo "$NAGIOSTATS" | grep "^Passive Hosts Last 1/5/15/60 min:" \
                     | perl -pe "s|.*\d+ / \d+ / \d+ / (\d+)|\1|"`

# Active Host Checks
act_hst_checks_last_1min=`echo "$NAGIOSTATS" | grep "^Active Host Checks Last 1/5/15 min:" \
                          | perl -pe "s|.*(\d+) / \d+ / \d+|\1|"`
act_hst_checks_last_5min=`echo "$NAGIOSTATS" | grep "^Active Host Checks Last 1/5/15 min:" \
                          | perl -pe "s|.*\d+ / (\d+) / \d+|\1|"`
act_hst_checks_last_15min=`echo "$NAGIOSTATS" | grep "^Active Host Checks Last 1/5/15 min:" \
                          | perl -pe "s|.*\d+ / \d+ / (\d+)|\1|"`

# Passive Host Checks
psv_hst_checks_last_1min=`echo "$NAGIOSTATS" | grep "^Passive Host Checks Last 1/5/15 min:" \
                          | perl -pe "s|.*(\d+) / \d+ / \d+|\1|"`
psv_hst_checks_last_5min=`echo "$NAGIOSTATS" | grep "^Passive Host Checks Last 1/5/15 min:" \
                          | perl -pe "s|.*\d+ / (\d+) / \d+|\1|"`
psv_hst_checks_last_15min=`echo "$NAGIOSTATS" | grep "^Passive Host Checks Last 1/5/15 min:" \
                          | perl -pe "s|.*\d+ / \d+ / (\d+)|\1|"`

# Active Service
act_srvs_last_1min=`echo "$NAGIOSTATS" | grep "^Active Services Last 1/5/15/60 min:" \
                    | perl -pe "s|.*(\d+) / \d+ / \d+ / \d+|\1|"`
act_srvs_last_5min=`echo "$NAGIOSTATS" | grep "^Active Services Last 1/5/15/60 min:" \
                    | perl -pe "s|.*\d+ / (\d+) / \d+ / \d+|\1|"`
act_srvs_last_15min=`echo "$NAGIOSTATS" | grep "^Active Services Last 1/5/15/60 min:" \
                     | perl -pe "s|.*\d+ / \d+ / (\d+) / \d+|\1|"`
act_srvs_last_60min=`echo "$NAGIOSTATS" | grep "^Active Services Last 1/5/15/60 min:" \
                     | perl -pe "s|.*\d+ / \d+ / \d+ / (\d+)|\1|"`

# Passive Service
psv_srvs_last_1min=`echo "$NAGIOSTATS" | grep "^Passive Services Last 1/5/15/60 min:" \
                    | perl -pe "s|.*(\d+) / \d+ / \d+ / \d+|\1|"`
psv_srvs_last_5min=`echo "$NAGIOSTATS" | grep "^Passive Services Last 1/5/15/60 min:" \
                    | perl -pe "s|.*\d+ / (\d+) / \d+ / \d+|\1|"`
psv_srvs_last_15min=`echo "$NAGIOSTATS" | grep "^Passive Services Last 1/5/15/60 min:" \
                     | perl -pe "s|.*\d+ / \d+ / (\d+) / \d+|\1|"`
psv_srvs_last_60min=`echo "$NAGIOSTATS" | grep "^Passive Services Last 1/5/15/60 min:" \
                     | perl -pe "s|.*\d+ / \d+ / \d+ / (\d+)|\1|"`

# Active Service Checks
act_srv_checks_last_1min=`echo "$NAGIOSTATS" | grep "^Active Service Checks Last 1/5/15 min:" \
                          | perl -pe "s|.*(\d+) / \d+ / \d+|\1|"`
act_srv_checks_last_5min=`echo "$NAGIOSTATS" | grep "^Active Service Checks Last 1/5/15 min:" \
                          | perl -pe "s|.*\d+ / (\d+) / \d+|\1|"`
act_srv_checks_last_15min=`echo "$NAGIOSTATS" | grep "^Active Service Checks Last 1/5/15 min:" \
                          | perl -pe "s|.*\d+ / \d+ / (\d+)|\1|"`

# Passive Service Checks
psv_srv_checks_last_1min=`echo "$NAGIOSTATS" | grep "^Passive Service Checks Last 1/5/15 min:" \
                          | perl -pe "s|.*(\d+) / \d+ / \d+|\1|"`
psv_srv_checks_last_5min=`echo "$NAGIOSTATS" | grep "^Passive Service Checks Last 1/5/15 min:" \
                          | perl -pe "s|.*\d+ / (\d+) / \d+|\1|"`
psv_srv_checks_last_15min=`echo "$NAGIOSTATS" | grep "^Passive Service Checks Last 1/5/15 min:" \
                          | perl -pe "s|.*\d+ / \d+ / (\d+)|\1|"`

# Total Host State Change
total_hst_state_change_min=`echo "$NAGIOSTATS" | grep "^Total Host State Change:" \
                          | perl -pe "s|.*(\d+\.\d+) / \d+\.\d+ / \d+\.\d+ .*|\1|"`
total_hst_state_change_max=`echo "$NAGIOSTATS" | grep "^Total Host State Change:" \
                          | perl -pe "s|.*\d+\.\d+ / (\d+\.\d+) / \d+\.\d+ .*|\1|"`
total_hst_state_change_ave=`echo "$NAGIOSTATS" | grep "^Total Host State Change:" \
                          | perl -pe "s|.*\d+\.\d+ / \d+\.\d+ / (\d+\.\d+) .*|\1|"`

# Active Host State Change
act_hst_state_change_min=`echo "$NAGIOSTATS" | grep "^Active Host State Change:" \
                          | perl -pe "s|.*(\d+\.\d+) / \d+\.\d+ / \d+\.\d+ .*|\1|"`
act_hst_state_change_max=`echo "$NAGIOSTATS" | grep "^Active Host State Change:" \
                          | perl -pe "s|.*\d+\.\d+ / (\d+\.\d+) / \d+\.\d+ .*|\1|"`
act_hst_state_change_ave=`echo "$NAGIOSTATS" | grep "^Active Host State Change:" \
                          | perl -pe "s|.*\d+\.\d+ / \d+\.\d+ / (\d+\.\d+) .*|\1|"`

# Passive Host State Change
psv_hst_state_change_min=`echo "$NAGIOSTATS" | grep "^Passive Host State Change:" \
                          | perl -pe "s|.*(\d+\.\d+) / \d+\.\d+ / \d+\.\d+ .*|\1|"`
psv_hst_state_change_max=`echo "$NAGIOSTATS" | grep "^Passive Host State Change:" \
                          | perl -pe "s|.*\d+\.\d+ / (\d+\.\d+) / \d+\.\d+ .*|\1|"`
psv_hst_state_change_ave=`echo "$NAGIOSTATS" | grep "^Passive Host State Change:" \
                          | perl -pe "s|.*\d+\.\d+ / \d+\.\d+ / (\d+\.\d+) .*|\1|"`

# Total Service State Change
total_srv_state_change_min=`echo "$NAGIOSTATS" | grep "^Total Service State Change:" \
                          | perl -pe "s|.*(\d+\.\d+) / \d+\.\d+ / \d+\.\d+ .*|\1|"`
total_srv_state_change_max=`echo "$NAGIOSTATS" | grep "^Total Service State Change:" \
                          | perl -pe "s|.*\d+\.\d+ / (\d+\.\d+) / \d+\.\d+ .*|\1|"`
total_srv_state_change_ave=`echo "$NAGIOSTATS" | grep "^Total Service State Change:" \
                          | perl -pe "s|.*\d+\.\d+ / \d+\.\d+ / (\d+\.\d+) .*|\1|"`

# Active Service State Change
act_srv_state_change_min=`echo "$NAGIOSTATS" | grep "^Active Service State Change:" \
                          | perl -pe "s|.*(\d+\.\d+) / \d+\.\d+ / \d+\.\d+ .*|\1|"`
act_srv_state_change_max=`echo "$NAGIOSTATS" | grep "^Active Service State Change:" \
                          | perl -pe "s|.*\d+\.\d+ / (\d+\.\d+) / \d+\.\d+ .*|\1|"`
act_srv_state_change_ave=`echo "$NAGIOSTATS" | grep "^Active Service State Change:" \
                          | perl -pe "s|.*\d+\.\d+ / \d+\.\d+ / (\d+\.\d+) .*|\1|"`

# Passive Service State Change
psv_srv_state_change_min=`echo "$NAGIOSTATS" | grep "^Passive Service State Change:" \
                          | perl -pe "s|.*(\d+\.\d+) / \d+\.\d+ / \d+\.\d+ .*|\1|"`
psv_srv_state_change_max=`echo "$NAGIOSTATS" | grep "^Passive Service State Change:" \
                          | perl -pe "s|.*\d+\.\d+ / (\d+\.\d+) / \d+\.\d+ .*|\1|"`
psv_srv_state_change_ave=`echo "$NAGIOSTATS" | grep "^Passive Service State Change:" \
                          | perl -pe "s|.*\d+\.\d+ / \d+\.\d+ / (\d+\.\d+) .*|\1|"`

# Active Host Latency
act_hst_latency_min=`echo "$NAGIOSTATS" | grep "^Active Host Latency:" \
                     | perl -pe "s|.*(\d+\.\d+) / \d+\.\d+ / \d+\.\d+ .*|\1|"`
act_hst_latency_max=`echo "$NAGIOSTATS" | grep "^Active Host Latency:" \
                     | perl -pe "s|.*\d+\.\d+ / (\d+\.\d+) / \d+\.\d+ .*|\1|"`
act_hst_latency_ave=`echo "$NAGIOSTATS" | grep "^Active Host Latency:" \
                     | perl -pe "s|.*\d+\.\d+ / \d+\.\d+ / (\d+\.\d+) .*|\1|"`

# Passive Host Latency
psv_hst_latency_min=`echo "$NAGIOSTATS" | grep "^Passive Host Latency:" \
                     | perl -pe "s|.*(\d+\.\d+) / \d+\.\d+ / \d+\.\d+ .*|\1|"`
psv_hst_latency_max=`echo "$NAGIOSTATS" | grep "^Passive Host Latency:" \
                     | perl -pe "s|.*\d+\.\d+ / (\d+\.\d+) / \d+\.\d+ .*|\1|"`
psv_hst_latency_ave=`echo "$NAGIOSTATS" | grep "^Passive Host Latency:" \
                     | perl -pe "s|.*\d+\.\d+ / \d+\.\d+ / (\d+\.\d+) .*|\1|"`

# Active Host Execution Time
act_hst_exec_time_min=`echo "$NAGIOSTATS" | grep "^Active Host Execution Time:" \
                       | perl -pe "s|.*(\d+\.\d+) / \d+\.\d+ / \d+\.\d+ .*|\1|"`
act_hst_exec_time_max=`echo "$NAGIOSTATS" | grep "^Active Host Execution Time:" \
                       | perl -pe "s|.*\d+\.\d+ / (\d+\.\d+) / \d+\.\d+ .*|\1|"`
act_hst_exec_time_ave=`echo "$NAGIOSTATS" | grep "^Active Host Execution Time:" \
                       | perl -pe "s|.*\d+\.\d+ / \d+\.\d+ / (\d+\.\d+) .*|\1|"`

#Active Service Latency
act_srv_latency_min=`echo "$NAGIOSTATS" | grep "^Active Service Latency:" \
                     | perl -pe "s|.*(\d+\.\d+) / \d+\.\d+ / \d+\.\d+ .*|\1|"`
act_srv_latency_max=`echo "$NAGIOSTATS" | grep "^Active Service Latency:" \
                     | perl -pe "s|.*\d+\.\d+ / (\d+\.\d+) / \d+\.\d+ .*|\1|"`
act_srv_latency_ave=`echo "$NAGIOSTATS" | grep "^Active Service Latency:" \
                     | perl -pe "s|.*\d+\.\d+ / \d+\.\d+ / (\d+\.\d+) .*|\1|"`

# Passive Service Latency
psv_srv_latency_min=`echo "$NAGIOSTATS" | grep "^Passive Service Latency:" \
                     | perl -pe "s|.*(\d+\.\d+) / \d+\.\d+ / \d+\.\d+ .*|\1|"`
psv_srv_latency_max=`echo "$NAGIOSTATS" | grep "^Passive Service Latency:" \
                     | perl -pe "s|.*\d+\.\d+ / (\d+\.\d+) / \d+\.\d+ .*|\1|"`
psv_srv_latency_ave=`echo "$NAGIOSTATS" | grep "^Passive Service Latency:" \
                     | perl -pe "s|.*\d+\.\d+ / \d+\.\d+ / (\d+\.\d+) .*|\1|"`

# Active Service Execution Time
act_srv_exec_time_min=`echo "$NAGIOSTATS" | grep "^Active Service Execution Time:" \
                       | perl -pe "s|.*(\d+\.\d+) / \d+\.\d+ / \d+\.\d+ .*|\1|"`
act_srv_exec_time_max=`echo "$NAGIOSTATS" | grep "^Active Service Execution Time:" \
                       | perl -pe "s|.*\d+\.\d+ / (\d+\.\d+) / \d+\.\d+ .*|\1|"`
act_srv_exec_time_ave=`echo "$NAGIOSTATS" | grep "^Active Service Execution Time:" \
                       | perl -pe "s|.*\d+\.\d+ / \d+\.\d+ / (\d+\.\d+) .*|\1|"`

# item keys
ITEMKEYS='total_hsts
total_srvs
cmd_buffers_used
cmd_buffers_high
cmd_buffers_total
external_cmds_last_1min
external_cmds_last_5min
external_cmds_last_15min
act_hsts_last_1min
act_hsts_last_5min
act_hsts_last_15min
act_hsts_last_60min
psv_hsts_last_1min
psv_hsts_last_5min
psv_hsts_last_15min
psv_hsts_last_60min
act_hst_checks_last_1min
act_hst_checks_last_5min
act_hst_checks_last_15min
psv_hst_checks_last_1min
psv_hst_checks_last_5min
psv_hst_checks_last_15min
act_srvs_last_1min
act_srvs_last_5min
act_srvs_last_15min
act_srvs_last_60min
psv_srvs_last_1min
psv_srvs_last_5min
psv_srvs_last_15min
psv_srvs_last_60min
act_srv_checks_last_1min
act_srv_checks_last_5min
act_srv_checks_last_15min
psv_srv_checks_last_1min
psv_srv_checks_last_5min
psv_srv_checks_last_15min
total_hst_state_change_min
total_hst_state_change_max
total_hst_state_change_ave
act_hst_state_change_min
act_hst_state_change_max
act_hst_state_change_ave
psv_hst_state_change_min
psv_hst_state_change_max
psv_hst_state_change_ave
total_srv_state_change_min
total_srv_state_change_max
total_srv_state_change_ave
act_srv_state_change_min
act_srv_state_change_max
act_srv_state_change_ave
psv_srv_state_change_min
psv_srv_state_change_max
psv_srv_state_change_ave
act_hst_latency_min
act_hst_latency_max
act_hst_latency_ave
psv_hst_latency_min
psv_hst_latency_max
psv_hst_latency_ave
act_hst_exec_time_min
act_hst_exec_time_max
act_hst_exec_time_ave
act_srv_latency_min
act_srv_latency_max
act_srv_latency_ave
psv_srv_latency_min
psv_srv_latency_max
psv_srv_latency_ave
act_srv_exec_time_min
act_srv_exec_time_max
act_srv_exec_time_ave'

for var in $ITEMKEYS
do
  echo - $var $TIMESTAMP ${!var} >> $ZABBIXSENDFILE
done

$ZABBIXSENDER_CMD -z $ZABBIXSERVER -s $ZABBIXHOSTNAME -Ti $ZABBIXSENDFILE > /dev/null
RC=$?
if [ $RC -ne 0 ]; then
  echo $RC
  exit 1
fi
echo 0
