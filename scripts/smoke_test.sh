#!/bin/bash

# smoke_test.sh

# Variables
URL="http://localhost:5000/"

# Wait for the service to start
sleep 5

# Perform smoke test
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $URL)

if [ $HTTP_CODE -eq 200 ]; then
  echo "Smoke test passed: Application is running."
else
  echo "Smoke test failed: Application is not running."
  exit 1
fi
