################################################################################################################################
# This file describes the SSL certs creation and registering it to the zone records and defining additional record for the ALB #
################################################################################################################################

#################################################################################################
# Define the public zone of the hosted domain
#################################################################################################

data "aws_route53_zone" "zone" {
  name         = "${var.www_domain}"
  private_zone = false
}

#################################################################################################
# Creation of the SSL certificate
#################################################################################################
resource "aws_acm_certificate" "certificate" {
    domain_name       = "${var.www_domain}"
    validation_method  = "DNS"
    tags = {
        Environment      = "${var.www_domain} SSL certificate"
    }
}

#################################################################################################
# Register the created certificate in the ROute53 records
#################################################################################################

resource "aws_route53_record" "certificate_record" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone.zone_id
}
#################################################################################################
# Valdiate the SSL certificate
#################################################################################################
resource "aws_acm_certificate_validation" "ertificate_validation" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_record: record.fqdn]
}

#################################################################################################
# Create Route53 records for the ALB
#################################################################################################

resource "aws_route53_record" "alb_record" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "${var.www_domain}"
  type    = "A"

  alias {
    name                   = aws_alb.application_load_balancer.dns_name
    zone_id                = aws_alb.application_load_balancer.zone_id
    evaluate_target_health = true
  }
  depends_on = [ aws_alb.application_load_balancer ]
}

# create WWW entry
resource "aws_route53_record" "www_alb_record" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "www.${var.www_domain}"
  type    = "A"

  alias {
    name                   = aws_alb.application_load_balancer.dns_name
    zone_id                = aws_alb.application_load_balancer.zone_id
    evaluate_target_health = true
  }
  depends_on = [ aws_alb.application_load_balancer ]
}