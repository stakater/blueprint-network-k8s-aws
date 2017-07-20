resource "aws_route_table" "persistence" {
  vpc_id = "${var.vpc_id}"

  # Ignore routing table changes because we will add Kubernetes PodCIDR routing outside of Terraform
  lifecycle {
    ignore_changes = ["route"]
  }

  tags {
    Name              = "${var.name}-RT"
    KubernetesCluster = "${var.kubernetes_cluster}"
  }
}

resource "aws_subnet" "persistence" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.private_persistence_subnets[count.index]}"
  availability_zone = "${var.azs[count.index]}"
  count             = "${length(var.azs)}"

  tags {
    Name              = "${var.name}-${var.azs[count.index]}"
    KubernetesCluster = "${var.kubernetes_cluster}"
  }
}

resource "aws_route_table_association" "persistence" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.persistence.*.id, count.index)}"
  route_table_id = "${aws_route_table.persistence.id}"
}
