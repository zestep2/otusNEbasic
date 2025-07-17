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

##### Провреим связь пингом:
```
R1#ping 192.168.1.1

Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 192.168.1.1, timeout is 2 seconds:
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 0/0/1 ms
```
Работает!

##### Выясним кто DR, а кто BDR:

R1#show ip ospf interface 
```
GigabitEthernet0/0/1 is up, line protocol is up
  Internet address is 10.53.0.1/24, Area 0
  Process ID 56, Router ID 1.1.1.1, Network Type BROADCAST, Cost: 1
  Transmit Delay is 1 sec, State DR, Priority 1
  Designated Router (ID) 1.1.1.1, Interface address 10.53.0.1
  Backup Designated Router (ID) 2.2.2.2, Interface address 10.53.0.2
  Timer intervals configured, Hello 10, Dead 40, Wait 40, Retransmit 5
    Hello due in 00:00:04
  Index 1/1, flood queue length 0
  Next 0x0(0)/0x0(0)
  Last flood scan length is 1, maximum is 1
  Last flood scan time is 0 msec, maximum is 0 msec
  Neighbor Count is 1, Adjacent neighbor count is 1
    Adjacent with neighbor 2.2.2.2  (Backup Designated Router)
  Suppress hello for 0 neighbor(s)
```

```
R2#sho ip ospf interface 

Loopback1 is up, line protocol is up
  Internet address is 192.168.1.1/24, Area 0
  Process ID 56, Router ID 2.2.2.2, Network Type LOOPBACK, Cost: 1
  Loopback interface is treated as a stub Host
GigabitEthernet0/0/1 is up, line protocol is up
  Internet address is 10.53.0.2/24, Area 0
  Process ID 56, Router ID 2.2.2.2, Network Type BROADCAST, Cost: 1
  Transmit Delay is 1 sec, State BDR, Priority 1
  Designated Router (ID) 1.1.1.1, Interface address 10.53.0.1
  Backup Designated Router (ID) 2.2.2.2, Interface address 10.53.0.2
  Timer intervals configured, Hello 10, Dead 40, Wait 40, Retransmit 5
    Hello due in 00:00:08
  Index 2/2, flood queue length 0
  Next 0x0(0)/0x0(0)
  Last flood scan length is 1, maximum is 1
  Last flood scan time is 0 msec, maximum is 0 msec
  Neighbor Count is 1, Adjacent neighbor count is 1
    Adjacent with neighbor 1.1.1.1  (Designated Router)
  Suppress hello for 0 neighbor(s)
```
R1 - DR, R2 - BDR, т.к. R1 выйграл выборы потому что
ываыва
ываыва
ываыва
ываыва










