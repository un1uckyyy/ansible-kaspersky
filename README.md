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
