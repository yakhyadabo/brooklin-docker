#!/bin/sh -e

# BROOKLIN_CLUSTER_NAME
if [[ -z "$BROOKLIN_CLUSTER_NAME" ]]; then
    echo "ERROR: missing mandatory config: BROOKLIN_CLUSTER_NAME"
    exit 1
fi

# BROOKLIN_ZOOKEEPER_CONNECT
if [[ -z "$BROOKLIN_ZOOKEEPER_CONNECT" ]]; then
    echo "ERROR: missing mandatory config: BROOKLIN_ZOOKEEPER_CONNECT"
    exit 1
fi

# BROOKLIN_HTTP_PORT
if [[ -z "$BROOKLIN_HTTP_PORT" ]]; then
    export BROOKLIN_HTTP_PORT="32311"
fi

(
    function updateConfig() {
        key=$1
        value=$2
        file=$3

        # Omit $value here, in case there is sensitive information
        echo "[Configuring] '$key' in '$file'"

        # If config exists in file, replace it. Otherwise, append to file.
        if grep -E -q "^#?$key=" "$file"; then
            sed -r -i "s@^#?$key=.*@$key=$value@g" "$file" #note that no config values may contain an '@' char
        else
            echo "$key=$value" >> "$file"
        fi
    }

    updateConfig "brooklin.server.coordinator.cluster" "${BROOKLIN_CLUSTER_NAME}" "${BROOKLIN_CONFIG}/server.properties"
    updateConfig "brooklin.server.coordinator.zkAddress" "${BROOKLIN_ZOOKEEPER_CONNECT}" "${BROOKLIN_CONFIG}/server.properties"
    updateConfig "brooklin.server.httpPort" "${BROOKLIN_HTTP_PORT}" "${BROOKLIN_CONFIG}/server.properties"
)

exec "$BROOKLIN_HOME/bin/brooklin-server-start.sh" "${BROOKLIN_CONFIG}/server.properties" ">/dev/null" "2>&1"

