# User Segments Service

Сервис для управления пользовательскими сегментами с поддержкой случайного распределения пользователей.

## Технологии

- **Ruby 3.2+**
- **Roda** - легковесный web framework
- **ActiveRecord 7.1** - ORM для работы с базой данных
- **PostgreSQL** - реляционная база данных
- **Tailwind CSS** - CSS framework для UI
- **Mina** - инструмент для деплоя

## Функциональность

### Основные возможности

- ✅ Создание, изменение и удаление сегментов
- ✅ Автоматическое распределение сегментов на процент пользователей
- ✅ Управление сегментами пользователей (добавление/удаление)
- ✅ API для работы с пользователями и сегментами
- ✅ Web интерфейс с Tailwind CSS

### Примеры сегментов

- `MAIL_VOICE_MESSAGES` - Голосовые сообщения в почте
- `CLOUD_DISCOUNT_30` - Скидка 30% на облако
- `MAIL_GPT` - GPT в письмах

## Установка и настройка

### 1. Клонирование репозитория

```bash
git clone <repository-url>
cd user_segments_service
```

### 2. Установка зависимостей

```bash
bundle install
```

### 3. Настройка переменных окружения

Создайте файл `.env` на основе `.env.example`:

```bash
cp .env.example .env
```

Отредактируйте `.env` при необходимости:

```bash
# Database Configuration
DATABASE_URL=postgres://localhost/user_segments_dev

# Application Environment
RACK_ENV=development

# Server Configuration
PORT=9292
```

### 4. Настройка базы данных

```bash
# Создать базу данных
bundle exec rake db:create

# Выполнить миграции
bundle exec rake db:migrate

# Загрузить тестовые данные (100 пользователей + 3 сегмента)
bundle exec rake db:seed
```

Или выполнить все за один раз:

```bash
bundle exec rake db:setup
```

## Запуск

### Режим разработки

```bash
# Через Puma
bundle exec puma

# Или с автоперезагрузкой через rerun
bundle exec rerun -- rackup
```

Сервис будет доступен на `http://localhost:9292`

### Production режим

```bash
RACK_ENV=production bundle exec puma -C config/puma.rb
```

## API Endpoints

### Сегменты

#### Создать сегмент

```bash
POST /api/segments
Content-Type: application/json

{
  "slug": "MAIL_GPT",
  "name": "GPT в письмах",
  "description": "Эксперимент с GPT",
  "auto_assign_percent": 30
}
```

**Ответ:**
```json
{
  "id": 1,
  "slug": "MAIL_GPT",
  "name": "GPT в письмах",
  "description": "Эксперимент с GPT",
  "created_at": "2026-01-10T14:00:00Z"
}
```

#### Обновить сегмент

```bash
PUT /api/segments/:slug
Content-Type: application/json

{
  "name": "Новое название",
  "description": "Новое описание",
  "auto_assign_percent": 20
}
```

**Примечание:** Параметр `auto_assign_percent` опционален. Если указан, дополнительно назначит сегмент указанному проценту пользователей, которые еще не имеют этот сегмент.

#### Удалить сегмент

```bash
DELETE /api/segments/:slug
```

### Пользователи

#### Создать пользователя

```bash
POST /api/users
```

**Ответ:**
```json
{
  "id": 101,
  "created_at": "2026-01-10T14:00:00Z"
}
```

#### Получить сегменты пользователя

```bash
GET /api/users/:user_id/segments
```

**Ответ:**
```json
{
  "user_id": 1,
  "segments": [
    {
      "slug": "MAIL_GPT",
      "name": "GPT в письмах",
      "description": "Эксперимент с GPT"
    },
    {
      "slug": "CLOUD_DISCOUNT_30",
      "name": "Скидка 30% на облако",
      "description": "Тестирование скидки на подписку в облаке"
    }
  ]
}
```

#### Добавить сегменты пользователю

```bash
POST /api/users/:user_id/segments
Content-Type: application/json

{
  "segments": ["MAIL_GPT", "CLOUD_DISCOUNT_30"]
}
```

**Ответ:**
```json
{
  "added": ["MAIL_GPT", "CLOUD_DISCOUNT_30"],
  "errors": []
}
```

#### Удалить сегменты у пользователя

```bash
DELETE /api/users/:user_id/segments
Content-Type: application/json

{
  "segments": ["MAIL_GPT"]
}
```

**Ответ:**
```json
{
  "removed": ["MAIL_GPT"],
  "errors": []
}
```

## Примеры использования

### cURL

#### Создание сегмента с автоназначением 30% пользователей

```bash
curl -X POST http://localhost:9292/api/segments \
  -H "Content-Type: application/json" \
  -d '{
    "slug": "MAIL_GPT",
    "name": "GPT в письмах",
    "description": "Эксперимент с GPT",
    "auto_assign_percent": 30
  }'
```

#### Получение сегментов пользователя

```bash
curl http://localhost:9292/api/users/1/segments
```

#### Добавление сегментов пользователю

```bash
curl -X POST http://localhost:9292/api/users/1/segments \
  -H "Content-Type: application/json" \
  -d '{"segments": ["MAIL_GPT", "CLOUD_DISCOUNT_30"]}'
```

## Структура проекта

```
user_segments_service/
├── app.rb                  # Основное приложение Roda
├── config.ru               # Rack конфигурация
├── Gemfile                 # Зависимости Ruby
├── Rakefile                # Rake задачи
├── config/
│   ├── database.rb         # Конфигурация ActiveRecord
│   └── deploy.rb           # Конфигурация Mina для деплоя
├── db/
│   ├── migrate/            # Миграции базы данных
│   └── seeds.rb            # Тестовые данные
├── models/
│   ├── user.rb             # Модель пользователя
│   ├── segment.rb          # Модель сегмента
│   └── user_segment.rb     # Модель связи
└── views/
    ├── layout.erb          # Основной шаблон
    ├── index.erb           # Главная страница
    ├── segments.erb        # Список сегментов
    ├── segment_form.erb    # Форма создания сегмента
    └── users.erb           # Список пользователей
```

## Деплой с Mina

### Настройка

1. Отредактируйте `config/deploy.rb`:
   - Укажите ваш сервер в `domain`
   - Укажите репозиторий в `repository`
   - Настройте пути и пользователя

2. Первоначальная настройка на сервере:

```bash
bundle exec mina setup
```

3. Деплой:

```bash
bundle exec mina deploy
```

4. Миграции на production:

```bash
bundle exec mina db:migrate
```

## База данных

### Схема

#### Таблица `users`
- `id` - первичный ключ
- `created_at` - дата создания

#### Таблица `segments`
- `id` - первичный ключ
- `slug` - уникальный идентификатор (например, MAIL_GPT)
- `name` - название сегмента
- `description` - описание
- `created_at` - дата создания
- `updated_at` - дата обновления

#### Таблица `user_segments`
- `id` - первичный ключ
- `user_id` - внешний ключ на users
- `segment_id` - внешний ключ на segments
- `assigned_at` - дата назначения
- Уникальный индекс на (user_id, segment_id)

### Команды для работы с БД

```bash
# Создать базу данных
bundle exec rake db:create

# Выполнить миграции
bundle exec rake db:migrate

# Откатить последнюю миграцию
bundle exec rake db:rollback

# Сбросить базу данных
bundle exec rake db:reset

# Загрузить seed данные
bundle exec rake db:seed
```

## Разработка

### Добавление новой миграции

```bash
# Создайте файл в db/migrate/ с именем вида:
# 004_your_migration_name.rb

class YourMigrationName < ActiveRecord::Migration[7.1]
  def change
    # ваш код
  end
end
```

## Тестирование API

Можно использовать любой HTTP клиент (cURL, Postman, Insomnia, httpie).

Пример с httpie:

```bash
# Создание сегмента
http POST :9292/api/segments slug=TEST_SEGMENT name="Test" auto_assign_percent:=25

# Получение сегментов пользователя
http :9292/api/users/1/segments
```

## Лицензия

MIT

## Контакты

Для вопросов и предложений создавайте Issues в репозитории.
