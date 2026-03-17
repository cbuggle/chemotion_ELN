#!/bin/bash

./prepare-rubygems.sh

# echo "coping with missing gems"
# bundle pristine charlock_holmes --verbose
# bundle pristine rmagick --verbose

echo "STARTING RAILS SERVER ..."
bundle exec rails s -p 3000 -b 0.0.0.0
echo "STARTING RAILS SERVER ... success"
