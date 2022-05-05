#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"


  echo -e "\n~~~~~ MY SALON ~~~~~\n"

  echo -e "\nWelcome to My Salon, how can I help you?\n" 

  

  MAIN_MENU(){
  if [[ $1 ]]
    then
    echo -e "\n$1"
  fi
  
  # Using while-read method
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do 
     echo "$SERVICE_ID) $SERVICE_NAME"

  done
  read SERVICE_ID_SELECTED
  # Checking if the service ID is between 1 to 5
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]$  ]]
    then
       MAIN_MENU "I could not find that service. What would you like today?"
  else   
      # if ID entered is between 1-5 then do the following:
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name from customers WHERE phone='$CUSTOMER_PHONE'")
      CUSTOMER_ID=$($PSQL "SELECT customer_id from customers WHERE phone='$CUSTOMER_PHONE'")

      # if customer does not exist
      if  [[ -z $CUSTOMER_NAME  ]]
        then
        # Add customer

        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        #Insert customer into customers
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        CUSTOMER_ID=$($PSQL "SELECT customer_id from customers WHERE phone='$CUSTOMER_PHONE'")       

      fi  

       echo -e "\nWhat time would you like your$SERVICE_NAME,$CUSTOMER_NAME?"
       read SERVICE_TIME
       SERVICE_TIME=$(echo $SERVICE_TIME | sed 's/am/:00/')

       INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES ($SERVICE_ID_SELECTED,$CUSTOMER_ID,'$SERVICE_TIME')")
       echo "I have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."



  fi     
  }

  MAIN_MENU
