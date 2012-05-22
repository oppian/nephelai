{
  "AWSTemplateFormatVersion" : "2010-09-09",
  
  "Description": "Creates a standard load balanced RDS backed deploy.",
  
  "Parameters" : {
    "InstanceType" : {
      "Description" : "WebServer EC2 instance type",
      "Type" : "String",
      "Default" : "m1.small",
      "AllowedValues" : [ "t1.micro","m1.small","m1.medium","m1.large","m1.xlarge","m2.xlarge","m2.2xlarge","m2.4xlarge","c1.medium","c1.xlarge","cc1.4xlarge","cc2.8xlarge","cg1.4xlarge"],
      "ConstraintDescription" : "must be a valid EC2 instance type."
    },
    "KeyName" : {
      "Default" : "default",
      "Description" : "Name of an existing EC2 KeyPair to enable SSH access to the PuppetMaster",
      "Type" : "String"
    },
    "PuppetModulesLocation" : {
      "Default" : "PUPPETMODULES",
      "Description" : "Location of package (Zip, GZIP or Git repository URL) that includes the puppet modules content",
      "Type" : "String"
    },
    "PuppetClass" : {
      "Default" : "PUPPETCLASS",
      "Description" : "Puppet module(s) to run",
      "Type" : "String"
    },
    "DatabaseType": {
      "Default": "db.m1.small",
      "Description" : "The database instance type",
      "Type": "String",
      "AllowedValues" : [ "db.m1.small", "db.m1.large", "db.m1.xlarge", "db.m2.xlarge", "db.m2.2xlarge", "db.m2.4xlarge" ],
      "ConstraintDescription" : "must contain only alphanumeric characters."
    },
    "DatabaseUser": {
      "Default" : "admin",
      "NoEcho": "true",
      "Type": "String",
      "Description" : "Database admin account name",
      "MinLength": "1",
      "MaxLength": "16",
      "AllowedPattern" : "[a-zA-Z][a-zA-Z0-9]*",
      "ConstraintDescription" : "must begin with a letter and contain only alphanumeric characters."
    },
    "DatabasePassword": {
      "Default" : "admin",
      "NoEcho": "true",
      "Type": "String",
      "Description" : "Database admin account password",
      "MinLength": "1",
      "MaxLength": "41",
      "AllowedPattern" : "[a-zA-Z0-9]*",
      "ConstraintDescription" : "must contain only alphanumeric characters."
    },
    "DatabaseSize": {
      "Default" : "5",
      "Type": "Number",
      "Description" : "Database size in Gb",
      "MinValue": "5",
      "MaxValue": "1024",
      "ConstraintDescription" : "must be between 5 and 1024Gb."
    },
    "DatabaseName": {
      "Type": "String",
      "Default" : "MyDatabase",
      "MinLength" : 0,
      "Description" : "The database name."
    },
    "SourceBucket": {
      "Type": "String",
      "Description" : "Source bucket name.",
      "Default" : "SOURCEBUCKET"
    },
    "SourceName": {
      "Type": "String",
      "Description" : "Source file name.",
      "Default" : "SOURCENAME"
    }
    ,"AWSSecretKey" : {
      "Type": "String",
      "Description" : "AWS Secret Key",
      "Default" : "AWS_SECRET_ACCESS_KEY"    
    }
    ,"AWSKey" : {
      "Type": "String",
      "Description" : "AWS Key",
      "Default" : "AWS_ACCESS_KEY_ID"    
    }
    ,"S3Bucket" : {
      "Type": "String",
      "Description" : "S3 Bucket",
      "Default" : "S3_BUCKET"    
    }
    ,"Hostname": {
      "Type": "String",
      "Description" : "External hostname.",
      "Default" : "HOSTNAME1"
    }
ifdef(`HOSTNAME2',`dnl
    ,"Hostname2": {
      "Type": "String",
      "Description" : "External hostname2.",
      "Default" : "HOSTNAME2"
    }
')dnl
    ,"DomainName": {
      "Type": "String",
      "Description" : "External domain (must be in route53).",
      "Default" : "DOMAINNAME"
    },
    "OperatorEmail": {
      "Description": "Email address to notify if there are any scaling operations",
      "Type": "String",
      "Default" : "ADMINEMAIL"
    }
    ,"Debug": {
      "Description": "Start app in debug mode.",
      "Type": "String",
      "AllowedValues" : [ "True", "False" ],
      "Default" : "DEBUG"
    }
    ,"MultiAZDatabase": {
      "Default": "MULTIAZDB",
      "Description" : "Create a multi-AZ MySQL Amazon RDS database instance",
      "Type": "String",
      "AllowedValues" : [ "true", "false" ],
      "ConstraintDescription" : "must be either true or false."
    }
    
    ,"AvailabilityZones": {
      "Default": "AZLIST",
      "Description" : "List of availability zones that the load balancer and scaling group will be configured for",
      "Type": "CommaDelimitedList"
    },

    "WebServerCapacityMax": {
      "Default": "5",
      "Description" : "The maximum number of WebServer instances.",
      "Type": "Number"
    },
    "WebServerCapacityMin": {
      "Default": "1",
      "Description" : "The minimum number of WebServer instances",
      "Type": "Number"
    }
ifdef(`RDSSNAPSHOT', `dnl
    ,"DatabaseSnapshot": {
      "Type": "String",
      "Description" : "The database snapshot to copy.",
      "Default" : "RDSSNAPSHOT"
    }
')dnl

ifdef(`SECRET_KEY', `dnl
    ,"SecretKey": {
      "Default": "SECRET_KEY",
      "Description" : "Django Secret Key",
      "Type": "String"
    }
')dnl

  },

  
  "Mappings" : {
    "AWSInstanceType2Arch" : {
      "t1.micro"    : { "Arch" : "64" },
      "m1.small"    : { "Arch" : "64" },
      "m1.medium"   : { "Arch" : "64" },
      "m1.large"    : { "Arch" : "64" },
      "m1.xlarge"   : { "Arch" : "64" },
      "m2.xlarge"   : { "Arch" : "64" },
      "m2.2xlarge"  : { "Arch" : "64" },
      "m2.4xlarge"  : { "Arch" : "64" },
      "c1.medium"   : { "Arch" : "64" },
      "c1.xlarge"   : { "Arch" : "64" },
      "cc1.4xlarge" : { "Arch" : "64HVM" },
      "cc2.8xlarge" : { "Arch" : "64HVM" },
      "cg1.4xlarge" : { "Arch" : "64HVM" }
    },

    "AWSRegionArch2AMI" : {
      "us-east-1"      : { "32" : "ami-31814f58", "64" : "ami-1b814f72", "64HVM" : "ami-0da96764" },
      "us-west-2"      : { "32" : "ami-38fe7308", "64" : "ami-30fe7300", "64HVM" : "NOT_YET_SUPPORTED" },
      "us-west-1"      : { "32" : "ami-11d68a54", "64" : "ami-1bd68a5e", "64HVM" : "NOT_YET_SUPPORTED" },
      "eu-west-1"      : { "32" : "ami-973b06e3", "64" : "ami-953b06e1", "64HVM" : "NOT_YET_SUPPORTED" },
      "ap-southeast-1" : { "32" : "ami-b4b0cae6", "64" : "ami-beb0caec", "64HVM" : "NOT_YET_SUPPORTED" },
      "ap-northeast-1" : { "32" : "ami-0644f007", "64" : "ami-0a44f00b", "64HVM" : "NOT_YET_SUPPORTED" },
      "sa-east-1"      : { "32" : "ami-3e3be423", "64" : "ami-3c3be421", "64HVM" : "NOT_YET_SUPPORTED" }
    },
    
    "InstanceTypeMap" : {
      "db.m1.small" : {
        "CPULimit" : "60",
        "FreeStorageSpaceLimit" : "1024",
        "ReadIOPSLimit" : "100",
        "WriteIOPSLimit" : "100"
      },
      "db.m1.large" : {
        "CPULimit" : "60",
        "FreeStorageSpaceLimit" : "1024",
        "ReadIOPSLimit" : "100",
        "WriteIOPSLimit" : "100"
      },
      "db.m1.xlarge" : {
        "CPULimit" : "60",
        "FreeStorageSpaceLimit" : "1024",
        "ReadIOPSLimit" : "100",
        "WriteIOPSLimit" : "100"
      },
      "db.m2.xlarge" : {
        "CPULimit" : "60",
        "FreeStorageSpaceLimit" : "1024",
        "ReadIOPSLimit" : "100",
        "WriteIOPSLimit" : "100"
      },
      "db.m2.2xlarge" : {
        "CPULimit" : "60",
        "FreeStorageSpaceLimit" : "1024",
        "ReadIOPSLimit" : "100",
        "WriteIOPSLimit" : "100"
      },
      "db.m2.4xlarge" : {
        "CPULimit" : "60",
        "FreeStorageSpaceLimit" : "1024",
        "ReadIOPSLimit" : "100",
        "WriteIOPSLimit" : "100"
      }
    }
  },
    
  "Resources" : {
  
    "NotificationTopic": {
      "Type": "AWS::SNS::Topic",
      "Properties": {
        "Subscription": [ {
            "Endpoint": { "Ref": "OperatorEmail" },
            "Protocol": "email" } ]
      }
    },
    
    "CFNInitUser" : {
      "Type" : "AWS::IAM::User",
      "Properties" : {
        "Path": "/",
        "Policies": [{
          "PolicyName": "root",
          "PolicyDocument": { "Statement":[{
            "Effect"   : "Allow",
            "Action"   : [
              "cloudformation:DescribeStackResource",
              "s3:GetObject"
            ],
            "Resource" :"*"
          }]}
        }]
      }
    },

    "CFNKeys" : {
      "Type" : "AWS::IAM::AccessKey",
      "Properties" : {
        "UserName" : { "Ref": "CFNInitUser" }
      }
    },
    
    "BucketPolicy" : {
      "Type" : "AWS::S3::BucketPolicy",
      "Properties" : {
        "PolicyDocument": {
          "Version"      : "2008-10-17",
          "Id"           : "s3GetObjectReadPolicy",
          "Statement"    : [{
            "Sid"        : "ReadAccess",
            "Action"     : ["s3:GetObject"],
            "Effect"     : "Allow",
            "Resource"   : { "Fn::Join" : ["", ["arn:aws:s3:::", { "Ref" : "SourceBucket" }, "/*"]]},
            "Principal"  : { "AWS": {"Fn::GetAtt" : ["CFNInitUser", "Arn"]} }
          }]
        },
        "Bucket" : { "Ref" : "SourceBucket" }
      }
    },
    
    "WebServerGroup" : {
      "Type" : "AWS::AutoScaling::AutoScalingGroup",
      "Properties" : {
        "AvailabilityZones"       : { "Ref" : "AvailabilityZones" },
        "Cooldown"                : "600",
        "HealthCheckGracePeriod"  : "600",
        "HealthCheckType"         : "ELB",
        "LaunchConfigurationName" : { "Ref" : "LaunchConfig" },
        "MinSize"                 : { "Ref" : "WebServerCapacityMin" },
        "MaxSize"                 : { "Ref" : "WebServerCapacityMax" },
        "LoadBalancerNames"       : [ { "Ref" : "ElasticLoadBalancer" } ],
        "NotificationConfiguration" : {
          "TopicARN" : { "Ref" : "NotificationTopic" },
          "NotificationTypes" : [ "autoscaling:EC2_INSTANCE_LAUNCH","autoscaling:EC2_INSTANCE_LAUNCH_ERROR","autoscaling:EC2_INSTANCE_TERMINATE", "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"]
        }
      }
   },
   
   "LaunchConfig" : {
      "Type" : "AWS::AutoScaling::LaunchConfiguration",
      "DependsOn" : "BucketPolicy",
      "Metadata" : {
        "AWS::CloudFormation::Init" : {
          "config" : {
            "packages" : {
              "yum" : {
                "puppet"        : [],
                "puppet-server" : [],
                "ruby-devel"    : [],
                "gcc"           : [],
                "make"          : [],
                "rubygems"      : []
              },
              "rubygems" : {
                "json"          : []
              }
            },
            "sources" : {
              "/etc/puppet" : { "Ref" : "PuppetModulesLocation" },
              "/deploy" : { "Fn::Join" : ["/", ["https://s3.amazonaws.com", 
                { "Ref" : "SourceBucket" },
                { "Ref" : "SourceName" }
              ]]}
            },
            "files" : {
              "/etc/puppet/manifests/site.pp" : {
                "content" : { "Fn::Join" : ["", [
                  "Exec { path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin', logoutput => true }\n",
                  "include ", { "Ref" : "PuppetClass" }
                ]]}
              }
            }
          }
        },
        "AWS::CloudFormation::Authentication" : {
          "S3AccessCreds" : {
            "type" : "S3",
            "accessKeyId" : { "Ref" : "CFNKeys" },
            "secretKey" : {"Fn::GetAtt": ["CFNKeys", "SecretAccessKey"]},
            "buckets" : [ { "Ref" : "SourceBucket" } ]
          }
        },
        "Puppet" : {
          "adminemail"     : {"Ref" : "OperatorEmail" },
          "debug"          : {"Ref" : "Debug" },
          "host"           : {"Fn::GetAtt" : ["DatabaseInstance", "Endpoint.Address"]},
          "database"       : {"Ref" : "DatabaseName"},
          "user"           : {"Ref" : "DatabaseUser"},
          "password"       : {"Ref" : "DatabasePassword" },
          "aws_secret_key" : {"Ref" : "AWSSecretKey" },
          "aws_key"        : {"Ref" : "AWSKey" },
          "s3_bucket"      : {"Ref" : "S3Bucket" },
          "domain"         : {"Ref" : "DomainName"},
          "hostname"       : {"Ref" : "Hostname"}
ifdef(`HOSTNAME2',`dnl
          ,"hostname2"     : {"Ref" : "Hostname2"}
')dnl
ifdef(`SECRET_KEY',`dnl
          ,"secret_key"    : {"Ref" : "SecretKey"}
')dnl
        }
      },
      "Properties" : {
        "KeyName"        : { "Ref" : "KeyName" },
        "ImageId"        : { "Fn::FindInMap" : [ "AWSRegionArch2AMI", { "Ref" : "AWS::Region" },
                           { "Fn::FindInMap" : [ "AWSInstanceType2Arch", { "Ref" : "InstanceType" }, "Arch" ] } ] },
        "SecurityGroups" : [ { "Ref" : "EC2SecurityGroup" } ],
        "InstanceType"   : { "Ref" : "InstanceType" },
        "UserData"       : { "Fn::Base64" : { "Fn::Join" : ["", [
                              "#!/bin/bash\n",
                              "yum update -y aws-cfn-bootstrap\n",
                              
                              "# Helper function\n",
                              "function error_exit\n",
                              "{\n",
                              "  /opt/aws/bin/cfn-signal -e 1 -r \"$1\" '", { "Ref" : "WaitHandle" }, "'\n",
                              "  exit 1\n",
                              "}\n",
                    
                              "/opt/aws/bin/cfn-init --region ", { "Ref" : "AWS::Region" },
                              "    -s ", { "Ref" : "AWS::StackName" }, " -r LaunchConfig ",
                              "    --access-key ", { "Ref" : "CFNKeys" },
                              "    --secret-key \"", { "Fn::GetAtt" : ["CFNKeys", "SecretAccessKey"]}, "\"", 
                              " || error_exit 'Failed to run cfn-init'\n",
                              "/bin/sed -i -e '0,/enabled=0/{s/enabled=0/enabled=1/}' /etc/yum.repos.d/epel.repo\n",
                              "/usr/bin/puppet apply /etc/puppet/manifests/site.pp -v || error_exit 'Failed to apply puppet'\n",
                              "/opt/aws/bin/cfn-signal -e $? -r \"Setup complete\" '", { "Ref" : "WaitHandle" }, "'\n"
        ]]}}
      }
    },
    
    "WaitHandle" : {
      "Type" : "AWS::CloudFormation::WaitConditionHandle"
    },

    "WaitCondition" : {
      "Type" : "AWS::CloudFormation::WaitCondition",
      "DependsOn" : "WebServerGroup",
      "Properties" : {
        "Handle" : {"Ref" : "WaitHandle"},
        "Timeout" : "900"
      }
    },
    
    "WebServerScaleUpPolicy" : {
      "Type" : "AWS::AutoScaling::ScalingPolicy",
      "Properties" : {
        "AdjustmentType" : "ChangeInCapacity",
        "AutoScalingGroupName" : { "Ref" : "WebServerGroup" },
        "Cooldown" : "600",
        "ScalingAdjustment" : "1"
      }
    },
    "WebServerScaleDownPolicy" : {
      "Type" : "AWS::AutoScaling::ScalingPolicy",
      "Properties" : {
        "AdjustmentType"       : "ChangeInCapacity",
        "AutoScalingGroupName" : { "Ref" : "WebServerGroup" },
        "Cooldown"             : "600",
        "ScalingAdjustment"    : "-1"
      }
    },
    "ElasticLoadBalancer" : {
      "Type" : "AWS::ElasticLoadBalancing::LoadBalancer",
      "Metadata" : {
        "Comment" : "Configure the Load Balancer with a simple health check"
      },
      "Properties" : {
        "AvailabilityZones" : { "Ref" : "AvailabilityZones" },
        "Listeners" : [ {
          "LoadBalancerPort" : "80",
          "InstancePort"     : "80",
          "Protocol"         : "HTTP"
        } ],
        "HealthCheck" : {
          "Target"             : "HTTP:80/",
          "HealthyThreshold"   : "2",
          "UnhealthyThreshold" : "5",
          "Interval"           : "60",
          "Timeout"            : "5"
        }
      }
    },
    "ELBLatencyHigh": {
     "Type" : "AWS::CloudWatch::Alarm",
     "Properties" : {
        "AlarmDescription"   : "Scale up if Avg Latency > 1 second over 5mins",
        "MetricName"         : "Latency",
        "Namespace"          : "AWS/ELB",
        "Statistic"          : "Average",
        "Period"             : "60",
        "EvaluationPeriods"  : "5",
        "Threshold"          :  "1",
        "AlarmActions"       : [ 
          { "Ref": "WebServerScaleUpPolicy" }
        ],
        "OKActions"          : [ 
          { "Ref": "WebServerScaleDownPolicy" }
        ],
        "Dimensions"         : [
          {
            "Name": "LoadBalancerName",
            "Value": { "Ref": "ElasticLoadBalancer" }
          }
        ],
        "ComparisonOperator" : "GreaterThanThreshold"
      }
    },
        
    "DatabaseInstance" : {
      "Type" : "AWS::RDS::DBInstance",
      "Properties" : {
        "MultiAZ"              : { "Ref" : "MultiAZDatabase" },
ifdef(`RDSSNAPSHOT',
`"DBSnapshotIdentifier" : { "Ref" : "DatabaseSnapshot" },',
`"DBName"               : { "Ref" : "DatabaseName" },'
)
        "AllocatedStorage"     : { "Ref" : "DatabaseSize" },
        "Engine"               : "MySQL",
        "DBInstanceClass"      : { "Ref" : "DatabaseType" },
        "DBSecurityGroups"     : [ { "Ref": "DBSecurityGroup" } ],
        "MasterUsername"       : { "Ref" : "DatabaseUser" },
        "MasterUserPassword"   : { "Ref" : "DatabasePassword" }
      },
      "DeletionPolicy" : "RDSDELETIONPOLICY"
    },
    
    "DBSecurityGroup": {
      "Type": "AWS::RDS::DBSecurityGroup",
      "Properties": {
        "DBSecurityGroupIngress": {
          "EC2SecurityGroupName": { "Ref": "EC2SecurityGroup" }
        },
        "GroupDescription": "database access"
      }
    },
    
    "DBCPUAlarmHigh": {
      "Type": "AWS::CloudWatch::Alarm",
      "Properties": {
        "AlarmDescription": { "Fn::Join" : [ "", ["Alarm if ", { "Ref" : "DatabaseName" }, " CPU > ", { "Fn::FindInMap" : [ "InstanceTypeMap", { "Ref" : "DatabaseType" }, "CPULimit" ]}, "% for 5 minutes" ]]},
        "Namespace": "AWS/RDS",
        "MetricName": "CPUUtilization",
        "Statistic": "Average",
        "Period": "60",
        "Threshold": { "Fn::FindInMap" : [ "InstanceTypeMap", { "Ref" : "DatabaseType" }, "CPULimit" ]},
        "ComparisonOperator": "GreaterThanThreshold",
        "EvaluationPeriods": "5",
        "AlarmActions": [ { "Ref": "NotificationTopic" } ],
        "Dimensions": [{
            "Name": "DBInstanceIdentifier",
            "Value": { "Ref": "DatabaseInstance" }
        }]
      }
    }, 
    "DBFreeStorageSpace": {
      "Type": "AWS::CloudWatch::Alarm",
      "Properties": {
        "AlarmDescription": { "Fn::Join" : [ "", ["Alarm if ", { "Ref" : "DatabaseName" }, " storage space <= ", { "Fn::FindInMap" : [ "InstanceTypeMap", { "Ref" : "DatabaseType" }, "FreeStorageSpaceLimit" ]}, " for 5 minutes" ]]},
        "Namespace": "AWS/RDS",
        "MetricName": "FreeStorageSpace",
        "Statistic": "Average",
        "Period": "60",
        "Threshold": { "Fn::FindInMap" : [ "InstanceTypeMap", { "Ref" : "DatabaseType" }, "FreeStorageSpaceLimit" ]},
        "ComparisonOperator": "LessThanOrEqualToThreshold",
        "EvaluationPeriods": "5",
        "AlarmActions": [ { "Ref": "NotificationTopic" } ],
        "Dimensions": [{
            "Name": "DBInstanceIdentifier",
            "Value": { "Ref": "DatabaseInstance" }
        }]
      }
    }, 
    "DBReadIOPSHigh": {
      "Type": "AWS::CloudWatch::Alarm",
      "Properties": {
        "AlarmDescription": { "Fn::Join" : [ "", ["Alarm if ", { "Ref" : "DatabaseName" }, " WriteIOPs > ", { "Fn::FindInMap" : [ "InstanceTypeMap", { "Ref" : "DatabaseType" }, "ReadIOPSLimit" ]}, " for 5 minutes" ]]},
        "Namespace": "AWS/RDS",
        "MetricName": "ReadIOPS",
        "Statistic": "Average",
        "Period": "60",
        "Threshold": { "Fn::FindInMap" : [ "InstanceTypeMap", { "Ref" : "DatabaseType" }, "ReadIOPSLimit" ]},
        "ComparisonOperator": "GreaterThanThreshold",
        "EvaluationPeriods": "5",
        "AlarmActions": [ { "Ref": "NotificationTopic" } ],
        "Dimensions": [{
            "Name": "DBInstanceIdentifier",
            "Value": { "Ref": "DatabaseInstance" }
        }]
      }
    },
    "DBWriteIOPSHigh": {
      "Type": "AWS::CloudWatch::Alarm",
      "Properties": {
        "AlarmDescription": { "Fn::Join" : [ "", ["Alarm if ", { "Ref" : "DatabaseName" }, " WriteIOPs > ", { "Fn::FindInMap" : [ "InstanceTypeMap", { "Ref" : "DatabaseType" }, "WriteIOPSLimit" ]}, " for 5 minutes" ]]},
        "Namespace": "AWS/RDS",
        "MetricName": "WriteIOPS",
        "Statistic": "Average",
        "Period": "60",
        "Threshold": { "Fn::FindInMap" : [ "InstanceTypeMap", { "Ref" : "DatabaseType" }, "WriteIOPSLimit" ]},
        "ComparisonOperator": "GreaterThanThreshold",
        "EvaluationPeriods": "5",
        "AlarmActions": [ { "Ref": "NotificationTopic" } ],
        "Dimensions": [{
            "Name": "DBInstanceIdentifier",
            "Value": { "Ref": "DatabaseInstance" }
        }]
      }
    },

    "EC2SecurityGroup" : {
      "Type" : "AWS::EC2::SecurityGroup",
      "Properties" : {
        "GroupDescription" : "Group for puppet communication",
        "SecurityGroupIngress" : [
          {"IpProtocol" : "tcp", "FromPort" : "22", "ToPort" : "22", "CidrIp" : "0.0.0.0/0" },
          {"IpProtocol" : "tcp", "FromPort" : "80", "ToPort" : "80", "CidrIp" : "0.0.0.0/0" }
        ]        
      }
    },
    
    "myDNS" : {
        "Type" : "AWS::Route53::RecordSetGroup",
        "Properties" : {
          "HostedZoneName" : { "Fn::Join" : ["", [
                { "Ref" : "DomainName" }
                ,"."
              ]]},
          "RecordSets" : [
            {
              "Name" : { "Ref" : "Hostname" },
              "Type" : "A",
              "AliasTarget" : {
                  "HostedZoneId" : { "Fn::GetAtt" : ["ElasticLoadBalancer", "CanonicalHostedZoneNameID"] },
                  "DNSName" : { "Fn::GetAtt" : ["ElasticLoadBalancer","CanonicalHostedZoneName"] }
              }
            }
ifdef(`HOSTNAME2',`dnl
            ,{
              "Name" : { "Ref" : "Hostname2" },
              "Type" : "A",
              "AliasTarget" : {
                  "HostedZoneId" : { "Fn::GetAtt" : ["ElasticLoadBalancer", "CanonicalHostedZoneNameID"] },
                  "DNSName" : { "Fn::GetAtt" : ["ElasticLoadBalancer","CanonicalHostedZoneName"] }
              }
            }
')dnl
          ]   
        }
    }
    
  },
  
  "Outputs" : {
    "LoadBalancerURL" : {
      "Description" : "The URL of the Load Balancer",
      "Value" :  { "Fn::Join" : [ "", [ "http://", { "Fn::GetAtt" : [ "ElasticLoadBalancer", "DNSName" ]}]]}
    },
    "AliasURL" : {
      "Description" : "The URL of the website",
      "Value" :  { "Fn::Join" : [ "", [ "http://", { "Ref" : "Hostname" }, "/"]]}
    }
  }
}