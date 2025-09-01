#!/bin/sh

set -e

input=$(</dev/stdin)

<<< "$input" yq . | jv ${KRM_SCHEMA-$(dirname $$0)/krm.schema.json} -
