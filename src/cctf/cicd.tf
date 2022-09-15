//resource "aws_ecr_repository" "grapefruit" {
//  name = "${var.name}-grapefruit"
//}

//resource "aws_codecommit_repository" "grapefruit" {
//  repository_name = "${var.name}-grapefruit"
//  description     = "${var.name}-grapefruit"
//  count           = "${var.devops_count ? 1 : 0}"
//}

resource "aws_ecr_repository" "melon" {
  name  = "${var.name}-melon"
  count = "${var.devops_count ? 1 : 0}"
}

resource "aws_codecommit_repository" "melon" {
  repository_name = "${var.name}-melon"
  description     = "${var.name}-melon"
  count           = "${var.devops_count ? 1 : 0}"
}

resource "aws_codecommit_repository" "CC-Template-Scanner" {
  repository_name = "${var.name}-CC-Template-Scanner"
  description     = "${var.name}-CC-Template-Scanner"
  count           = "${var.devops_count ? 1 : 0}"
}

//resource "aws_ecr_repository" "apple" {
//  name  = "${var.name}-apple"
// count = "${var.devops_count ? 1 : 0}"
//}

//resource "aws_codecommit_repository" "apple" {
//  repository_name = "${var.name}-apple"
//  description     = "${var.name}-apple"
//  count           = "${var.devops_count ? 1 : 0}"
//}
