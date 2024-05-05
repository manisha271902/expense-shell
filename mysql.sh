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

dnf install mysql-server -y
VALIDATE $? "Installing MYSQL" &>>$LOG_FILE

systemctl enable mysqld 
VALIDATE $? "Enabling mysql" &>>$LOG_FILE

systemctl start mysqld 
VALIDATE $? "starting mysql" &>>$LOG_FILE


mysql_secure_installation --set-root-pass cherry123
VALIDATE $? "Setting up root usr password" &>>$LOG_FILE
