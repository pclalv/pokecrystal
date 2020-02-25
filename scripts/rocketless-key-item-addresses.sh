#!/usr/bin/env bash

jq -c '[.[] | select(.label | test("RocketlessLoRLanceScript2"))]' crystal-speedchoice-label-details.json \
  | jet --from json --to edn --keywordize
