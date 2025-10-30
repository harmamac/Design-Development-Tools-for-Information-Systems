#!/usr/bin/env bash
# Assignment 1: "Psychic" — Bash script

step=1
total=0
hits=0

# Arrays to store last 10 generated numbers and whether they were hits (1) or not (0)
declare -a nums=()
declare -a hitflags=()

GREEN="\e[32m"
RESET="\e[0m"

print_last_numbers() {
  # Print the last up-to-10 generated numbers, highlighting hits in green
  printf "Numbers: "
  local n=${#nums[@]}
  for (( i=0; i<n; i++ )); do
    if [[ "${hitflags[$i]}" -eq 1 ]]; then
      printf "${GREEN}%s${RESET} " "${nums[$i]}"
    else
      printf "%s " "${nums[$i]}"
    fi
  done
  printf "\n"
}

while true; do
  # Generate the number for this step
  gen=$(( RANDOM % 10 ))

  echo "Step: $step"

  # Read & validate input
  while true; do
    read -rp "Please enter number from 0 to 9 (q - quit): " input
    if [[ "$input" == "q" ]]; then
      exit 0
    elif [[ "$input" =~ ^[0-9]$ ]]; then
      break
    else
      echo "Invalid input. Please enter a single digit 0–9 or 'q' to quit."
    fi
  done

  # Update totals and determine hit/miss
  (( total += 1 ))
  if [[ "$input" -eq "$gen" ]]; then
    echo "Hit! My number: $gen"
    hitflag=1
    (( hits += 1 ))
  else
    echo "Miss! My number: $gen"
    hitflag=0
  fi

  # Maintain rolling window of last 10 numbers
  nums+=( "$gen" )
  hitflags+=( "$hitflag" )
  if (( ${#nums[@]} > 10 )); then
    nums=( "${nums[@]: -10}" )
    hitflags=( "${hitflags[@]: -10}" )
  fi

  # Compute percentages (rounded)
  hitpct=$(( (hits * 100 + total / 2) / total ))
  misspct=$(( 100 - hitpct ))
  echo "Hit: ${hitpct}% Miss: ${misspct}%"

  print_last_numbers

  (( step += 1 ))
done
