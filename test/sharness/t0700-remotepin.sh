#!/usr/bin/env bash

test_description="Test ipfs remote pinning operations"

. lib/test-lib.sh

test_remote_pins() {
  PIN_ARGS="$1"
  LS_ARGS="$2"
  BASE=$3
  if [ -n "$BASE" ]; then
    BASE_ARGS="--cid-base=$BASE"
  fi

  test_expect_success "create some hashes using base $BASE" '
    HASH_A=$(echo "A" | ipfs add $BASE_ARGS -q --pin=false) &&
    HASH_B=$(echo "B" | ipfs add $BASE_ARGS -q --pin=false) &&
    HASH_C=$(echo "C" | ipfs add $BASE_ARGS -q --pin=false)
  '
  test_expect_success "'ipfs pin remote add $PIN_ARGS'" '
    ID_A=$(ipfs pin remote add --enc=json $PIN_ARGS $BASE_ARGS --name=name_a $HASH_A | jq --raw-output .ID)
  '

  test_expect_success "'ipfs pin remote ls $PIN_ARGS' for existing pins by name" '
    FOUND_ID_A=$(ipfs pin remote ls --enc=json --name=name_a) | jq --raw-output .ID &&
    if [ $ID_A = $FOUND_ID_A ]; then
        return 0
    else
        return 1
    fi
  '

  test_expect_success "'ipfs pin remote rm $PIN_ARGS' an existing pin by ID" '
    ipfs pin remote rm --enc=json $ID_A) | jq --raw-output .ID
  '

  test_expect_success "'ipfs pin remote ls $PIN_ARGS' for deleted pin" '
    FOUND_ID_A=$(ipfs pin remote ls --enc=json --name=name_a) | jq --raw-output .ID &&
    if [ "" = $FOUND_ID_A ]; then
        return 0
    else
        return 1
    fi
  '
}

test_init_ipfs

# create user on pinning service
# IPFS_REMOTE_PIN_SERVICE=XXX
# IPFS_REMOTE_PIN_KEY=$(curl -X POST $IPFS_REMOTE_PIN_SERVICE/users -d email=sharness@ipfs.io | jq --raw-output '.access_token')
# returns {"email":"sharness@ipfs.io","access_token":"b79694866904060dc21a4ddcced4f8f1"}

IPFS_REMOTE_PIN_SERVICE=http://163.172.146.161:5000/api/v1
IPFS_REMOTE_PIN_KEY="b79694866904060dc21a4ddcced4f8f1"

test_remote_pins "" "" ""

test_kill_ipfs_daemon

test_done
