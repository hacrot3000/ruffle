#!/bin/bash
set -e # exit on error

git pull
git status
read -p "Commit message: " msg
git commit -m "$msg"
git push