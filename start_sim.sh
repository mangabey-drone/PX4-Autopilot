#!/bin/bash

# Arguments
# --no-agent: Do not start the ROS agent
# --agent-host: The host of the ROS agent (default: localhost)
# --agent-port: The port of the ROS agent (default: 8888)

# Default values
AGENT_HOST="localhost"
AGENT_PORT="8888"

# Parse the arguments
for i in "$@"
do
case $i in
    --no-agent)
    NO_AGENT=true
    shift
    ;;
    --agent-host=*)
    AGENT_HOST="${i#*=}"
    shift
    ;;
    --agent-port=*)
    AGENT_PORT="${i#*=}"
    shift
    ;;
    *)
    # unknown option
    ;;
esac
done

# Function to stop the ros agent
cleanup() {
  echo "Stopping ROS agent..."
  if [ -z ${NO_AGENT+x} ]; then
    docker kill $PID
  fi
  echo "Simulation stopped"
}

# Trap the SIGINT signal (Ctrl-C)
trap cleanup SIGINT

# Start the ros agent
if [ -z ${NO_AGENT+x} ]; then
  echo "Starting ROS agent..."
  PID=$(docker run -d --rm --network=host -e ROS_DOMAIN_ID=0 ejemyr/ros-humble-micro-xrce-dds-agent:latest)
  echo "ROS agent started"
fi

# Start the simulation
cd /home/parallels/src/PX4-Autopilot
echo "Starting simulation..."
PX4_UXRCE_DDS_HOST=$AGENT_HOST PX4_UXRCE_DDS_PORT=$AGENT_PORT make px4_sitl gz_x500
echo "Simulation started"

# Clean up
cleanup
