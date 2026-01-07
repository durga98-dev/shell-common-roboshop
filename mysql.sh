#!/bin/bash

source ./common.sh 

checkroot

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing Mysql server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling Mysql server"

systemctl start mysqld  &>>$LOG_FILE
VALIDATE $? "Starting Mysql server"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Setting up root password"

print_total_time