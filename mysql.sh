USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
echo "ENter DB password"
read -s db_pswd   #kindha configure chesina root pasword eh ikada use cheyali


if [ $USERID -ne 0 ]
then    
    echo -e "$R Please run with root user $N"
else
    echo -e "$G You are a super user $N"
fi


VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e " $2 ... $G SUCCESS $N"
    else
        echo -e " $2 ... $R FAILED $N"
    fi

}

dnf install mysql-server -y  &>>$LOG_FILE
VALIDATE $? "Installing MYSQL"

systemctl enable mysqld  &>>$LOG_FILE
VALIDATE $? "Enabling mysql" 

systemctl start mysqld  &>>$LOG_FILE
VALIDATE $? "starting mysql" 


# mysql_secure_installation --set-root-pass cherry123 &>>$LOG_FILE   
# VALIDATE $? "Setting up root usr password" 


#Belowe code is used for idempotency  nature
mysql -h db.manisha.fun -uroot -p${db_pswd} -e "show databases;" &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass db_pswd &>>$LOG_FILE
else
    echo -e "mysql root password is already setup, so $Y skipping $N"
fi

    

#ikada password dynamic ga istunam ->  mysql_secure_installation -uroot cherry123 -e "show databases;" &>>$LOG_FILE
#mysql_secure_installation --set-root-pass cherry123 &>>$LOG_FILE  (ee cmd first time password set chesetapud matrame work avthadi)  