# Установленный софт

Документация по всем инструментам из `Brewfile`. Организовано по категориям.

---

## Shell & Prompt

### fish
**Умный интерактивный shell.**
Автодополнение из коробки, подсветка синтаксиса в реальном времени, web-based config. Не требует плагинов для базового удобства в отличие от zsh/bash.

```fish
# подсвечивает команду красным если бинарник не найден — сразу видно опечатку
git comit -m "fix"  # → красный, ещё до Enter
```

### starship
**Кросс-shell промпт написанный на Rust.**
Показывает git-статус, версию рантайма, код выхода предыдущей команды, время выполнения длинных команд. Конфиг в `starship.toml`.

```
~/project/api on  main [!] via  v20.11.0 took 3s
❯
```

### fisher
**Менеджер плагинов для fish.**
Плагины описываются в `fish/fish_plugins` и устанавливаются одной командой. Работает без субшеллов и eval-хаков.

```fish
fisher install jorgebucaran/autopair.fish  # автозакрытие скобок
fisher update                               # обновить все плагины
```

---

## Runtime Manager

### mise
**Менеджер версий рантаймов (node, go, java и 200+ других).**
Заменяет nvm, goenv, sdkman. Версии описаны в `mise/config.toml`, переключаются автоматически при входе в директорию. Быстрее asdf благодаря Rust.

```toml
# mise/config.toml
[tools]
node = "lts"
go   = "latest"
java = "lts"
```

```fish
mise install          # установить все рантаймы из конфига
mise use node@22      # переключить версию node в текущем проекте
mise ls               # список установленных версий
```

---

## Modern Unix: замены стандартных утилит

### eza
**Современная замена `ls`.**
Цвета, иконки, git-статус файлов, tree-режим. Активно поддерживается (форк unmaintained `exa`).

```fish
eza --long --all --git     # ls -la + git-статус каждого файла
eza --tree --level=2       # дерево директорий
```

### bat
**`cat` с подсветкой синтаксиса и нумерацией строк.**
Понимает 150+ языков, интегрируется с `git diff`, умеет пейджинг. Используется как pager для `man`.

```fish
bat src/main.go            # с подсветкой Go
bat --diff file.txt        # показать только изменённые строки
```

### ripgrep (`rg`)
**Быстрый grep на Rust.**
В 10–100 раз быстрее GNU grep на больших кодовых базах. Автоматически игнорирует `.gitignore`, бинарные файлы, скрытые директории. Конфиг в `~/.config/ripgreprc`.

```fish
rg "TODO" src/             # найти все TODO в src/
rg -t go "context.Context" # только в .go файлах
rg --hidden "secret"       # включая скрытые файлы
```

### fd
**Быстрая замена `find`.**
Интуитивный синтаксис, соблюдает `.gitignore`, поддерживает regex. Используется плагинами fzf.

```fish
fd ".go"                   # все .go файлы рекурсивно
fd -e yaml -x bat {}       # открыть все yaml через bat
fd --type d "node_modules" # найти все node_modules директории
```

### git-delta
**Diff с подсветкой синтаксиса для git.**
Заменяет стандартный `git diff` вывод — показывает изменения построчно с цветами, side-by-side режим, понимает синтаксис языков.

```fish
git diff            # автоматически через delta (настроен в gitconfig)
git show HEAD~1     # красивый вывод предыдущего коммита
```

### xh
**Быстрый HTTP-клиент, замена httpie.**
Синтаксис совместим с httpie, но написан на Rust — в разы быстрее. Поддерживает JSON, форм-данные, заголовки, сессии.

```fish
xh get httpbin.org/get          # GET-запрос
xh post api.example.com/users \
    name="Oleg" email="o@x.ru"  # POST с JSON телом
xh -F post example.com/upload \
    file@photo.jpg               # загрузка файла
```

### doggo
**DNS-клиент, замена `dig`.**
Красивый вывод с цветами, поддержка DoH (DNS over HTTPS), DoT. Активируется через алиас `dig` в `fish/graf009/dog.fish`.

```fish
dig github.com          # → doggo github.com (через алиас)
doggo github.com MX     # MX-записи
doggo @1.1.1.1 ya.ru    # запрос к конкретному серверу
```

---

## Git & Signing

### git
**Система контроля версий.**
Настроен в `gitconfig`: SSH-подпись коммитов, delta как pager, identity switching через `includeIf gitdir`.

```fish
git tree           # красивый граф истории (алиас из gitconfig)
git s              # краткий статус (алиас: git status --short --branch)
git ac "fix: typo" # add all + commit (алиас)
```

### gh
**Официальный CLI GitHub.**
Работа с PR, issues, releases, actions прямо из терминала. Аутентификация через браузер.

```fish
gh pr create --fill          # создать PR из текущей ветки
gh pr list                   # список открытых PR
gh issue create              # создать issue интерактивно
gh run watch                 # следить за CI в реальном времени
gh repo clone org/repo       # клонировать репозиторий
```

### bfg
**Быстрая очистка git-истории.**
Удаляет большие файлы или секреты из всей истории репозитория. В 10–720x быстрее `git filter-branch`.

```fish
# удалить файл с паролями из всей истории
bfg --delete-files passwords.txt repo.git

# заменить строки с секретами
bfg --replace-text secrets.txt repo.git
```

---

## Editors & Terminal Tools

### micro
**Современный терминальный редактор.**
Управление как в обычных редакторах (Ctrl+S, Ctrl+Z, Ctrl+F), мышь работает, подсветка синтаксиса, плагины. Настроен как `$EDITOR` в `fish/conf.d/env.fish`.

```fish
micro main.go        # открыть файл
# Ctrl+E → командная строка редактора
# Ctrl+G → справка
```

### pv
**Pipe Viewer — прогресс для потоков данных.**
Показывает скорость и прогресс при передаче данных через pipe. Незаменим при работе с большими файлами.

```fish
# прогресс при копировании большого файла
pv dump.sql | gzip > dump.sql.gz

# прогресс импорта в базу
pv dump.sql | psql mydb
```

### tree
**Отображение структуры директорий деревом.**
Простая альтернатива `eza --tree` когда нужен чистый текстовый вывод.

```fish
tree -L 2 src/          # дерево на 2 уровня
tree -I "node_modules"  # исключить директории
```

### mas
**CLI для Mac App Store.**
Установка и обновление приложений из App Store без GUI. Используется в `Brewfile` для `mas "Bitwarden"` и других.

```fish
mas search bitwarden     # найти приложение
mas install 1352778147   # установить по ID
mas upgrade              # обновить все App Store приложения
```

---

## Network & Infra Diagnostics

### mtr
**Traceroute + ping в одном инструменте.**
Показывает маршрут пакетов и потери на каждом хопе в реальном времени. Незаменим при диагностике сетевых проблем.

```fish
mtr github.com           # интерактивный traceroute
mtr --report ya.ru       # отчёт за 10 циклов
```

### nmap
**Сканер сетей и портов.**
Обнаружение хостов, открытых портов, версий сервисов, OS-фингерпринтинг. Используется для аудита инфраструктуры.

```fish
nmap -sV 192.168.1.1         # версии сервисов на хосте
nmap -p 80,443,8080 host.ru  # проверить конкретные порты
nmap 192.168.1.0/24          # сканировать подсеть
```

### iperf3
**Тест пропускной способности сети.**
Измеряет реальную скорость между двумя хостами. Полезен при настройке VPN, проверке качества канала.

```fish
# на сервере:
iperf3 -s

# на клиенте:
iperf3 -c server-ip    # измерить скорость до сервера
```

---

## Infrastructure & Kubernetes

### kubernetes-cli (`kubectl`)
**CLI для управления Kubernetes кластерами.**
Основной инструмент работы с k8s: деплой, отладка, просмотр логов.

```fish
kubectl get pods -n prod           # список подов в namespace
kubectl describe pod api-xxx       # детали пода
kubectl exec -it pod-name -- sh   # зайти в под
kubectl apply -f deployment.yaml   # применить манифест
```

### helm
**Пакетный менеджер для Kubernetes.**
Устанавливает сложные приложения в k8s через чарты. Управляет версиями релизов.

```fish
helm repo add bitnami https://...
helm install myapp bitnami/postgresql
helm upgrade myapp bitnami/postgresql --set auth.password=xxx
helm rollback myapp 1             # откат к предыдущей версии
```

### k9s
**Терминальный UI для Kubernetes.**
Навигация по кластеру в реальном времени: поды, деплойменты, логи, exec — всё без набора длинных kubectl команд.

```fish
k9s                    # открыть UI
# :pods → список подов
# l → логи выбранного пода
# s → shell в под
# d → describe ресурса
```

### kubectx + kubens
**Быстрое переключение контекстов и namespace в k8s.**
Два инструмента в одном пакете. Убирает необходимость писать `--context` и `--namespace` в каждой команде.

```fish
kubectx                # список контекстов
kubectx prod-cluster   # переключиться на prod
kubens kube-system     # сменить namespace
kubens -               # вернуться к предыдущему
```

### stern
**Tail логов из нескольких подов одновременно.**
Незаменим при отладке: фильтрует по label selector, раскрашивает вывод каждого пода в свой цвет.

```fish
stern api              # логи всех подов с "api" в имени
stern -n prod api      # в namespace prod
stern --since=15m api  # только за последние 15 минут
```

### terraform
**Инфраструктура как код (IaC).**
Декларативное описание облачных ресурсов. Используется для управления Yandex Cloud и других провайдеров.

```fish
terraform init         # инициализация провайдеров
terraform plan         # предпросмотр изменений
terraform apply        # применить изменения
terraform destroy      # удалить ресурсы
```

### ansible-lint
**Линтер для Ansible playbooks.**
Проверяет синтаксис и best practices в yaml-плейбуках Ansible. Используется в CI для work-репозиториев.

```fish
ansible-lint playbook.yml      # проверить файл
ansible-lint roles/            # проверить директорию с ролями
```

### asimov
**Автоматическое исключение зависимостей из Time Machine.**
Находит `node_modules`, `.git`, кеши и добавляет их в исключения Time Machine. Экономит место на бэкапе.

```fish
asimov                 # запустить вручную (обычно через launchd)
```

---

## Dev Tooling

### hadolint
**Линтер для Dockerfile.**
Проверяет синтаксис и best practices: правильный базовый образ, порядок слоёв, безопасность.

```fish
hadolint Dockerfile
# → DL3008: Pin versions in apt-get install
```

### yamllint
**Линтер для YAML файлов.**
Проверяет синтаксис, отступы, дублирующиеся ключи. Полезен для k8s манифестов и CI конфигов.

```fish
yamllint deployment.yaml
yamllint .                      # все yaml в проекте
```

### jsonlint
**Валидатор JSON.**
Проверяет корректность JSON с понятными сообщениями об ошибках и указанием строки.

```fish
jsonlint package.json
cat api-response.json | jsonlint
```

### jq
**Процессор JSON в командной строке.**
Фильтрация, трансформация, форматирование JSON. Незаменим при работе с API и k8s.

```fish
kubectl get pods -o json | jq '.items[].metadata.name'
curl api/users | jq '.[] | select(.role == "admin")'
jq '.dependencies | keys' package.json
```

### yq
**`jq` для YAML (и JSON, XML, TOML).**
Чтение и изменение YAML/Helm-чартов, k8s манифестов без ручного редактирования.

```fish
yq '.spec.replicas' deployment.yaml
yq -i '.image.tag = "v2.0"' values.yaml   # обновить in-place
yq -o json config.yaml                     # конвертировать в JSON
```

### fzf
**Универсальный fuzzy finder.**
Интерактивный поиск по любому списку: история команд (Ctrl+R), файлы (Ctrl+T), процессы. Интегрирован в fish через `fzf --fish | source`.

```fish
# Ctrl+R → поиск по истории команд
# Ctrl+T → fuzzy выбор файла
kubectl get pods | fzf | xargs kubectl logs
git log --oneline | fzf | awk '{print $1}' | xargs git show
```

### zoxide
**Умный `cd` с памятью.**
Запоминает часто посещаемые директории и переходит в них по частичному совпадению. Алиас `cd` настроен в `fish/conf.d/aliases.fish`.

```fish
cd dotfiles    # → ~/project/public/dotfiles (если бывал там раньше)
cd api         # → ~/project/podeli/api
zi             # интерактивный выбор через fzf
```

### lazygit
**Терминальный UI для git.**
Визуальный интерфейс для staging, коммитов, rebase, merge — без запоминания сложных git-команд.

```fish
lazygit        # открыть UI в текущем репо
# space → stage/unstage файл
# c → коммит
# P → push
# r → rebase интерактивный
```

### dive
**Анализ слоёв Docker-образов.**
Показывает что добавляет каждый слой Dockerfile, помогает найти лишние файлы и уменьшить размер образа.

```fish
dive nginx:latest
# стрелки → навигация по слоям
# Tab → переключение между слоями и файлами
```

### sqlite
**Встроенная SQL база данных.**
Локальная БД без сервера. Полезна для быстрого прототипирования, анализа данных, отладки приложений.

```fish
sqlite3 app.db
sqlite> .tables
sqlite> SELECT * FROM users LIMIT 5;
sqlite> .schema users
```

### mmctl
**CLI для Mattermost.**
Управление Mattermost-сервером: каналы, пользователи, посты — без веб-интерфейса.

```fish
mmctl auth login https://mattermost.company.ru --name work
mmctl channel list team:general
mmctl user list
```

### atuin
**Shell history с поиском и синхронизацией.**
Заменяет стандартный Ctrl+R: поиск по всей истории с фильтрацией по директории, хосту, статусу выхода. Синхронизация между машинами.

```fish
# Ctrl+R → открыть atuin search
atuin stats              # статистика использования команд
atuin search "kubectl"   # найти команды с kubectl
```

### maven
**Build-система для Java/JVM проектов.**
Управление зависимостями, сборка, тесты, деплой. JVM рантайм управляется через `mise`.

```fish
mvn clean install         # полная сборка
mvn test                  # запустить тесты
mvn spring-boot:run       # запустить Spring Boot приложение
mvn dependency:tree       # дерево зависимостей
```

### openssl@3
**Криптографическая библиотека.**
Генерация ключей, сертификатов, шифрование. Используется как зависимость многих инструментов.

```fish
openssl genrsa -out key.pem 4096           # сгенерировать RSA ключ
openssl req -x509 -key key.pem -out cert.pem -days 365  # self-signed cert
openssl s_client -connect github.com:443   # проверить TLS сертификат
```

---

## Fonts

### font-martian-mono
**Моноширинный шрифт Martian Mono.**
Чёткий программистский шрифт с хорошей читаемостью на любом DPI, поддержка лигатур.

### font-sauce-code-pro-nerd-font (Source Code Pro Nerd Font)
**Source Code Pro с иконками Nerd Fonts.**
Содержит тысячи иконок (файловые типы, git-статусы, девайсы) для красивого отображения в starship, eza, k9s.

---

## Terminal & Editors

### kitty
**Быстрый GPU-ускоренный терминал.**
Поддержка изображений в терминале, множество вкладок и окон, кастомные шрифты, низкая задержка. Конфиг в `kitty/`.

### visual-studio-code
**Редактор кода Microsoft.**
Основная IDE: LSP, отладчик, расширения для Go, TypeScript, Helm, Terraform, Docker. Конфиг в `vscode.json`.

---

## Infra GUI

### headlamp
**CNCF-certified Kubernetes GUI.**
Веб-UI для k8s кластеров с расширяемой плагин-системой. Заменяет Lens (стал платным). Открытый исходный код.

### dbeaver-community
**Универсальный GUI для баз данных.**
Подключение к PostgreSQL, MySQL, SQLite, ClickHouse и 80+ другим СУБД. Визуальный редактор запросов, ERD-диаграммы.

---

## Tunneling

### cloudflared
**Cloudflare Tunnel — замена ngrok.**
Проксирует локальный сервис через Cloudflare без проброса портов. Работает за NAT, поддерживает кастомные домены, бесплатный тариф.

```fish
cloudflared tunnel --url localhost:3000    # быстрый тоннель
cloudflared tunnel create myapp           # именованный тоннель
```

---

## Yandex Cloud

### yandex-cloud-cli (`yc`)
**CLI для управления Yandex Cloud.**
Управление всеми сервисами YC: Compute, Managed Kubernetes, Object Storage, Cloud Functions, VPC.

```fish
yc config list                           # текущая конфигурация
yc compute instance list                 # список VM
yc managed-kubernetes cluster list       # список k8s кластеров
yc managed-kubernetes cluster get-credentials --name mycluster
kubectl get nodes                        # после получения kubeconfig
```

---

## Productivity

### obsidian
**База знаний на основе Markdown.**
Заметки с двусторонними ссылками, граф связей, плагины. Файлы хранятся локально в обычных `.md` файлах.

---

## Communication

### telegram
**Мессенджер Telegram.**
Основной мессенджер для работы и личного общения.

### zoom
**Видеоконференции Zoom.**
Встречи, вебинары, демонстрация экрана.

---

## Media

### spotify
**Стриминг музыки.**

### vlc
**Универсальный медиаплеер.**
Воспроизводит любые форматы видео и аудио без дополнительных кодеков.

---

## Security & Privacy

### bitwarden (App Store)
**Менеджер паролей с открытым кодом.**
Хранит пароли, SSH ключи, секретные заметки. E2E шифрование, синхронизация между устройствами. Предпочтительна App Store версия.

### bitwarden-cli (`bw`)
**CLI для Bitwarden — управление секретами из терминала.**
Используется для загрузки SSH ключей и переменных окружения из vault. В дотфайлах есть две функции поверх него: `bw-ssh` и `bw-env`.

```fish
bw login                    # первичный вход (один раз)
bw unlock --raw             # разблокировать vault, получить сессию
bw list items               # список всех секретов
bw get notes "fish.env"     # получить содержимое secure note

# Функции из dotfiles:
bw-env                      # загрузить токены из vault в ~/.fish.env
bw-ssh                      # загрузить SSH ключи из vault в ssh-agent
```

**Как подготовить vault:**
1. В Bitwarden создать **Secure Note** с именем `fish.env` и телом `KEY=value` (по одному на строку)
2. Для каждого SSH ключа создать **Secure Note** с именем `SSH key: id_orlov`, `SSH key: id_dc`, и т.д. — тело = содержимое приватного ключа

### cryptomator
**Клиентское шифрование для облачных хранилищ.**
Создаёт зашифрованный vault поверх iCloud Drive, Dropbox, Google Drive. Ключ хранится локально — провайдер не видит содержимое.

---

## IoT & Infrastructure

### mqtt-explorer
**GUI-клиент для MQTT брокеров.**
Подключение к Mosquitto, HiveMQ и другим MQTT брокерам. Визуализация топиков, публикация сообщений. Полезен при работе с IoT устройствами.

---

## Hardware & Hobby

### arduino-ide
**IDE для программирования Arduino.**
Написание, компиляция и загрузка прошивок на Arduino и совместимые платы.

### betaflight-configurator
**Настройка полётных контроллеров Betaflight.**
GUI для настройки FPV-дронов: PID, моторы, приёмники, OSD.

### raspberry-pi-imager
**Запись образов на SD-карты для Raspberry Pi.**
Выбор образа (Raspberry Pi OS, Ubuntu, и другие), запись на карту, предварительная конфигурация SSH/WiFi.

### android-platform-tools (`adb`)
**Android Debug Bridge.**
Отладка Android-устройств, передача файлов, установка APK без Google Play.

```fish
adb devices                        # список подключённых устройств
adb install app.apk                # установить APK
adb logcat | rg "MyApp"            # логи приложения
adb shell                          # shell на устройстве
```

---

## Crypto

### ledger-wallet
**Приложение для аппаратного кошелька Ledger.**
Управление криптовалютами на Ledger Nano: установка приложений, просмотр балансов, подтверждение транзакций.

---

## App Store

| Приложение | Назначение |
|---|---|
| **Bitwarden** | Менеджер паролей (основная версия) |
| **Mattermost** | Корпоративный мессенджер (self-hosted) |
| **Windows App** | Microsoft Remote Desktop — подключение к Windows |
| **Tomato One** | Pomodoro таймер для управления временем |
