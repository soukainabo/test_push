#!/usr/bin/env bash

# Script to create a new tag and then push Master on Qualif
# The tag to enter must match <major.minor.patch> with (major,minor,patch) ∈ ℕ , example : 11.8.105
# Major is a major update to the software
# Minor is a small update to the software
# Patch is any change made (hot fix)

NEW_TAG=$1

# Check if the format of new tag is valid, must match "major.minor.patch"
rx='^([0-9]+\.){2}(\*|[0-9]+)$'
if [[ $NEW_TAG =~ $rx ]]; then
    #  Transform new tag to int
    NEW_TAG_INT=$(echo $NEW_TAG | tr -d .)

    # Get last tag and transform it to int
    LAST_TAG=$(git tag | tail -1)
    LAST_TAG_INT=$(echo $LAST_TAG | tr -d v.)

    # Compare new tag and last tag
    if [[ $NEW_TAG_INT -le $LAST_TAG_INT ]]
    then
        echo "ERROR:The new tag must be bigger than the last tag $LAST_TAG"
    else
        read -r -p "Are you sure to add new tag v'$NEW_TAG' and push to qualif? [y/N] " RESPONSE
        if [[ "$RESPONSE" =~ ^([yY][eE][sS]|[yY])+$ ]]
        then
            echo "Checkout to Master"
            git checkout master
            git tag v$NEW_TAG # Create new tag in local
            git push origin v$NEW_TAG # Push the new tag to remote
            echo "New tag added : v$NEW_TAG"
            git push origin master:qualif # Push master in qualif
            echo "Master was pushed in Qualif"
        else
            echo "Tag canceled"
        fi
    fi
else
    echo "ERROR:Please enter a three digit version, example 2.3.0"
fi