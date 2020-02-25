#!/usr/bin/env bash

jq '[.[] | select(.label | test("FuchsiaGym_MapEventHeader.*"))]' crystal-speedchoice-label-details.json \
  | jet --from json --to edn --keywordize \
  | bb '(->> *input*
             (map #(-> % 
                       (dissoc :hex_values)
                       (update :integer_values clojure.string/split #" ")))
             (mapv (fn [patch]
                    (-> patch
                        (assoc :integer_values
                               (->> patch
                                    :integer_values
                                    (mapv #(Integer/parseInt %))
                                    (drop 1)
                                    (take 2)
                                    vec))
                        (update-in [:address_range :begin] inc)
                        (update-in [:address_range :end] - 10)))))'
