#!/usr/bin/env bash

set -eu

STACK_NAME=$1
BUCKET_NAME=$2
TABLE_NAME=$3

getDynamoDBName() {
	aws cloudformation describe-stacks \
		--stack-name "${STACK_NAME}" \
		--query "Stacks[0].Outputs[?OutputKey=='DynamoDBTableName'].OutputValue" \
		--output text
	return $?
}

getS3BucketName() {
	aws cloudformation describe-stacks \
		--stack-name "${STACK_NAME}" \
		--query "Stacks[0].Outputs[?OutputKey=='S3BucketName'].OutputValue" \
		--output text
	return $?
}

aws cloudformation deploy \
	--stack-name "${STACK_NAME}" \
	--template-file terraform_backend.yaml \
	--parameter-overrides \
	S3BucketName="${BUCKET_NAME}" \
	DynamoDBTableName="${TABLE_NAME}" \

cat <<EOS
{
	"stack_name": "${STACK_NAME}",
	"s3_bucket_name": "$(getS3BucketName)",
	"dynamodb_name": "$(getDynamoDBName)"
}
EOS
