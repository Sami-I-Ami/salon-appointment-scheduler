#!/bin/bash

# psql variable to run statements
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

# title
echo -e "\n ~~~~~ Salon Scheduler ~~~~~"

# main menu
MAIN_MENU() {
  # display message when inputted
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # service select
  echo -e "\nWelcome! What service would you like today?"
  echo -e "\n1) cut\n2) trim\n3) style\n4) color\n5) perm"
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/ //g')

  # if not one of the choices
  if [[ -z $SERVICE_NAME ]]
  then
    # send back to menu
    MAIN_MENU "Sorry, that isn't one of our services."

  else
    # get phone number
    echo -e "\nWhat is your phone number?"
    read CUSTOMER_PHONE

    # get customer name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    
    # if customer is not in database
    if [[ -z $CUSTOMER_NAME ]]
    then
      # ask for name
      echo -e "\nOh, it seems like you're new here! What's your name?"
      read CUSTOMER_NAME

      # insert into database
      INSERT_NAME_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
      echo $INSERT_NAME_RESULT
    fi

    # format customer name and get customer id
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ //g')
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # get appointment time
    echo -e "\nWhen would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
    read SERVICE_TIME

    # enter appointment into schedule
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
    echo $INSERT_APPOINTMENT_RESULT
  fi
}

MAIN_MENU 
