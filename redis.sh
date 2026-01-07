#!/bin/bash

source ./common.sh
checkroot

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling default module Redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling module Redis 7"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing Redis"

sed -i -e '/s/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no'/etc/redis/redis.conf
VALIDATE $? "Allowing remote connections to Redis"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enabling service Redis"

systemctl start redis &>>$LOG_FILE
VALIDATE $? "Started service Redis"

print_total_time