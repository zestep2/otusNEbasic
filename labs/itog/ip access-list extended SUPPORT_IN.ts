ip access-list extended SUPPORT_IN
 deny ip any 172.16.5.0 0.0.0.255
 deny ip any 172.16.10.0 0.0.0.255
 deny ip any 172.16.15.0 0.0.0.255
 deny ip any 172.16.30.0 0.0.0.255
 deny ip any 192.168.0.0 0.0.255.255
 permit ip 172.16.2.0 0.0.0.255 any
 deny ip any any
ip access-list extended MGMT_IN
 permit ip 172.16.3.0 0.0.0.255 172.16.2.0 0.0.0.255
 permit ip 172.16.3.0 0.0.0.255 10.10.20.0 0.0.0.255
 deny ip any any
ip access-list extended BOSS_SALES_IN
 deny ip any 172.16.2.0 0.0.0.255
 deny ip any 172.16.3.0 0.0.0.255
 deny ip any 172.16.20.0 0.0.0.255
 deny ip any 192.168.0.0 0.0.255.255
 permit ip 172.16.5.0 0.0.0.255 any
 permit ip 172.16.10.0 0.0.0.255 any
 permit ip 172.16.15.0 0.0.0.255 any
 deny ip any any
ip access-list extended WIFI_IN
 deny ip any 172.0.0.0 0.255.255.255
 deny ip any 192.0.0.0 0.255.255.255
 permit ip 172.16.20.0 0.0.0.255 any
 deny ip any any
ip access-list extended PRINTERS_IN
 permit ip 172.16.25.0 0.0.0.255 172.16.2.0 0.0.0.255
 permit ip 172.16.25.0 0.0.0.255 172.16.5.0 0.0.0.255
 permit ip 172.16.25.0 0.0.0.255 172.16.10.0 0.0.0.255
 permit ip 172.16.25.0 0.0.0.255 172.16.15.0 0.0.0.255
 permit ip 172.16.25.0 0.0.0.255 172.16.30.0 0.0.0.255
 deny ip any any
ip access-list extended SEC_IN
 permit ip 172.16.30.0 0.0.0.255 172.16.25.0 0.0.0.255
 permit ip 172.16.30.0 0.0.0.255 10.10.20.0 0.0.0.255
 deny ip any any



 interface GigabitEthernet0/0/0
 ip address 20.20.20.6 255.255.255.240
 ip ospf 44 area 0
!
interface GigabitEthernet0/1/0
 ip address 30.30.30.6 255.255.255.240
 ip ospf 44 area 0