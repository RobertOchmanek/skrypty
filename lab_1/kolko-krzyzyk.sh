#!/bin/bash

PLAYER_X="X"
PLAYER_O="O"

FIELD=""
TURN=1
WITH_COMPUTER=true
GAME_IN_PROGRESS=true

BOARD=(1 2 3 4 5 6 7 8 9)

function display_board () {
	clear
	echo "(S) - save current game and exit"
	echo
	echo " ${BOARD[0]} | ${BOARD[1]} | ${BOARD[2]} "
	echo "-----------"
	echo " ${BOARD[3]} | ${BOARD[4]} | ${BOARD[5]} "
	echo "-----------"
	echo " ${BOARD[6]} | ${BOARD[7]} | ${BOARD[8]} "
	echo "-----------"
	echo
}

function choose_player () {
	if [[ $(($TURN % 2)) == 0 ]]
	then
		PLAYER_SYMBOL=$PLAYER_O
		if [ $WITH_COMPUTER == false ]
		then
			echo -n "Player O: pick a field: "
		fi
	else
		PLAYER_SYMBOL=$PLAYER_X
		echo -n "Player X: pick a field: "
	fi

	if [ $WITH_COMPUTER == true ] && [[ $(($TURN % 2)) == 0 ]]
	then
		random_field
	else
		read FIELD
	fi

	if [[ $FIELD == "S" ]]
	then
		save_game
	elif [[ ! $FIELD =~ ^-?[0-9]+$ ]]
	then
		echo -e "Not a valid field.\n"
		choose_player
	else
		FIELD_VALUE=${BOARD[($FIELD - 1)]}
		if [[ ! $FIELD_VALUE =~ ^[0-9]+$ ]]
		then
			if [ $WITH_COMPUTER == false ] || [[ $(($TURN % 2)) == 1 ]]
			then
				echo -e "Field already taken.\n"
			fi
			choose_player
		else
			BOARD[($FIELD - 1)]=$PLAYER_SYMBOL
			((TURN=TURN+1))
		fi
	fi
}

function random_field () {
	FIELD=$(( ( RANDOM % 10 ) + 1 ))
}

function check_board () {
	if [[ ${BOARD[$1]} == ${BOARD[$2]} ]] && \
		[[ ${BOARD[$2]} == ${BOARD[$3]} ]]; then
	GAME_IN_PROGRESS=false
	fi
	if [ $GAME_IN_PROGRESS == false ]; then
		if [ ${BOARD[$1]} == "X" ]; then
			echo "Player X wins!"
			return
		else
			echo "Player O wins!"
			return
		fi
	fi
}

function choose_winner () {
	if [ $GAME_IN_PROGRESS == false ]; then return; fi
	check_board 0 1 2
	if [ $GAME_IN_PROGRESS == false ]; then return; fi
	check_board 3 4 5
	if [ $GAME_IN_PROGRESS == false ]; then return; fi
	check_board 6 7 8
	if [ $GAME_IN_PROGRESS == false ]; then return; fi
	check_board 0 4 8
	if [ $GAME_IN_PROGRESS == false ]; then return; fi
	check_board 2 4 6
	if [ $GAME_IN_PROGRESS == false ]; then return; fi
	check_board 0 3 6
	if [ $GAME_IN_PROGRESS == false ]; then return; fi
	check_board 1 4 7
	if [ $GAME_IN_PROGRESS == false ]; then return; fi
	check_board 2 5 8
	if [ $GAME_IN_PROGRESS == false ]; then return; fi
	
	if [ $TURN -gt 9 ];
	then
		GAME_IN_PROGRESS=false
		echo "It's a draw!"
	fi
}

function save_game () {

	rm -f save_game.txt

	ITERATION=0
	while [ $ITERATION -lt 11 ]
	do
		if [[ $ITERATION == 10 ]]
		then
			echo "$WITH_COMPUTER" >> save_game.txt
		elif [[ $ITERATION == 9 ]]
		then
			echo "$TURN" >> save_game.txt
		else
			echo "${BOARD[$ITERATION]}" >> save_game.txt
		fi
		((ITERATION=ITERATION+1))
	done
	exit
}

function load_game () {
	echo "(L) - load previous game, (C) new game with computer, (2) two player mode: "
	
	CONTINUE=true

	while [ $CONTINUE == true ]
	do
		read OPTION

		if [[ $OPTION == "L" ]]
		then
			if [ ! -f save_game.txt ]
			then
				echo "Save file does not exist! Press enter to start a new game: "
				read OPTION
				CONTINUE=false
			else
				FIELD_INDEX=0
				while IFS= read -r FIELD_VALUE
				do
					if [[ $FIELD_INDEX == 10 ]]
					then
						WITH_COMPUTER=$FIELD_VALUE
					elif [[ $FIELD_INDEX == 9 ]]
					then
						TURN=$FIELD_VALUE
					else
						BOARD[$FIELD_INDEX]=$FIELD_VALUE
					fi
					((FIELD_INDEX=FIELD_INDEX+1))
				done < save_game.txt
				CONTINUE=false
			fi
		elif [[ $OPTION == "C" ]]
		then
			WITH_COMPUTER=true
			CONTINUE=false
		elif [[ $OPTION == "2" ]]
		then
			WITH_COMPUTER=false
			CONTINUE=false
		else
			echo "Not a valid option."
			echo
		fi
	done
}

load_game
display_board
while $GAME_IN_PROGRESS
do
	choose_player
	display_board
	choose_winner
done
