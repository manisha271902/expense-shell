#!/bin/bash
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
echo "ENter password"
read -s db_pswd


if [ $USERID -ne 0 ]
then    
    echo -e "$R Please run with root user $N"
else
    echo -e "$G You are a super user $N"
fi


VALIDATE(){
    if [ $1 eq 0 ]
    then
        echo -e "$G $2 ... SUCCESS $N"
    else
        echo -e "$R $2 ... FAILED $N"
    fi

}

dnf module disable nodejs -y
VALIDATE $? "Diasbling default nodejs" &>>$LOG_FILE

dnf module enable nodejs:20 -y
VALIDATE $? "enabling  nodejs 20 version" &>>$LOG_FILE

dnf install nodejs -y
VALIDATE $? "Installing Nodejs" &>>$LOG_FILE

useradd expense
VALIDATE $? "Adding USer" &>>$LOG_FILE

# mkdir /app
# VALIDATE $? "Creating APp direcorty" &>>$LOG_FILE

# curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
# VALIDATE $? "Downloading code" &>>$LOG_FILE

# cd /app
# VALIDATE $? "Downloading code" &>>$LOG_FILE

# unzip /tmp/backend.zip
