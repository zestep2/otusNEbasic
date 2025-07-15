#  Лабораторная работа - Реализация DHCPv4
#### Топология
![alt text](image.png)
[Итоговый файл cpt для этой лабораторной](./lab_cpt.pkt)

#### 1.	Таблица адресации
| Устройство | Интерфейс    | IP-адрес   | Маска подсети       | Шлюз по умолчанию |
|------------|--------------|------------|---------------------|-------------------|
| R1         | G0/0/0       | 10.0.0.1   | 255.255.255.252     | —                 |
|            | G0/0/1       | —          | —                   | —                 |
|            | G0/0/1.100   | 192.168.0.1   |     255.255.255.192                | —                 |
|            | G0/0/1.200   |	192.168.0.65|	255.255.255.224| —                 |
|            | G0/0/1.1000  | —          | —                   | —                 |
| R2         | G0/0         | 10.0.0.2   | 255.255.255.252     | —                 |
|            | G0/0/1       | 192.168.0.97|255.255.255.240| —                 |
| S1         | VLAN 200     |192.168.0.66|255.255.255.224|192.168.0.65|
| S2         | VLAN 1       |            |                     |                   |
| PC-A       | NIC          | DHCP       | DHCP                | DHCP              |
| PC-B       | NIC          | DHCP       | DHCP                | DHCP              |
#### 2.	Таблица VLAN
| VLAN  | Имя          | Назначенный интерфейс                          |
|-------|--------------|-----------------------------------------------|
| 1     | Нет          | S2: F0/18                                     |
| 100   | Клиенты      | S1: F0/6                                      |
| 200   | Управление   | S1: VLAN 200                                  |
| 999   | Parking_Lot  | S1: F0/1-4, F0/7-24, G0/1-2                  |
| 1000  | Собственная  | —                                             |



#### Задачи:
1. [Часть 1. Создание сети и настройка основных параметров устройства](#часть-1-создание-сети-и-настройка-основных-параметров-устройства)
2. [Часть 2. Настройка и проверка двух серверов DHCPv4 на R1](#часть-2-настройка-и-проверка-двух-серверов-dhcpv4-на-r1)
3. [Часть 3. Настройка и проверка DHCP-ретрансляции на R2](#часть-3-настройка-и-проверка-dhcp-ретрансляции-на-r2)


### Часть 1. Создание сети и настройка основных параметров устройства
### Шаг 1.	Создание схемы адресации
Делить сеть 192.168.0.0/24 на подсети в соответсвии с заданием и записывает данные в таблицу
Клиентская А на 58 хостов - 192.168.0.0/26
Управляющая B на 28 хостов - 192.168.0.64/27
Клиентская C на 12 узлов - 192.168.0.96/28

### Шаг 2-3.	Создайте сеть согласно топологии

Подключаем сеть в соответствии с топологией, настраиваем базовые параметры маршрутизаторов



[Базовая настройка маршрутизатора R1](./R1_conf)

[Базовая настройка маршрутизатора R2](./R2_conf)


### Шаг 4.	Настройка маршрутизации между сетями VLAN на маршрутизаторе R1
Активируем интерфейс G0/0/1 на маршрутизаторе и настроем подинтерфейсы для каждой VLAN в соответствии с требованиями таблицы IP-адресации:
```
R1(config)#interface gigabitEthernet 0/0/1
R1(config-if)#no shutdown 

R1(config)#interface g0/0/1.100
R1(config-subif)#encapsulation dot1Q 100
R1(config-subif)#ip address 192.168.0.1 255.255.255.192
R1(config-subif)#description CLIENTS-58HOSTS
R1(config-subif)#ex

R1(config)#interface g0/0/1.200
R1(config-subif)#encapsulation dot1Q 200
R1(config-subif)#ip address 192.168.0.65 255.255.255.224
R1(config-subif)#description MGMT
R1(config-subif)#ex

R1(config)#interface g0/0/1.1000
R1(config-subif)#encapsulation dot1Q 1000 native
R1(config-subif)#description NATIVE
R1(config-subif)#ex
```

### Шаг 5.	Настроим G0/1 на R2, затем G0/0/0 и статическую маршрутизацию для обоих маршрутизаторов
#### a.	Настроим G0/0/1 на R2:

```
R2(config)#interface g0/0/1
R2(config-if)#no shutdown 
R2(config-if)#ip address 192.168.0.97 255.255.255.240
```
#### b.	Настроим интерфейс G0/0/0 для каждого маршрутизатора:
```
R1(config)#interface g0/0/0
R1(config-if)#ip address 10.0.0.1 255.255.255.252
R1(config-if)#no shutdown 
```
```
R2(config)#interface gigabitEthernet 0/0/0
R2(config-if)#ip address 10.0.0.2 255.255.255.252
R2(config-if)#no shu
```
#### c.	Настроим маршрут по умолчанию на каждом маршрутизаторе, указывая на IP-адрес G0/0/0 на другом маршрутизаторе:
```
R1(config)#ip default-gateway 10.0.0.2 
```
```
R2(config)#ip default-gateway 10.0.0.1
```
#### d.	Убедимся, что статическая маршрутизация работает с помощью пинга до адреса G0/0/1 R2 от R1:
```
R2# ping 10.0.0.1

Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 10.0.0.1, timeout is 2 seconds:
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 0/0/0 ms
```
Все успешно!

### Шаг 6.	Настройте базовые параметры каждого коммутатора.

[Базовая настройка коммутатора S1](./S1_conf)

[Базовая настройка коммутатора S2](./S2_conf)


### Шаг 7.	Создайте сети VLAN на коммутаторе S1.

Создадим необходимые VLAN на коммутаторе 1, настроем и активирем интерфейс управления на S1 (VLAN 200), используя второй IP-адрес из подсети, рассчитанный ранее. Кроме того установим шлюз по умолчанию на S1:

```
S1(config)#vlan 100
S1(config-vlan)#name CLIENTS
S1(config-vlan)#ex

S1(config)#vlan 200
S1(config-vlan)#name MGMT
S1(config-vlan)#ex

S1(config)#vlan 999
S1(config-vlan)#name PARKING
S1(config-vlan)#ex

S1(config)#vlan 1000
S1(config-vlan)#name NATIVE
S1(config-vlan)#ex

S1(config)#interface vlan 200
S1(config-if)#ip address 192.168.0.66 255.255.255.224
S1(config-if)#ex

S1(config)#ip default-gateway 192.168.0.65
```

Настроем и активируем интерфейс управления на S2 (VLAN 1), используя второй IP-адрес из подсети, рассчитанный ранее. Кроме того, установим шлюз по умолчанию на S2:
```
S2(config)#interface vlan 1
S2(config-if)#ip address 192.168.0.67 255.255.255.224
S2(config-if)#no shutdown 
```

Назначим все неиспользуемые порты S1 VLAN Parking_Lot, настроим их для статического режима доступа и административно деактивируем их. На S2 административно деактивируем все неиспользуемые порты:
```
S1(config)#interface range fastEthernet 0/1-4, fastEthernet 0/7-24, g0/1-2
S1(config-if-range)#switchport mode access 
S1(config-if-range)#switchport access vlan 999
S1(config-if-range)#shutdown 
```
```
S2(config)#interface range fa0/1-4, fa0/6-17, fa0/19-24, g0/1-2
S2(config-if-range)#shutdown 
```
### Шаг 8.	Назначьте сети VLAN соответствующим интерфейсам коммутатора.


S1(config)#interface fa0/6
S1(config-if)#sw
S1(config-if)#switchport mode
S1(config-if)#switchport mode ac
S1(config-if)#switchport mode access 
S1(config-if)#sw
S1(config-if)#switchport ac
S1(config-if)#switchport access vlan 100
S1(config-if)#ex
S1(config)#inte fa 0/5
S1(config-if)#sw mo tru

S1(config-if)#
%LINEPROTO-5-UPDOWN: Line protocol on Interface FastEthernet0/5, changed state to down

%LINEPROTO-5-UPDOWN: Line protocol on Interface FastEthernet0/5, changed state to up

%LINEPROTO-5-UPDOWN: Line protocol on Interface Vlan200, changed state to up

S1(config)#inte
S1(config)#interface fa0/6
S1(config-if)#sw
S1(config-if)#switchport mode
S1(config-if)#switchport mode ac
S1(config-if)#switchport mode access 
S1(config-if)#sw
S1(config-if)#switchport ac
S1(config-if)#switchport access vlan 100
S1(config-if)#ex
S1(config)#inte fa 0/5
S1(config-if)#sw mo tru

S1(config-if)#
%LINEPROTO-5-UPDOWN: Line protocol on Interface FastEthernet0/5, changed state to down

%LINEPROTO-5-UPDOWN: Line protocol on Interface FastEthernet0/5, changed state to up

%LINEPROTO-5-UPDOWN: Line protocol on Interface Vlan200, changed state to up

S1(config)#inte
S1(config)#interface fa0/6
S1(config-if)#sw
S1(config-if)#switchport mode
S1(config-if)#switchport mode ac
S1(config-if)#switchport mode access 
S1(config-if)#sw
S1(config-if)#switchport ac
S1(config-if)#switchport access vlan 100
S1(config-if)#ex
S1(config)#inte fa 0/5
S1(config-if)#sw mo tru

S1(config-if)#
%LINEPROTO-5-UPDOWN: Line protocol on Interface FastEthernet0/5, changed state to down

%LINEPROTO-5-UPDOWN: Line protocol on Interface FastEthernet0/5, changed state to up

%LINEPROTO-5-UPDOWN: Line protocol on Interface Vlan200, changed state to up

S1(config)#inte
S1(config)#interface fa0/6
S1(config-if)#sw
S1(config-if)#switchport mode
S1(config-if)#switchport mode ac
S1(config-if)#switchport mode access 
S1(config-if)#sw
S1(config-if)#switchport ac
S1(config-if)#switchport access vlan 100
S1(config-if)#ex
S1(config)#inte fa 0/5
S1(config-if)#sw mo tru

S1(config-if)#
%LINEPROTO-5-UPDOWN: Line protocol on Interface FastEthernet0/5, changed state to down

%LINEPROTO-5-UPDOWN: Line protocol on Interface FastEthernet0/5, changed state to up

%LINEPROTO-5-UPDOWN: Line protocol on Interface Vlan200, changed state to up

S1(config-if)#sw trun
S1(config-if)#sw trunk all
S1(config-if)#sw trunk allowed vl
S1(config-if)#sw trunk allowed vlan 100,200,999
S1(config-if)#sw trunk allowed vlan 1000 na
S1(config-if)#sw trunk allowed vlan 1000 natu
S1(config-if)#sw trunk allowed vlan 1000 nat
S1(config-if)#sw trunk na
S1(config-if)#sw trunk native vl
S1(config-if)#sw trunk native vlan 1000


### Шаг 1. Более подробно изучим конфигурацию PC-A
a.	Выполните команду ipconfig /all на PC-A и посмотрим на результат
```
C:\>ipconfig /all

FastEthernet0 Connection:(default port)

   Connection-specific DNS Suffix..: 
   Physical Address................: 0060.470A.B4B5
   Link-local IPv6 Address.........: FE80::260:47FF:FE0A:B4B5
   IPv6 Address....................: 2001:DB8:ACAD:1:260:47FF:FE0A:B4B5
   IPv4 Address....................: 0.0.0.0
   Subnet Mask.....................: 0.0.0.0
   Default Gateway.................: FE80::1
                                     0.0.0.0
   DHCP Servers....................: 0.0.0.0
   DHCPv6 IAID.....................: 
   DHCPv6 Client DUID..............: 00-01-00-01-D4-A3-EB-41-00-60-47-0A-B4-B5
   DNS Servers.....................: ::
                                     0.0.0.0
```
DNS-сервера нет

### Шаг 2. Настроим R1 для предоставления DHCPv6 без состояния для PC-A.

Создаем пул DHCP IPv6 на R1 с именем R1-STATELESS:
```
R1(config)#ipv6 dhcp pool R1-STATELESS
R1(config-dhcpv6)#dns-server 2001:db8:acad::254
R1(config-dhcpv6)#domain-name STATELESS.com
```
Настроим интерфейс G0/0/1 на R1, чтобы предоставить флаг конфигурации OTHER для локальной сети R1 и укажем только что созданный пул DHCP в качестве ресурса DHCP для этого интерфейса:
```
R1(config)# interface g0/0/1
R1(config-if)#ipv6 nd other-config-flag 
R1(config-if)#ipv6 dhcp server R1-STATELESS
```
Сохраняем конфигурациюю и перезапускаем PC-A:
```
C:\>ipconfig /all

FastEthernet0 Connection:(default port)

   Connection-specific DNS Suffix..: STATELESS.com 
   Physical Address................: 0060.470A.B4B5
   Link-local IPv6 Address.........: FE80::260:47FF:FE0A:B4B5
   IPv6 Address....................: 2001:DB8:ACAD:1:260:47FF:FE0A:B4B5
   IPv4 Address....................: 0.0.0.0
   Subnet Mask.....................: 0.0.0.0
   Default Gateway.................: FE80::1
                                     0.0.0.0
   DHCP Servers....................: 0.0.0.0
   DHCPv6 IAID.....................: 522232587
   DHCPv6 Client DUID..............: 00-01-00-01-D4-A3-EB-41-00-60-47-0A-B4-B5
   DNS Servers.....................: 2001:DB8:ACAD::254
                                     0.0.0.0
```
Ура, DNS появился!

Проверим связь с помощью пинга IP-адреса интерфейса G0/1 R2:
```
C:\>ping 2001:db8:acad:3::1

Pinging 2001:db8:acad:3::1 with 32 bytes of data:

Reply from 2001:DB8:ACAD:3::1: bytes=32 time<1ms TTL=254
Reply from 2001:DB8:ACAD:3::1: bytes=32 time<1ms TTL=254
Reply from 2001:DB8:ACAD:3::1: bytes=32 time<1ms TTL=254
Reply from 2001:DB8:ACAD:3::1: bytes=32 time<1ms TTL=254

Ping statistics for 2001:DB8:ACAD:3::1:
    Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
    Minimum = 0ms, Maximum = 0ms, Average = 0ms
```
Связь есть, все хорошо)

### Часть 4. Настройка и проверка состояния DHCPv6 сервера на R1

Создадим пул DHCPv6 на R1 для сети 2001:db8:acad:3:aaa::/80. Это предоставит адреса локальной сети, подключенной к интерфейсу G0/0/1 на R2. В составе пула зададим DNS-сервер 2001:db8:acad: :254 и доменное имя STATEFUL.com:
```
R1(config)#ipv6 dhcp pool R2-STATEFUL
R1(config-dhcpv6)#address prefix 2001:db8:acad:3:aaa::/80
R1(config-dhcpv6)#dns-server 2001:db8:acad::254
R1(config-dhcpv6)#domain-name STATEFUL.com
```
Назначим только что созданный пул DHCPv6 интерфейсу g0/0/0 на R1:
```
R1(config)#inte g0/0/0
R1(config-if)#ipv6 dhcp server R2-STATEFUL
```

### Часть 5. Настройка и проверка DHCPv6 Relay на R2
### Шаг 1. Включим PC-B и проверим адрес SLAAC, который он генерирует:
```
C:\>ipconfig /all

FastEthernet0 Connection:(default port)

   Connection-specific DNS Suffix..: 
   Physical Address................: 0009.7CAC.B8B8
   Link-local IPv6 Address.........: FE80::209:7CFF:FEAC:B8B8
   IPv6 Address....................: 2001:DB8:ACAD:3:209:7CFF:FEAC:B8B8
   IPv4 Address....................: 0.0.0.0
   Subnet Mask.....................: 0.0.0.0
   Default Gateway.................: FE80::1
                                     0.0.0.0
   DHCP Servers....................: 0.0.0.0
   DHCPv6 IAID.....................: 
   DHCPv6 Client DUID..............: 00-01-00-01-B3-51-03-9C-00-09-7C-AC-B8-B8
   DNS Servers.....................: ::
                                     0.0.0.0
```
IPv6 адрес раздался с R2

### Шаг 2. Настроим R2 в качестве агента DHCP-ретрансляции для локальной сети на G0/0/1:
```
R2(config)#interface g0/0/1
R2(config-if)#ipv6 nd managed-config-flag
R2(config-if)#ipv6 dhcp relay destination 2001:db8:acad:2::1 g0/0/0
                        ^
% Invalid input detected at '^' marker.
R2(config-if)#ipv6 dhcp ?
  client  Act as an IPv6 DHCP client
  server  Act as an IPv6 DHCP server
```
Команда relay в CPT не работает, но по идее должно (но это не точно, что не работает, а не что должно)

### Шаг 3. Попытка получить адрес IPv6 из DHCPv6 на PC-B.

Откроем командную строку на PC-B и выполним команду ipconfig /all и проверим выходные данные, чтобы увидеть результаты операции ретрансляции DHCPv6 (но не работает из-за причин в шаге 2)
```
C:\>ipconfig /all

FastEthernet0 Connection:(default port)

   Connection-specific DNS Suffix..: 
   Physical Address................: 0009.7CAC.B8B8
   Link-local IPv6 Address.........: FE80::209:7CFF:FEAC:B8B8
   IPv6 Address....................: ::
   IPv4 Address....................: 0.0.0.0
   Subnet Mask.....................: 0.0.0.0
   Default Gateway.................: FE80::1
                                     0.0.0.0
   DHCP Servers....................: 0.0.0.0
   DHCPv6 IAID.....................: 328692804
   DHCPv6 Client DUID..............: 00-01-00-01-B3-51-03-9C-00-09-7C-AC-B8-B8
   DNS Servers.....................: ::
                                     0.0.0.0
```
По идее выше должны быть адреса из пула R2-STATEFUL на R1