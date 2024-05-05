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

dnf install mysql-server -y
VALIDATE $? "Installing MYSQL" &>>$LOG_FILE

systemctl enable mysqld 
VALIDATE $? "Enabling mysql" &>>$LOG_FILE

systemctl start mysqld 
VALIDATE $? "starting mysql" &>>$LOG_FILE


# mysql_secure_installation --set-root-pass cherry123
# VALIDATE $? "Setting up root usr password" &>>$LOG_FILE


#Belowe code is used for idempotency  nature
mysql_secure_installation -uroot -p${db_pswd} -e "show databases;" &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass db_pswd 
else
    echo -e "mysql root password is already setup, so $Y skipping $N"
fi

    

#ikada password dynamic ga istunam ->  mysql_secure_installation -uroot cherry123 -e "show databases;" &>>$LOG_FILE
