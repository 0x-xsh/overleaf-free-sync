#!/bin/bash

# Set the name of the zip file to move
ZIPFILE=mythesis.zip

# Set the path to the downloads folder
DOWNLOADS=~/Downloads

# Set the path to the destination folder
DESTINATION=~/thesis

# Check if the file already exists in the destination folder
if [ -f $DESTINATION/$ZIPFILE ]; then
    echo -e "\e[33mRemoving existing $ZIPFILE file in $DESTINATION...\e[0m"
    rm $DESTINATION/$ZIPFILE
fi

# Extract the zip file into a new folder
echo -e "\e[32mExtracting $ZIPFILE into $DOWNLOADS/mythesis folder...\e[0m"
unzip -q -o $DOWNLOADS/$ZIPFILE -d $DOWNLOADS/mythesis || { echo -e "\e[31mError: Failed to extract $ZIPFILE.\e[0m" ; exit 1; }

# Compare the files in the extracted folder and the destination folder
echo -e "\e[32mComparing the extracted files and the files in the destination folder...\e[0m"
if diff -r -q $DOWNLOADS/mythesis $DESTINATION/mythesis; then
    rm -rf $DOWNLOADS/mythesis*
    echo -e "\e[33mNo changes detected, removing the downloaded folder and exiting...\e[0m"
    exit 0
fi

# Check if the destination folder already exists, and if it does, delete it
if [ -d $DESTINATION/mythesis ]; then
    echo -e "\e[33mDeleting existing mythesis folder in $DESTINATION...\e[0m"
    rm -rf $DESTINATION/mythesis || { echo -e "\e[31mError: Failed to delete $DESTINATION/mythesis.\e[0m" ; exit 1; }
fi

# Move the extracted folder from the downloads folder to the destination folder
echo -e "\e[32mMoving mythesis folder to $DESTINATION...\e[0m"
mv $DOWNLOADS/mythesis $DESTINATION || { echo -e "\e[31mError: Failed to move mythesis folder to $DESTINATION.\e[0m" ; exit 1; }

# Remove the downloaded file
echo -e "\e[33mRemoving downloaded $ZIPFILE file from $DOWNLOADS...\e[0m"
rm $DOWNLOADS/$ZIPFILE || { echo -e "\e[31mError: Failed to remove $DOWNLOADS/$ZIPFILE.\e[0m" ; exit 1; }

# Add the extracted files to the staging area
echo -e "\e[32mAdding files to the staging area...\e[0m"
cd $DESTINATION/mythesis || { echo -e "\e[31mError: Failed to change directory to $DESTINATION/mythesis.\e[0m" ; exit 1; }
git add . || { echo -e "\e[31mError: Failed to add files to staging area.\e[0m" ; exit 1; }

# Check if there are any changes to commit
if git diff-index --quiet HEAD --; then
    echo -e "\e[33mThere are no changes to commit.\e[0m"
    exit 0
fi

# Prompt the user for a commit message
echo -e "\e[32mEnter a commit message: \e[0m"
read message

# Commit changes with the entered message and push to main
echo -e "\e[32mCommitting changes and pushing to main...\e[0m"
git commit -m "$message" || { echo -e "\e[31mError: Failed to commit changes.\e[0m" ; exit 1; }
git push origin main || { echo -e "\e[31mError: Failed to push changes to main branch.\e[0m" ; exit 1; }

