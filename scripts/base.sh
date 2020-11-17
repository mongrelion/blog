#!/usr/bin/env bash

# Check if Hugo is installed. Exit if it isn't.
checkhugo=$(command -v hugo)
if [ "${checkhugo}" == "" ]
then
  echo "-> hugo not found"
  exit 1
fi
