# cloud-deployer-pac2

Desplegar un blog amb el CMS Wordpress en el cloud públic de Amazon Web Services (AWS) i gestionar la seguretat de tota la infraestructura necessària.

![image](https://user-images.githubusercontent.com/6838845/176989255-7b1b95d0-6248-4213-891b-1bcac330fbbc.png)

Els requeriments de seguretat són els següents:

  - L’accés a la màquina EC2 només es podrà realitzar mitjançant claus SSH
  - Creació d’un Security Group que garanteixi que el servidor EC2 només té oberts els següents ports 80 (HTTP), 443 (HTTPS) i 22 (SSH)

## Crear les claus rsa

```bash
ssh-keygen -b 4096 -t rsa -f AFERRANC-CCF-Key-WebServer
```

```bash
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in AFERRANC-CCF-Key-WebServer.
Your public key has been saved in AFERRANC-CCF-Key-WebServer.pub.
The key fingerprint is:
SHA256:qUpRNfw0BTWqLYxBCaUTE1pfnkvkSMu4e5F92uUuZbI cloudshell-user@ip-10-0-66-20.eu-central-1.compute.internal
The key's randomart image is:
+---[RSA 4096]----+
|    *++o= .++    |
|   o X.O.oo. .   |
|  . + B =o..     |
|     + B =.      |
|    o + S o .    |
|     o o =.oo    |
|    o o . .=.    |
|   . o    E.     |
|    .      ..    |
+----[SHA256]-----+
```

## Inicialitzar terraform

```bash
terraform init
```

```bash
Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Installing hashicorp/aws v4.20.0...
- Installed hashicorp/aws v4.20.0 (self-signed, key ID 34365D9472D7468F)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/plugins/signing.html

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

## Deploy de la infraestructura

```bash
terraform plan --out plan.out

terraform apply plan.out
```

## Destruir la infraestructura

```bash
terraform destroy
```
