#!/bin/bash

# Function to create an issue
create_issue() {
  REPO=$1
  ISSUE_TITLE=$2
  ISSUE_BODY=$3

  gh issue create -R "$REPO" --title "$ISSUE_TITLE" --body "$ISSUE_BODY"
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
        create_issue "$REPO" "Repo lint error" "$failure\n\n$report"
    fi
done
