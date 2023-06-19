#! /bin/bash


cmd=$1
db_username=$2
db_password=$3

sudo systemctl status docker || systemctl systemctl start docker

#check container status (try the following cmds on terminal)
docker container inspect jrvs-psql
container_status=$(docker container ls -a -f name=jrvs-psql | wc -l)

#User switch case to handle create|stop|start opetions
case $cmd in 
  create)
  
  # Check if the container is already created
  if [ $container_status -eq 2 ]; then
		echo 'Container already exists'
		exit 1	
	fi

  #check # of CLI arguments
  if [ $# -ne 3 ]; then
    echo 'Create requires username and password'
    exit 1
  fi
  
  #Create container
	docker volume create pgdata
  #Start the container
	docker run --name jrvs-psql
  #Make sure you understand what's `$?`
	exit $?
	;;

  start|stop) 
  #check instance status; exit 1 if container has not been created
  if [ $container_status -ne 2 ]; then
    echo 'Instance has not been created'
    exit 1
fi
 
  #Start or stop the container
	docker container $cmd jrvs-psql
	exit $?
	;;	
  
  *)
	echo 'Illegal command'
	echo 'Commands: start|stop|create'
	exit 1
	;;
esac 
