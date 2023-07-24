#!/bin/bash

# Function to check if an open issue with the same title already exists
issue_exists() {
  REPO=$1
  ISSUE_TITLE=$2
  gh issue list -R "$REPO" --state open --json title | grep -q "\"title\":\"$ISSUE_TITLE\""
}

# Function to create an issue if it doesn't already exist
create_issue_if_not_exists() {
  REPO=$1
  ISSUE_TITLE=$2
  ISSUE_BODY=$3
  existing_issue_number=$(issue_exists "$REPO" "$ISSUE_TITLE")
  if [ -z "$existing_issue_number" ]; then
    gh issue create -R "$REPO" --title "$ISSUE_TITLE" --body "$ISSUE_BODY"
  else
    echo "An open issue with the title '$ISSUE_TITLE' already exists in the repository '$REPO'. Skipping issue creation."
  fi
}

# List repositories in the organization
REPOS=$(gh repo list $ORG_NAME --visibility public -L 100 | awk '{print $1}')

# Loop through each repository and create an issue
for REPO in $REPOS; do
    mkdir -p results/$REPO
    repolinter -g https://github.com/$REPO -f markdown -u https://raw.githubusercontent.com/eBay/.github/main/repolinter.yaml > results/$REPO.md
    if [ $? -eq 1 ] ; then
        failure="The repository '$REPO' is not compliant with Allianz guidelines. Please review opensource.allianz.com/guidelines"
        report=`cat results/$REPO.md`
        create_issue_if_not_exists "$REPO" "Repo lint error" "$failure\n\n$report"
    fi
done
