#!/bin/bash

# Get the uptime of the server
uptime=$(uptime -p)

# Send an email with the uptime
echo "Server uptime: $uptime" | mail -s "Server Uptime Report" testsybil.dev@gmail.com
