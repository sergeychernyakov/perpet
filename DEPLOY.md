# Деплой

Сейчас прототип живёт на сервере Маркетпульта, рядом с остальными сайтами:
`deploy@195.19.209.216`, каталог `/var/www/perpet`, адрес `perpet.маркетпульт.рф`.

## Как всё устроено

- **Puma** под systemd — юнит `perpet.service`, слушает `127.0.0.1:3100`,
  лимит памяти 320 МБ (на сервере всего 960 МБ и ещё четыре сайта).
- **nginx** — виртуальный хост `/etc/nginx/sites-available/perpet`: отдаёт статику из
  `public/` сам, остальное проксирует в Puma.
- **SQLite** — файлы в `/var/www/perpet/storage`, наполняются через `db:seed`.
- **Ruby 3.2.3** системный, гемы в `vendor/bundle` внутри проекта.

## Обновление

```bash
bin/deploy          # git push + обновление сервера + перезапуск
bin/deploy --seed   # то же плюс пересоздать демонстрационные данные
```

Полезное:

```bash
ssh deploy@195.19.209.216 'sudo journalctl -u perpet -n 50'   # логи
ssh deploy@195.19.209.216 'cd /var/www/perpet && RAILS_ENV=production bundle exec rails console'
```

## Что осталось настроить

1. A-запись `perpet` → `195.19.209.216` в DNS домена маркетпульт.рф.
2. После этого — сертификат: `sudo certbot --nginx -d perpet.xn--80akofbvesci4h.xn--p1ai`.

---

# Запасной вариант: Oracle Cloud Always Free


Если понадобится отдельная машина: бесплатная виртуалка Oracle Cloud плюс бесплатный
хостинг VK для мини-приложения.

## 1. Виртуалка в Oracle Cloud Always Free

Что нужно сделать в панели Oracle (это делается под вашим аккаунтом):

1. Создать аккаунт на cloud.oracle.com. Для подтверждения личности просят карту, но списаний
   в рамках Always Free нет.
2. Создать Compute Instance:
   - образ **Canonical Ubuntu 24.04**;
   - shape **VM.Standard.A1.Flex**, 2 OCPU и 12 ГБ памяти (с 15 июня 2026 это потолок Always Free);
   - если регион отвечает «Out of host capacity» — попробовать другой домен доступности, другой
     регион или временно взять две микро-машины VM.Standard.E2.1.Micro (1 ГБ);
   - добавить свой SSH-ключ.
3. Открыть порты 80 и 443: Networking → Virtual Cloud Network → Security Lists → Ingress Rules,
   источник `0.0.0.0/0`, TCP, порты 80 и 443.
4. На самой машине открыть те же порты в iptables:

   ```bash
   sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT
   sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 443 -j ACCEPT
   sudo netfilter-persistent save
   ```

5. Поставить Docker:

   ```bash
   curl -fsSL https://get.docker.com | sudo sh
   sudo usermod -aG docker ubuntu
   ```

Важно про Always Free: Oracle забирает простаивающие машины — если за 7 дней 95-й процентиль
загрузки CPU меньше 20% (для A1 ещё память и сеть). Чтобы машину не отобрали, аккаунт переводят
в Pay As You Go: бесплатные ресурсы остаются бесплатными, а правило простоя перестаёт действовать.

## 2. Домен

Нужен домен с A-записью на IP машины — без него Let's Encrypt не выпустит сертификат.
Подойдёт бесплатный поддомен на duckdns.org или любой свой.

## 3. Доступ к реестру образов

Образ хранится в GitHub Container Registry. Нужен токен с правом `write:packages`:
https://github.com/settings/tokens → Generate new token (classic).

Сам токен в репозиторий не кладём — `.kamal/secrets` только ссылается на файл рядом с профилем:

```bash
mkdir -p ~/.config/kamal
echo 'ghp_ваш_токен' > ~/.config/kamal/ghcr_token
chmod 600 ~/.config/kamal/ghcr_token
```

## 4. Первый деплой

В `config/deploy.yml` подставить IP машины и домен вместо `<SERVER_IP>` и `<DOMAIN>`, затем:

```bash
kamal setup          # ставит Docker-окружение, прокси и выкатывает приложение
kamal seed           # наполняет базу демонстрационными данными
```

Дальше каждое обновление — одной командой:

```bash
kamal deploy
```

Полезное:

```bash
kamal logs           # логи приложения
kamal console        # консоль Rails на сервере
kamal app exec "bin/rails db:migrate"
```

База SQLite лежит в томе `perpet_storage` и переживает деплои.

## 5. Мини-приложение VK

1. Создать мини-приложение в кабинете разработчика dev.vk.com и получить его ID.
2. В проекте мини-приложения настроить публикацию:

   ```bash
   npm install --save-dev @vkontakte/vk-miniapps-deploy
   npx vk-miniapps-deploy   # первый запуск попросит авторизоваться под вашим аккаунтом VK
   ```

3. Собранная статика уезжает на хостинг VK: бесплатно, с CDN и HTTPS.
4. В настройках приложения указать адрес хостинга VK, а в коде мини-приложения — адрес API
   сайта (`https://<DOMAIN>`), не `localhost`.
5. На стороне Rails разрешить домен мини-приложения в CORS, когда появится API.
