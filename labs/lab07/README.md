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
| S2         | VLAN 1       |192.168.0.67|255.255.255.224|192.168.0.65 |
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
Делим сеть 192.168.0.0/24 на подсети в соответсвии с заданием и записывает данные в таблицу.

Клиентская А на 58 хостов - 192.168.0.0/26

Управляющая B на 28 хостов - 192.168.0.64/27

Клиентская C на 12 узлов - 192.168.0.96/28

### Шаг 2-3.	Создаем сеть согласно топологии

Подключаем сеть в соответствии с топологией, настраиваем базовые параметры маршрутизаторов



[Базовая настройка маршрутизатора R1](./R1_conf)

[Базовая настройка маршрутизатора R2](./R2_conf)


### Шаг 4.	Настройка маршрутизации между сетями VLAN на маршрутизаторе R1
##### Активируем интерфейс G0/0/1 на маршрутизаторе и настроем подинтерфейсы для каждой VLAN в соответствии с требованиями таблицы IP-адресации:
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
R1(config)#ip route 0.0.0.0 0.0.0.0 10.0.0.2
```
```
R2(config)#ip route 0.0.0.0 0.0.0.0 10.0.0.1
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

##### Создадим необходимые VLAN на коммутаторе 1, настроем и активирем интерфейс управления на S1 (VLAN 200), используя второй IP-адрес из подсети, рассчитанный ранее. Кроме того установим шлюз по умолчанию на S1:

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

##### Настроим и активируем интерфейс управления на S2 (VLAN 1), используя второй IP-адрес из подсети, рассчитанный ранее. Кроме того, установим шлюз по умолчанию на S2:
```
S2(config)#interface vlan 1
S2(config-if)#ip address 192.168.0.67 255.255.255.224
S2(config-if)#no shutdown 
```

##### Назначим все неиспользуемые порты S1 VLAN Parking_Lot, настроим их для статического режима доступа и административно деактивируем их. На S2 административно деактивируем все неиспользуемые порты:
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
### Шаг 8-9.	Назначаем сети VLAN соответствующим интерфейсам коммутатора и настраиваем транк
```
S1(config)#interface fa0/5
S1(config-if)#switchport mode access 
S1(config-if)#switchport access vlan 100
S1(config-if)#ex
S1(config)#inte fa 0/6
S1(config-if)#sw mo tru
S1(config-if)#sw trunk allowed vlan 100,200,999,1000
S1(config-if)#sw trunk native vlan 1000
S1(config-if)#end
S1(config-if)#wr
```

##### Вопрос: Какой IP-адрес был бы у ПК, если бы он был подключен к сети с помощью DHCP?
##### Ответ: Самоназначенный Windows или никакого

### Часть 2. Настройка и проверка двух серверов DHCPv4 на R1

### Шаг 1.	Настроим R1 с пулами DHCPv4 для двух поддерживаемых подсетей
##### Исключим первые 5 адресов из пулов:
```

R1(config)#ip dhcp excluded-address 192.168.0.1 192.168.0.5
R1(config)#ip dhcp excluded-address 192.168.0.65 192.168.0.69
R1(config)#ip dhcp excluded-address 192.168.0.97 192.168.0.101
```
##### Создаем пулы DHCP:
```
R1(config)#ip dhcp pool CLIENTS-58HOST
R1(dhcp-config)#network 192.168.0.0 255.255.255.192
R1(dhcp-config)#default-router 192.168.0.1
R1(dhcp-config)#domain-name CCNA-lab.com
R1(dhcp-config)#ex

R1(config)#ip dhcp pool R2_Client_LAN
R1(dhcp-config)#network 192.168.0.96 255.255.255.240 
R1(dhcp-config)#default-router 192.168.0.97
R1(dhcp-config)#domain-name CCNA-lab.com
R1(dhcp-config)#end
R1#wr
```
Время аренды lease нельзя назначить в CPT, иначе команды выглядела бы так:
`lease {days [hours [ minutes]] | infinite}`

##### Проверим конфигурацию сервера DHCPv4:
```
R1#show ip dhcp pool 

Pool CLIENTS-58HOST :
 Utilization mark (high/low)    : 100 / 0
 Subnet size (first/next)       : 0 / 0 
 Total addresses                : 62
 Leased addresses               : 0
 Excluded addresses             : 3
 Pending event                  : none

 1 subnet is currently in the pool
 Current index        IP address range                    Leased/Excluded/Total
 192.168.0.1          192.168.0.1      - 192.168.0.62      0    / 3     / 62

Pool R2_Client_LAN :
 Utilization mark (high/low)    : 100 / 0
 Subnet size (first/next)       : 0 / 0 
 Total addresses                : 14
 Leased addresses               : 0
 Excluded addresses             : 3
 Pending event                  : none

 1 subnet is currently in the pool
 Current index        IP address range                    Leased/Excluded/Total
 192.168.0.97         192.168.0.97     - 192.168.0.110     0    / 3     / 14
```
Пулы существуют, но исключено только 3 адреса ???

##### Проверим выданные адреса:
```
R1#show ip dhcp binding 
IP address       Client-ID/              Lease expiration        Type
                 Hardware address
```
Пока ни одного адреса не выделено

##### Для проверки сообщений DHCP можно использовать команду `show ip dhcp server statistics`, но в CPT она не работает

##### Попробуем получить IP-адрес на PC-A, включив DHCP-клиент:
```
C:\>ipconfig /all

FastEthernet0 Connection:(default port)

   Connection-specific DNS Suffix..: CCNA-lab.com
   Physical Address................: 0060.3E94.2168
   Link-local IPv6 Address.........: FE80::260:3EFF:FE94:2168
   IPv6 Address....................: ::
   IPv4 Address....................: 192.168.0.6
   Subnet Mask.....................: 255.255.255.192
   Default Gateway.................: ::
                                     192.168.0.1
   DHCP Servers....................: 192.168.0.1
   DHCPv6 IAID.....................: 
   DHCPv6 Client DUID..............: 00-01-00-01-48-1A-A9-B6-00-60-3E-94-21-68
   DNS Servers.....................: ::
                                     0.0.0.0
```
Ура, получили IP-адрес из пула за вычетом исключенных

##### Проверим подключение с помощью пинга IP-адреса интерфейса R2 G0/0/1:
```
C:\>ping 192.168.0.97

Pinging 192.168.0.97 with 32 bytes of data:

Reply from 192.168.0.97: bytes=32 time<1ms TTL=254
Reply from 192.168.0.97: bytes=32 time<1ms TTL=254
Reply from 192.168.0.97: bytes=32 time<1ms TTL=254
Reply from 192.168.0.97: bytes=32 time<1ms TTL=254

Ping statistics for 192.168.0.97:
    Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
    Minimum = 0ms, Maximum = 0ms, Average = 0ms
```
Все ок!

### Часть 3. Настройка и проверка DHCP-ретрансляции на R2
##### Настроим R2 в качестве агента DHCP-ретрансляции: 
```
R2(config)#inte g0/0/1
R2(config-if)#ip helper-address 10.0.0.1
```
##### Попробуем получить IP-адрес на PC-B:
```
C:\>ipconfig /all

FastEthernet0 Connection:(default port)

   Connection-specific DNS Suffix..: CCNA-lab.com
   Physical Address................: 0006.2A45.78EA
   Link-local IPv6 Address.........: FE80::206:2AFF:FE45:78EA
   IPv6 Address....................: ::
   IPv4 Address....................: 192.168.0.102
   Subnet Mask.....................: 255.255.255.240
   Default Gateway.................: ::
                                     192.168.0.97
   DHCP Servers....................: 10.0.0.1
   DHCPv6 IAID.....................: 
   DHCPv6 Client DUID..............: 00-01-00-01-5A-BC-B9-99-00-06-2A-45-78-EA
   DNS Servers.....................: ::
                                     0.0.0.0
```

Ура, все получилось, мы полчили адрес из пула для R2 через ретрансляцию!

##### Проверим подключение с помощью пинга IP-адреса интерфейса R1 G0/0/1
```
C:\>ping 192.168.0.1

Pinging 192.168.0.1 with 32 bytes of data:

Reply from 192.168.0.1: bytes=32 time<1ms TTL=254
Reply from 192.168.0.1: bytes=32 time<1ms TTL=254
Reply from 192.168.0.1: bytes=32 time<1ms TTL=254
Reply from 192.168.0.1: bytes=32 time<1ms TTL=254

Ping statistics for 192.168.0.1:
    Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
    Minimum = 0ms, Maximum = 0ms, Average = 0ms
```
Все работает отлично!


##### Проверим выданные адреса на R1:
```
R1#sho ip dhc bin
IP address       Client-ID/              Lease expiration        Type
                 Hardware address
192.168.0.6      0060.3E94.2168           --                     Automatic
192.168.0.102    0006.2A45.78EA           --                     Automatic
```
Выданные адреса для PC-A и PC-B указаны, все хорошо!

