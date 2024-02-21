#!/bin/bash
echo 'Enter your username:'
read USERNAME
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
# get user id
USER_ID=$($PSQL "SELECT user_id from users where username='$USERNAME'")
# generate a number
SECRET_NUMBER=$(($RANDOM % 1000 + 1))
GUESS(){
  if [[ $1 ]]
  then
    echo $1
  fi
  # read guessed number
  read GUESSED_NUMBER
  # if isn't an integer
  if [[ ! $GUESSED_NUMBER =~ ^[0-9]+$ ]]
  then
    GUESS  "That is not an integer, guess again:"
  else 
    ((NUMBER_OF_TRIES++))
    # if the number is correct
    if [[ $GUESSED_NUMBER = $SECRET_NUMBER ]]
    then
      echo "You guessed it in $NUMBER_OF_TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
      ((GAMES_PLAYED++))
      # update of table
      if [[ $NUMBER_OF_TRIES < $BEST_GAME || $BEST_GAME=0 ]]
      then 
        ADD_GAME_PLAYED=$($PSQL "UPDATE users set games_played=$GAMES_PLAYED, best_game=$NUMBER_OF_TRIES where user_id=$USER_ID")
      else
        ADD_GAME_PLAYED=$($PSQL "UPDATE users set games_played=$GAMES_PLAYED where user_id=$USER_ID")
      fi
    # if the number isn't correct
    else 
      if [[ $GUESSED_NUMBER > $SECRET_NUMBER ]]
      then
        GUESS "It's lower than that, guess again:"
      else 
        if [[ $GUESSED_NUMBER < $SECRET_NUMBER ]]
        then
          GUESS  "It's higher than that, guess again:"
        fi
      fi
    fi
  fi
}
# if found
if [[ ! -z $USER_ID ]]
then  
  # get users game history
  GAMES_PLAYED=$($PSQL "SELECT games_played from users where user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game from users where user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  # start the game
  GUESS "Guess the secret number between 1 and 1000:"

# if not found
else 
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # add user 
  ADD_USER_RESULT=$($PSQL "INSERT INTO users (username) values('$USERNAME')")
  # get user id 
  USER_ID=$($PSQL "SELECT user_id from users where username='$USERNAME'")
  NUMBER_OF_TRIES=0
  # start the game
  GUESS "Guess the secret number between 1 and 1000:"
fi
