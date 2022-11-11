Автополучение и автоприменение ssl сертификатов.
- управлять доменом будем через cloudflare
- 1) Создайте токен API от Cloudflare:
  Перейдите к https://dash.cloudflare.com/profile/api-tokens.
  В разделе «Токены API » выберите «Создать токен ».
  Выберите « Использовать шаблон» для « Редактировать зону DNS».
    Ресурсы зоны :
        Включают
        Специальная зона
        Выберите домен, который мы хотим использовать для DDNS
        Этот шаг является необязательным. Если пропустить, этот токен API будет иметь разрешения для всех ваших доменов Cloudflare.
   В разделе TTL выберите Даты начала/окончания или оставьте без изменений, чтобы эти разрешения не истекали. 
   
- Создаем на DSM файл cloud.ini (можно по другому назвать) в папке (у вас своя для контейнеров) /volume2/docker/certbot/cloudflare/
  в файл cloud.ini пишем : dns_cloudflare_api_token = ВАШ API токен
- Создаем
     /volume2/docker/certbot/cloudflare/cert - папка для сертификатов
     /volume2/docker/certbot/cloudflare/log - папка для логов работы letsencrypt
     
- Копируем docker-compose.yml в /volume2/docker/certbot/cloudflare/ 
- Редактируем docker-compose.yml под свои данные
  
Копируем скрипт replace_synology_ssl_certs.sh в любое место, можно в /volume2/docker/certbot/cloudflare/
Проверяем скрипт, и меняем пути если необходимо.
В планировщике DSM создаем задачу на выполнение скрипта от имени root, периодичность 1 раз в месяц,
в поле скрипт вставляем "bash /volume2/docker/certbot/cloudflare/replace_synology_ssl_certs.sh"
