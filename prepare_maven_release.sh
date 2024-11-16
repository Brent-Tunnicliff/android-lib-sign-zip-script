#!/bin/bash
# This script is used for signing and archiving a maven android package that has already been generated locally.

# Get the arguments
while getopts ":hp:n:v:" opt; do
	case $opt in
  		h)
			echo """
Signs and zips an android library package for publishing. Requires the library to already be published to local Maven. Required arguments:
  * -p: path of the package within local maven, e.g. 'dev/tunnicliff'
  * -n: name of the package, e.g. 'lib-ui-android
  * -v: version of the package, e.g. 1.0.0
			""" >&2
			exit 0
			;;
    	p)
			ARGUMENT_PATH="$OPTARG"
    		;;
    	n)
			ARGUMENT_NAME="$OPTARG"
    		;;
    	v)
			ARGUMENT_VERSION="$OPTARG"
    		;;
    	\?)
			echo "Invalid option -$OPTARG" >&2
    		exit 1
    		;;
  	esac

  	case $OPTARG in
    	-*) 
			echo "Option $opt needs a valid argument"
    		exit 1
    		;;
  	esac
done

# Check that each argument contains a value.
check_argument_exists() {
	if [[ -z "$2" ]]; then
    	echo "Option $1 needs a valid argument"
    	exit 1
	fi
}

check_argument_exists "-p" "$ARGUMENT_PATH"
check_argument_exists "-n" "$ARGUMENT_NAME"
check_argument_exists "-v" "$ARGUMENT_VERSION"

# Prepare paths
LOCAL_MAVEN_PATH=~/.m2/repository
FILE_NAME="$ARGUMENT_NAME-$ARGUMENT_VERSION"
FULL_PACKAGE_PATH="$LOCAL_MAVEN_PATH/$ARGUMENT_PATH/$ARGUMENT_NAME"
VERSION_PATH="$FULL_PACKAGE_PATH/$ARGUMENT_VERSION"
ZIP_FILE_NAME="$FILE_NAME.zip"
ZIP_INPUT="$ARGUMENT_PATH/$ARGUMENT_NAME/$ARGUMENT_VERSION"
ZIP_OUTPUT="$FULL_PACKAGE_PATH/$ZIP_FILE_NAME"

# Check each directory exists.
check_directory_exists() {
	if [ ! -d "$1" ]; then
    	echo "Directory $1 not found!"
    	exit 1
	fi
}

# check_directory_exists "~/clearly/not/a/real/path"
check_directory_exists "$LOCAL_MAVEN_PATH"
check_directory_exists "$FULL_PACKAGE_PATH"
check_directory_exists "$VERSION_PATH"

# Check there are files withing the version directory.
if [ -z "$( ls -A "$VERSION_PATH" )" ]; then
	echo "Directory $VERSION_PATH is empty. Make sure to publish to local maven before running this script."
	exit 1
fi

AAR_FILE="$VERSION_PATH/$FILE_NAME.aar"
MODULE_FILE="$VERSION_PATH/$FILE_NAME.module"
SOURCES_FILE="$VERSION_PATH/$FILE_NAME-sources.jar"
POM_FILE="$VERSION_PATH/$FILE_NAME.pom"

# Double check each file exists.
check_file_exists() {
	if [ ! -f "$1" ]; then
    	echo "File $1 not found!"
	fi
}

check_file_exists "$AAR_FILE"
check_file_exists "$MODULE_FILE"
check_file_exists "$SOURCES_FILE"
check_file_exists "$POM_FILE"

# Start processing files

generate_files() {
	echo "Generating $1.asc"
	gpg -ab "$1"
	check_file_exists "$1.asc"

	echo "Generating $1.md5"
	md5sum "$1" | cut -d ' ' -f 1 > "$1".md5
	check_file_exists "$1.md5"

	echo "Generating $1.sha1"
	sha1sum "$1" | cut -d ' ' -f 1 > "$1".sha1
	check_file_exists "$1.sha1"
}

generate_files "$AAR_FILE"
generate_files "$MODULE_FILE"
generate_files "$SOURCES_FILE"
generate_files "$POM_FILE"

# Zip the files together for upload.

echo "Preparing $ZIP_FILE_NAME"

# The zip input needs to be relative path from `LOCAL_MAVEN_PATH` or we get extra nesting.
cd "$LOCAL_MAVEN_PATH" && zip -r "$ZIP_OUTPUT" "$ZIP_INPUT" || echo "Failed to generate zip" && exit 1

echo "Success! Zip file is located here: $ZIP_OUTPUT"
