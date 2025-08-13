#  Лабораторная работа - Настройка протоколов CDP, LLDP и NTP
#### Топология
![alt text](image.png)

[Итоговый файл cpt для этой лабораторной](./lab_cpt.pkt)

#### Таблица адресации
| Устройство | Интерфейс   | IP-адрес   | Маска подсети    | Шлюз по умолчанию |
|------------|-------------|------------|------------------|-------------------|
| R1         | Loopback1   | 172.16.1.1 | 255.255.255.0    | —                 |
|            | G0/0/1      | 10.22.0.1  | 255.255.255.0    | —                 |
| S1         | SVI VLAN 1  | 10.22.0.2  | 255.255.255.0    | 10.22.0.1         |
| S2         | SVI VLAN 1  | 10.22.0.3  | 255.255.255.0    | 10.22.0.1         |

#### Задачи:
1. [Создание сети и настройка основных параметров устройства](#часть-1-создание-сети-и-настройка-основных-параметров-устройства)
2. [Обнаружение сетевых ресурсов с помощью CDP](#часть-2-обнаружение-сетевых-ресурсов-с-помощью-протокола-cdp)
3. [Обнаружение сетевых ресурсов с помощью LLDP](#часть-3-обнаружение-сетевых-ресурсов-с-помощью-протокола-lldp)
4. [Настройка и проверка NTP](#часть-4-настройка-и-проверка-ntp)



### Создание сети и настройка основных параметров устройства
##### Подключаем сеть в соответствии с топологией, настраиваем базовые параметры маршрутизаторов и коммутаторов в соотвествии в заданием

[Базовая настройка маршрутизатора R1](./R1_conf)

[Базовая настройка коммутатора S1](./S1_conf)

[Базовая настройка коммутатора S2](./S2_conf)

### Обнаружение сетевых ресурсов с помощью протокола CDP
#### На R1 используйте соответствующую команду show cdp, чтобы определить, сколько интерфейсов включено CDP, сколько из них включено и сколько отключено:
```
R1#show cdp interface 
Vlan1 is administratively down, line protocol is down
  Sending CDP packets every 60 seconds
  Holdtime is 180 seconds
GigabitEthernet0/0/0 is administratively down, line protocol is down
  Sending CDP packets every 60 seconds
  Holdtime is 180 seconds
GigabitEthernet0/0/1 is up, line protocol is up
  Sending CDP packets every 60 seconds
  Holdtime is 180 seconds
```
Видим, чтот 2 из 3 интерфейсов выключено. CDP включен на всех интерфейсах, активен 1 интерфейс


#### На R1 используйте соответствующую команду show cdp, чтобы определить версию IOS, используемую на S1:
```
R1#show cdp entry *

Device ID: S1
Entry address(es): 
Platform: cisco 2960, Capabilities: Switch
Interface: GigabitEthernet0/0/1, Port ID (outgoing port): FastEthernet0/5
Holdtime: 169

Version :
Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(2)SE4, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2013 by Cisco Systems, Inc.
Compiled Wed 26-Jun-13 02:49 by mnguyen

advertisement version: 2
Duplex: full
```
На S1 используется Version 15.0(2)SE4 iOS

#### На S1 используйте соответствующую команду show cdp, чтобы определить, сколько пакетов CDP было выданных:
По идее должна работать команда `show cdp traffic`, но в CPT она не работает. С помощью других команд show cdp определить количество пакетов CDP не удалось.

#### Настройте SVI для VLAN 1 на S1 и S2, используя IP-адреса, указанные в таблице адресации выше. Настройте шлюз по умолчанию для каждого коммутатора на основе таблицы адресов:
```
S1(config)#interface vlan 1
S1(config-if)#ip address 10.22.0.2 255.255.255.0
S1(config-if)#no sh
S1(config)#ip default-gateway 10.22.0.1
```
И аналогично для S2.

#### На R1 выполните команду show cdp entry S1 
```
R1#show cdp entry S1

Device ID: S1
Entry address(es): 
  IP address : 10.22.0.2
Platform: cisco 2960, Capabilities: Switch
Interface: GigabitEthernet0/0/1, Port ID (outgoing port): FastEthernet0/5
Holdtime: 170

Version :
Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(2)SE4, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2013 by Cisco Systems, Inc.
Compiled Wed 26-Jun-13 02:49 by mnguyen

advertisement version: 2
Duplex: full
```
Видим, что теперь появилась информация по IP-адресу S1

#### Отключить CDP глобально на всех устройствах:
```
R1(config)#no cdp run 
```
И повторяем на других устройствах.

### Обнаружение сетевых ресурсов с помощью протокола LLDP















