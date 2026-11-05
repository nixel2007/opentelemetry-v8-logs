# AGENTS.md

## Телеметрия технологического журнала

Каждое событие технологического журнала экспортируется **и** спаном, **и** записью лога — без
исключений. Не предлагайте и не делайте событие только записью лога или только спаном, даже если
его данные переносятся в другой спан (например, атрибуты пары `VRSREQUEST`/`VRSRESPONSE`
в HTTP-спан `CALL`).

## Документация

Каталог `docs/product` публикуется на сайте [autumn-library.github.io](https://autumn-library.github.io)
(репозиторий `autumn-library/autumn-library.github.io`, VitePress). Сайт подключает каталог
как `docs/products/NNN-opentelemetry-v8-logs/` и при сборке переписывает пути: из каждого
сегмента вырезается числовой префикс сортировки (`020-configuration.md` → `configuration`).
Любая мёртвая ссылка роняет сборку всего сайта (`Error: N dead link(s) found`).

### Ссылки между страницами

- Ссылайтесь на страницы `docs/product` относительным путём **без числового префикса**:
  `[настройка](./configuration.md)`, `[состав телеметрии](./telemetry.md#трассы)`.
- Не используйте имя файла с префиксом (`020-configuration.md`, `./030-telemetry.md`): после
  переписывания путей такой страницы на сайте нет.
- На публичный интерфейс других библиотек ссылайтесь так же, как в их документации:
  `/api/<репозиторий>/<путь>.md`.
- `README.md` на сайт не попадает и читается на GitHub, поэтому в нём остаются реальные пути
  к файлам (`docs/product/020-configuration.md`).

### Проверка перед коммитом

После правки `docs/` соберите сайт с локальной копией документации и убедитесь, что нет
сообщений `Found dead link`:

```bash
git clone --depth 1 https://github.com/autumn-library/autumn-library.github.io ../site
cd ../site
npm ci
mkdir -p docs/products
ln -sfn "$OLDPWD/docs/product" docs/products/011-opentelemetry-v8-logs
npx vitepress build
```

Сборка должна завершиться строкой `build complete`.
