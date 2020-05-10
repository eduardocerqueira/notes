# k8s home lab

Accessing dashboard: [https://192.168.1.250:30144](https://192.168.1.250:30144)

```
# get token
kubectl get secret $(kubectl get serviceaccount dashboard-admin-sa -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode

# or ...
kubectl get secrets
kubectl describe secret dashboard-admin-sa-token-5jkkk
```

removing authentication **dev-env**: 

```
kubectl -n kubernetes-dashboard get deployments/kubernetes-dashboard -o yaml > kubernetes-dashboard.yaml

vi kubernetes-dashboard.yaml
spec:
      containers:
      - args:
        - --auto-generate-certificates
        - --token-ttl=0  

kubectl -n kubernetes-dashboard rollout restart deployment/kubernetes-dashboard
```

Installing metrics server:

```
helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com
helm install banzaicloud-stable/metrics-server --version 0.0.8
helm install banzaicloud-stable/metrics-server --version 0.0.8 --generate-name
```

*service catalog*

```
git clone https://github.com/kubernetes-sigs/service-catalog.git
cd service-catalog
helm install charts/catalog --set image=quay.io/kubernetes-service-catalog/service-catalog:v0.3.0-beta.2-16-g52979db
```

* [https://github.com/kubernetes-sigs/service-catalog/blob/master/docs/install.md](https://github.com/kubernetes-sigs/service-catalog/blob/master/docs/install.md)
* [https://medium.com/@HoussemDellai/introduction-to-kubernetes-service-catalog-37317b15670](https://medium.com/@HoussemDellai/introduction-to-kubernetes-service-catalog-37317b15670)


*kubeApps*

```
helm repo add bitnami https://charts.bitnami.com/bitnami
kubectl create namespace kubeapps
helm install kubeapps --namespace kubeapps bitnami/kubeapps --set useHelm3=true
kubectl create serviceaccount kubeapps-operator
kubectl create clusterrolebinding kubeapps-operator --clusterrole=cluster-admin --serviceaccount=default:kubeapps-operator
```

*[https://github.com/kubeapps/kubeapps/blob/master/chart/kubeapps/README.md](https://github.com/kubeapps/kubeapps/blob/master/chart/kubeapps/README.md)


### helpful commands

k8s cheatsheet
[https://kubernetes.io/docs/reference/kubectl/cheatsheet/](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

```
kubectl cluster-info
kubectl proxy
kubectl get nodes
kubectl -n kube-system get all
kubectl -n kube-system get deployments
kubectl -n kubernetes-dashboard describe deployments kubernetes-dashboard
kubectl get namespace
kubectl -n kubernetes-dashboard get deployments
kubectl -n kubernetes-dashboard get deployments/kubernetes-dashboard -o yaml
kubectl get pods --all-namespaces
kubectl -n kubernetes-dashboard rollout restart deployment/kubernetes-dashboard
kubectl -n kubernetes-dashboard rollout status deployment/kubernetes-dashboard
```

### inventory

#### master node 

```
{"node":"master", "brand":"hp pavilon", "memory": "4GB", "cpu": "Intel i3 2.9 GHz"}
```

```
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.1.250:6443 --token fhyu5m.p8n2ce9mcebi9peo \
    --discovery-token-ca-cert-hash sha256:6d2a9e4b2553fdff5c7eec9adebb46743715a893ceba78ac45a1e53699b863e5
```

#### worker nodes

```
{"node":"node1", "brand":"hp pavilon", "memory": "8GB", "cpu": "AMD Radeon 1.8 GHz"}
{"node":"node2", "brand":"dell vostron 1520", "memory": "2GB", "cpu": "Intel Celeron 2.2 GHz"}
{"node":"node3", "brand":"dell vostron 1520", "memory": "2GB", "cpu": "Intel Celeron 2.2 GHz"}
{"node":"node4", "brand":"dell vostron 1500", "memory": "2GB", "cpu": "Intel Celeron 1.2 GHz"}
{"node":"node5", "brand":"dell latitude D620", "memory": "2GB", "cpu": "Intel duo core 1.6 GHz"}
{"node":"node6", "brand":"dell latitude D630", "memory": "4GB", "cpu": "Intel duo core 1.6 GHz"}
```
### Master

```
hostnamectl set-hostname master-node
vi /etc/systemd/logind.conf
    HandleLidSwitch=ignore
yum install net-tools vim unzip git
ifconfig 
vi /etc/hosts
    ip master-node
    ip node-1 worker-node-1
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
systemctl enable firewalld
systemctl start firewalld
systemctl status firewalld
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd –reload
firewall-cmd –-reload
firewall-cmd --reload
modprobe br_netfilter
cat /proc/sys/net/bridge/bridge-nf-call-iptables
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

yum install kubeadm docker -y 
systemctl enable kubelet
systemctl start kubelet
systemctl enable docker
systemctl start docker
swapoff -a
kubeadm init
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
kubectl get nodes
export kubever=$(kubectl version | base64 | tr -d '\n')
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"
kubectl get nodes
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
kubectl proxy
kubectl cluster-info
kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 10443:443
kubectl get nodes
kubectl -n kubernetes-dashboard edit service kubernetes-dashboard
kubectl create serviceaccount dashboard-admin-sa
kubectl create clusterrolebinding dashboard-admin-sa --clusterrole=cluster-admin --serviceaccount=default:dashboard-admin-sa
kubectl get secrets
curl -o helm.tar https://get.helm.sh/helm-v3.2.1-linux-amd64.tar.gz
tar -xvf helm.tar
mv linux-amd64/helm /usr/local/bin/helm

/usr/local/bin/helm init
 


 kubectl create serviceaccount --namespace kube-system tiller
   61  kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
   62  kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

   63  helm install --name heapster stable/heapster --namespace kube-system
   64  helm install --help
   65  kubectl get services --all-namespaces
   66  kubectl describe services kubernetes-dashboard --namespace=kube-system
   67  kubectl -n kubernetes-dashboard edit service kubernetes-dashboard
   68  kubectl -n kubernetes-dashboard get service kubernetes-dashboard
   69  ifconfig 
   70  kubectl proxy
   71  kubectl -n kubernetes-dashboard edit service kubernetes-dashboard
   72  kubectl describe secret dashboard-admin-sa-token-kw7vn
   73  kubectl get secrets
   74  kubectl describe secret dashboard-admin-sa-token-5jkkk

# metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.6/components.yaml


```

### Nodes

```
ip 
systemctl enable sshd
systemctl start sshd
yum install net-tools vim unzip
hostnamectl set-hostname worker-node-1
swapoff -a
vi /etc/fstab 
    # disable swap
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
reboot -n
vi /etc/systemd/logind.conf 
setenforce 0
vim /etc/hosts
vi /etc/sysconfig/selinux 
systemctl enable sshd
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-port=6783/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --permanent --add-port=30000-32767/tcp
firewall-cmd --reload
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

yum install kubeadm docker -y 
systemctl enable docker
systemctl start docker
systemctl enable kubelet
systemctl start kubelet
kubeadm join 192.168.1.250:6443 --token fhyu5m.p8n2ce9mcebi9peo     --discovery-token-ca-cert-hash sha256:6d2a9e4b2553fdff5c7eec9adebb46743715a893ceba78ac45a1e53699b863e5
```


### Reference

* [https://www.tecmint.com/install-kubernetes-cluster-on-centos-7/](https://www.tecmint.com/install-kubernetes-cluster-on-centos-7/)
* [https://github.com/kubernetes/dashboard](https://github.com/kubernetes/dashboard)
* [https://www.replex.io/blog/how-to-install-access-and-add-heapster-metrics-to-the-kubernetes-dashboard](https://www.replex.io/blog/how-to-install-access-and-add-heapster-metrics-to-the-kubernetes-dashboard)
* [https://github.com/helm/helm/releases](https://github.com/helm/helm/releases)
* [https://kubernetes.io/docs/reference/kubectl/cheatsheet/](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
* [https://hub.helm.sh/charts/banzaicloud-stable/metrics-server](https://hub.helm.sh/charts/banzaicloud-stable/metrics-server)
* [https://kubernetes.io/docs/concepts/storage/persistent-volumes/](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

