# Case-study оптимизации

Для применения полученных навыков был выбран реальный проект на production - мой пет проект GuildHall
url - https://guild-hall.org
код проекта - https://github.com/kortirso/comcon

## Предварительная настройка

- подключен NewRelic, Skylight
- подготовка большого набора данных для проверки оптимизации

## Feedback-Loop

`feedback_loop` для оптимизации:

- поиск точки роста через NewRelic и Skylight
- модификация кода
- проверка результата
- повторение

## Находка 1.1
Целый комплекс эндпоинтов для отображения одной страницы, при вызове events#show происходит вызов эндпоинтов:
- Api::V1::EventsController#subscribers
- Api::V1::EventsController#characters_without_subscribe
- Api::V1::EventsController#user_characters
Первые два как раз являются основными точками роста

Суть проблемы - по первоначальному замыслу и планированию структуры есть модель Event, на него могут подписаться персонажи из определенной группы (изначально никто не подписан), после у них может меняться статус подписки, затем на фронтэнде выводится информация через #subscribers о подписавшихся персонажах и через #characters_without_subscribe - о неподписавшихся (в этом запросе приходится искать тех, кто мог подписаться, но не подписался)

Решение:
- при создании события сразу подписывать всех персонажей на него с условным статусом "Подписан"
- затем список будет получаться через 1 эндпоинт
- добавить кэширование, ведь достаточно продолжительное время он будет неизменным и можно будет определять его актуальность по всем статусам-подписям
- сериализовывать через fast json api

Статистика до оптимизации
Skylight
- Api::V1::EventsController#subscribers, typical 112 ms, problem 448 ms, agony 2
- Api::V1::EventsController#characters_without_subscribe, typical 444 ms, problem 1200 ms, agony 3
- Api::V1::EventsController#user_characters, typical 41 ms, problem 147 ms, agony 0

NewRelic
- Api::V1::EventsController#subscribers, apdex 0.99, average 146 ms
- Api::V1::EventsController#characters_without_subscribe, apdex 0.8, average 549 ms
- Api::V1::EventsController#user_characters

Оптимизация:
- 1 новый эндпоинт (Api::V2::EventsController#subscribers) вместо 3 старых
- fast json api сериализация
- кэширование результатов https://github.com/kortirso/comcon/commit/0c49bee29e7107e303cc1cb16fe21b4207c4f9b2#diff-c2a7dc5d956f7cd307d4a4eb1ac0e12dR49
- использование activerecord-import для быстрого создания базовых подписок https://github.com/kortirso/comcon/commit/0c49bee29e7107e303cc1cb16fe21b4207c4f9b2#diff-49d71d479391d0d579099c5d6c941762R13

Статистика после оптимизации
Skylight
- Api::V2::EventsController#subscribers, typical 126 ms, problem 191 ms, agony 2

NewRelic
- Api::V2::EventsController#subscribers, apdex 0.98, average 151 ms

### Находка 1.2
При сериализации персонажа идет много дополнительных запросов на получение списка ролей - надо заменить на предварительный расчет текущих ролей персонажа, т.к. они к тому же редко меняются

Статистика после оптимизации
Skylight
- Api::V2::EventsController#subscribers, typical 81 ms, problem 144 ms, agony 1

NewRelic
- Api::V2::EventsController#subscribers, apdex 0.98, average 125 ms

Результат улучшился примерно в 7-12 раз по времени загрузки

## Находка 2.1
В проекте есть страница календаря с событиями, которая является основной используемой страницей, где пользователи могут посмотреть события, на которые они подписаны
На этой странице вызываются 2 эндпоинта
- Api::V2::EventsController#index - рендерит список событий для пользователя
- Api::V2::EventsController#filter_values - рендерит данные для фильтра событий
И оба эти эндпоинта являются основными точками роста на данный момент

Суть проблемы - для поиска доступных событий используется не оптимальный алгоритм, но благодаря изменениями в предыдущем пункте можно значительно ускорить процесс поиска доступных событий за меньшее кол-во запросов к БД + кэширование
Для второго эндпоинта часть данных берется из кэша, а часть данных рассчитывается, что не есть оптимально, т.к. в целом рассчитываемая часть редко меняется, поэтому надо добавить кэширование ответа в целом

Решение:
- оптимизация запросов в БД
- кэширование

Статистика до оптимизации
Skylight
- Api::V2::EventsController#index, typical 227 ms, problem 681 ms, agony 3
- Api::V2::EventsController#filter_values, typical 224 ms, problem 621 ms, agony 2

NewRelic
- Api::V2::EventsController#index, apdex 0.95, average 283 ms
- Api::V2::EventsController#filter_values, apdex 0.96, average 261 ms
