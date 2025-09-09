interface range gigabitEthernet 2/1, gig 3/1
sw mo tru
switchport trunk native vlan 777
switchport trunk allowed vlan 500,501,502,777

inte range gigabitEthernet 0/1, gi 1/1, gi 2/1, gi 3/1, gi 4/1, gi 5/1, gi 6/1, gi 7/1, gi 8/1, gi 9/1
sw mo trun


vlan 777 


en
conf t
inte ra gi0/1-2
sw mo tru
sw tru no
sw tru all vla 1001,600
end
wr


router ospf 44
auto-cost reference-bandwidth 10000
end
wri

## VLANS
sw trunk allowed vlan 602,603,605,610,615,620,625,630,635,640
sw tr na vl 640

## PORT SECURITU


## snooping-portfast
ip dhcp snooping
ip arp inspection vlan 600-650
ip arp inspection validate src-mac
interface range gig0/1, gig 0/2
ip dhcp snooping trust
ip arp inspection trust
exit
ip dhcp snooping vlan 602,603,605,610,615,620,625,630,635,640
interface range fa0/1-fa0/24
switchport port-security maximum 3
switchport port-security mac-address sticky 
switchport port-security violation restrict
ip dhcp snooping limit rate 6
spanning-tree portfast 
exit
spanning-tree portfast bpduguard default


##SSH
ena
conf t
ip domain-name skynet
crypto key generate rsa general-keys modulus 2048
ip ssh version 2
username admin privilege 15 secret 5rABiijz

line vty 0 4
transport input ssh
login local
end
write

## VLANS
vlan 602
name SUPPORT
exit
vlan 603
name MGMT
exit
vlan 605
name BOSS
exit
vlan 610
name SALES
exit
vlan 615
name FINANCE
exit
vlan 620
name WIFI
exit
vlan 625
name PRINTERS
exit
vlan 630
name SECRTY
exit
vlan 635
name PARKING
exit
vlan 640
name NATIVE
end
wri

##ROUTER TO OFFICE 1
ena
conf t
interface gigabitEthernet 0/0
no shut
exit

interface giga0/0.602
encap dot 602
descr SUPPORT
ip ad 172.16.2.251 255.255.255.0
standby 11 ip 172.16.2.1
standby 11 prior 200
standby 11 preempt
exit

interface giga0/0.603
encap dot 603
descr MGMT
ip ad 172.16.3.251 255.255.255.0
standby 12 ip 172.16.3.1
standby 12 prior 200
standby 12 preempt
exit

interface giga0/0.605
encap dot 605
descr BOSS
ip ad 172.16.5.251 255.255.255.0
standby 13 ip 172.16.5.1
standby 13 prior 200
standby 13 preempt
exit

interface giga0/0.610
encap dot 610
descr SSALES
ip ad 172.16.10.251 255.255.255.0
standby 14 ip 172.16.10.1
standby 14 prior 200
standby 14 preempt
exit

interface giga0/0.615
encap dot 615
descr FINANCE
ip ad 172.16.15.251 255.255.255.0
standby 15 ip 172.16.15.1
exit

interface giga0/0.620
encap dot 620
descr WIFI
ip ad 172.16.20.251 255.255.255.0
standby 16 ip 172.16.20.1
exit

interface giga0/0.625
encap dot 625
descr PRINTERS
ip ad 172.16.25.251 255.255.255.0
standby 17 ip 172.16.25.1
exit

interface giga0/0.630
encap dot 630
descr SECRTY
ip ad 172.16.30.251 255.255.255.0
standby 18 ip 172.16.30.1
exit


interface giga0/0.640
encap dot 640 native
descr NATIVE
end

write

## NTP
en
conf t
ntp server 10.10.10.200
end
wr

##ROUTER TO OFFICE 2
ena
conf t
interface gigabitEthernet 0/0
no shut
exit

interface giga0/0.602
encap dot 602
descr SUPPORT
ip ad 172.16.2.252 255.255.255.0
standby 11 ip 172.16.2.1
exit

interface giga0/0.603
encap dot 603
descr MGMT
ip ad 172.16.3.252 255.255.255.0
standby 12 ip 172.16.3.1
exit

interface giga0/0.605
encap dot 605
descr BOSS
ip ad 172.16.5.252 255.255.255.0
standby 13 ip 172.16.5.1
exit

interface giga0/0.610
encap dot 610
descr SSALES
ip ad 172.16.10.252 255.255.255.0
standby 14 ip 172.16.10.1
exit

interface giga0/0.615
encap dot 615
descr FINANCE
ip ad 172.16.15.252 255.255.255.0
standby 15 ip 172.16.15.1
standby 15 prior 200
standby 15 preempt
exit

interface giga0/0.620
encap dot 620
descr WIFI
ip ad 172.16.20.252 255.255.255.0
standby 16 ip 172.16.20.1
standby 16 prior 200
standby 16 preempt
exit

interface giga0/0.625
encap dot 625
descr PRINTERS
ip ad 172.16.25.252 255.255.255.0
standby 17 ip 172.16.25.1
standby 17 prior 200
standby 17 preempt
exit

interface giga0/0.630
encap dot 630
descr SECRTY
ip ad 172.16.30.252 255.255.255.0
standby 18 ip 172.16.30.1
standby 18 prior 200
standby 18 preempt
exit


interface giga0/0.640
encap dot 640 native
descr NATIVE
end

write

________________________

ena
conf t
interface gigabitEthernet 0/2/0
no shut
exit

interface giga0/2/0.500
encap dot 500
descr MGMT
ip ad 172.16.1.251 255.255.255.0
standby 1 ip 172.16.1.1
standby 1 prior 200
standby 1 preempt
exit


interface giga0/2/0.501
encap dot 501
descr SERVICE
ip ad 10.10.10.251 255.255.255.0
standby 2 ip 10.10.10.1
standby 2 prior 200
standby 2 preempt
exit

interface giga0/2/0.502
encap dot 502
descr SERVICE
ip ad 10.10.20.251 255.255.255.0
standby 3 ip 10.10.20.1
standby 3 prior 200
standby 3 preempt
exit

interface giga0/2/0.777
encap dot 777 native
descr NATIVE
end

write



ena
conf t
interface gigabitEthernet 0/2/0
no shut
exit

interface giga0/2/0.500
encap dot 500
descr MGMT
ip ad 172.16.1.252 255.255.255.0
standby 1 ip 172.16.1.1
exit


interface giga0/2/0.501
encap dot 501
descr SERVICE
ip ad 10.10.10.252 255.255.255.0
standby 2 ip 10.10.10.1
exit

interface giga0/2/0.502
encap dot 502
descr SERVICE
ip ad 10.10.20.252 255.255.255.0
standby 3 ip 10.10.20.1
exit

interface giga0/2/0.777
encap dot 777 native
descr NATIVE
end

write


##ROUTER TO SERVERS
ena
conf t
interface gigabitEthernet 0/3/0
no shut
exit

interface giga0/3/0.500
encap dot 500
descr MGMT
ip ad 172.16.1.251 255.255.255.0
standby 1 ip 172.16.1.1
standby 1 prior 200
standby 1 preempt
exit


interface giga0/3/0.501
encap dot 501
descr SERVICE
ip ad 10.10.10.251 255.255.255.0
standby 2 ip 10.10.10.1
standby 2 prior 200
standby 2 preempt
exit

interface giga0/3/0.502
encap dot 502
descr SERVICE
ip ad 10.10.20.251 255.255.255.0
standby 3 ip 10.10.20.1
standby 3 prior 200
standby 3 preempt
exit

interface giga0/3/0.777
encap dot 777 native
descr NATIVE
end

write



ena
conf t
interface gigabitEthernet 0/2/0
no shut
exit

interface giga0/2/0.500
encap dot 500
descr MGMT
ip ad 172.16.1.251 255.255.255.0
standby 1 ip 172.16.1.1
standby 1 prior 200
standby 1 preempt
exit


interface giga0/2/0.501
encap dot 501
descr SERVICE
ip ad 10.10.10.251 255.255.255.0
standby 2 ip 10.10.10.1
standby 2 prior 200
standby 2 preempt
exit

interface giga0/2/0.502
encap dot 502
descr SERVICE
ip ad 10.10.20.251 255.255.255.0
standby 3 ip 10.10.20.1
standby 3 prior 200
standby 3 preempt
exit

interface giga0/2/0.777
encap dot 777 native
descr NATIVE
end

write



ena
conf t
interface gigabitEthernet 0/2/0
no shut
exit

interface giga0/2/0.500
encap dot 500
descr MGMT
ip ad 172.16.1.252 255.255.255.0
standby 1 ip 172.16.1.1
exit


interface giga0/2/0.501
encap dot 501
descr SERVICE
ip ad 10.10.10.252 255.255.255.0
standby 2 ip 10.10.10.1
exit

interface giga0/2/0.502
encap dot 502
descr SERVICE
ip ad 10.10.20.252 255.255.255.0
standby 3 ip 10.10.20.1
exit

interface giga0/2/0.777
encap dot 777 native
descr NATIVE
end

write





