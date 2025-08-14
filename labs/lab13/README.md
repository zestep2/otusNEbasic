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



### Часть 1. Создание сети и настройка основных параметров устройства
##### Подключаем сеть в соответствии с топологией, настраиваем базовые параметры маршрутизаторов и коммутаторов в соотвествии в заданием

[Базовая настройка маршрутизатора R1](./R1_conf)

[Базовая настройка коммутатора S1](./S1_conf)

[Базовая настройка коммутатора S2](./S2_conf)

### Часть 2. Обнаружение сетевых ресурсов с помощью протокола CDP
#### На R1 используйте соответствующую команду `show cdp`, чтобы определить, сколько интерфейсов включено CDP, сколько из них включено и сколько отключено:
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

### Часть 3. Обнаружение сетевых ресурсов с помощью протокола LLDP
#### Включим LLDP командой `lldp run` и посмотрим информацию о S2 на S1:
```
S1#sho lldp neighbors detail 
------------------------------------------------
Chassis id: 000A.F335.6301
Port id: Fa0/1
Port Description: FastEthernet0/1
System Name: S2
System Description:
Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(2)SE4, RELEASE SOFTWARE (fc1)
Technical Support: http://www.cisco.com/techsupport
Copyright (c) 1986-2013 by Cisco Systems, Inc.
Compiled Wed 26-Jun-13 02:49 by mnguyen
Time remaining: 90 seconds
System Capabilities: B
Enabled Capabilities: B
Management Addresses - not advertised
Auto Negotiation - supported, enabled
Physical media capabilities:
    100baseT(FD)
    100baseT(HD)
    1000baseT(HD)
Media Attachment Unit type: 10
Vlan ID: 1
```
Chassis id - это MAС-адрес порта Fa0/1 на S2
```
S2#show interfaces fa0/1
FastEthernet0/1 is up, line protocol is up (connected)
  Hardware is Lance, address is 000a.f335.6301 (bia 000a.f335.6301)
```


#### Соединитесь через консоль на всех устройствах и используйте команды LLDP, необходимые для отображения топологии физической сети только из выходных данных команды show:
```
S1#show lldp neighbors 
Capability codes:
    (R) Router, (B) Bridge, (T) Telephone, (C) DOCSIS Cable Device
    (W) WLAN Access Point, (P) Repeater, (S) Station, (O) Other
Device ID           Local Intf     Hold-time  Capability      Port ID
S2                  Fa0/1          120        B               Fa0/1
R1                  Fa0/5          120        R               Gig0/0/1

Total entries displayed: 2
```
```
R1#sho lldp neighbors 
Capability codes:
    (R) Router, (B) Bridge, (T) Telephone, (C) DOCSIS Cable Device
    (W) WLAN Access Point, (P) Repeater, (S) Station, (O) Other
Device ID           Local Intf     Hold-time  Capability      Port ID
S1                  Gig0/0/1       120        B               Fa0/5

Total entries displayed: 1
```
```
S2#sho lldp  neighbors 
Capability codes:
    (R) Router, (B) Bridge, (T) Telephone, (C) DOCSIS Cable Device
    (W) WLAN Access Point, (P) Repeater, (S) Station, (O) Other
Device ID           Local Intf     Hold-time  Capability      Port ID
S1                  Fa0/1          120        B               Fa0/1

Total entries displayed: 1
```
По этой информации можно однозначно определить топологию сети


### Часть 4. Настройка и проверка NTP

#### Посмотрим текущее время на R1 c помощью команды `show clock detail`:

| Дата       | Время     | Часовой пояс | Источник времени |
|------------|-----------|--------------|------------------|
| 1993-03-1 | 00:12:31.133  | UTC        | hardware calendar   |

#### Установим время на R1 и включим на нем NTP сервер с уровнем слоя 4:
```
R1#clock set 11:25:25 14 august 2025
R1(config)#ntp master 5
R1#show ntp status 
Clock is synchronized, stratum 4, reference is 127.127.1.1
nominal freq is 250.0000 Hz, actual freq is 249.9990 Hz, precision is 2**24
reference time is EC1CC66A.0000007A (11:32:58.122 UTC Thu Aug 14 2025)
clock offset is 0.00 msec, root delay is 0.00  msec
root dispersion is 0.00 msec, peer dispersion is 0.24 msec.
loopfilter state is 'CTRL' (Normal Controlled Loop), drift is - 0.000001193 s/s system poll interval is 5, last update was 28 sec ago.
```
Все ок!

#### Посмотрим текщее время на S1 и S2:

| Дата       | Время     | Часовой пояс |Коммутатор |
|------------|-----------|--------------|------------------|
| 1993-03-1 | 0:26:46.98  | UTC       | S1   |
| 1993-03-1 | 0:27:17.199  | UTC       | S2   |

#### Настроим S1 и S2 в качестве клиентов NTP:
```
S1(config)#ntp server 10.22.0.1
```
Аналогично для S2

#### Проверим результат:
```
S1#sho ntp status 
Clock is synchronized, stratum 16, reference is 10.22.0.1
nominal freq is 250.0000 Hz, actual freq is 249.9990 Hz, precision is 2**24
reference time is 292150E0.000003CD (22:49:4.973 UTC Sun Jan 27 2058)
clock offset is 0.00 msec, root delay is 0.00  msec
root dispersion is 10.89 msec, peer dispersion is 0.12 msec.
loopfilter state is 'CTRL' (Normal Controlled Loop), drift is - 0.000001193 s/s system poll interval is 4, last update was 16 sec ago.
```
```
S1#sho ntp associations 

address         ref clock       st   when     poll    reach  delay          offset            disp
*~10.22.0.1     127.127.1.1     5    8        16      377    0.00           0.00              0.12
 * sys.peer, # selected, + candidate, - outlyer, x falseticker, ~ configured
```
```
S1#sho clock detail 
11:44:10.17 UTC Thu Aug 14 2025
Time source is NTP
```
Ура, заработало, мы в 2025 году! (для S2 все тоже самое)

