#  Лабораторная работа. Настройка протокола OSPFv2 для одной области
#### Топология
![alt text](image.png)

[Итоговый файл cpt для этой лабораторной](./lab_cpt.pkt)

#### Таблица адресации
| Устройство | Интерфейс | IP-адрес   | Маска подсети    |
|:----------:|:---------:|:----------:|:----------------:|
| R1         | G0/0/1    | 10.53.0.1  | 255.255.255.0    |
|            | Loopback1 | 172.16.1.1 | 255.255.255.0    |
| R2         | G0/0/1    | 10.53.0.2  | 255.255.255.0    |
|            | Loopback1 | 192.168.1.1| 255.255.255.0    |

#### Задачи:
1. [Создание сети и настройка основных параметров устройства](#часть-1-создание-сети-и-настройка-основных-параметров-устройства)
2. [Настройка и проверка базовой работы OSPFv2](#часть-2-настройка-и-проверка-базовой-работы-протокола-ospfv2-для-одной-области)
3. [Оптимизация конфигурации OSPFv2](#часть-3-оптимизация-и-проверка-конфигурации-ospfv2-для-одной-области)


### Часть 1. Создание сети и настройка основных параметров устройства
##### Подключаем сеть в соответствии с топологией, настраиваем базовые параметры маршрутизаторов и коммутаторов в соотвествии в заданием

[Базовая настройка маршрутизатора R1](./R1_conf)

[Базовая настройка маршрутизатора R2](./R2_conf)

[Базовая настройка коммутатора S1](./S1_conf)

[Базовая настройка коммутатора S2](./S2_conf)

### Часть 2. Настройка и проверка базовой работы OSPFv2
##### Настроим интерфейсы:
```
R1(config)#interface g0/0/1
R1(config-if)#ip address 10.53.0.1 255.255.255.0
R1(config-if)#ex
R1(config)#interface loopback 1
R1(config-if)#ip address 172.16.1.1 255.255.255.0
```
```
R2(config)#interface g0/0/1
R2(config-if)#ip address 10.53.0.2 255.255.255.0
R2(config-if)#ex
R2(config)#interface loopback 1
R2(config-if)#ip address 192.168.1.1 255.255.255.0
```
##### Настроим статические идентификаторы маршрутизаторов, идентификатор процесса и включим ввсе в область 0 на интерфейсе:
```
R1(config)#router ospf 56
R1(config-router)#router-id 1.1.1.1
R1(config-router)#ex
R1(config)#inte g0/0/1
R1(config-if)#ip ospf 56 area 0
```
```
R2(config)#router ospf 56
R2(config-router)#router-id 2.2.2.2
R2(config-router)#ex
R2(config)#inte g0/0/1
R2(config-if)#ip ospf 56 area 0
```
##### На R2 объявим сеть loopback1 в область OSPF 0:
```
R2(config)#router ospf 56
R2(config-router)#network 192.168.1.0 0.0.0.255 area 0
```
Проверим R1 на наличие этого маршрута:
```
R1#show ip route ospf 
     192.168.1.0/32 is subnetted, 1 subnets
O       192.168.1.1 [110/2] via 10.53.0.2, 00:00:55, GigabitEthernet0/0/1
```
Ура, маршрут появился!

##### Проверим связь пингом:
```
R1#ping 192.168.1.1

Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 192.168.1.1, timeout is 2 seconds:
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 0/0/1 ms
```
Работает!

##### Выясним кто DR, а кто BDR:
```
R1#show ip ospf interface 
GigabitEthernet0/0/1 is up, line protocol is up
  Internet address is 10.53.0.1/24, Area 0
  Process ID 56, Router ID 1.1.1.1, Network Type BROADCAST, Cost: 1
  Transmit Delay is 1 sec, State BDR, Priority 1
  Designated Router (ID) 2.2.2.2, Interface address 10.53.0.2
  Backup Designated Router (ID) 1.1.1.1, Interface address 10.53.0.1
  Timer intervals configured, Hello 10, Dead 40, Wait 40, Retransmit 5
    Hello due in 00:00:02
  Index 1/1, flood queue length 0
  Next 0x0(0)/0x0(0)
  Last flood scan length is 1, maximum is 1
  Last flood scan time is 0 msec, maximum is 0 msec
  Neighbor Count is 1, Adjacent neighbor count is 1
    Adjacent with neighbor 2.2.2.2  (Designated Router)
  Suppress hello for 0 neighbor(s
```

```
R2#sho ip ospf int

Loopback1 is up, line protocol is up
  Internet address is 192.168.1.1/24, Area 0
  Process ID 56, Router ID 2.2.2.2, Network Type LOOPBACK, Cost: 1
  Loopback interface is treated as a stub Host
GigabitEthernet0/0/1 is up, line protocol is up
  Internet address is 10.53.0.2/24, Area 0
  Process ID 56, Router ID 2.2.2.2, Network Type BROADCAST, Cost: 1
  Transmit Delay is 1 sec, State DR, Priority 1
  Designated Router (ID) 2.2.2.2, Interface address 10.53.0.2
  Backup Designated Router (ID) 1.1.1.1, Interface address 10.53.0.1
  Timer intervals configured, Hello 10, Dead 40, Wait 40, Retransmit 5
    Hello due in 00:00:08
  Index 2/2, flood queue length 0
  Next 0x0(0)/0x0(0)
  Last flood scan length is 1, maximum is 1
  Last flood scan time is 0 msec, maximum is 0 msec
  Neighbor Count is 1, Adjacent neighbor count is 1
    Adjacent with neighbor 1.1.1.1  (Backup Designated Router)
  Suppress hello for 0 neighbor(s)
```
Видно, что R2 - DR, R1 - BDR. R2 выйграл выборы потому что у него выше приоритет по routerID. При выборах сначала проверяется приоритет ospf на интерфейсе (от 0 до 255, где 0 не может стать BR/BDR), если значения равны (по умолччанию 1 в бродкаст сети) - то сравниваются routerID, побеждает наивысший.

###  Оптимизация конфигурации OSPFv2
#### Шаг 1. Реализация различных оптимизаций на каждом маршрутизаторе
####  На R1 настроим приоритет OSPF интерфейса G0/0/1 на 50, чтобы убедиться, что R1 является назначенным маршрутизатором:
```
R1(config)#interface g0/0/1
R1(config-if)#ip ospf priority 50
```
#### Перезапустим службу OSPF и проверим результат выборов:
```
R1#clear ip ospf process 
R1#sho ip osp neighbor 
Neighbor ID     Pri   State           Dead Time   Address         Interface
2.2.2.2           1   FULL/BDR        00:00:37    10.53.0.2       GigabitEthernet0/0/1
```
Видно, что теперь R1 - DR, что мы и добивались меняя приоритет

#### Настроим таймеры OSPF на G0/0/1 каждого маршрутизатора для таймера приветствия, составляющего 30 секунд:
```
R1(config)#interface g0/0/1
R1(config-if)#ip osp
R1(config-if)#ip ospf hell
R1(config-if)#ip ospf hello-interval 30
```
```
R2(config)#interface g0/0/1
R2(config-if)#ip os
R2(config-if)#ip ospf he
R2(config-if)#ip ospf hello-interval 30
```

#### На R1 настроим статический маршрут по умолчанию, который использует интерфейс Loopback 1 в качестве интерфейса выхода. Затем распространим маршрут по умолчанию в OSPF:
```
R1(config)#ip route 0.0.0.0 0.0.0.0 loopback 1
R1(config)#router ospf 56
R1(config-router)#default-information originate 
```
#### Добавим конфигурацию, необходимую для OSPF для обработки R2 Loopback 1 как сети точка-точка:
```
R2(config)#interface loopback 1
R2(config-if)#ip ospf network point-to-point 
```


#### Только на R2 добавим конфигурацию, необходимую для предотвращения отправки объявлений OSPF в сеть Loopback 1:
```
R2(config)#router ospf 56
R2(config-router)#passive-interface loopback 1
```

#### Изменим базовую пропускную способность для маршрутизаторов:

```
R1(config)#router ospf 56
R1(config-router)#auto-cost reference-bandwidth 1000
```
```
R2(config)#router ospf 56
R2(config-router)#auto-cost reference-bandwidth 1000
```

#### Перезапустим ospf процесс:

```
R1#clear ip ospf process 
```

### Шаг 2. Убедимся, что оптимизация OSPFv2 реализовалась:

```
R1#sho ip ospf interface g0/0/1

GigabitEthernet0/0/1 is up, line protocol is up
  Internet address is 10.53.0.1/24, Area 0
  Process ID 56, Router ID 1.1.1.1, Network Type BROADCAST, Cost: 10
  Transmit Delay is 1 sec, State DR, Priority 50
  Designated Router (ID) 1.1.1.1, Interface address 10.53.0.1
  Backup Designated Router (ID) 2.2.2.2, Interface address 10.53.0.2
  Timer intervals configured, Hello 30, Dead 40, Wait 40, Retransmit 5
    Hello due in 00:00:04
  Index 1/1, flood queue length 0
  Next 0x0(0)/0x0(0)
  Last flood scan length is 1, maximum is 1
  Last flood scan time is 0 msec, maximum is 0 msec
  Neighbor Count is 1, Adjacent neighbor count is 1
    Adjacent with neighbor 2.2.2.2  (Backup Designated Router)
  Suppress hello for 0 neighbor(s)
```
Видим - приоритет 50, таймеры Hello 30, Dead 40, а тип сети - Broadcast

#### Проверим маршруты на R1:
```
R1#sho ip route
.
.
.
O    192.168.1.0/24 [110/10] via 10.53.0.2, 00:05:12, GigabitEthernet0/0/1
S*   0.0.0.0/0 is directly connected, Loopback1
```
Есть сеть с Loopback 1 маршрутизатора R2, с маской 24 после того как мы изменили тип подключения на P2P на интерфейсе Loopback 1

#### Посмотрим маршруты на R2:
```
R2#sho ip rou
Codes: L - local, C - connected, S - static, R - RIP, M - mobile, B - BGP
       D - EIGRP, EX - EIGRP external, O - OSPF, IA - OSPF inter area
       N1 - OSPF NSSA external type 1, N2 - OSPF NSSA external type 2
       E1 - OSPF external type 1, E2 - OSPF external type 2, E - EGP
       i - IS-IS, L1 - IS-IS level-1, L2 - IS-IS level-2, ia - IS-IS inter area
       * - candidate default, U - per-user static route, o - ODR
       P - periodic downloaded static route

Gateway of last resort is 10.53.0.1 to network 0.0.0.0

     10.0.0.0/8 is variably subnetted, 2 subnets, 2 masks
C       10.53.0.0/24 is directly connected, GigabitEthernet0/0/1
L       10.53.0.2/32 is directly connected, GigabitEthernet0/0/1
     192.168.1.0/24 is variably subnetted, 2 subnets, 2 masks
C       192.168.1.0/24 is directly connected, Loopback1
L       192.168.1.1/32 is directly connected, Loopback1
O*E2 0.0.0.0/0 [110/1] via 10.53.0.1, 00:00:26, GigabitEthernet0/0/1
```
Видим маршрут по-умолчанию от R1

#### Запустим ping до адреса интерфейса R1 Loopback 1 из R2:
```
R2#ping 172.16.1.1

Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 172.16.1.1, timeout is 2 seconds:
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 0/1/7 ms
```
Успешно! Был использован маршрут по умолчанию

### Вопрос:
Почему стоимость OSPF для маршрута по умолчанию отличается от стоимости OSPF в R1 для сети 192.168.1.0/24?

### Ответ:
Потому что, loopback-интерфейсы по умолчанию имеют стоимость 1, а стоимость обычных интерфейсов (в нашем случае для сети 192.168.1.0/24 эта стоимость равна 10) вычисляется по пропускной способности

