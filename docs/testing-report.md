AWS Capstone Project - Testing Report
1. Project Overview

This document contains the testing results for the AWS Capstone Project. The project was tested using multiple EC2 server instances to verify application availability, HTTP connectivity, automation, and basic security configuration.

Number of EC2 servers tested: 5

2. Infrastructure Testing
EC2 Instance Testing
Server	Instance Status	Public IP Accessible	Web Server	Status
Server 1	Running	Yes	Apache	Passed
Server 2	Running	Yes	Apache	Passed
Server 3	Running	Yes	Apache	Passed
Server 4	Running	Yes	Apache	Passed
Server 5	Running	Yes	Apache	Passed
Security Group Testing
Server	SSH (22)	HTTP (80)	Website Accessible	Status
Server 1	Configured	Configured	Yes	Passed
Server 2	Configured	Configured	Yes	Passed
Server 3	Configured	Configured	Yes	Passed
Server 4	Configured	Configured	Yes	Passed
Server 5	Configured	Configured	Yes	Passed
3. Web Application Testing
Server	Test	Expected Result	Actual Result	Status
Server 1	Open website	Website loads	Website loaded successfully	Passed
Server 1	HTTP connection	Connection successful	HTTP connection successful	Passed
Server 1	HTML page	Page displays correctly	Page displayed correctly	Passed
Server 2	Open website	Website loads	Website loaded successfully	Passed
Server 2	HTTP connection	Connection successful	HTTP connection successful	Passed
Server 2	HTML page	Page displays correctly	Page displayed correctly	Passed
Server 3	Open website	Website loads	Website loaded successfully	Passed
Server 3	HTTP connection	Connection successful	HTTP connection successful	Passed
Server 3	HTML page	Page displays correctly	Page displayed correctly	Passed
Server 4	Open website	Website loads	Website loaded successfully	Passed
Server 4	HTTP connection	Connection successful	HTTP connection successful	Passed
Server 4	HTML page	Page displays correctly	Page displayed correctly	Passed
Server 5	Open website	Website loads	Website loaded successfully	Passed
Server 5	HTTP connection	Connection successful	HTTP connection successful	Passed
Server 5	HTML page	Page displays correctly	Page displayed correctly	Passed
4. Automation Testing

The user-data script was tested during EC2 instance initialization.

Server	User-Data Executed	Web Server Installed	Web Server Running	Website Deployed	Status
Server 1	Yes	Yes	Yes	Yes	Passed
Server 2	Yes	Yes	Yes	Yes	Passed
Server 3	Yes	Yes	Yes	Yes	Passed
Server 4	Yes	Yes	Yes	Yes	Passed
Server 5	Yes	Yes	Yes	Yes	Passed

The automation successfully installed and started the web server on the tested instances.

5. Security Testing
Security Test	Expected Result	Result	Status
AWS credentials stored in GitHub	Credentials should not be exposed	No credentials found	Passed
Sensitive files excluded	Sensitive files should be excluded	.gitignore configured	Passed
SSH access	Only authorized access allowed	Configured	Passed
HTTP access	Port 80 available for web traffic	Configured	Passed
Unnecessary ports	Should remain restricted	Restricted	Passed
6. Screenshots

The following screenshots should be added as project evidence:

AWS EC2 Server 1
AWS EC2 Server 2
AWS EC2 Server 3
AWS EC2 Server 4
AWS EC2 Server 5
Security Group configuration
Terminal/SSH connection
Website running in browser
GitHub repository
User-data configuration
7. Final Result

The AWS Capstone Project was tested across five EC2 server instances. The instances were successfully launched, the web server was configured, and the web application was accessible through HTTP.

The automation script was also tested to verify that the required web server configuration could be performed automatically during instance initialization.

Overall testing result: Passed

8. Issues and Solutions
Issue 1: Website initially unavailable

Problem: The website was not accessible immediately after the EC2 instance was created.

Solution: The security group configuration was checked and HTTP access on port 80 was enabled.

Issue 2: Web server not running

Problem: The web server was not responding on one test instance.

Solution: The web server service was checked and restarted.

Issue 3: User-data execution delay

Problem: The website was not immediately available after instance launch.

Solution: The instance was allowed additional time to complete the user-data script and install the required packages.

9. Conclusion

The testing demonstrated that the AWS infrastructure and web application can be deployed across multiple EC2 instances. The application was accessible through HTTP, the web server was operational, and the automation script successfully configured the required environment.

Note: The test results above are sample data and should be replaced with actual results and screenshots from the AWS environment before final submission.