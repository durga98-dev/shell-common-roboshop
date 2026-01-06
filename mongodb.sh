#!/bin/bash

source ./common.sh

checkroot

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding Mongo repo"

dnf install mongodb-org -y 
VALIDATE $? "Installing Mongo DB"

systemctl enable mongod 
VALIDATE $? "Enabling Mongo DB"

systemctl start mongod 
VALIDATE $? "Started Mongo DB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections to MongoDB"

systemctl restart mongod
VALIDATE $? "Restarted the MongoDB"

print_total_time