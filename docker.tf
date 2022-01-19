resource "docker_container" "web" {
  name = "hashicorp-learn"
  image = docker_image.nginx.latest
  #image = "sha256:ea335eea17ab984571cd4a3bcf90a0413773b559c75ef4cda07d0ce952b00291"

  env  = []

  ports {
    external = 8081
    internal = 80
    ip       = "::"
  }
}
resource "docker_image" "nginx" {
  name = "nginx:latest"
}
