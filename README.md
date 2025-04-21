## Задача

- Необходимо развернуть микросервис на виртуальной машине (ВМ), используя систему управления конфигурациями. (Ansible)

- Микросервис: HTTP сервер, который экспортирует на 8080 порт Prometheus метрики.
  Одна из метрик должна предоставлять данные о том, на какой типе хоста запущен сервер: виртуальная машина, контейнер
  или физический сервер.
  Адаптировать ansible-role и ansible-playbook под 2 сценария разворачивания сервиса: systemd служба или docker
  контейнер

- Автоматизировать этап создания виртуальной машины используя подход Infrastructure as a Code и Terraform

## Установка Ansible

```shell
python3 -m venv venv
source venv/bin/activate

pip install ansible
```

Также установим готовую роль для установки docker

```shell
ansible-galaxy install geerlingguy.docker
```

## Добавление публичного ssh ключа на удаленную машину

```shell
ssh-copy-id -p 10022 alma@127.0.0.1
```

## Ping удаленной машины

```shell
ansible -i ansible/inventory.ini all -m ping
```

# Сборка микросервиса и доставка

## Бинарный файл, как systemd служба

```shell
make binary
```

```shell
ansible-playbook -i ansible/inventory.ini ansible/playbook.yaml \
  --extra-vars "deploy_mode=systemd" --ask-become-pass
```

## Docker образ

```shell
make image
```

```shell
ansible-playbook -i ansible/inventory.ini ansible/playbook.yaml \
  --extra-vars "deploy_mode=docker" --ask-become-pass
```

# Terraform

установим Terraform используя <a href="https://developer.hashicorp.com/terraform/install?ref=roksblog.de#linux">apt</a>

затем установим libvirt <a href="https://github.com/dmacvicar/terraform-provider-libvirt">provider</a>

скачаем образ AlmaLinux 9

```shell
wget https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-9.5-20241120.x86_64.qcow2
mv AlmaLinux-9-GenericCloud-9.5-20241120.x86_64.qcow2 ./terraform/alma
```

```shell
terraform init
terraform validate
terraform apply
```

убедимся, что ВМ запустилась и получила IP-адрес

```shell
virsh list --all
virsh net-dhcp-leases alma_network
```

далее указываем ip и username (alma) в ansible inventory.ini
become pass - "alma" (можно задать в terraform/cloud_init.cfg)