#!/bin/bash

# Check if INITIAL_COMMAND is set and not empty
if [ -n "$INITIAL_COMMAND" ]; then
  echo "Running initial command: $INITIAL_COMMAND"
  eval "$INITIAL_COMMAND"
else
  echo "No initial command provided, proceeding normally."
fi

