#!/bin/sh

CHART=$1


cd ${CHART}
if [ -f "values.schema.json" ]; then
  echo "Skip, file values.schema.json already exist. Delete it for force"
  exit 0
fi

helm schema-gen values.yaml > values.schema.json