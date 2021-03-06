(ns laciniaclj.schema
  "contains custom resolvers and
  a function to provide the full schema."
  (:require
   [clojure.java.io :as io]
   [clojure.edn :as edn]
   [com.walmartlabs.lacinia.util :as util]
   [com.walmartlabs.lacinia.schema :as schema]))

(defn resolve-game-by-id
  [games-map context args value]
  (let [{:keys [id]} args]
    (get games-map id)))

(defn resolver-map []
  (let [cgg-data (-> "cgg-data.edn"
                     (io/resource)
                     slurp
                     edn/read-string)
        games-map (->> cgg-data
                      :games
                      (reduce #(assoc %1 (:id %2) %2) {}))]
    {:query/game-by-id
     (partial resolve-game-by-id games-map)}))

(defn load-schema
  []
  (-> "cgg-schema.edn"
      (io/resource)
      slurp
      edn/read-string
      (util/attach-resolvers (resolver-map))
      schema/compile))
