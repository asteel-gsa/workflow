#!/bin/bash
git_sha=$(git rev-list HEAD)
sha=$(git rev-list --after="1 hour" $git_sha)
if test -z $sha
then
    echo "false"
else
    echo "true"
fi
