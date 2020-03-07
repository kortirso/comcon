# Case-study оптимизации

Для применения полученных навыков был выбран реальный проект на production - мой пет проект GuildHall, url - https://guild-hall.org

## Предварительная настройка

- подключен NewRelic, Skylight
- подготовка большого набора данных для проверки оптимизации

## Feedback-Loop

`feedback_loop` для оптимизации:

- поиск точки роста через NewRelic и Skylight
- модификация кода
- проверка результата
- повторение

## Находка 1
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

