#!/bin/bash


############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "Auto-build script for Angular-based projects."
   echo
   echo "Syntax: deploy.sh [-p|b|h|a|v]"
   echo "options:"
   echo "p     Set path of the code to build."
   echo "b     Set branch of the code to build."
   echo "h     Print this Help."
   echo "a     Print author and exit"
   echo "v     Print script version and exit."
   echo
}

# Print version
PrintAuthor(){
   echo "AUTHOR: $_AUTHOR";
}

# Print version
PrintVersion(){
   echo "VERSION: $_VERSION";
}

############################################################
############################################################
# Main program                                             #
############################################################
############################################################

# Set variables
_VERSION="0.0.1";
_AUTHOR="JanD";

# OPTIONS
_DEPLOY_DIR="$(pwd)"
_BRANCH="develop";
_PATH="frontend";
_DATE_STRING=$(date +"%Y%m%d%H%M%S")

############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options
while getopts ":a:v:h:n:p:b:" option; do
   case $option in
      a)
         PrintAuthor
         exit;;
      v)
         PrintVersion
         exit;;
      h) # display Help
         Help
         exit;;
      p) # Enter a valid path
         _PATH=$OPTARG
         echo "Set path: $_PATH";;
      b) # Enter a git branch
         _BRANCH=$OPTARG
         echo "Set branch: $_BRANCH";;
      \?) # Invalid option
         echo "Error: Invalid option"
         Help
         exit;;
   esac
done

if [ -d "$_PATH" ]; then 
  if [ -L "$_PATH" ]; then
    echo "$_PATH is not a valid directory...";
    exit;
  else
    echo "$_PATH is a directory...";
    cd $_PATH;
  fi
else
  echo "$_PATH is not a valid directory...";
  exit;
fi

_BUILD_REPO="$_DEPLOY_DIR/built/$_PATH/$_BRANCH";
_BUILD_DIR="$_BUILD_REPO/$_DATE_STRING";
_BUILD_LATEST="$_BUILD_REPO/latest";
_BUILT_DIR="$_DEPLOY_DIR/$_PATH/dist"
_COMMIT_MESSAGE="Jan > PTFB > Changes of branch ${_BRANCH} for: ${_DATE_STRING}"

echo "CURRENT DIRECTORY: $(pwd)";
echo "EXECUTING BUILD ON BRANCH $_BRANCH WITH PATH $_PATH ..."

git checkout $_BRANCH;
git pull;
npm run build:$_BRANCH;

rm -Rf $_BUILD_LATEST;
cp -Rf $_BUILT_DIR $_BUILD_DIR;
cp -Rf $_BUILT_DIR $_BUILD_LATEST;

cd $_BUILD_REPO;

echo "BUILD DIRECTORY: $(pwd)";

git add .;
git commit -m "$_COMMIT_MESSAGE";
git branch -M $_BRANCH;
git push -u origin $_BRANCH;
