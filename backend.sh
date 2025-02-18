#/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1 )
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "Installing $2....$R Failure $N"
        exit 1
    else 
        echo -e "Installing $2.....$G Success $N"
    fi    
}

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo "ERROR :: You must have sudo access to execute this script"
        exit 1
    fi      
}

echo "Script started executing at: $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT

dnf module disable nodejs -y
VALIDATE $? "Disabling existing default NodeJS"

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling NodeJS 20"

dnf install nodejs -y
VALIDATE $? "Installing NodeJS"

useradd expense
VALIDATE $? "Adding expense user"

mkdir /app
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "Downloding backend"

cd /app

unzip /tmp/backend.zip
VALIDATE $? "unzip backedn"

npm install
VALIDATE $? "Installing dependencies"

cp /c/devops/daws-82s/repos/expense-shell/backedn.service /etc/systemd/system/backend.service

#Prepare mysql schema

