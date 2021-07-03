"""An AWS Python Pulumi program."""

import pulumi
import pulumi_aws as aws
# import pulumi_docker as docker

# TODO: static ips

PROJECT_NAME = 'HomeAssistant'
TAGS = {'owner': 'lwebb', 'created_with': 'pulumi'}
# INSTANCE_AMI = 'ami-0a1002150df471b2b'
# INSTANCE_TYPE = 't3.small'
KEY_PAIR_PUB = '../secrets/HomeAssistant.id_rsa.pub'
AVAILABILITY_ZONE = 'ap-southeast-2a'
BLUEPRINT_ID = 'ubuntu_20_04'
BUNDLE_ID = 'small_2_2'
KEY_PAIR = None
PORTS = [22, 80, 443, 6443]


def get_port_def(port, protocol='tcp'):
    return aws.lightsail.InstancePublicPortsPortInfoArgs(protocol=protocol,
                                                         from_port=port, to_port=port)


def create_lightsail_instance(name, bundle_id=BUNDLE_ID):
    global KEY_PAIR
    if not KEY_PAIR:
        KEY_PAIR = aws.lightsail.KeyPair('%s-keypair' % PROJECT_NAME,
                                         public_key=open(KEY_PAIR_PUB).read())
    i = aws.lightsail.Instance(name, availability_zone=AVAILABILITY_ZONE,
                               blueprint_id=BLUEPRINT_ID, key_pair_name=KEY_PAIR.name,
                               bundle_id=BUNDLE_ID, tags=TAGS)
    port_infos = []
    for p in PORTS:
        port_infos.append(get_port_def(p))
    aws.lightsail.InstancePublicPorts('%s-ports' % name,
                                      instance_name=i, port_infos=port_infos)

    ip = aws.lightsail.StaticIp('%s-staticip' % name)
    aws.lightsail.StaticIpAttachment('%s-staticip-binding' % name,
                                     static_ip_name=ip.id, instance_name=i.id)

    return i

# # pull the registry creds from ecr in a format that can be used
# def get_registry_creds():
#     creds = aws.ecr.get_authorization_token()
#     return docker.ImageRegistry(creds.proxy_endpoint, creds.user_name, creds.password)
#
#
# # resources
# scan_opts = aws.ecr.RepositoryImageScanningConfigurationArgs(scan_on_push=True)
# enc_opts = aws.ecr.RepositoryEncryptionConfigurationArgs(encryption_type='AES256')
# registry = aws.ecr.Repository(
#                '%s-registry' % PROJECT_NAME.lower(),
#                image_scanning_configuration=scan_opts,
#                encryption_configurations=[enc_opts],
#                image_tag_mutability="MUTABLE",
#                tags=TAGS
#              )
#
# vpc = aws.ec2.Vpc('%s-vpc' % PROJECT_NAME, cidr_block='172.16.0.0/16', tags=TAGS)
# gateway = aws.ec2.InternetGateway('%s-igw' % PROJECT_NAME, vpc_id=vpc.id)
# subnet = aws.ec2.Subnet('%s-subnet' % PROJECT_NAME, vpc_id=vpc.id, cidr_block='172.16.10.0/24',
#                         availability_zone=AVAILABILITY_ZONE, tags=TAGS,
#                         map_public_ip_on_launch=True)
# route_table = aws.ec2.RouteTable('%s-routetable' % PROJECT_NAME, vpc_id=vpc.id, tags=TAGS)
# route = aws.ec2.Route('%s-route-igw' % PROJECT_NAME, destination_cidr_block='0.0.0.0/0',
#                       gateway_id=gateway.id, route_table_id=route_table.id)
# aws.ec2.RouteTableAssociation('%s-subnet-association' % PROJECT_NAME, subnet_id=subnet.id, route_table_id=route_table.id)
#
# egress = [
#   aws.ec2.SecurityGroupEgressArgs(
#     from_port=0,
#     to_port=0,
#     protocol='-1',
#     cidr_blocks=['0.0.0.0/0']
#   )
# ]
# ingress = [
#   aws.ec2.SecurityGroupIngressArgs(from_port=22, to_port=22, protocol='tcp', cidr_blocks=['0.0.0.0/0']),
#   aws.ec2.SecurityGroupIngressArgs(from_port=80, to_port=80, protocol='tcp', cidr_blocks=['0.0.0.0/0']),
#   aws.ec2.SecurityGroupIngressArgs(from_port=443, to_port=443, protocol='tcp', cidr_blocks=['0.0.0.0/0']),
#   aws.ec2.SecurityGroupIngressArgs(from_port=6443, to_port=6443, protocol='tcp', cidr_blocks=['0.0.0.0/0'])
# ]
#
# security_group = aws.ec2.SecurityGroup('%s-sg' % PROJECT_NAME, vpc_id=vpc.id, tags=TAGS,
#                                        egress=egress, ingress=ingress)
#
# role = aws.iam.Role('%s-role' % PROJECT_NAME, path='/', assume_role_policy="""{
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": "sts:AssumeRole",
#             "Principal": {
#                "Service": "ec2.amazonaws.com"
#             },
#             "Effect": "Allow",
#             "Sid": ""
#         }
#     ]
# }""")
# role_policy = aws.iam.RolePolicy('%s-rolepolicy' % PROJECT_NAME, role=role.id, policy="""{
#     "Version": "2012-10-17",
#     "Statement": [{
#         "Effect": "Allow",
#         "Action": [
#             "ecr:Get*",
#             "ecr:List*",
#             "ecr:Describe*",
#             "ecr:BatchGet*"
#         ],
#         "Resource": "*",
#         "Sid": ""
#     }]
# }""")
# instance_profile = aws.iam.InstanceProfile('%s-instanceprofile' % PROJECT_NAME, role=role.name)
#
# key_pair = aws.ec2.KeyPair('%s-keypair' % PROJECT_NAME, tags=TAGS, public_key=open(KEYPAIR).read())
#
# credit_opts = aws.ec2.InstanceCreditSpecificationArgs(cpu_credits='standard')
# master = aws.ec2.Instance('%s-instance-master' % PROJECT_NAME, ami=INSTANCE_AMI,
#                           associate_public_ip_address=True, instance_type=INSTANCE_TYPE,
#                           vpc_security_group_ids=[security_group.id], subnet_id=subnet.id,
#                           tags=TAGS, credit_specification=credit_opts, key_name=key_pair.key_name,
#                           iam_instance_profile=instance_profile.name)
# agent = aws.ec2.Instance('%s-instance-agent' % PROJECT_NAME, ami=INSTANCE_AMI,
#                          associate_public_ip_address=True, instance_type=INSTANCE_TYPE,
#                          vpc_security_group_ids=[security_group.id], subnet_id=subnet.id,
#                          tags=TAGS, credit_specification=credit_opts, key_name=key_pair.key_name,
#                          iam_instance_profile=instance_profile.name)
#
# image = docker.Image('%s-image' % PROJECT_NAME, build=docker.DockerBuild(context='../app'),
#                      image_name=registry.repository_url, registry=get_registry_creds())


master = create_lightsail_instance('%s-master' % PROJECT_NAME)
# agent = create_lightsail_instance('%s-agent' % PROJECT_NAME)


# outputs
# pulumi.export('registry_url', registry.repository_url)
# pulumi.export('vpc_id', vpc.id)
# pulumi.export('subnet_id', subnet.id)
# pulumi.export('gateway_id', gateway.id)
pulumi.export('master_ip', master.public_ip_address)
# pulumi.export('agent_ip', agent.public_ip_address)
