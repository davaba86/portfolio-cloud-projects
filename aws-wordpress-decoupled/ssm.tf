resource "aws_iam_role" "ssm_session_manager" {
  name        = "ssm-session-manager"
  description = "Allows EC2 instances to call AWS services on your behalf."

  assume_role_policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" : [
      {
        "Action" = "sts:AssumeRole",
        "Effect" = "Allow",
        "Sid"    = ""
        "Principal" = {
          "Service" = "ec2.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
}

resource "aws_iam_instance_profile" "ssm_session_manager" {
  name = "ssm-session-manager"
  role = aws_iam_role.ssm_session_manager.name
}

resource "aws_ssm_document" "session_manager_preferences" {
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Document to hold regional settings for Session Manager"
    sessionType   = "Standard_Stream"
    inputs = {
      cloudWatchEncryptionEnabled = true
      cloudWatchLogGroupName      = ""
      cloudWatchStreamingEnabled  = true
      idleSessionTimeout          = "20"
      kmsKeyId                    = ""
      maxSessionDuration          = ""
      runAsDefaultUser            = ""
      runAsEnabled                = false
      s3BucketName                = ""
      s3EncryptionEnabled         = true
      s3KeyPrefix                 = ""
      shellProfile = {
        linux   = "/bin/bash"
        windows = ""
      }
    }
  })
}
