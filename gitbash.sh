#!/usr/bin/env bash

# Script to create a new tag and then push Master on Qualif
# The tag to enter must match <major.minor.patch> with (major,minor,patch) ∈ ℕ , example : 2.3.0
# Major is a major update to the software
# Minor is a small update to the software
# Patch is any change made (hot fix)

NEW_TAG=$1

# Check if the format of new tag is valid, must match "major.minor.patch"
rx='^([0-9]+\.){2}(\*|[0-9]+)$'
if [[ $NEW_TAG =~ $rx ]]
then
    # Get git last tag
    LAST_TAG=$(git tag | tail -1 | tr -d v)

    # Compare new and last tags
    if [[ $NEW_TAG == $LAST_TAG ]]
    then
        echo "ERROR:The new tag must be greater than the last tag $LAST_TAG"
        exit 1
    fi

    # If last and new tags not equals, transform them to list and compare their digits
    NEW_TAG_LIST=(${NEW_TAG//\./ })
    LAST_TAG_LIST=(${LAST_TAG//\./ })
    for i in 0 1 2
    do
        if [[ ${NEW_TAG_LIST[${i}]} -lt ${LAST_TAG_LIST[${i}]} ]]
        then
            echo "ERROR:The new tag must be greater than the last tag $LAST_TAG"
            exit 1
        elif [[ ${NEW_TAG_LIST[${i}]} -gt ${LAST_TAG_LIST[${i}]} ]]
        then
            break
        else
            continue
        fi
    done

    read -r -p "Are you sure to add new tag v$NEW_TAG and push to qualif? [y/N] " RESPONSE
    if [[ "$RESPONSE" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        echo "Checkout to Master"
        git checkout master
        git tag v$NEW_TAG # Create new tag in local

        # Push the new tag to remote
        output=$(git push origin v$NEW_TAG 2>&1)
        # If error delete local tag
        if [[ $output == fatal* ]]
        then
            echo $output
            git tag -d v$NEW_TAG
            exit 1
        fi
        echo "New git tag added : v$NEW_TAG"

        # Push Master in Qualif
        output=$(git push -f origin master:qualif 2>&1)
        if [[ $output == fatal* ]]
        then
            echo $output
            echo "Push to Qualif didn't work, please resolve the error above"
            exit 1
        fi
        echo "Master was pushed in Qualif"

    else
        echo "Add tag canceled"
    fi
else
    echo "ERROR:Please enter a three digit version, example 2.3.0"
fi