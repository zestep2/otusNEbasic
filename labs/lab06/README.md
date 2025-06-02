#  Лабораторная работа - Развертывание коммутируемой сети с резервными каналами
#### Топология
![alt text](image.png)

#### Таблица адресации
| Устройство | Интерфейс | IP-адрес     | Маска подсети    |
|------------|-----------|--------------|------------------|
| S1         | VLAN 1    | 192.168.1.1  | 255.255.255.0    |
| S2         | VLAN 1    | 192.168.1.2  | 255.255.255.0    |
| S3         | VLAN 1    | 192.168.1.3  | 255.255.255.0    |

#### Цели:
- [Часть 1. Создание сети и настройка основных параметров устройства](#часть-1-создание-сети-и-настройка-основных-параметров-устройства)
- [Часть 2. Выбор корневого моста](#часть-2-выбор-корневого-моста)
- [Часть 3. Наблюдение за процессом выбора протоколом STP порта, исходя из стоимости портов](#часть-3-наблюдение-за-процессом-выбора-протоколом-stp-порта-исходя-из-стоимости-портов)
- [Часть 4. Наблюдение за процессом выбора протоколом STP порта, исходя из приоритета портов](#часть-4-наблюдение-за-процессом-выбора-протоколом-stp-порта-исходя-из-приоритета-портов)


### Часть 1. Создание сети и настройка основных параметров устройства
Подключаем сеть в соответствии с топологией, настриваем базовые параметры коммутатора и IP-адреса

[Итоговый файл cpt для этой лабораторной](./lab_cpt.pkt)

[Базовая настройка коммутатора S1](./S1_conf)

[Базовая настройка коммутатора S2](./S2_conf)

[Базовая настройка коммутатора S3](./S3_conf)

Все эхо-запросы от коммутаторов успешно проходят!

### Часть 2. Выбор корневого моста

### Шаг 1. Отключите все порты на коммутаторах
```
interface range fa0/1-24,g0/1-2
shutdown 
```
Повторяем для S2,S3

### Шаг 2:	Настройте подключенные порты в качестве транковых
```
interface range fa0/1-4
switchport trunk allowed vlan all
```
Повторяем для S2,S3

### Шаг 3:	Включите порты F0/2 и F0/4 на всех коммутаторах
```
interface range fa0/2,fa0/4
no shutdown
```
Повторяем для S2,S3

### Шаг 4:	Отобразите данные протокола spanning-tree
#### Для S1:
```
S1#show spanning-tree 
VLAN0001
  Spanning tree enabled protocol ieee
  Root ID    Priority    32769
             Address     0002.1736.A7AC
             Cost        19
             Port        4(FastEthernet0/4)
             Hello Time  2 sec  Max Age 20 sec  Forward Delay 15 sec

  Bridge ID  Priority    32769  (priority 32768 sys-id-ext 1)
             Address     0060.47E4.93C8
             Hello Time  2 sec  Max Age 20 sec  Forward Delay 15 sec
             Aging Time  20

Interface        Role Sts Cost      Prio.Nbr Type
---------------- ---- --- --------- -------- --------------------------------
Fa0/2            Altn BLK 19        128.2    P2p
Fa0/4            Root FWD 19        128.4    P2p
```
#### Для S2:
```
S2#show spanning-tree 
VLAN0001
  Spanning tree enabled protocol ieee
  Root ID    Priority    32769
             Address     0002.1736.A7AC
             Cost        19
             Port        4(FastEthernet0/4)
             Hello Time  2 sec  Max Age 20 sec  Forward Delay 15 sec

  Bridge ID  Priority    32769  (priority 32768 sys-id-ext 1)
             Address     000A.F3E6.A8A9
             Hello Time  2 sec  Max Age 20 sec  Forward Delay 15 sec
             Aging Time  20

Interface        Role Sts Cost      Prio.Nbr Type
---------------- ---- --- --------- -------- --------------------------------
Fa0/4            Root FWD 19        128.4    P2p
Fa0/2            Desg FWD 19        128.2    P2p
```
#### Для S3:
```
S3#show spanning-tree 
VLAN0001
  Spanning tree enabled protocol ieee
  Root ID    Priority    32769
             Address     0002.1736.A7AC
             This bridge is the root
             Hello Time  2 sec  Max Age 20 sec  Forward Delay 15 sec

  Bridge ID  Priority    32769  (priority 32768 sys-id-ext 1)
             Address     0002.1736.A7AC
             Hello Time  2 sec  Max Age 20 sec  Forward Delay 15 sec
             Aging Time  20

Interface        Role Sts Cost      Prio.Nbr Type
---------------- ---- --- --------- -------- --------------------------------
Fa0/4            Desg FWD 19        128.4    P2p
Fa0/2            Desg FWD 19        128.2    P2p
```


С учетом выходных данных, поступающих с коммутаторов, ответьте на следующие вопросы. 

Какой коммутатор является корневым мостом? 
##### Ответ: S3

Почему этот коммутатор был выбран протоколом spanning-tree в качестве корневого моста?
##### Ответ: потому что у него был самый низкий приоритет из всех коммутаторов. Одинаковый административный прииоритет + одинаковый №влана дает равенство. Тогда побеждает коммутатор с наименьшим МАС-ом. Тут 0002.1736.A7AC оказался меньше чем 000A.F3E6.A8A9 (S2) и 0060.47E4.93C8 (S1)

Какие порты на коммутаторе являются корневыми портами?
##### Ответ: Для S1 Fa0/4 корневой. Для S2 Fa0/4 корневой.

Какие порты на коммутаторе являются назначенными портами?
##### Ответ: Для S2 Fa0/2 назначенный (designated). Для S3 Fa0/2 и Fa0/4 назначенный (designated).

Какой порт отображается в качестве альтернативного и в настоящее время заблокирован?
##### Ответ: Для S1 Fa0/2 отображается альтернативным и заблокировавн (Altn BLK)

Почему протокол spanning-tree выбрал этот порт в качестве невыделенного (заблокированного) порта?
##### Ответ: После выборов root bridge, коммутаторы выбрали root-порт с наименьшей стоимостью маршрута до root bridge. Далее они присвоили роли оставшимся портам (не root). При одинаковой стоимости на не-root портах начинается сраниваться приоритет bridge id и он оказался меньше (лучше) у S2 из-за его MAC-адреса (000A.F3E6.A8A9<0060.47E4.93C8)


### Часть 3: Наблюдение за процессом выбора протоколом STP порта, исходя из стоимости портов

### Шаг 1:	Определите коммутатор с заблокированным портом
Как определили выше, это порт Fa0/2 на S1:
```
Interface        Role Sts Cost      Prio.Nbr Type
---------------- ---- --- --------- -------- --------------------------------
Fa0/2            Altn BLK 19        128.2    P2p
Fa0/4            Root FWD 19        128.4    P2p
```

### Шаг 2:	Измените стоимость порта
Изменяем стоимость root порта на S1:
```
S1(config)#interface fastEthernet 0/4
S1(config-if)#spanning-tree vlan 1 cost 18
```
### Шаг 3:	Просмотрите изменения протокола spanning-tree
```
S1#show spanning-tree 
VLAN0001
  Spanning tree enabled protocol ieee
  Root ID    Priority    32769
             Address     0002.1736.A7AC
             Cost        18
             Port        4(FastEthernet0/4)
             Hello Time  2 sec  Max Age 20 sec  Forward Delay 15 sec

  Bridge ID  Priority    32769  (priority 32768 sys-id-ext 1)
             Address     0060.47E4.93C8
             Hello Time  2 sec  Max Age 20 sec  Forward Delay 15 sec
             Aging Time  20

Interface        Role Sts Cost      Prio.Nbr Type
---------------- ---- --- --------- -------- --------------------------------
Fa0/2            Desg FWD 19        128.2    P2p
Fa0/4            Root FWD 18        128.4    P2p
```
```
S2#show spanning-tree 
VLAN0001
  Spanning tree enabled protocol ieee
  Root ID    Priority    32769
             Address     0002.1736.A7AC
             Cost        19
             Port        4(FastEthernet0/4)
             Hello Time  2 sec  Max Age 20 sec  Forward Delay 15 sec

  Bridge ID  Priority    32769  (priority 32768 sys-id-ext 1)
             Address     000A.F3E6.A8A9
             Hello Time  2 sec  Max Age 20 sec  Forward Delay 15 sec
             Aging Time  20

Interface        Role Sts Cost      Prio.Nbr Type
---------------- ---- --- --------- -------- --------------------------------
Fa0/4            Root FWD 19        128.4    P2p
Fa0/2            Altn BLK 19        128.2    P2p
```

#### Видим, что порт fa0/2 на S1 стал назначенным, а порт fa0/2 на S2 - альтернативным (было наоборот)


Почему протокол spanning-tree заменяет ранее заблокированный порт на назначенный порт и блокирует порт, который был назначенным портом на другом коммутаторе?
##### Ответ - потому что изменился приоритет по 1-му признаку - стоимости пути до root. Теперь на S1 он стал 18. На S2 приходит информация, что с порта fa0/2 до root стоимость 18. А от с S2 в сторону S1 указано 19. Значит надо блокировать порт с большим (худшим) приоритетом, это порт на S2


### Шаг 4:	Удалите изменения стоимости порта
```
S1(config)#interface fastEthernet 0/4
S1(config-if)#no spanning-tree vlan 1 cost 18
```
```
S1#show spanning-tree 
VLAN0001
  Spanning tree enabled protocol ieee
  Root ID    Priority    32769
             Address     0002.1736.A7AC
             Cost        19
             Port        4(FastEthernet0/4)
             Hello Time  2 sec  Max Age 20 sec  Forward Delay 15 sec

  Bridge ID  Priority    32769  (priority 32768 sys-id-ext 1)
             Address     0060.47E4.93C8
             Hello Time  2 sec  Max Age 20 sec  Forward Delay 15 sec
             Aging Time  20

Interface        Role Sts Cost      Prio.Nbr Type
---------------- ---- --- --------- -------- --------------------------------
Fa0/2            Altn BLK 19        128.2    P2p
Fa0/4            Root FWD 19        128.4    P2p
```
Все вернулось к прежнему, теперь порт заблокирован, а не назначен

### Часть 4:	Наблюдение за процессом выбора протоколом STP порта, исходя из приоритета портов
#### a.	Включите порты F0/1 и F0/3 на всех коммутаторах
Пишем на коммутаторах:
```
interface range fa0/1,fa0/3
no shutdown
```
#### b.	Проверяем состояние STP на некорневых коммутаторах:
```
S1#show spanning-tree 
VLAN0001
  Spanning tree enabled protocol ieee
  Root ID    Priority    32769
             Address     0002.1736.A7AC
             Cost        19
             Port        3(FastEthernet0/3)
             Hello Time  2 sec  Max Age 20 sec  Forward Delay 15 sec

  Bridge ID  Priority    32769  (priority 32768 sys-id-ext 1)
             Address     0060.47E4.93C8
             Hello Time  2 sec  Max Age 20 sec  Forward Delay 15 sec
             Aging Time  20

Interface        Role Sts Cost      Prio.Nbr Type
---------------- ---- --- --------- -------- --------------------------------
Fa0/1            Altn BLK 19        128.1    P2p
Fa0/2            Altn BLK 19        128.2    P2p
Fa0/3            Root FWD 19        128.3    P2p
Fa0/4            Altn BLK 19        128.4    P2p
```
```
S2#show spanning-tree 
VLAN0001
  Spanning tree enabled protocol ieee
  Root ID    Priority    32769
             Address     0002.1736.A7AC
             Cost        19
             Port        3(FastEthernet0/3)
             Hello Time  2 sec  Max Age 20 sec  Forward Delay 15 sec

  Bridge ID  Priority    32769  (priority 32768 sys-id-ext 1)
             Address     000A.F3E6.A8A9
             Hello Time  2 sec  Max Age 20 sec  Forward Delay 15 sec
             Aging Time  20

Interface        Role Sts Cost      Prio.Nbr Type
---------------- ---- --- --------- -------- --------------------------------
Fa0/1            Desg FWD 19        128.1    P2p
Fa0/4            Altn BLK 19        128.4    P2p
Fa0/3            Root FWD 19        128.3    P2p
Fa0/2            Desg FWD 19        128.2    P2p
```

#### Root-порт на обоих коммутаторах переключился на fa0/3 (вместо fa0/4)


### Вопросы-ответы:
Какой порт выбран протоколом STP в качестве порта корневого моста на каждом коммутаторе некорневого моста? Почему протокол STP выбрал эти порты в качестве портов корневого моста на этих коммутаторах?
##### Ответ: С наименьшим приоритетом, при прочих равных с наименьшим номером порта. В обоих случаях это оказался fa0/3.

1.	Какое значение протокол STP использует первым после выбора корневого моста, чтобы определить выбор порта?
##### Ответ: стоимость (cost) до root моста на портах
2.	Если первое значение на двух портах одинаково, какое следующее значение будет использовать протокол STP при выборе порта?
##### Ответ: приоритет bridge id (bid). Административно настраиваемый, если равен, например по умолчанию - то приоритет за меньшим MAC-адресом
3.	Если оба значения на двух портах равны, каким будет следующее значение, которое использует протокол STP при выборе порта?
##### Ответ: приоритеты портов (128 + номер порта, чем меньше - тем лучше)

