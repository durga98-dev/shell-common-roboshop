#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/shell-script"
LOG_FILE_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOG_FOLDER/$LOG_FILE_NAME.log"
SCRIPT_DIR=$PWD
START_TIME=$(date +%s)
MONGODB_HOST=mongodb.durgadevops.fun
MYSQL_HOST=mysql.durgadevops.fun

mkdir -p $LOG_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

checkroot(){
    if [ $USERID -ne 0 ]; then
        echo -e "$R ERROR:: Run the script with root privilege $N"
        exit 1
    fi
}
# Function - will not run unless until we call it explicitly
VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$R ERROR:: $2 FAILED $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disabling module" 

    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Enabling required module"

    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installing Nodejs"

    npm install &>>$LOG_FILE
    VALIDATE $? "Install dependencies" 
}

app_setup(){
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
        VALIDATE $? "Creating system user"
    else
        echo -e "User already exist ... $Y SKIPPING $N"
    fi
    
    mkdir -p /app 
    VALIDATE $? "creating app directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip 
    VALIDATE $? "Downloading $app_name application"

    cd /app 
    VALIDATE $? "Change the directory"

    rm -rf /app/*
    VALIDATE $? "Removing the existing code"

    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "Unzip $app_name application"
}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "copy the service file"

    systemctl daemon-reload
    VALIDATE $? "Reload the service"

    systemctl enable $app_name &>>$LOG_FILE
    VALIDATE $? "Enable the service"

    systemctl start $app_name &>>$LOG_FILE
    VALIDATE $? "Start the service"
}

java_setup(){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Installing Maven"

    mvn clean package  &>>$LOG_FILE
    VALIDATE $? "Packing the applications"

    mv target/shipping-1.0.jar shipping.jar 
    VALIDATE $? "Renaming the artifact"
}

python_setup(){
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "Installing Python"

    pip3 install -r requirements.txt &>>$LOG_FILE
    VALIDATE $? "Installing dependencies"
}

app_restart(){
    systemctl restart $app_name
    VALIDATE $? "Restarted $app_name"
}

print_total_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))
    echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"
}