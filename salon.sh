#! /bin/bash
CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SQL QUERY")

# Script to schedule salon appointments

# Function to display services and get user input
MAIN_MENU() {
  echo -e "\n~~~~~ MY SALON ~~~~~\n"
  echo "Welcome to My Salon, how can I help you?"
  
  # Get list of services
  SERVICES=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT service_id, name FROM services ORDER BY service_id")
  
  # Display services
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # If argument is passed, it’s an error message
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  read SERVICE_ID_SELECTED
  
  # Validate service_id
  SERVICE_NAME_SELECTED=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
  if [[ -z $SERVICE_NAME_SELECTED ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    GET_CUSTOMER_INFO
  fi
}

GET_CUSTOMER_INFO() {
  # Prompt for phone
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # Check if customer exists
  CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  # If not found
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo "I don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # Insert new customer
    INSERT_CUSTOMER_RESULT=$(psql --username=freecodecamp --dbname=salon -c "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  # Get appointment time
  echo -e "\nWhat time would you like your $SERVICE_NAME_SELECTED, $CUSTOMER_NAME?"
  read SERVICE_TIME

  # Get customer_id
  CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # Insert appointment
  INSERT_APPOINTMENT_RESULT=$(psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # Output final message
  echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU
