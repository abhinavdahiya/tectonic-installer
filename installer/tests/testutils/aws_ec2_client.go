package testutils

import (
	"log"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"os"
)

const (
	awsAccessKeyIdEnv     = "AWS_ACCESS_KEY_ID"
	awsSecretAccessKeyEnv = "AWS_SECRET_ACCESS_KEY"
	awsRegionEnv          = "AWS_REGION"
)

func GetAWSClient() *ec2.EC2 {
	awsAccessKeyId := os.Getenv(awsAccessKeyIdEnv)
	awsSecretAccessKey := os.Getenv(awsSecretAccessKeyEnv)
	awsRegion := os.Getenv(awsRegionEnv)

	if awsAccessKeyId == "" || awsSecretAccessKey == "" {
		log.Fatal("AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY env variables are not set")
	}
	sess := session.Must(session.NewSession())
	creds := credentials.NewStaticCredentials(awsAccessKeyId, awsSecretAccessKey, "")
	client := ec2.New(sess, &aws.Config{Region: aws.String(awsRegion), Credentials: creds})
	return client
}

func GetAwsInstances() (*ec2.DescribeInstancesOutput, error) {

	client := GetAWSClient()

	params := &ec2.DescribeInstancesInput{
		Filters: []*ec2.Filter{
			{
				Name:   aws.String("instance-state-name"),
				Values: []*string{aws.String("running"), aws.String("pending")},
			},
		},
	}
	resp, err := client.DescribeInstances(params)

	if err != nil {
		log.Fatalf("there was an error listing instances in %s", err.Error())
	}

	return resp, err

}

func GetAwsVolumes() (*ec2.DescribeVolumesOutput, error) {

	client := GetAWSClient()

	volumeParams := &ec2.DescribeVolumesInput{
		Filters: []*ec2.Filter{
			{
				Name:   aws.String("status"),
				Values: []*string{aws.String("in-use"), aws.String("available")},
			},
		},
	}

	resp, err := client.DescribeVolumes(volumeParams)
	if err != nil {
		log.Fatalf("There was an error listing volumes in %s", err.Error())

	}

	return resp, err

}
