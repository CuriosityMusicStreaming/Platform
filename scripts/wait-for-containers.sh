#!/usr/bin/env bash

readonly STATUS_HEALTHY='healthy'
readonly CHECK_INTERVAL_SECONDS=1

wait_for_container() {
    local CONTAINER_NAME=$1
    for i in {1..60}; do
        CONTAINER_STATUS=$(docker inspect --format='{{.State.Health.Status}}' "$CONTAINER_NAME")
        if [[ $CONTAINER_STATUS == "$STATUS_HEALTHY" ]]; then
            echo "" # new line
            echo "$CONTAINER_NAME is healthy"
            break
        fi
        sleep ${CHECK_INTERVAL_SECONDS}
        echo -ne "\r\033[0KWaiting for $CONTAINER_NAME to start for ${i} seconds. Current $CONTAINER_NAME status: ${CONTAINER_STATUS}."
    done

    if [[ $CONTAINER_STATUS != "$STATUS_HEALTHY" ]]; then
        echo >&2 "Could not start $CONTAINER_NAME"
        exit 1
    fi
}

for CONTAINER_NAME in "$@"; do
    wait_for_container "$CONTAINER_NAME"
done
