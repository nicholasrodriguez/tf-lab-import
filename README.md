# Terraform Import Tests

Terraform import manages infrastructure that wasn't created by Terraforms by loading supported resources into your Terraform workspace's state. The import command doesn't automatically generate the configuration to manage the infrastructure, though. Because of this, importing existing infrastructure into Terraform is a multi-step process.

Bringing existing infrastructure under Terraform's control involves five main steps:

1.    Identify the existing infrastructure to be imported.
2.    Import infrastructure into your Terraform state.
3.    Write Terraform configuration that matches that infrastructure.
4.    Review the Terraform plan to ensure the configuration matches the expected state and infrastructure.
5.    Apply the configuration to update your Terraform state.

### Install prerequisites

1. Terraform: https://www.terraform.io/downloads.html
1. Docker: https://docs.docker.com/get-docker/

### Create a docker container (the following commands require sudo on CentOS 8)

1. Run this docker command to create a container with the latest nginx image.

    ```shell
    sudo docker run --name hashicorp-learn --detach --publish 8080:80 nginx:latest
    ```

1. Verify container is running by running `sudo docker ps` or visiting `0.0.0.0:8080`
    in your web browser.

    ```shell
    sudo docker ps --filter "name=hashicorp-learn"
    ```

### Import container resource

1. Initialize your workspace by running `terraform init`.

1. Add empty resource stub to `docker.tf` for the container.

    ```hcl
    resource "docker_container" "web" { }
    ```

1. Import the container into Terraform state.

    ```shell
    sudo terraform import docker_container.web $(sudo docker inspect -f {{.ID}} hashicorp-learn)
    ```

1. Now the container is in your terraform configuration's state.

    ```shell
    sudo terraform show
    ```

1. Run `sudo terraform plan`. Terraform shows errors for missing required arguments
    (`image`, `name`).

    ```shell
    sudo terraform plan
    ```

1. Generate configuration and save it in `docker.tf`, replacing the empty
    resource created earlier.

    ```shell
    sudo terraform show -no-color > docker.tf
    ```

1. Re-run `sudo terraform plan`.
    ```shell
    sudo terraform plan
    ```

1. Terraform will show warnings and errors about a deprecated attribute
    (`links`), and several read-only attributes (`ip_address`, `network_data`,
    `gateway`, `ip_prefix_length`, `id`). Remove these attributes from `docker.tf`.

    ```

    ```

1. Re-run `sudo terraform plan`.

    ```shell
    sudo terraform plan
    ```

    It should now execute successfully. The plan indicates that Terraform will
    update in place to add the `attach`, `logs`, `must_run`, and `start`
    attributes. Notice that the container resource will not be replaced.

1. Apply the changes. Remember to confirm the run with a `yes`.

    ```shell
    sudo terraform apply
    ```

1. There are now several attributes in `docker.tf` that are unnecessary because
    they are the same as their default values. After removing these attributes,
    `docker.tf` will look something like the following.

    ```hcl
    # docker_container.web:
    resource "docker_container" "web" {
       name  = "hashicorp-learn"
       image = "sha256:9beeba249f3ee158d3e495a6ac25c5667ae2de8a43ac2a8bfd2bf687a58c06c9"

       ports {
           external = 8080
           internal = 80
       }
    }
    ```

1. Run `sudo terraform plan` again to verify that removing these attributes did not
    change the configuration.

    ```shell
    sudo terraform plan
    ```

### Verify that your infrastructure still works as expected

```shell
$ sudo docker ps --filter "name=hashicorp-learn"
```

    You can revisit `0.0.0.0:8080` in your web browser to verify that it is
    still up. Also note the "Status" - the container has been up and running
    since it was created, so you know that it was not restarted when you
    imported it into Terraform.

### Create a docker image resource

1. Retrieve the image's tag name by running the following command, replacing the
    sha256 value shown with the one from `docker.tf`.

    ```shell
    sudo docker image inspect sha256:ea335eea17ab984571cd4a3bcf90a0413773b559c75ef4cda07d0ce952b00291 -f {{.RepoTags}}
    ```

1. Add the following configuration to your docker.tf file.

    ```hcl
    resource "docker_image" "nginx" {
      name = "nginx:latest"
    }
    ```

1. Run `sudo terraform apply` to apply the changes. Remember to confirm the run with
    a `yes`.

    ```shell
    sudo terraform apply
    ```

1. Now that Terraform has created a resource for the image, refer to it in
    `docker.tf` like so:

    ```hcl
    resource "docker_container" "web" {
      name  = "hashicorp-learn"
      image = docker_image.nginx.latest

    # File truncated...
    ```

1. Verify that your configuration matches the current state.

    ```shell
    sudo terraform apply
    ```

### Manage the container with Terraform

1. In your `docker.tf` file, change the container's external port from `8080` to
    `8081`.

    ```hcl
    resource "docker_container" "web" {
      name  = "hashicorp-learn"
      image = "sha256:602e111c06b6934013578ad80554a074049c59441d9bcd963cb4a7feccede7a5"

      ports {
        external = 8081
        internal = 80
      }
    }
    ```

1. Apply the change. Remember to confirm the run with a `yes`.

    ```shell
    sudo terraform apply
    ```

1. Verify that the new container works by running `sudo docker ps` or visiting
    `0.0.0.0:8081` in your web browser.

    ```shell
    sudo docker ps --filter "name=hashicorp-learn"
    ```

### Destroy resources

1. Run `sudo terraform destroy` to destroy the container. Remember to confirm
    destruction with a `yes`.

    ```shell
    sudo terraform destroy
    ```

1. Run `sudo docker ps` to validate that the container was destroyed.

    ```shell
    sudo docker ps --filter "name=hashicorp-learn"
    ```
