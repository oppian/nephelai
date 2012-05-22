nephelai
========

Templates and preprocessor to build AWS CloudFormation templates. 

nephelai means The Clouds

Usage
-----

The following command will build a CloudFormation json file using the specifed configuration

        ./cfn-build.sh example/examplesite.m4
        
This will create in the current directory a file `examplesite-{datetimestamp}.template.json` which can be used by AWS CloudFormation to create a cloud stack. It will allow you to edit the parameters on AWS when you deploy.

Settings
--------

* `PUPPETCLASS` --- The specific name of the puppet class that will start the deploy
    Puppet will be started in local mode (no server) which gets kicked of by this class, no params. You want to put a puppet directory into your source which will handle deployment of your app. Puppet will be started with:
    ```
    Exec { path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin', logoutput => true }
    include PUPPETCLASS
    ```

* `PUPPETMODULES` --- A link to a set of generic puppet modules that will be added to the local puppet.
    This url will be downloaded and expanded into `/etc/puppet/`. You are free to use ours or put in your own. Our puppet modules includes a `puppet.conf` that sets `modulepath=$confdir/modules:/deploy/puppet/modules`. Note that `/deploy/puppet/modules` is in the modulepath which allows `PUPPETCLASS` to be found in the web applications source.

* `SOURCEBUCKET` --- A S3 bucket that contains the source to the web application.
    This bucket can be private as the CloudFormation templates will create an AWS user to have read access to this bucket. This allows you to deploy private source code.

* `SOURCENAME` --- The filename on the S3 bucket to download.
    It will look for source found at `S3:SOURCEBUCKET/SOURCENAME` and expand it into `/deploy`. Make sure it has a `/puppet` directory in it so the application can be deployed.

* `HOSTNAME1` --- The hostname that will be created in AWS route53 to point to the load balancer.
    Using route53 a host entry will be created that is aliased to the Elastic Load Balancer. Make sure the domain is managed by route53.

* `HOSTNAME2` --- The (optional) second hostname that will be created in route53 to point to the load balancer.
    This is optional but allows a second hostname to be aliased. This is so you can have say the `domain.com` and `www.domain.com` both pointing to the same website.

* `DOMAINNAME` --- The domain name that will be passed down to the app for it to use (such as Django).

* `ADMINEMAIL` --- Email address that will be configured to get AWS SNS notifications for when instances are scaled up/down.

* `RDSSNAPSHOT` --- An optional AWS RDS snapshot to create the database from.
    If specified the RDS instance will use this snapshot to create the database. Otherwise a fresh RDS instance will be created.

* `RDSDELETIONPOLICY` --- What AWS DeletionPolicy you want on the RDS instance, can be `Delete`, `Retain` or `Snapshot`.
    Normally for dev stacks you set it to `Delete` and for production you probably will use `Snapshot` or even possibly `Retain`
    More details can be found at http://docs.amazonwebservices.com/AWSCloudFormation/latest/UserGuide/aws-attribute-deletionpolicy.html
    * `Delete` --- Means to delete the database when the stack is deleted.
    * `Retain` --- Means the RDS instance is left running when you delete the stack.
    * `Snapshot` --- A database snapshot will be taken before the RDS instance is deleted.

* `MULTIAZDB` --- Specifies if the RDS instance is a multi-az instance or not.

* `DEBUG` --- A flag that can be passed down to puppet, can be used for example in Django settings.

* `AZLIST` --- A comma separated list of availability zones you want your instances and load balancer to span, make sure you have at least this number of minimum instances.

* `SECRET_KEY` --- A django secret key can be specified here to be filled out with puppet.

* `AWS_ACCESS_KEY_ID` --- An AWS key that will be passed down to puppet for webapps use.

* `AWS_SECRET_ACCESS_KEY` --- A secret AWS key that will be passed to puppet for the webapp to use.

* `S3_BUCKET` --- An S3 bucket we pass down to puppet for the webapp to use.