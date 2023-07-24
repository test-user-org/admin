#!/bin/bash

echo "**1"

# Function to create an issue
create_issue() {
  REPO=$1
  ISSUE_TITLE=$2
  ISSUE_BODY=$3

  gh issue create -R "$REPO" --title "$ISSUE_TITLE" --body "$ISSUE_BODY"
}

# List repositories in the organization
REPOS=$(gh repo list $ORG_NAME -L 100 | awk '{print $1}')

echo $REPOS

# Loop through each repository and create an issue
for REPO in $REPOS; do
  create_issue "$ORG_NAME/$REPO" "Automated Issue Title" "This is the issue body."
done
