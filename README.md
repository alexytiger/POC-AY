# Introduction 
An API Gateway in front of the Lambda API function acts as an intermediary between external request and the logic implemented in the Lambda function. The API Gateway is configured to route the request to the Lambda function.

Lambda-api (<a href="https://benefitexpress.visualstudio.com/_git/POCs?path=/lambda-api">lambda-api project folder</a>) is a Web API housing the definitions to interact with the File Controller. It outline the actions for the POST, GET and DELETE endpoints

S3-lambda-s3 (<a href="https://benefitexpress.visualstudio.com/_git/POCs?path=/s3-lambda-s3">s3-lambda-s3 project folder</a>) is a function that listens to events from an S3 bucket. If a file is uploaded to the bucket the lambda function must be called, it will receive the file information, then it will save it to another bucket in json format. 

![Architecture Diagram](/images/architecture.png)

> All infrastructure resources were created using Terraform, the configuration files are located in the **infra** folder

## How to test the POC?

Install Thunder Client extension for VS Code and import ```APIGateway.json``` collection
https://marketplace.visualstudio.com/items?itemName=rangav.vscode-thunder-client (we can do it with Postman too but collection need to be create because this one is for Thunder only)

### API Gateway Base URL
https://zrvxq60mkc.execute-api.us-east-1.amazonaws.com/v1/

### Endpoints
- **POST**
    - **Route:** ``/api/file/upload``
    - **Description:** Upload file to bucket ``poc-elfuerte-dv-upload``, then this bucket sends a notification to the ``s3-lambda-s3`` function generating a new json file with the file information, this file is stored in the ``poc-elfuerte-dv-download`` bucket
    ![POST Request](/images/post.png)

- **Get**
    - **Route:** ``/api/file/list``
    - **Description:** returns the list of objects in the ``poc-elfuerte-dv-download`` bucket
    ![GET Request](/images/list.png)

- **Get**
    - **Route:** ``/api/file/{key}``
    - **Description:** returns an object by its key in the ``poc-elfuerte-dv-download`` bucket
    ![GET Request](/images/get.png)

- **Delete**
    - **Route:** ``/api/file/{key}``
    - **Description:** removes an object by its key in the ``poc-elfuerte-dv-download`` bucket
    ![DELETE Request](/images/delete.png)


## How to create Lambda function in dotnet?

1. The easiest way is to use the AWS Toolkit extension for Visual Studio
```https://aws.amazon.com/visualstudio/```

2. Crete new Lambda project using AWS Toolkit.
![Create Project](/images/createproject.png)

3. Select a template.
![Select Template](/images/select-template.png)

4. Write the modifications that are necessary in your code.

5. Once your function is ready, 
it can be deployed using the same extension (AWS Toolkit).
https://aws.amazon.com/blogs/developer/using-the-aws-lambda-project-in-visual-studio/


## How to test your function from AWS Console?
In this example, it is showcase a Lambda function that runs through an S3 event. In this scenario, the triggering event occurs when new file is created in the ```poc-elfuerte-dv-upload``` bucket. 

### Dev environment

https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/functions/s3-lambda-s3?tab=configure

![Test Lambda](/images/test-lambda.png)

**Note how the permission policy associated whit the function allows it to be executed by the bucket event**

> Terraform Code https://benefitexpress.visualstudio.com/_git/POCs?path=/infra/lambda.tf&version=GBpoc-elfuerte&line=43&lineEnd=49&lineStartColumn=1&lineEndColumn=2&lineStyle=plain&_a=contents

![View Policy](/images/viewpolicy.png)

```
{
  "Version": "2012-10-17",
  "Id": "default",
  "Statement": [
    {
      "Sid": "AllowS3Invoke",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "lambda:InvokeFunction",
      "Resource": "arn:aws:lambda:us-east-1:028954361857:function:s3-lambda-s3",
      "Condition": {
        "ArnLike": {
          "AWS:SourceArn": "arn:aws:s3:::poc-elfuerte-dv-upload"
        }
      }
    }
  ]
}
```

**If you navigate in the AWS Console to ```poc-elfuerte-dv-upload``` bucket and click on the properties tab. Then scroll down so you can see the configured event notification.**

![Properties Tab](/images/propertiestab.png)

> Terraform Code https://benefitexpress.visualstudio.com/_git/POCs?path=/infra/s3.tf&version=GBpoc-elfuerte&line=98&lineEnd=107&lineStartColumn=1&lineEndColumn=2&lineStyle=plain&_a=contents

![Event Notification](/images/event-s3.png)

**Return to the Lambda function in the console and go to the test tab. Select a S3-put template in the dropdown. This template correspond to and object creation event in the bucket.**

![Test Lambda](/images/test-example.png)

**Then click on test button and observe the function response.**

![Test Lambda](/images/function-response.png)

**The processing of the function has culminated with the creation of new json file in the ```poc-elfuerte-dv-download``` bucket**

![Result Object](/images/result-object.png)

> Code https://benefitexpress.visualstudio.com/_git/POCs?path=/s3-lambda-s3/POCElfuerteLambda/LambdaEntryPoint.cs&version=GBpoc-elfuerte&line=18&lineEnd=38&lineStartColumn=1&lineEndColumn=10&lineStyle=plain&_a=contents









