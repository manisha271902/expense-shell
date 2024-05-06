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
mkdir -p /app
VALIDATE $? "Creating APp direcorty" &>>$LOG_FILE

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "Downloading code" &>>$LOG_FILE

cd /app
rm -rf /app/*
unzip /tmp/backend.zip
VALIDATE $? "Extracted backend code"

npm install &>>$LOGFILE
VALIDATE $? "Installing nodejs Dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service
VALIDATE $? "Copied backend service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon Reload"

systemctl start backend &>>$LOGFILE
VALIDATE $? "Starting backend"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enabling backend"


#schema ni load cheyali, so

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing MySQL Client"


 mysql -h db.manisha.fun -uroot  -p${mysql_root_password} < /app/schema/backend.sql
 VALIDATE $? "Schema laoding"

 systemctl restart backend
 VALIDATE $? "Restarting Backend"


