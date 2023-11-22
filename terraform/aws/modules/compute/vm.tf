resource "aws_launch_template" "ec2_lt" {
    name                   = "${var.ec2_GS_name}"
    image_id               = "${var.ec2_GS_ami}"
    instance_type          = "${var.ec2_GS_instance_type}"
    key_name               = "${var.ec2_GS_ssh_key_name}"
    user_data              = "${base64encode(data.template_file.user_data.rendered)}"
    vpc_security_group_ids = ["${var.vpc_sg_pub_id}"]
}


resource "aws_lb" "ec2_lb" {
    name               = "${var.ec2_lb_name}"
    load_balancer_type = "application"
    subnets            = ["${var.vpc_sn_pub_az1_id}", "${var.vpc_sn_pub_az2_id}"]
    security_groups    = ["${var.vpc_sg_pub_id}"]
}

resource "aws_lb_target_group" "ec2_lb_tg" {
    name     = "${var.ec2_lb_tg_name}"
    protocol = "${var.ec2_lb_tg_protocol}"
    port     = "${var.ec2_lb_tg_port}"
    vpc_id   = "${var.vpc_id}"
}

resource "aws_lb_listener" "ec2_lb_listener" {
    protocol          = "${var.ec2_lb_listener_protocol}"
    port              = "${var.ec2_lb_listener_port}"
    load_balancer_arn = aws_lb.ec2_lb.arn
    
    default_action {
        type             = "${var.ec2_lb_listener_action_type}"
        target_group_arn = aws_lb_target_group.ec2_lb_tg.arn
    }
}


resource "aws_autoscaling_group" "ec2_asg" {
    name                = "${var.ec2_asg_name}"
    desired_capacity    = "${var.ec2_asg_desired_capacity}"
    min_size            = "${var.ec2_asg_min_size}"
    max_size            = "${var.ec2_asg_max_size}"
    vpc_zone_identifier = ["${var.vpc_sn_pub_az1_id}", "${var.vpc_sn_pub_az2_id}"]
    target_group_arns   = [aws_lb_target_group.ec2_lb_tg.arn]
    launch_template {
        id      = aws_launch_template.ec2_lt.id
        version = "$Latest"
    }
}
resource "aws_security_group" "sg_public" {
    name   = "sg_public"
    vpc_id = "${var.vpc.id}"
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["${var.vpc.cidr}"]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        description = "TCP/80 from All"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "TCP/80 from All"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }


}

data "template_file" "cloud_init" {
    template = "${file("./modules/compute/init/cloud_init.sh")}"
}

resource "aws_instance" "instance" {
    ami                    = "${var.ec2_GS_ami}"
    instance_type          = "t2.micro"
    subnet_id              = "${var.subnet.id}"
    vpc_security_group_ids = [aws_security_group.sg_public.id]
    user_data              = "${base64encode(data.template_file.cloud_init.rendered)}"
}