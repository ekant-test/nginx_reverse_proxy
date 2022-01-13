
resource "aws_iam_role" "server" {
  name = "${local.service_name}-test"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge({
      "Name" = "${local.service_name}-test"
    })
}

resource "aws_iam_instance_profile" "server" {
  name = "${local.service_name}-test"
  role = aws_iam_role.server.name
}

# ---- attach the basic AWS managed SSM EC2 policies ---------------------------

resource "aws_iam_role_policy_attachment" "amzn_ssm_instance_core" {
  role       = aws_iam_role.server.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_role_policy" "server" {
  name = "${local.service_name}-${terraform.workspace}"
  role = aws_iam_role.server.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      # access the archive
      {
        "Effect" : "Allow",
        "Action" : [
          "*"
        ],
        "Resource" : [
          "arn:aws:s3:::test-bucket-ekant/*",
          "arn:aws:s3:::test-bucket-ekant"
        ]
      },
    ]
  })
}
