VERSION=$1
rx='^([0-9]+\.){2}(\*|[0-9]+)$'
if [[ $VERSION =~ $rx ]]; then
 echo "INFO:<-->Version $VERSION"
else
 echo "ERROR:<->Unable to validate package version: '$VERSION'"
 exit 1
fi