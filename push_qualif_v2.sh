#!/usr/bin/env bash

# Script to create a new tag and then push Master on Qualif
# The script accepts one parameter : type of the tag update :
# - Major is a major update to the software
# - Minor is a small update to the software
# - Patch is any change made (hot fix)

TAG_UPDATE=$1

# Check first if Changelog was updated with release tag
read -r -p "Did you update Changelog with the new tag? [y/N] " RESPONSE
if [[ "$RESPONSE" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
    # Get git last tag
    LAST_TAG=$(git tag --sort=v:refname | tail -1 | tr -d v)
    LAST_TAG_LIST=(${LAST_TAG//\./ })
    LAST_TAG_MAJOR=${LAST_TAG_LIST[0]}
    LAST_TAG_MINOR=(${LAST_TAG_LIST[1]})
    LAST_TAG_PATCH=(${LAST_TAG_LIST[2]})

    case $TAG_UPDATE in
        major)  NEW_MAJOR=$(($LAST_TAG_MAJOR+1))
                NEW_TAG="$NEW_MAJOR.0.0"
                echo $NEW_TAG ;;

        minor)  NEW_MINOR=$(($LAST_TAG_MINOR+1))
                NEW_TAG="$LAST_TAG_MAJOR.$NEW_MINOR.0"
                echo $NEW_TAG ;;

        patch)  NEW_PATCH=$(($LAST_TAG_PATCH+1))
                NEW_TAG="$LAST_TAG_MAJOR.$LAST_TAG_MINOR.$NEW_PATCH"
                echo $NEW_TAG ;;

        *)  echo "Typing error. Please enter update type : major or minor or patch"
            exit 0 ;;
    esac

    read -r -p "Are you sure to add new tag v$NEW_TAG and push to qualif? [y/N] " RESPONSE
    if [[ "$RESPONSE" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        echo "Checkout to Master"
        git checkout master
        # Create new tag in local
        git tag v$NEW_TAG

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
    echo "Please update first the Changelog with the new release tag"
fi