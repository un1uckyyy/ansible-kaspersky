## Установка Ansible

```shell
python3 -m venv venv
source venv/bin/activate

pip install ansible
```

## Добавление публичного ssh ключа на удаленную машину

```shell
ssh-copy-id -p 10022 alma@127.0.0.1
```

## Ping удаленной машины

```shell
ansible -i ansible/inventory.ini all -m ping
```

# Сборка микросервиса

## Бинарный файл

```shell
make binary
```

## Docker образ

```shell
make image
```

# Доставка сервиса

## Бинарный файл, как systemd служба

```shell
ansible-playbook -i inventory.ini playbook.yaml \
  --extra-vars "deploy_mode=systemd" --ask-become-pass
```

## Docker образ

```shell
ansible-playbook -i ansible/inventory.ini ansible/playbook.yaml \
  --extra-vars "deploy_mode=docker" --ask-become-pass
```
