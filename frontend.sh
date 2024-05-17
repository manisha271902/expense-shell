#!/bin/bash
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ]
then
    echo " $R please run with super user access $N"
else
    echo "$G You are a super user $N"
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo "$2 ....$R FAILED $N"
    else
        echo "$2..... $G SUCCESS $N"
    fi
}


dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabling Nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "starting Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "Removing existing content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html &>>$LOGFILE
unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "Extracting frontend code"

#check your repo and path
cp /home/ec2-user/expense-shell/expense.conf/ /etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "Downloading frontend code"


systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restarting nginx"

