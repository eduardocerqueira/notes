Systemctl to add static jenkins slave running as daemon
-------------------------------------------------------

main script: /home/fedora/jslave.sh

systemd unit: /usr/lib/systemd/system/jslave.service

**REF LINKS**

https://www.freedesktop.org/software/systemd/man/systemctl.html

https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/sect-Managing_Services_with_systemd-Unit_Files.html

https://docs.fedoraproject.org/en-US/Fedora/15/html/Deployment_Guide/ch-Services_and_Daemons.html


**Output sample:**

```
[fedora@static-jslave-f25 ~]$ sudo systemctl status jslave.service
● jslave.service - static jenkins slave daemon
   Loaded: loaded (/usr/lib/systemd/system/jslave.service; enabled; vendor preset: disabled)
   Active: active (running) since Tue 2017-05-09 14:26:57 UTC; 6min ago
 Main PID: 10765 (bash)
    Tasks: 17 (limit: 4915)
   CGroup: /system.slice/jslave.service
           ├─10765 /bin/bash jslave.sh
           └─10768 /usr/bin/java -Xmx2048m -jar /home/fedora/swarm-client-1.22-jar-with-dependencies.jar -master https://my-jenkins-vm.com -name static-jslave-F25 -executors 10 -labels

May 09 14:26:58 static-jslave-f25.localdomain bash[10765]: May 09, 2017 2:26:58 PM hudson.remoting.jnlp.Main$CuiListener <init>
May 09 14:26:58 static-jslave-f25.localdomain bash[10765]: INFO: Jenkins agent is running in headless mode.
May 09 14:26:58 static-jslave-f25.localdomain bash[10765]: May 09, 2017 2:26:58 PM hudson.remoting.jnlp.Main$CuiListener status
May 09 14:26:58 static-jslave-f25.localdomain bash[10765]: INFO: Locating server among [https://my-jenkins.com/]
May 09 14:26:58 static-jslave-f25.localdomain bash[10765]: May 09, 2017 2:26:58 PM hudson.remoting.jnlp.Main$CuiListener status
May 09 14:26:58 static-jslave-f25.localdomain bash[10765]: INFO: Connecting to my-jenkins.com:33627
May 09 14:26:58 static-jslave-f25.localdomain bash[10765]: May 09, 2017 2:26:58 PM hudson.remoting.jnlp.Main$CuiListener status
May 09 14:26:58 static-jslave-f25.localdomain bash[10765]: INFO: Handshaking
May 09 14:26:58 static-jslave-f25.localdomain bash[10765]: May 09, 2017 2:26:58 PM hudson.remoting.jnlp.Main$CuiListener status
May 09 14:26:58 static-jslave-f25.localdomain bash[10765]: INFO: Connected
```
