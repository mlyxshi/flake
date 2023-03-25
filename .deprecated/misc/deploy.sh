#!/bin/bash
for i in $(ls .github/workflows|grep deploy)
do
    gh workflow run ${i}
done