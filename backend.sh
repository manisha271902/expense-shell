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
read -s mysql_root_password


if [ $USERID -ne 0 ]
then    
    echo -e "$R Please run with root user $N"
    exit 1
else
    echo -e "$G You are a super user $N"
fi


VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$G $2 ... SUCCESS $N"
    else
        echo -e "$R $2 ... FAILED $N"
        exit 1
    fi

}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Diasbling default nodejs" 

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enabling  nodejs 20 version" 

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing Nodejs" 

id expense &>>$LOG_FILE
if [ $? -ne 0 ]
then
    useradd expense
    VALIDATE $? "Creating USer"    
else
    echo -e "$R User already exists!!! $N" 
fi
mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Creating APp direcorty" 

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE

VALIDATE $? "Downloading code" 

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE $? "Extracted backend code"

npm install &>>$LOG_FILE
VALIDATE $? "Installing nodejs Dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOG_FILE
VALIDATE $? "Copied backend service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon Reload"

systemctl start backend &>>$LOG_FILE
VALIDATE $? "Starting backend"

systemctl enable backend &>>$LOG_FILE
VALIDATE $? "Enabling backend"


#schema ni load cheyali, so

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing MySQL Client"


 mysql -h db.manisha.fun -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOG_FILE
 VALIDATE $? "Schema laoding"

 systemctl restart backend &>>$LOG_FILE
 VALIDATE $? "Restarting Backend"


