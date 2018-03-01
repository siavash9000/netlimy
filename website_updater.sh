#!/usr/bin/env bash
update_website () {
    echo "trying to update website"
    bundle install
    jekyll build --verbose --config /website/_config.yml --source /website --destination /deployment
    last_commit_id=$(git log --format="%H" -n 1)
    echo "$last_commit_id" > /updater_state/last_commit.txt
}

cd /website
while true
do
    if [ -e /updater_state/last_commit.txt ]
    then
        last_commit_id=$(git log --format="%H" -n 1)
        git pull origin master
        if [[ $(< /updater_state/last_commit.txt) != "$last_commit_id" ]]; then
            echo "Houston, we have a change"
            update_website
        fi
    else
        echo "did not found /updater/last_commit.txt: cloning website"
        git clone $WEBSITE_GIT_REPO .
        touch /updater_state/last_commit.txt
        update_website
    fi
    sleep 5
done


