#  Лабораторная работа. Базовая настройка коммутатора
###  Задание:

1. __Часть 1. Проверка конфигурации коммутатора по умолчанию__
2. __Часть 2. Создание сети и настройка основных параметров устройства__
  * Настройте базовые параметры коммутатора.
  * Настройте IP-адрес для ПК.
3. __Часть 3. Проверка сетевых подключений__
  * Отобразите конфигурацию устройства.
  * Протестируйте сквозное соединение, отправив эхо-запрос.
  * Протестируйте возможности удаленного управления с помощью Telnet.




###  Решение:
#### __Часть 1. Проверка конфигурации коммутатора по умолчанию__

Для проверки конфигурации подключаемся к коммутатору через консольный кабель и устанавливаем соединение через программу эмуляции терминала:

![alt text](image-1.png)

Проверяем настройки коммутатора по-умолчанию.
Заходим в привилегированный режим

```enable```

Проверяем стартовый конфиг:

```show running-config```

```
Building configuration...

Current configuration : 1080 bytes
!
version 15.0
no service timestamps log datetime msec
no service timestamps debug datetime msec
no service password-encryption
!
hostname Switch
!
!
!
!
!
!
spanning-tree mode pvst
spanning-tree extend system-id
!
interface FastEthernet0/1
!
interface FastEthernet0/2
!
interface FastEthernet0/3
!
interface FastEthernet0/4
!
interface FastEthernet0/5
!
interface FastEthernet0/6
!
interface FastEthernet0/7
!
interface FastEthernet0/8
!
interface FastEthernet0/9
!
interface FastEthernet0/10
!
interface FastEthernet0/11
!
interface FastEthernet0/12
!
interface FastEthernet0/13
!
interface FastEthernet0/14
!
interface FastEthernet0/15
!
interface FastEthernet0/16
!
interface FastEthernet0/17
!
interface FastEthernet0/18
!
interface FastEthernet0/19
!
interface FastEthernet0/20
!
interface FastEthernet0/21
!
interface FastEthernet0/22
!
interface FastEthernet0/23
!
interface FastEthernet0/24
!
interface GigabitEthernet0/1
!
interface GigabitEthernet0/2
!
interface Vlan1
 no ip address
 shutdown
!
!
!
!
line con 0
!
line vty 0 4
 login
line vty 5 15
 login
!
!
!
!
end
```







  1. [Задокументируем используемое адресное пространство с использованием IPv4 и IPv6;](README.md#1-%D0%B7%D0%B0%D0%B4%D0%BE%D0%BA%D1%83%D0%BC%D0%B5%D0%BD%D1%82%D0%B8%D1%80%D1%83%D0%B5%D0%BC-%D0%B8%D1%81%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D1%83%D0%B5%D0%BC%D0%BE%D0%B5-%D0%B0%D0%B4%D1%80%D0%B5%D1%81%D0%BD%D0%BE%D0%B5-%D0%BF%D1%80%D0%BE%D1%81%D1%82%D1%80%D0%B0%D0%BD%D1%81%D1%82%D0%B2%D0%BE-%D1%81-%D0%B8%D1%81%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5%D0%BC-ipv4-%D0%B8-ipv6)
  2. [Задокументируем выделенные для маршрутизаторов IP-адреса;](README.md#2-%D0%B7%D0%B0%D0%B4%D0%BE%D0%BA%D1%83%D0%BC%D0%B5%D0%BD%D1%82%D0%B8%D1%80%D1%83%D0%B5%D0%BC-%D0%B2%D1%8B%D0%B4%D0%B5%D0%BB%D0%B5%D0%BD%D0%BD%D1%8B%D0%B5-%D0%B4%D0%BB%D1%8F-%D0%BC%D0%B0%D1%80%D1%88%D1%80%D1%83%D1%82%D0%B8%D0%B7%D0%B0%D1%82%D0%BE%D1%80%D0%BE%D0%B2-ip-%D0%B0%D0%B4%D1%80%D0%B5%D1%81%D0%B0)
  3. [Настроим IP-адреса с учетом приведённой выше схемы и задокументируем изменения:](README.md#3-%D0%BD%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B8%D0%BC-ip-%D0%B0%D0%B4%D1%80%D0%B5%D1%81%D0%B0-%D1%81-%D1%83%D1%87%D0%B5%D1%82%D0%BE%D0%BC-%D0%BF%D1%80%D0%B8%D0%B2%D0%B5%D0%B4%D1%91%D0%BD%D0%BD%D0%BE%D0%B9-%D0%B2%D1%8B%D1%88%D0%B5-%D1%81%D1%85%D0%B5%D0%BC%D1%8B-%D0%B8-%D0%B7%D0%B0%D0%B4%D0%BE%D0%BA%D1%83%D0%BC%D0%B5%D0%BD%D1%82%D0%B8%D1%80%D1%83%D0%B5%D0%BC-%D0%B8%D0%B7%D0%BC%D0%B5%D0%BD%D0%B5%D0%BD%D0%B8%D1%8F)
     - [Пример настройки на маршрутизаторе R1;](README.md#%D0%BF%D1%80%D0%B8%D0%BC%D0%B5%D1%80-%D0%BD%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B9%D0%BA%D0%B8-%D0%BD%D0%B0-%D0%BC%D0%B0%D1%80%D1%88%D1%80%D1%83%D1%82%D0%B8%D0%B7%D0%B0%D1%82%D0%BE%D1%80%D0%B5-r1)
     - [Конфигурационные файлы;](configs/)
     - [Итоговая графическая схема.](README.md#%D0%B8%D1%82%D0%BE%D0%B3%D0%BE%D0%B2%D0%B0%D1%8F-%D0%B3%D1%80%D0%B0%D1%84%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%B0%D1%8F-%D1%81%D1%85%D0%B5%D0%BC%D0%B0)

###  1. Задокументируем используемое адресное пространство с использованием IPv4 и IPv6.
